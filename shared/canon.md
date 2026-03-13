# Canon — OOP, XP, Agile, and Rails Principles

This is the shared reference for principles, thinkers, and patterns used across multiple skills. When a skill tells you to draw on the canon, read this file and apply the relevant principles — not as citations, but as grounded positions that inform your questions and opinions.

---

## Sandi Metz (POODR)

- **Single Responsibility Principle:** a class should have one reason to change. If you can't describe what a class does without using "and", it has too many responsibilities.
- **Small classes, small methods.** Short, focused, easy to understand in isolation.
- **Depend on abstractions, not concretions.** Inject dependencies rather than hardcoding them.
- **Message-based design.** Think about the messages objects send to each other, not what they contain.
- **Tell, Don't Ask.** Tell objects what to do rather than asking for their data and making decisions for them.
- Dependencies are expensive. Simple objects with single responsibilities are easier to replace than complex ones with hidden assumptions baked in.

## Martin Fowler (Refactoring)

- **Named smells:** Feature Envy, Shotgun Surgery, Data Clump, Primitive Obsession, Divergent Change, Long Method, Large Class, Long Parameter List. Use his vocabulary precisely — it's a shared language worth owning.
- **Named moves:** Extract Method, Extract Class, Move Method, Inline Method, Replace Conditional with Polymorphism, Hide Delegate, Introduce Parameter Object. Name the move, don't describe it vaguely.
- If the code is telling you it needs something, listen. If the assumption is speculative, it's a smell before you've written a line.

## Robert Martin (Clean Code / SOLID)

- **SOLID principles:** Single Responsibility, Open/Closed, Liskov Substitution, Interface Segregation, Dependency Inversion.
- **Single level of abstraction:** each function should operate at one level of abstraction. Don't mix high-level orchestration with low-level details.
- **Function size:** small. Functions should do one thing.
- **Naming as design:** if you can't name it clearly, you don't understand it yet.

## Kent Beck (XP / Simple Design)

- **4 Rules of Simple Design** (in priority order): passes the tests, reveals intention, no duplication of knowledge, fewest elements.
- **YAGNI:** don't build for a future that might not arrive. Let the design emerge from real feedback rather than anticipated need.
- **Red-green-refactor:** write a failing test, make it pass, then improve the design. Refactor is a phase, not an afterthought.
- **Make the change easy, then make the easy change.** If the change is hard, first refactor to make it easy.
- **Do the simplest thing that could possibly work.**

## Ward Cunningham

- **Technical debt** is a deliberate choice with a known cost — not an accident. Name whether code looks like intentional debt (a conscious shortcut with a plan to repay) or accidental debt (a mess no one chose). The distinction matters for how you communicate about it.

## Gang of Four (Design Patterns)

- Only invoke patterns when the code is reaching for one clumsily or would clearly benefit from one. Don't pattern-match for sport.
- Useful when you recognise the shape of a problem that a pattern solves. Harmful when applied speculatively or to impress.

## thoughtbot

### Practices (from the [thoughtbot playbook](https://thoughtbot.com/playbook/developing))

- **Test-Driven Development** as a core practice, not an optional extra. Write tests first. Always.
- **Pair programming** for knowledge sharing and code quality.
- **Code reviews** as a team practice, not a gate.
- **Refactoring** as a continuous practice — improve structure without changing behaviour.
- **Acceptance tests** to validate that solutions meet business requirements.
- **Continuous integration** — automate builds and tests. The pipeline should always be green.
- **Style guides** for consistency — follow them, don't debate them.

### Patterns

- **Callbacks are a smell for business logic.** Prefer explicit service calls over `after_create`, `before_save`, etc. for anything beyond simple data concerns. Callbacks hide control flow and make testing harder.
- **Skinny everything.** Not just skinny controllers — skinny models too. Extract to POROs when a model has more than one reason to change.
- **Reach for POROs before abstractions.** A plain Ruby object is almost always simpler than a concern, a module, or a framework abstraction.
- **Service objects** have one public method (`call`) and one responsibility. If you can't state what a service object does in one sentence, it's doing too much.
- **Form objects** for complex input — multi-model forms, complex params, validation logic that doesn't belong on a single model.
- **Query objects** for complex ActiveRecord queries that don't belong as model scopes.
- **If it's hard to test, it's probably in the wrong place.** Testability is a design signal, not a testing problem.
- **Walking skeleton:** start with the thinnest possible end-to-end slice that proves the architecture works.

### Ruby Science (from [thoughtbot/ruby-science](https://github.com/thoughtbot/ruby-science))

The canonical reference for identifying and fixing code quality problems in Rails applications.

**Code smells to recognise:**

- Long Method, Large Class, Long Parameter List — size smells that signal too many responsibilities
- Feature Envy — a method that uses another object's data more than its own
- Shotgun Surgery — a change that requires edits in many places
- Divergent Change — a class that changes for multiple unrelated reasons
- Duplicated Code — repeated logic that can drift apart
- Uncommunicative Name — names that don't reveal intent
- Callback — business logic hidden in AR lifecycle hooks
- Mixin — concerns and modules used as junk drawers instead of cohesive abstractions
- Case Statement — conditionals that should be polymorphism
- Single Table Inheritance — STI used where it creates more problems than it solves
- Comments — comments that exist because the code doesn't explain itself

**Principles to apply:**

- Single Responsibility Principle
- Open/Closed Principle
- Dependency Inversion Principle
- Composition over Inheritance
- Law of Demeter
- Tell, Don't Ask
- DRY — but duplication is far cheaper than the wrong abstraction

**Solutions (named refactoring moves for Rails):**

- Extract Method, Extract Class, Extract Partial, Extract Validator, Extract Value Object, Extract Decorator
- Introduce Form Object, Introduce Parameter Object, Introduce Explaining Variable
- Move Method, Inline Class, Rename Method
- Inject Dependencies
- Replace Callback with Method
- Replace Conditional with Polymorphism, Replace Conditional with Null Object
- Replace Mixin with Composition, Replace Subclasses with Strategies
- Use Class as Factory, Use Convention over Configuration

## Agile Principles

- **Working software is the primary measure of progress.** Not plans, not documents, not effort.
- **Welcome changing requirements,** even late in development. Agile processes harness change for the customer's competitive advantage.
- **Deliver working software frequently,** from a couple of weeks to a couple of months, with a preference to the shorter timescale.
- **Simplicity — the art of maximising the amount of work not done — is essential.** (This is YAGNI applied at the project level.)
- **Assumptions that haven't been tested by a real user or a real system are hypotheses, not constraints.** Treat them accordingly.
