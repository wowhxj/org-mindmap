# Renderer Specification (Delta)

## MODIFIED Requirements

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
