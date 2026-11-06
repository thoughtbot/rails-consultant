export const meta = {
  name: 'ship',
  description: 'Take a SPEC from prepare through TDD, review, verification, and a draft PR',
  phases: [
    { title: 'Prepare', detail: 'identify a preparatory refactor, then make it' },
    { title: 'Implement', detail: 'drive the SPEC out with TDD' },
    { title: 'Review', detail: 'five lenses in parallel, then synthesize and fix' },
    { title: 'Verify', detail: 'run the real app against the criteria' },
    { title: 'Open', detail: 'open a draft PR, then have it checked' },
  ],
}

const SPEC = args && args.spec
if (!SPEC) throw new Error('ship: pass {spec: "<path to the SPEC>"} as args')

const ARTIFACTS =
  'The SPEC (' + SPEC + ') and anything made to report on the work, like ' +
  'screenshots, captured diffs, notes, HTML pages and logs, stay out of every commit. ' +
  'If they are untracked, leave them untracked.'

const COMMIT =
  'Then invoke the `commit` skill. Commit only what this step produced. ' + ARTIFACTS +
  ' Later steps read these messages instead of the sessions that wrote the code, so ' +
  'each message should state what the change does, what it does not cover, and ' +
  'anything left unverified.'

const NO_NESTING =
  'You have no tool for spawning subagents. Where the skill says to dispatch them, ' +
  'follow its own stated fallback and say in your report that you did, so nobody ' +
  'reads a timeboxed skim as a full sweep.'

const AFTERWARD =
  'Also fill `assumptions`, `surprises` and `unsure`, one short line each, all about ' +
  'the change and the repo: what this step took as given that neither the SPEC nor the ' +
  'code confirms, what in the repo turned out different from what the SPEC or code ' +
  'suggested, and what is still unconfirmed. Empty lists are a real answer.'

const AFTERWARD_FIELDS = {
  assumptions: { type: 'array', items: { type: 'string' } },
  surprises: { type: 'array', items: { type: 'string' } },
  unsure: { type: 'array', items: { type: 'string' } },
}

// Everything the run has established so far. Every halt carries this out, because a
// halt is where a human picks the work up by hand and the reports are all they get.
const sofar = { spec: SPEC, suiteGreen: null, screenshots: [], afterward: [] }

function afterward(step, result) {
  if (!result) return
  sofar.afterward.push({
    step: step,
    assumptions: result.assumptions || [],
    surprises: result.surprises || [],
    unsure: result.unsure || [],
  })
}

function halt(phaseName, reason) {
  log('Halted at ' + phaseName + ' — ' + reason)
  return Object.assign({ haltedAt: phaseName, reason: reason }, sofar)
}

// ---------------------------------------------------------------- Prepare

phase('Prepare')

const prep = await agent(
  'Invoke the `preparatory-refactor` skill with this SPEC as its argument: ' + SPEC + '\n\n' +
  NO_NESTING + '\n\n' +
  'The skill is right that you identify and do not edit. Change nothing. Nobody is ' +
  'watching this run, so there is no one to show the naive diff to — write it, use ' +
  'it, and fold what it proves into the report.\n\n' +
  'Return the report verbatim in `report`, and the moves you would defend. A move is ' +
  'a refactor to make. When the skill says no preparation is needed, `moves` is ' +
  'empty — "no refactor" is the absence of a move, never a move of its own. ' + AFTERWARD,
  { label: 'prepare:identify', phase: 'Prepare', schema: {
    type: 'object',
    properties: {
      report: { type: 'string' },
      moves: { type: 'array', items: { type: 'object', properties: {
        move: { type: 'string' },
        confidence: { type: 'number' },
      }, required: ['move', 'confidence'] } },
      testCommand: { type: 'string' },
      ...AFTERWARD_FIELDS,
    },
    required: ['report', 'moves'],
  } }
)

if (!prep) {
  // Distinct from "it found nothing". Saying "no move cleared the bar" here would be a
  // claim about the repo made by a run where nobody looked at it.
  return halt('Prepare', 'the preparatory-refactor agent returned nothing — the repo was never assessed')
}

afterward('Prepare: identify', prep)
sofar.preparatoryReport = prep.report

const justified = (prep.moves || []).filter(m => m.confidence >= 80)
let made = null

