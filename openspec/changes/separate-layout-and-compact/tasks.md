## 1. Defcustom and Configuration

- [ ] 1.1 Add `org-mindmap-default-compacted` defcustom (boolean, default `nil`) near existing defcustoms
- [ ] 1.2 Update `org-mindmap-default-layout` defcustom `:type` to `(choice (const top) (const centered))` and change default to `top`

## 2. Property Parsing and Legacy Migration

- [ ] 2.1 Update `org-mindmap--parse-properties` to also parse `:compacted` from block header
- [ ] 2.2 Add auto-migration logic: when legacy `:layout left`/`:layout compact`/`:layout centered` is detected, rewrite the `#+begin_mindmap` header line with the new canonical form and re-parse
- [ ] 2.3 Add a `compacted` parameter to function signatures: `org-mindmap-build-subtree`, `org-mindmap-build-tree-layout`, `org-mindmap-render-tree`

## 3. Core Layout Logic Decoupling

- [ ] 3.1 In `org-mindmap-build-subtree`, replace `(if (eq layout 'left) ...)` on the child-placement branch (line ~188) with `(if compacted ...)` — sequential placement when `nil`, gap-fill when `t`
- [ ] 3.2 Keep the centering step (`(eq layout 'centered)` at line ~214) unchanged — it only depends on layout, not compaction
- [ ] 3.3 Replace all remaining `'left` references with `'top` in `org-mindmap-build-subtree`
- [ ] 3.4 In `org-mindmap-build-tree-layout`, replace `(if (eq layout 'left) ...)` on the root-placement branch (line ~250) with `(if compacted ...)`
- [ ] 3.5 Replace all remaining `'left` references with `'top` in `org-mindmap-build-tree-layout`

## 4. Top-Level Render Entry Point

- [ ] 4.1 Update `org-mindmap-render-tree` to accept `compacted` parameter, default from `org-mindmap-default-compacted`
- [ ] 4.2 Pass `compacted` through to `org-mindmap-build-tree-layout`
- [ ] 4.3 Update all callers of `org-mindmap-render-tree` to pass the `compacted` value

## 5. Interactive Commands

- [ ] 5.1 Rewrite `org-mindmap-switch-layout` to cycle `top ↔ centered` only (remove `compact` and `left` from the pcase)
- [ ] 5.2 Create new `org-mindmap-toggle-compaction` command that reads current `:compacted`, toggles it, rewrites the header, and re-aligns
- [ ] 5.3 Update `org-mindmap-align` and `org-mindmap--update-buffer` to extract both `:layout` and `:compacted` from parsed properties and pass them through

## 6. Tests

- [ ] 6.1 Update `tests/test-rendering.el` — replace all `'left` with `'top`, and add `compacted` parameter to all layout calls
- [ ] 6.2 Add test cases for the four combinations: top/not-compacted, top/compacted, centered/not-compacted, centered/compacted
- [ ] 6.3 Add test cases for legacy property auto-migration
- [ ] 6.4 Run existing tests to verify nothing else breaks

## 7. Cleanup

- [ ] 7.1 Grep codebase for any remaining references to `'left` or `'compact` as layout values and fix
- [ ] 7.2 Update `TODO.org` and any design notes referencing the old layout names
- [ ] 7.3 Verify `demo.org` works with the new settings
