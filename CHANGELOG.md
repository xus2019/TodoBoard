# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.0.3] - 2026-04-25

### Fixed
- **Project column reorder actually fires now.** `ProjectDragData` and `TodoDragData` no longer share `public.json` — both export UTTypes that conform only to `.data`, and the project drop destination is moved off the shared column body onto the column header itself. Stacking two `dropDestination`s of `.json`-conforming types on the same view was making the earlier todo destination swallow project drops, so `handleProjectDrop` never ran (issue diagnosed via independent Codex review).
- Project columns: `.draggable` spans the entire header HStack so the column is grabbable from any non-button area; the grip icon turns the cursor into an open-hand on hover; header now visibly highlights when a column is hovered as a drop target.
- Window: explicit restore + alpha fade-in via `applicationWillFinishLaunching` hook reduces the SwiftUI first-frame jitter on Cmd+W → reopen. (Note: macOS 14 SwiftUI `WindowGroup` does not expose a public hook earlier than `didBecomeMain` — fully eliminating the snap requires either `NSWindow.makeKeyAndOrderFront` swizzling or moving away from `WindowGroup` to a custom `NSWindowController`. This fade is the best the public API allows.)
- Window: first launch now centers a 1200×800 window on the active screen instead of relying on `WindowGroup`'s default placement.
- Window: `applicationWillTerminate` saves the current frame, so quitting the app (Cmd+Q) preserves size and position too.

### Changed
- App icon is now padded into a 1024×1024 transparent canvas with content scaled to ~80% so the rendered Dock/Finder size matches Apple's apps (`scripts/pad-icon.swift` invoked by `scripts/build-app.sh`).

## [1.0.2] - 2026-04-25

### Fixed
- Todo card now grows in height to fit wrapped multi-line titles (`NSViewRepresentable.sizeThatFits` reports cell-wrapped height)
- Window size is preserved across `Cmd+W` close → reopen: minSize moved from SwiftUI `.frame` to `NSWindow.minSize`; explicit `setFrameUsingName` / `saveFrame(usingName:)` on key/close
- App now opens at 1200×800 by default on first launch

### Added
- Visible drag handle (`line.3.horizontal`) on each project column header; cursor switches to open-hand on hover so column reordering is discoverable

## [1.0.1] - 2026-04-25

### Fixed
- Window: double-clicking the toolbar zooms the window again
- Window: size and position now persist across launches via `setFrameAutosaveName`
- Done todos: thoughts/notes are editable inline; persists on collapse and on view disappear
- Todo title input wraps long text instead of truncating; pasted multiline is normalized to single-line so Markdown serialization stays intact
- Project columns can be reordered by dragging the column header (calls existing `reorderProjects`)

### Changed
- Drag-drop payloads use distinct exported UTTypes (`com.todoboard.todo-drag`, `com.todoboard.project-drag`) so todo and project drops no longer share `public.json`

## [1.0.0] - 2025-01-01

### Added
- Multi-column kanban board with drag & drop reordering and cross-column move
- Markdown file storage — each project maps to one `.md` file
- Live file sync via `kqueue`-based file watcher with SHA-256 content hashing
- 4 built-in themes: Moonlight, Daylight, Solarized, Minimal
- Ambient particle effects: rain, snow, fireflies, sakura, stardust (SpriteKit)
- Global keyboard shortcut for quick todo input
- Archive section with grouping by week / month / all
- Custom tag system with color picker
- Full-text search overlay
- Markdown import / export (single project or merged)
- Inspector editor panel for todo details
- Light / Dark / System appearance support
- In-app update checker

[Unreleased]: https://github.com/xus2019/TodoBoard/compare/v1.0.3...HEAD
[1.0.3]: https://github.com/xus2019/TodoBoard/releases/tag/v1.0.3
[1.0.2]: https://github.com/xus2019/TodoBoard/releases/tag/v1.0.2
[1.0.1]: https://github.com/xus2019/TodoBoard/releases/tag/v1.0.1
[1.0.0]: https://github.com/xus2019/TodoBoard/releases/tag/v1.0.0
