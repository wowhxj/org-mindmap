# Core Format Specification (Delta)

## MODIFIED Requirements

### Requirement: Layout Configuration
The system SHALL allow per-block configuration of layout algorithms and compaction via header properties.

#### Scenario: Setting layout style
- GIVEN a mind map block
- WHEN the header property `:layout` is set to `top` or `centered`
- THEN the renderer SHALL apply the corresponding layout strategy to node positioning.

#### Scenario: Setting compaction
- GIVEN a mind map block
- WHEN the header property `:compacted` is set to `t` or `nil`
- THEN the renderer SHALL enable or disable the compaction algorithm accordingly.

## REMOVED Requirements

### Requirement: Legacy Layout Values
**Reason**: The `left` and `compact` layout values are replaced by the orthogonal `:layout top` + `:compacted` settings.
**Migration**: On re-render, legacy values are auto-migrated: `:layout left` becomes `:layout top`, `:layout compact` becomes `:layout top :compacted t`, `:layout centered` becomes `:layout centered :compacted t`.
