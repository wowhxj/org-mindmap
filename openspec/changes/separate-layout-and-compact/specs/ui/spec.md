# UI and Interaction Specification (Delta)

## ADDED Requirements

### Requirement: Compaction Toggle Command
The system SHALL provide an interactive command to toggle the `:compacted` property on the current mindmap block.

#### Scenario: Toggling compaction on
- GIVEN a mindmap block with `:compacted nil`
- WHEN the user executes `org-mindmap-toggle-compaction`
- THEN the `:compacted` property SHALL be set to `t`
- AND the block SHALL be re-rendered with compaction active.

#### Scenario: Toggling compaction off
- GIVEN a mindmap block with `:compacted t`
- WHEN the user executes `org-mindmap-toggle-compaction`
- THEN the `:compacted` property SHALL be set to `nil`
- AND the block SHALL be re-rendered with compaction disabled.

## MODIFIED Requirements

### Requirement: Layout Switching Command
The system SHALL provide an interactive command `org-mindmap-switch-layout` to cycle through layout strategies.

#### Scenario: Cycling layout strategies
- GIVEN a mindmap block with `:layout top`
- WHEN the user executes `org-mindmap-switch-layout`
- THEN the `:layout` property SHALL change to `centered`
- AND the block SHALL be re-rendered.
- GIVEN a mindmap block with `:layout centered`
- WHEN the user executes `org-mindmap-switch-layout`
- THEN the `:layout` property SHALL change to `top`
- AND the block SHALL be re-rendered.

## REMOVED Requirements

### Requirement: Legacy Layout Cycling
**Reason**: `org-mindmap-switch-layout` no longer cycles through the deprecated `left` and `compact` values.
**Migration**: Use `org-mindmap-switch-layout` to toggle between `top` and `centered`, and use `org-mindmap-toggle-compaction` to independently control compaction.
