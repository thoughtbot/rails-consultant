---
name: audit
description: Systematic sweep across all problem spaces for a file, class, or flow — security, performance, data integrity, edge cases, error handling, and more. The "I don't know what I don't know" tool.
argument-hint: "[file path, class name, or flow description]"
disable-model-invocation: true
context: fork
agent: Explore
---

Perform a systematic audit of `$ARGUMENTS`. This is not a conversation — it is a thorough, structured analysis across every problem space listed below. Read the code, its tests, its git history, and any related files before producing the report.

## Research Phase

1. Read the target code thoroughly
2. Read any tests for the target (`spec/` or `test/` equivalents)
3. Check git history: `git log --oneline -15 <file>` — look for recent hotfixes, reverts, or churn that signals fragility
4. Read related files — models it depends on, services it calls, controllers that invoke it
5. Check the schema for any tables involved: `db/schema.rb`

## Problem Spaces

Analyse the code against every problem space below. Skip a section only if it genuinely does not apply to this code. Do not pad sections with speculative concerns — report only what you actually found.

### 1. Responsibility and Cohesion
- Does this code have a single reason to change?
- Are there multiple responsibilities tangled together?
- Would renaming the class/method to describe exactly what it does require the word "and"?

### 2. Coupling and Dependencies
- What does this code know about that it shouldn't?
- What would break if a dependency changed?
- Are dependencies injected or hardcoded?

### 3. Security
- Input validation: are params sanitised, strong parameters used?
- SQL injection: any raw SQL built from user input?
- Authorization: is there authorization (not just authentication)? Can a user access another user's resources?
- Mass assignment: are params passed directly to create/update?
- XSS: is user-provided content rendered without escaping?
- Data exposure: does the response leak internal IDs, timestamps, or other users' data?
- Rate limiting: is the action protected against abuse?

### 4. Data Integrity
- Are uniqueness validations backed by database constraints?
- Are related writes wrapped in transactions?
- Do model validations match database constraints?
- Can orphaned records be created? Are there foreign key constraints?
- Are there race conditions between check and write?

### 5. Edge Cases
- What happens with nil, empty, zero, blank string inputs?
- What happens with empty collections?
- Boundary conditions: first item, last item, exactly at limit
- Time-of-check-time-of-use issues
- Concurrency: what happens under parallel requests?

### 6. Error Handling
- What does the user see when this fails?
- Are rescues too broad? (`rescue StandardError` catching unintended exceptions)
- Are errors logged/reported or silently swallowed?
- What happens when an external service is down?
- Does one failure cascade?

### 7. Performance
- N+1 queries: are associations eager-loaded?
- Loading full records when only a count or subset of columns is needed
- Missing database indexes on filtered/sorted columns
- Work in the request cycle that belongs in a background job
- Behaviour at scale: what happens with 1M rows?
- Expensive computations that aren't memoized

### 8. Testing
- Is the code tested? What's the coverage?
- Are tests testing behaviour or implementation?
- Are there brittle tests that would break on refactor?
- Is the happy path tested? Are failure paths tested?
- Are there integration/system tests, or only unit tests?
- Are edge cases from section 5 covered?

### 9. Design and Simplicity
- Is this the simplest thing that could work?
- Are there abstractions that aren't earning their existence?
- Does the code follow the conventions of the rest of the codebase?

### 10. Duplication and Emerging Patterns
Go beyond the target. Search the broader codebase for patterns related to the code under audit:
- Is the same logic, query pattern, or method chain repeated elsewhere? Use grep and glob to find actual instances — don't guess.
- Are there near-duplicates — code that does the same thing with slight variation? These are more dangerous than exact copies because they diverge silently.
- Is there an emerging pattern that should be extracted? Look for: repeated query chains that should be scopes, repeated conditional logic that should be a service object, repeated view formatting that should be a helper or partial.
- For each duplication found: name what's duplicated, list where it appears, note how the copies differ, and assess whether extraction is warranted or whether the duplication is cheaper than the wrong abstraction (Metz: "duplication is far cheaper than the wrong abstraction").
- If extraction is warranted, name the extraction precisely and where it should live, following the codebase's existing conventions.

### 11. Rails Patterns (if applicable)
- Business logic in callbacks that should be explicit service calls
- Code in the wrong layer (model vs service vs form vs query object)
- Concerns hiding coupling vs genuinely grouping cohesive behaviour
- Rails abstractions used where a plain Ruby object would be simpler

## Report Format

For each problem space where you found issues, report:

**[Problem Space Name]**

For each finding:
- **What**: describe the issue in plain English
- **Where**: file path and line number(s)
- **Why it matters**: the concrete risk — what could go wrong, not abstract principle
- **Severity**: critical (will cause bugs or security issues), warning (should fix), or note (worth knowing)

## Summary

End with a prioritised list across all problem spaces:

1. **Fix now** — critical issues that are actively dangerous
2. **Fix soon** — warnings that will cause problems under realistic conditions
3. **Worth knowing** — notes that inform future work but don't require immediate action

If the code is solid in a problem space, say so in one line and move on. A clean audit is a useful signal — don't manufacture findings.

## Principles

Draw on the canon when naming issues. Name the principle and its source when it grounds a finding — not as decoration, but because it tells the user what to study if they want to see this pattern themselves next time.

### Canon — OOP, XP, Agile, and Rails Principles

**Sandi Metz (POODR):** Single Responsibility Principle — a class should have one reason to change. Small classes, small methods. Depend on abstractions, not concretions. Message-based design. Tell, Don't Ask.

**Martin Fowler (Refactoring):** Named smells — Feature Envy, Shotgun Surgery, Data Clump, Primitive Obsession, Divergent Change, Long Method, Large Class, Long Parameter List. Named moves — Extract Method, Extract Class, Move Method, Inline Method, Replace Conditional with Polymorphism, Hide Delegate, Introduce Parameter Object.

**Robert Martin (SOLID):** Single Responsibility, Open/Closed, Liskov Substitution, Interface Segregation, Dependency Inversion. Single level of abstraction. Naming as design.

**Kent Beck (XP):** 4 Rules of Simple Design (passes tests, reveals intention, no duplication of knowledge, fewest elements). YAGNI. Red-green-refactor. Do the simplest thing that could possibly work.

**Ward Cunningham:** Technical debt is a deliberate choice with a known cost — not an accident. Name whether it's intentional or accidental.

**thoughtbot patterns:** Callbacks are a smell for business logic. Skinny everything — extract to POROs. Service objects have one public `call` method and one responsibility. Form objects for complex input. Query objects for complex queries. If it's hard to test, it's probably in the wrong place.

**Ruby Science smells:** Long Method, Large Class, Feature Envy, Shotgun Surgery, Divergent Change, Duplicated Code, Uncommunicative Name, Callback, Mixin, Case Statement. DRY — but duplication is far cheaper than the wrong abstraction (Metz).