if (justified.length) {
  log(justified.length + ' preparatory move(s) cleared the bar — making them')
  made = await agent(
    'Make this behavior-preserving refactor. It was proposed by a session that could ' +
    'not edit code, and you are not that session — if the move turns out not to be ' +
    'behavior-preserving once you are in the files, stop and say so rather than ' +
    'reshaping it into something that is. Set `made` false and name the reason; ' +
    'stopping is a real result here and the run records it.\n\n' +
    'If the report below proposes no refactor at all — it says to skip preparation ' +
    'and go straight to the feature — set `nothingProposed` true, `made` false, and ' +
    'change nothing. A move you judged unsafe is a stop, not this.\n\n' +
    prep.report + '\n\n' +
    'The suite that covers the site: ' + (prep.testCommand || 'find it yourself') + '. ' +
    'It passes now and passes after, unchanged. A move that needs a new test is the ' +
    'feature, not preparation — stop there.\n\n' + COMMIT + '\n\n' + AFTERWARD,
    { label: 'prepare:refactor', phase: 'Prepare', schema: {
      type: 'object',
      properties: {
        report: { type: 'string' },
        made: { type: 'boolean' },
        nothingProposed: { type: 'boolean' },
        movesMade: { type: 'array', items: { type: 'string' } },
        stopReason: { type: 'string' },
        suiteGreen: { type: 'boolean' },
        ...AFTERWARD_FIELDS,
      },
      required: ['report', 'made', 'suiteGreen'],
    } }
  )

  afterward('Prepare: refactor', made)
  if (!made) {
    return halt('Prepare', 'the refactor agent was skipped or died — the tree may hold a ' +
                'partial refactor, so check it before rerunning')
  }
  if (made.suiteGreen === false) {
    return halt('Prepare', 'the suite is red after a refactor that was supposed to be ' +
                'behavior-preserving — that is the one thing it promised')
  } else if (made.nothingProposed && !made.made && !(made.movesMade || []).length) {
    log('The preparatory report proposed no refactor — going straight to the feature')
    sofar.preparatoryMoves = []
  } else if (!made.made) {
    return halt('Prepare', 'the refactor was not made: ' + (made.stopReason || 'no reason given'))
  } else {
    sofar.preparatoryMoves = made.movesMade || justified.map(m => m.move)
  }
} else {
  log('The preparatory pass found no move worth defending — going straight to the feature')
  sofar.preparatoryMoves = []
}

// -------------------------------------------------------------- Implement

phase('Implement')

const impl = await agent(
  'Invoke the `implement-with-tdd` skill with this SPEC as its argument: ' + SPEC + '\n\n' +
  'One deviation from the skill, and only one: it tells you to leave everything ' +
  'uncommitted. Commit instead — a later step diffs against what you left. ' + COMMIT + '\n\n' +
  AFTERWARD + '\n\n' +
  'Its stop conditions still hold. Nobody is watching this run, so a stop you cannot ' +
  'resolve alone is a stop: set `stopped` and name what you would have asked. Do not ' +
  'decide a scope question by starting.\n\n' +
  '`suiteGreen` is the one machine-checkable fact this whole chain produces. Report it ' +
  'honestly, including a failure in code you never touched — say so in the report, but ' +
  'do not round it up to true.',
  { label: 'implement:tdd', phase: 'Implement', schema: {
    type: 'object',
    properties: {
      report: { type: 'string' },
      stopped: { type: 'boolean' },
      stopReason: { type: 'string' },
      criteriaUnbuilt: { type: 'array', items: { type: 'string' } },
      suiteGreen: { type: 'boolean' },
      ...AFTERWARD_FIELDS,
    },
    required: ['report', 'stopped', 'suiteGreen'],
  } }
)

if (!impl) return halt('Implement', 'the implementation agent returned nothing')

afterward('Implement', impl)
sofar.implementationReport = impl.report
sofar.criteriaUnbuilt = impl.criteriaUnbuilt || []
sofar.suiteGreen = impl.suiteGreen

if (impl.stopped) {
  return halt('Implement', impl.stopReason || 'the implementation stopped without naming a reason')
}
if (sofar.criteriaUnbuilt.length) {
  log(sofar.criteriaUnbuilt.length + ' criteria left unbuilt — the review and the ' +
      'walkthrough below cover a partial SPEC')
}

// ----------------------------------------------------------------- Review

phase('Review')

