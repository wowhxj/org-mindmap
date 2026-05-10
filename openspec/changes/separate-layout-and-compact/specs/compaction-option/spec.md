# Compaction Option Specification

## Purpose
Provide an independent, orthogonal setting for controlling whether child nodes fill vacant vertical gaps (compaction) or are stacked sequentially.

## ADDED Requirements

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
