#!/usr/bin/env python3
"""Score a unified diff on stdin for PR risk. Same diff in, same JSON out."""
import json
import os
import re
import sys

LOCKFILES = {
    "Gemfile.lock", "package-lock.json", "yarn.lock", "pnpm-lock.yaml", "bun.lock", "bun.lockb",
    "deno.lock", "poetry.lock", "uv.lock", "Pipfile.lock", "Cargo.lock", "composer.lock",
    "mix.lock", "go.sum", "Podfile.lock", "Package.resolved", "pubspec.lock",
    "packages.lock.json", "gradle.lockfile",
}
MANIFESTS = {
    "Gemfile", "package.json", "deno.json", "requirements.txt", "Pipfile", "pyproject.toml",
    "setup.py", "setup.cfg", "environment.yml", "go.mod", "Cargo.toml", "composer.json",
    "mix.exs", "pom.xml", "build.gradle", "build.gradle.kts", "libs.versions.toml",
    "Podfile", "Package.swift", "pubspec.yaml", "packages.config", "Directory.Packages.props",
}
SENSITIVE = {
    "auth", "authn", "authz", "authentication", "authorization", "oauth", "oidc", "sso",
    "saml", "jwt", "mfa", "otp", "login", "logout", "signin", "session", "sessions",
    "password", "passwords", "permission", "permissions", "policy", "policies", "rbac",
    "acl", "token", "tokens", "secret", "secrets", "credential", "credentials", "crypto",
    "encryption", "payment", "payments", "billing", "charge", "charges", "stripe",
    "paypal", "braintree", "refund", "refunds", "payout", "payouts",
}
GENERATED = re.compile(
    r"(^|/)(vendor|node_modules|dist|generated|__generated__)/|(^|/)db/(schema\.rb|structure\.sql)$"
    r"|\.(min\.js|min\.css|map|snap|pb\.go|g\.dart|designer\.cs)$|_pb2\.pyi?$|\.generated\.\w+$"
    r"|ModelSnapshot\.cs$"
)
MIGRATION = re.compile(
    r"(^|/)(db/migrate|migrations?|alembic/versions|db/changelog)/|(?<!structure)\.sql$",
    re.I,
)
DESTRUCTIVE = re.compile(
    r"\b(drop|remove|rename)_?(columns?|table|join_?table|reference|belongs_?to|timestamps|field|model)(_?if_?exists)?\b"
    r"|\b(change|alter)_?(column|field)(_?null)?\b|\bdelete_?model\b"
    r"|\b(drop(_if_exists)?|rename)\s+(table|column|schema)\b|\b(truncate|delete\s+from)\b"
    r"|\balter\s+table\b.*\b(drop|rename)\b|\bSchema::drop|\bremove\s+:\w",
    re.I,
)
ROLLBACK_START = re.compile(
    r"\bdef\s+(down|downgrade)\b|\bexports\.down\b|\bfunction\s+down\s*\(|\bvoid\s+Down\s*\("
    r"|\basync\s+down\s*\(|\bdown\s*:\s*(async\b|function\b|\()|\+goose\s+Down\b|^\s*-?\s*rollback\s*:"
)
ROLLBACK_END = re.compile(
    r"\bdef\s+(up|upgrade|change)\b|\bexports\.up\b|\bfunction\s+up\s*\(|\bvoid\s+Up\s*\("
    r"|\basync\s+up\s*\(|\bup\s*:\s*(async\b|function\b|\()|\+goose\s+Up\b|^\s*-\s*changeSet\s*:"
)
INFRA = re.compile(
    r"^(\.github|\.circleci|\.buildkite|k8s|kubernetes|helm|charts|terraform|ansible|deploy)/"
    r"|(^|/)config/(?!locales/)|(^|/)settings(/\w+)?\.py$"
    r"|(^|/)(Dockerfile[^/]*|docker-compose[^/]*\.ya?ml|compose\.ya?ml|Procfile[^/]*|Jenkinsfile"
    r"|fly\.toml|render\.yaml|app\.json|vercel\.json|netlify\.toml|serverless\.ya?ml"
    r"|\.gitlab-ci\.yml|\.travis\.yml|azure-pipelines\.yml|bitbucket-pipelines\.yml"
    r"|application(-\w+)?\.(properties|ya?ml)|appsettings[^/]*\.json|web\.config|\.env[^/]*)$"
    r"|\.(tf|tfvars)$"
)
TEST = re.compile(
    r"(^|/)(test|tests|spec|specs|__tests__|e2e|cypress)/|(_test|_spec|\.test|\.spec)\.\w+$"
    r"|(^|/)(test_\w+|conftest)\.py$|Tests?\.(java|kt|swift|cs|php|scala|groovy)$"
)
CODE = re.compile(
    r"\.(rb|py|js|mjs|cjs|jsx|ts|tsx|go|rs|java|kt|swift|php|ex|exs|cs|scala|groovy|dart"
    r"|clj|hs|erl|lua|m|mm|c|cc|cpp|h|erb|haml|slim|eex|heex|twig|jinja|j2|ejs|hbs|cshtml"
    r"|vue|svelte)$"
)


