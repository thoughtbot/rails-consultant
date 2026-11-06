# Translating for a reader from another stack

Read this when you know the reader's background and the project isn't in it.

## The point of an analogy

The reviewer isn't confused about programming. They're missing the *conventions*:
what this framework does for you, what's expected to live where, what's normal
versus what's a workaround. Their own stack gives them exactly that at home, so
the analogy does real work: it hands them the conventions they'd otherwise have
to infer from the diff.

Which means: translate concepts and conventions, not syntax. "It's their service
provider, wiring things up once at boot" is useful. "`:=` is like `=`" is noise.

## How to use one

**Say the analogy, then the difference that matters.** An analogy without its
limit sets the reviewer up to be wrong later. "This struct is their model,
except nothing saves it; it's just data in memory" tells them where their
instincts stop applying, which is the part they can't get from the diff.

**One per idea, then move on.** Analogies stack badly. Once you've said a
Go handler is their controller action, keep calling it that; don't reach for a
second metaphor two paragraphs later.

**Skip it when the thing is already universal.** A typo fix, a renamed variable,
a null check: nobody needs a translation for that. Forcing an analogy onto
something obvious reads as condescension, and the reviewer starts skimming.

**Never make the analogy do the explaining.** The annotation still has to say
why the change was made. The analogy only makes the *what* cheap to parse so the
why has room.

**Say so when there's no match.** Type systems, eventual consistency, explicit
dependency injection often have no honest equivalent in the reader's stack.
Describe the actual thing plainly instead of stretching a comparison.

## Worked examples

For a Laravel developer reading a Go branch.

**Weak, syntax with no why:**
> This adds a `sync.Once` around the config loader.

**Better, convention plus the reason:**
> Does what binding a singleton in a service provider does: the config is read
> once, the first time anything asks, and shared after that. It moved here
> because two packages were each reading the file on their own and disagreed
> after a deploy.

**Weak, the analogy is the whole annotation:**
> A goroutine is basically a queued job.

**Better, analogy sets up the actual point:**
> Starting a goroutine here is like dispatching a Laravel job, minus the queue:
> it runs in the same process, so a restart mid-resize loses the thumbnail,
> with no `failed_jobs` row to pick it back up. That's why the upload is marked
> pending first and a sweep finishes any left behind.