const target = await agent(
  'Invoke the `multi-lens-review` skill, then carry out step 1 only — fix the target. Stop before ' +
  'the intent step and before dispatch; five reviewers run after you and they need the ' +
  'diff you capture.\n\n' +
  'The target is the working tree against its base. Capture the diff to a temp file ' +
  'exactly as the skill says, including the staging dance for untracked files. Leave ' +
  'the SPEC out of the diff with `\':!' + SPEC + '\'`; it is what the change is ' +
  'measured against, not part of it.\n\n' +
  'The skill tells you to ask when the base will not resolve. Nobody is here to ask, ' +
  'and the failure it warns about is silent — the substitution collapses `git diff ' +
  '$base` into unstaged changes only, which is empty on a tree where every step has ' +
  'committed. So if the base ladder comes back empty, set `baseUnresolved` and stop ' +
  'rather than proceeding on a bare diff.\n\n' +
  'Report `lines` as the length of the captured diff. Return the review skill\'s own ' +
  'absolute base directory in `skillDir`.',
  { label: 'review:target', phase: 'Review', schema: {
    type: 'object',
    properties: {
      diffPath: { type: 'string' },
      mergeBase: { type: 'string' },
      skillDir: { type: 'string' },
      empty: { type: 'boolean' },
      baseUnresolved: { type: 'boolean' },
      lines: { type: 'number' },
    },
    required: ['diffPath', 'mergeBase', 'skillDir', 'empty', 'baseUnresolved', 'lines'],
  } }
)

if (!target) return halt('Review', 'the review-target agent returned nothing — the diff was never captured')
if (target.baseUnresolved) {
  return halt('Review', 'no base branch resolved, so there is nothing to diff against. ' +
              'The repo has no origin/HEAD, origin/main, or origin/master — say which ' +
              'branch to diff against and rerun')
}
if (target.empty) {
  return halt('Review', 'the captured diff is empty. Every step commits, so this means ' +
              'the implementation produced no change, not that work is uncommitted')
}
if (target.lines > 1500) {
  // multi-lens-review/SKILL.md's own ceiling. Past it the agents review the first part and report
  // nothing to say they stopped, which reads exactly like a clean pass.
  return halt('Review', 'the diff is ' + target.lines + ' lines, past the 1500 the review ' +
              'skill will read. Five reviewers handed more than that silently review the ' +
              'front of it. Review by commit range instead')
}

const LENSES = ['defects', 'spec-fidelity', 'conventions', 'domains', 'compatibility']

const FINDINGS = {
  type: 'object',
  properties: {
    findings: { type: 'array', items: { type: 'object', properties: {
      claim: { type: 'string' },
      locator: { type: 'string' },
      confidence: { type: 'number' },
      evidence: { type: 'string' },
      cost: { type: 'string' },
      fix: { type: 'string' },
    }, required: ['claim', 'locator', 'confidence', 'evidence'] } },
    ranWithNothingToCheck: { type: 'string' },
  },
  required: ['findings'],
}

const reviews = await parallel(LENSES.map(lens => () => agent(
  'Read ' + target.skillDir + '/agents/' + lens + '.md and act only as that reviewer. ' +
  'Read no other file in that skill — its dispatch and synthesis steps are not yours, ' +
  'and they describe git commands that would write to a tree you are reviewing.\n\n' +
  'Wherever that file writes {skill_dir}, it means: ' + target.skillDir + '\n\n' +
  'The diff, already captured so every reviewer reads the same one: ' + target.diffPath + '\n' +
  'The acceptance criteria the change was measured against: ' + SPEC + '\n\n' +
  'Read the whole diff and whole files around it, not excerpts.\n\n' +
  (lens === 'defects'
    ? 'Your agent file states its own tool allowlist. It is tighter than the one the ' +
      'other four reviewers get, and it governs — follow it as written.\n\n'
    : 'Read and report only — no command that writes, stages, or checks anything out, ' +
      'and no fixing a finding instead of filing it.\n\n') +
  'Findings only. No summary, no verdict, nothing about how the run went. The one ' +
  'exception is `ranWithNothingToCheck`: if what you were handed is missing or empty, ' +
  'say so there. An empty findings list otherwise means you looked and found nothing, ' +
  'and the two must not look alike.',
  { label: 'review:' + lens, phase: 'Review', schema: FINDINGS }
)))

const roster = LENSES.map((lens, i) => ({
  lens: lens,
  ran: !!reviews[i],
  blocked: (reviews[i] && reviews[i].ranWithNothingToCheck) || null,
  findings: (reviews[i] && reviews[i].findings) || [],
}))

const dead = roster.filter(r => !r.ran)
if (dead.length) {
  log(dead.length + ' of 5 reviewers died — ' + dead.map(r => r.lens).join(', ') +
      ' went unchecked, and the report will say so')
}

