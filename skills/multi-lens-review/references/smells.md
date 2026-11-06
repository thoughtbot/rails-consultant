# Code smells

The catalog from [refactoring.guru](https://refactoring.guru/refactoring/smells), with the tell — what you'd actually see in a diff. Follow the link for the refactorings that fix each one.

The catalog was written about class-based code. Most of it carries over to anything with functions and modules; the object-orientation section largely doesn't, so don't stretch it to fit a language that works differently.

## Bloaters

Code that grew until nobody could take it in at once.

- **Long Method** — the body runs long enough that a reader can't hold it; new lines keep landing in it.
- **Large Class** — the class gains fields and methods in every feature diff.
- **Primitive Obsession** — strings, integers, and constants stand in for domain concepts like Money or Phone.
- **Long Parameter List** — the signature takes more than three or four arguments.
- **Data Clumps** — the same group of variables travels together in several places.

## Object-orientation abusers

Object-oriented tools used against the grain.

- **Alternative Classes with Different Interfaces** — two classes do the same job under different method names.
- **Refused Bequest** — a subclass ignores most of what it inherits, or overrides it to throw or no-op.
- **Switch Statements** — a `switch` or `if/else` chain branching on a type or a code.
- **Temporary Field** — a field set in one code path and empty everywhere else.

## Change preventers

One change forces changes elsewhere.

- **Divergent Change** — one class edited for several unrelated reasons in the same diff.
- **Parallel Inheritance Hierarchies** — a new subclass here forces a matching subclass there.
- **Shotgun Surgery** — one behavior change requires small edits across many classes.

## Dispensables

Things whose absence would improve the code.

- **Comments** — the comment narrates what the code should have said itself.
- **Duplicate Code** — two fragments are nearly identical, often in siblings.
- **Data Class** — fields with accessors and no behavior.
- **Dead Code** — a variable, method, or class nothing references.
- **Lazy Class** — the class does too little to justify the file.
- **Speculative Generality** — an unused class, hook, or parameter built for a future that hasn't arrived.

## Couplers

Classes too tangled in each other.

- **Feature Envy** — a method reads another object's data more than its own.
- **Inappropriate Intimacy** — a class reaches into another's private fields and methods.
- **Message Chains** — `a.b().c().d()`, walking through several objects to get somewhere.
- **Middle Man** — a class that does nothing but delegate onward.
- **Incomplete Library Class** — a library you can't edit lacks something, so callers bolt on workarounds.
