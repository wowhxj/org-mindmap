## Context

Currently `org-mindmap.el` uses a single `layout` symbol (`left`/`compact`/`centered`) that conflates two concerns: the layout strategy (top vs centered) and whether compaction is active. The check `(eq layout 'left)` gates both the stacking strategy AND the absence of compaction, while centering is gated separately via `(eq layout 'centered)`. This makes the code confusing and prevents independent control.

All relevant code is in `org-mindmap.el`. The parser (`org-mindmap-parser.el`) is unaffected.

## Goals / Non-Goals

**Goals:**
- Split the single `layout` symbol into two independent settings: `layout` (`top`/`centered`) and `compacted` (boolean)
- Rename `left` to `top` to accurately describe the actual layout direction
- Provide separate interactive commands for changing layout and toggling compaction
- Auto-migrate legacy block properties so existing documents don't break

**Non-Goals:**
- Adding new layout strategies beyond the existing two
- Changing the compaction algorithm itself
- Changing the parser or the on-disk canvas format
- Adding GUI or menu integration

## Decisions

### Decision 1: Property names — `:layout` + `:compacted`

**Chosen**: Keep `:layout` for the layout strategy (values: `top`, `centered`), add `:compacted` as a boolean.

**Alternatives considered**:
- `:layout-style` + `:layout-compact` — more verbose, breaks existing `:layout` blocks
- Single property with two sub-values like `:layout top+compact` — still conflated, harder to parse

**Rationale**: Two cleanly separated properties match the orthogonality of the concerns. The `:layout` name stays for familiarity; only its allowed values change.

### Decision 2: Rename `left` → `top`

**Chosen**: `top` — accurately describes that the root is at the top with children extending downward.

**Alternatives considered**:
- Keep `left` for backward compat — misleading, the root hasn't been on the left since the bidirectional layout was introduced
- `tree` or `downward` — less conventional in mindmap terminology

**Rationale**: `top` is the standard term for this layout orientation in mindmap tools. The old `left` name is a historical artifact. Backward compatibility is handled via auto-migration.

### Decision 3: Auto-migration of legacy properties

**Chosen**: `org-mindmap--parse-properties` detects legacy values and maps them:
- `:layout left` → `:layout top` (no compaction)
- `:layout compact` → `:layout top :compacted t`
- `:layout centered` → `:layout centered :compacted t`

The migration rewrites the `#+begin_mindmap` header line in the buffer so it's persisted on next save.

**Alternatives considered**:
- Silent internal mapping without buffer rewrite — user never sees the new format, confusion persists
- Error on legacy values — breaks existing documents, forces manual intervention

**Rationale**: Auto-migration gives a seamless upgrade path. The buffer rewrite ensures the document converges to the canonical format.

### Decision 4: Compaction algorithm is gated on `compacted`, not on layout

**Chosen**: In `org-mindmap-build-subtree`, replace `(if (eq layout 'left) ...)` with `(if compacted ...)`. The centering step remains gated on `(eq layout 'centered)`.

The occupancy tracking functions (`org-mindmap--node-occupancy`, `org-mindmap--get-occupied`, `org-mindmap--check-overlap-subtree`) are unchanged and always available — they're just only called when `compacted` is true.

## Risks / Trade-offs

- **Breaking change for existing documents** → Auto-migration on parse handles this transparently. Users who never re-render an old mindmap won't notice until they do, at which point the header is updated.
- **`:compacted t` without compaction-aware layout** → Currently both layouts support compaction, so this is safe. If future layouts don't support compaction, the flag should be a no-op or warn.
- **Test breakage** → All tests referencing `'left`, `'compact`, or the old `:layout centered` semantics need updating. This is a one-time cost covered in the tasks.