const reviewed = await agent(
  'You are synthesizing a code review, then fixing what it found.\n\n' +
  'Invoke the `multi-lens-review` skill and follow step 4 — synthesize — against the roster ' +
  'below. Its dropping rules are the point: check every cited path against the ' +
  'merge-base ' + target.mergeBase + ', drop a finding whose evidence line is missing, ' +
  'move a misfiled one rather than dropping it, and keep the collisions it tells you ' +
  'to keep.\n\n' +
  'The roster carries a `ran` flag per lens. A lens with `ran: false` died and checked ' +
  'nothing; a lens with `blocked` set ran with nothing to check. Both are different ' +
  'from a lens that looked and found nothing, and step 4 opens by telling you to say ' +
  'so up front — a review missing a pass looks identical to one that passed it unless ' +
  'you name the difference.\n\n' +
  'Then step 5, with one deviation: there is nobody here to ask which findings to ' +
  'apply. Apply what you file under Defects and under Compatibility — those two cost ' +
  'something the moment this ships, which is why step 4 sorts them first. Leave ' +
  'Conventions, Domains and Fidelity for the human; those are judgment calls the ' +
  'author gets to make. Apply one at a time and stop on any fix that turns out bigger ' +
  'than its finding described. Say in `report` which you applied and which you left.\n\n' +
  'Each entry in `left` gets posted on the PR for whoever owns it. Write it as one ' +
  'short plain-English sentence a non-programmer could follow: the decision, not ' +
  'the code. No file paths, no finding numbers.\n\n' +
  'Run the suite after and report `suiteGreen` honestly. ' + COMMIT + ' ' + AFTERWARD + '\n\n' +
  'Roster:\n' + JSON.stringify(roster, null, 2),
  { label: 'review:synthesize', phase: 'Review', schema: {
    type: 'object',
    properties: {
      report: { type: 'string' },
      applied: { type: 'array', items: { type: 'string' } },
      left: { type: 'array', items: { type: 'string' } },
      suiteGreen: { type: 'boolean' },
      ...AFTERWARD_FIELDS,
    },
    required: ['report', 'suiteGreen'],
  } }
)

if (!reviewed) return halt('Review', 'the synthesis agent returned nothing — five lenses ran and their findings are lost')

afterward('Review', reviewed)
sofar.reviewReport = reviewed.report
sofar.reviewApplied = reviewed.applied || []
sofar.reviewLeft = reviewed.left || []
sofar.lensesUnchecked = dead.map(r => r.lens)
sofar.suiteGreen = reviewed.suiteGreen

// ----------------------------------------------------------------- Verify

phase('Verify')

const verified = await agent(
  'Invoke the `run` skill and drive this project\'s real app against the acceptance ' +
  'criteria in ' + SPEC + '. Passing tests are not the claim being checked here — ' +
  'reach the behavior the way a user would.\n\n' +
  (sofar.suiteGreen === false
    ? 'The suite is currently RED. Find out whether that is yours to fix or predates ' +
      'this branch, and say which in the report.\n\n' : '') +
  (sofar.criteriaUnbuilt.length
    ? 'These criteria were never built, so do not go looking for them: ' +
      sofar.criteriaUnbuilt.join('; ') + '\n\n' : '') +
  'Fix what is broken. ' + COMMIT + ' Report `suiteGreen` after any fix.\n\n' +
  'Where a criterion shows up on a screen, screenshot it once it holds. Save the ' +
  'images under a `ship-screenshots` directory in the system temp directory, never ' +
  'in the repo, and return their absolute paths in `screenshots`. Nothing on a ' +
  'screen to show, or no way to capture one: leave it empty and say why in the ' +
  'report.\n\n' +
  'If the app cannot be started from the repo\'s documented setup, say that plainly ' +
  'and set `ran` false. A verification that never ran and a verification that passed ' +
  'look identical in a summary unless you name the difference.\n\n' + AFTERWARD,
  { label: 'verify:app', phase: 'Verify', schema: {
    type: 'object',
    properties: {
      ran: { type: 'boolean' },
      report: { type: 'string' },
      criteriaConfirmed: { type: 'array', items: { type: 'string' } },
      fixed: { type: 'array', items: { type: 'string' } },
      screenshots: { type: 'array', items: { type: 'string' } },
      suiteGreen: { type: 'boolean' },
      ...AFTERWARD_FIELDS,
    },
    required: ['ran', 'report'],
  } }
)

