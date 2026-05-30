# Renderer Specification

## Purpose
Generate a 2D text representation of the logical tree using box-drawing characters and layout algorithms.
## Requirements
### Requirement: Deterministic Layout
The renderer SHALL calculate coordinates for all nodes before writing to the buffer.

#### Scenario: Centered layout vertical alignment
- GIVEN a parent node with multiple children
- WHEN the `:layout` property is `centered`
- THEN the parent node's row SHALL be the median of its children's rows.

#### Scenario: Top layout placement
- GIVEN a mindmap block with `:layout top`
- WHEN the block is rendered
- THEN the root SHALL be positioned at the top with children extending downward.

### Requirement: Collision Avoidance
The renderer SHALL ensure no two nodes or connectors occupy the same character cell.

#### Scenario: Compacted placement
- GIVEN a new child node being placed
- WHEN `:compacted` is `t`
- THEN the renderer SHALL find the minimum vertical coordinate for the node that does not overlap existing subtrees.

#### Scenario: Sequential placement (no compaction)
- GIVEN a new child node being placed
- WHEN `:compacted` is `nil`
- THEN the renderer SHALL place the child directly below the previous sibling
- AND no gap-filling search SHALL be performed.

### Requirement: Configurable Spacing
The renderer SHALL respect horizontal padding requirements between nodes.

#### Scenario: Applying horizontal spacing
- GIVEN a mindmap block with `:spacing N`
- WHEN rendering nodes
- THEN the renderer SHALL ensure at least `N` whitespace characters exist between a node's text and its sibling's vertical connector.

### Requirement: Symbol Selection and Pack Usage
The system SHALL select box-drawing characters and root delimiters based on the active primary sets.

#### Scenario: Primary connector pack usage
- GIVEN a mindmap being rendered
- THEN the renderer SHALL exclusively use the first connector pack in `org-mindmap-parser-connectors`.

#### Scenario: Primary root delimiter usage
- GIVEN a root node being rendered
- THEN the renderer SHALL wrap the text in the first delimiter pair in `org-mindmap-parser-root-delimiters`.

#### Scenario: Automatic symbol migration
- WHEN a mindmap is parsed using legacy symbols (from non-primary sets)
- AND the user triggers a re-render
- THEN the renderer SHALL write the new primary symbols to the buffer.

### Requirement: Visual Styling and Protection
The renderer SHALL apply semantic styling and optional editing protections to the canvas.

#### Scenario: Connector protection
- GIVEN the variable `org-mindmap-protect-connectors` is set to `t`
- WHEN rendering the mindmap
- THEN all connector characters SHALL have the `read-only` text property applied.

#### Scenario: Applying faces
- GIVEN a rendered mindmap
- THEN node text SHALL be styled with `org-mindmap-face-text`
- AND connectors SHALL be styled with `org-mindmap-face-connectors`.

### Requirement: Compaction Toggle Property
The system SHALL support a `:compacted` header property on mindmap blocks that controls whether the compaction algorithm is active, independent of the layout strategy.

#### Scenario: Enabling compaction with top layout
- GIVEN a mindmap block with `:layout top :compacted t`
- WHEN the block is rendered
- THEN child nodes SHALL be placed into the smallest available vertical gap that avoids collisions
- AND the root SHALL remain at the top.

#### Scenario: Enabling compaction with centered layout
- GIVEN a mindmap block with `:layout centered :compacted t`
- WHEN the block is rendered
- THEN child nodes SHALL be placed into the smallest available vertical gap that avoids collisions
- AND the root SHALL be centered between its left and right child groups.

#### Scenario: Disabling compaction with top layout
- GIVEN a mindmap block with `:layout top :compacted nil`
- WHEN the block is rendered
- THEN children SHALL be stacked sequentially below previous siblings
- AND no gap-filling SHALL occur.

#### Scenario: Disabling compaction with centered layout
- GIVEN a mindmap block with `:layout centered :compacted nil`
- WHEN the block is rendered
- THEN children SHALL be stacked sequentially below previous siblings
- AND the root SHALL be centered between its left and right child groups.

### Requirement: Default Compaction Setting
The system SHALL provide a defcustom `org-mindmap-default-compacted` that controls the default value of `:compacted` for new mindmap blocks.

#### Scenario: Default compaction value
- GIVEN `org-mindmap-default-compacted` is set to `nil`
- WHEN a new mindmap block is created without an explicit `:compacted` property
- THEN compaction SHALL be disabled for that block.

#### Scenario: Overriding default compaction
- GIVEN `org-mindmap-default-compacted` is set to `nil`
- WHEN a mindmap block specifies `:compacted t`
- THEN the explicit property SHALL override the default
- AND compaction SHALL be enabled for that block.

