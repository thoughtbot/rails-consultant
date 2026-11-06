# The tells

Read this only after the sketch is on disk. If you find yourself editing the sketch after reading this, you're building the case backwards.

Three of these are code smells read forward — Long Method, Primitive Obsession, Feature Envy. `/multi-lens-review` reports the same code. The difference is the sketch: there the finding is that the code costs something today, here it's that this feature's diff gets smaller. If you can't show the second, you're doing the other job in the wrong skill, so drop it.

- **The feature has nowhere to go.** The behavior belongs in the middle of a function that runs one thing end to end. Extract that thing, then call it through a pass-through that does nothing yet. Tests stay green, and the feature arrives as a body for a function that already exists and is already wired up.

  The shape is an identity function slotted into a composition: `f(g(x))` where `g` returns `x` unchanged. Fowler's was `apply_highlights(apply_ranges(lines))`, but it has other bodies — a middleware that just calls the next handler, a filter that keeps everything, a hook that returns its input, a strategy that returns the current default, a query object with no conditions yet. In a language without cheap composition it's a private function called on one line that returns its argument.

  Not this when the feature has to change what the existing step already does. A seam only pays when the new behavior *composes* — a step before or after — so if the feature threads into the current logic line by line, the pass-through is dead code and you've prepared nothing.

- **The feature is the third case.** An `if/else` on two variants, and this makes three. Turn the branch into data or dispatch first, and the feature becomes one entry instead of a third limb.

- **The feature only touches half of what the function does.** Parse-then-compute, fetch-then-format. Split the phases and the change lands in one of them instead of threading through both.

- **The feature adds the fourth rule to a primitive.** A string or integer already carrying validation, comparison, and formatting wherever it goes. Give it a name and the new rule has an owner.

- **The feature would deepen a reach.** The code here already reads another object's data to do its job, and the feature needs more of it. Move the behavior to the data before adding to it, or you widen a coupling you'll pay for twice.