def parse(diff):
    files, current, in_hunk, rollback = [], None, False, False
    for line in diff.splitlines():
        if line.startswith("diff --git "):
            m = re.match(r'diff --git "?a/(.*?)"? "?b/(.*?)"?$', line)
            current = {"path": m.group(2) if m else line[11:], "status": "modified", "added": [], "forward": [], "removed": 0}
            files.append(current)
            in_hunk = rollback = False
        elif current is None:
            continue
        elif in_hunk and line[:1] in ("+", " "):
            rollback = in_rollback(line[1:], rollback)
            if line[:1] == "+":
                current["added"].append(line[1:])
                if not rollback:
                    current["forward"].append(line[1:])
        elif in_hunk and line[:1] == "-":
            current["removed"] += 1
        elif line.startswith("@@"):
            in_hunk = True
            rollback = in_rollback(line.split("@@")[-1], False)
        elif line.startswith("new file mode"):
            current["status"] = "added"
        elif line.startswith("deleted file mode"):
            current["status"] = "deleted"
        elif line.startswith("rename to "):
            current["path"] = line[len("rename to "):]
        elif line.startswith("+++ b/"):
            current["path"] = line[len("+++ b/"):]
    return files


def in_rollback(line, rollback):
    if ROLLBACK_START.search(line):
        return True
    if ROLLBACK_END.search(line):
        return False
    return rollback


def words(path):
    return set(re.split(r"[^a-z0-9]+", re.sub(r"([a-z0-9])([A-Z])", r"\1 \2", path).lower()))


def is_dependency(path):
    name = os.path.basename(path)
    return name in LOCKFILES or name in MANIFESTS or name.endswith((".gemspec", ".csproj", ".fsproj")) or bool(re.match(r"requirements.*\.txt$", name))


def is_generated(path):
    return os.path.basename(path) in LOCKFILES or bool(GENERATED.search(path))


def score(files):
    signals = []

    def add(rule, points, reason, paths):
        signals.append({"rule": rule, "points": points, "reason": reason, "files": sorted(set(paths))})

    lines = sum(len(f["added"]) + f["removed"] for f in files if not is_generated(f["path"]))
    for limit, points in ((500, 3), (200, 2), (50, 1)):
        if lines >= limit:
            add("large_diff", points, f"{lines} lines changed, not counting lockfiles or generated files", [])
            break
    for limit, points in ((25, 2), (10, 1)):
        if len(files) >= limit:
            add("many_files", points, f"{len(files)} files changed", [])
            break

    tests = [f for f in files if TEST.search(f["path"])]
    other = [f for f in files if f not in tests]
    checks = [
        ("migration", 2, "Changes the database schema",
         [f for f in other if MIGRATION.search(f["path"])]),
        ("destructive_migration", 3, "Drops, renames, or rewrites existing columns, tables, or rows",
         [f for f in other if MIGRATION.search(f["path"]) and not f["path"].endswith(".down.sql")
          and any(DESTRUCTIVE.search(l) for l in f["forward"])]),
        ("sensitive_path", 3, "Touches authentication, authorization, payments, or secrets",
         [f for f in other if CODE.search(f["path"]) and words(f["path"]) & SENSITIVE]),
        ("dependencies", 2, "Adds, removes, or upgrades dependencies",
         [f for f in files if is_dependency(f["path"])]),
        ("infra_config", 2, "Changes CI, deploy, or app configuration",
         [f for f in other if INFRA.search(f["path"])]),
    ]
    for rule, points, reason, matched in checks:
        if matched:
            add(rule, points, reason, [f["path"] for f in matched])

    code = [
        f for f in other
        if f["status"] != "deleted" and CODE.search(f["path"])
        and not (MIGRATION.search(f["path"]) or INFRA.search(f["path"]) or is_generated(f["path"]))
    ]
    if code and not tests:
        add("untested_code", 2, "Changes code without changing any tests", [f["path"] for f in code])
    if sum(f["removed"] for f in tests) > sum(len(f["added"]) for f in tests):
        add("tests_removed", 2, "Deletes more test lines than it adds",
            [f["path"] for f in tests if f["removed"] > len(f["added"])])

    total = sum(s["points"] for s in signals)
    return {
        "score": total,
        "level": "high" if total >= 6 else "medium" if total >= 3 else "low",
        "files_changed": len(files),
        "lines_changed": lines,
        "signals": signals,
    }


if __name__ == "__main__":
    print(json.dumps(score(parse(sys.stdin.buffer.read().decode("utf-8", "replace"))), indent=2))
