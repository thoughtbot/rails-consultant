# Defects

The classes of bug worth hunting in a diff, with the tell — what you'd actually see.

Every item assumes a stack that can have it. Work out the language, the storage, and the concurrency model from the repo first, then skip what this one can't have. A missing-transaction finding in a codebase with no database, or a `&&`/`||` mix-up in a language whose operators are words, is noise.

## Correctness

- **Boundary** — empty collection, single element, zero, negative, the last index. Off-by-one in a slice, a range, or a loop bound.
- **Absent value** — something that can be missing, used as if it can't. Follow it to where it's produced, not to where the diff assumes it.
- **Swallowed failure** — a caught error that logs and continues, a return value nobody checks, a fallback that substitutes a wrong answer for an error.
- **Split write** — two writes that must both land, with nothing making them one operation.
- **Read-then-write gap** — state read, decided on, then written, with room for another actor in between.
- **Shared mutable state** — reached from two paths that can be inside it at once. Threads, tasks, jobs, a second process, whatever this stack has.
- **Flipped condition** — a negation, a boolean operator, or a comparison against the wrong variable. Reads fine, which is why it survives; catch it by tracing one concrete input through the branch.
- **Wrong test** — an assertion on the wrong value, a test that passes vacuously, a boundary the new tests skip. The tell is a test that would still pass with the bug in place.

## Performance

- **Work per iteration that could happen once** — a query, a connection, a file read, a compile, inside the loop.
- **Unbounded load** — a whole table, file, or response into memory. Correct at today's size, with nothing capping tomorrow's.
- **Accidental quadratic** — a scan inside a loop over the same data. Nested iteration where a lookup table would do.
- **Blocking call in the wrong place** — I/O on a path expected to return immediately, or inside a lock.

## Security

- **Untrusted input reaching an interpreter** — a query, a command, a template, a deserializer, a path, an outbound request, built by concatenation where the API offers a parameterized or escaped form.
- **Missing authorization** — the handler knows who the caller is and never checks that this record is theirs. Authentication present, ownership unchecked.
- **Secret in the wrong place** — a key, token, or password in source, a log line, an error message, a fixture, a URL.
- **Overexposure** — a response, log, or error carrying more of an object than the caller should see. A new field on whatever serializes it is the usual arrival.
- **Weakened check** — a validation, filter, expiry, or comparison the change loosens or deletes.
