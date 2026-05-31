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
