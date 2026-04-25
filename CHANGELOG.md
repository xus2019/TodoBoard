# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

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

[Unreleased]: https://github.com/xus2019/TodoBoard/compare/v1.0.1...HEAD
[1.0.1]: https://github.com/xus2019/TodoBoard/releases/tag/v1.0.1
[1.0.0]: https://github.com/xus2019/TodoBoard/releases/tag/v1.0.0