afterward('Verify', verified)
if (verified) {
  sofar.verificationReport = verified.report
  sofar.verified = verified.ran
  sofar.screenshots = verified.screenshots || []
  if (typeof verified.suiteGreen === 'boolean') sofar.suiteGreen = verified.suiteGreen
  if (!verified.ran) log('The app was never driven — the criteria are unconfirmed outside the suite')
} else {
  sofar.verified = false
  log('The verify agent returned nothing — the criteria are unconfirmed outside the suite')
}

// ------------------------------------------------------------------- Open

phase('Open')

const NOTE = {
  type: 'object',
  properties: { path: { type: 'string' }, line: { type: 'number' }, body: { type: 'string' } },
  required: ['path', 'line', 'body'],
}

const opened = await agent(
  'Invoke the `pr` skill with `--auto` and follow its Autonomous mode. The SPEC this ' +
  'branch builds is ' + SPEC + '.\n\n' +
  'Its "Have it checked" step needs a subagent, and you have no tool for spawning ' +
  'one. Skip that step only; a fresh agent checks your work after you.\n\n' +
  'Post the line notes `/pr --auto` calls for. Post no other comment on the PR.\n\n' +
  ARTIFACTS + ' They are not the uncommitted changes the skill stops for, and not a ' +
  'risk to report. Anything else uncommitted still stops you.\n\n' +
  'Return what you sent in `title`, `body` and `notes` whether or not the PR opened, ' +
  'and the base branch you used. ' + AFTERWARD,
  { label: 'open:pr', phase: 'Open', schema: {
    type: 'object',
    properties: {
      prUrl: { type: 'string' },
      notOpenedReason: { type: 'string' },
      base: { type: 'string' },
      title: { type: 'string' },
      body: { type: 'string' },
      notes: { type: 'array', items: NOTE },
      ...AFTERWARD_FIELDS,
    },
    required: ['base', 'title', 'body', 'notes'],
  } }
)

afterward('Open', opened)
if (!opened) return halt('Open', 'the PR agent returned nothing — the work is committed, maybe pushed, but no PR was described')

sofar.prUrl = opened.prUrl || null
if (!opened.prUrl) {
  Object.assign(sofar, {
    notOpenedReason: opened.notOpenedReason || 'no reason given',
    title: opened.title,
    body: opened.body,
    notes: opened.notes,
  })
}

const checked = await agent(
  'Someone who never saw this code written described it for a reviewer. Check that ' +
  'description against the code. Run `git diff ' + opened.base + '...HEAD` and read ' +
  'it yourself; the SPEC is ' + SPEC + '.\n\n' +
  'Look for: a claim the diff does not back, a why with no source (a commit sha or ' +
  'the SPEC), a risk it missed, a note that would still be true with the diff ' +
  'hidden, and anything in the body or a note\'s plain paragraph a non-technical ' +
  'reader would trip on. Skip wording. An analogy or drawing that is wrong gets ' +
  'fixed, not cut.\n\n' +
  'Keep the line naming the model at the end of the body and of each note. A note ' +
  'you add or rewrite ends with your own model name and ID from your system prompt, ' +
  'like `_Claude Opus 5.5 (claude-opus-5-5)_`, and keeps the shape the others have: ' +
  'the technical sentence, then a plain paragraph for a non-technical reader.\n\n' +
  (opened.prUrl
    ? 'Fix each one on ' + opened.prUrl + ' itself: the body with `gh pr edit ' +
      '--body-file`, a wrong note by editing that review comment, a missed risk as a ' +
      'new comment on its line. One pass, no second round.\n\n'
    : 'The PR was not opened, so return the corrected `title`, `body` and `notes`.\n\n') +
  'List each change in `changed`, one line each.\n\n' +
  JSON.stringify({ title: opened.title, body: opened.body, notes: opened.notes }, null, 2),
  { label: 'open:check', phase: 'Open', schema: {
    type: 'object',
    properties: {
      changed: { type: 'array', items: { type: 'string' } },
      title: { type: 'string' },
      body: { type: 'string' },
      notes: { type: 'array', items: NOTE },
    },
    required: ['changed'],
  } }
)

if (!checked) {
  log('The check agent returned nothing — the PR description went out unchecked')
  return Object.assign(sofar, { checkChanges: null })
}

sofar.checkChanges = checked.changed
// Once the PR is open the check edits it in place, and the PR is the only true copy.
if (opened.prUrl) return sofar

return Object.assign(sofar, {
  title: checked.title || opened.title,
  body: checked.body || opened.body,
  notes: checked.notes || opened.notes,
})
