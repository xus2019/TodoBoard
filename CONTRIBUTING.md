# Contributing to TodoBoard

Thank you for your interest in contributing! Here's how to get started.

## Getting Started

1. **Fork** the repository
2. **Clone** your fork: `git clone https://github.com/YOUR_USERNAME/TodoBoard.git`
3. Create a **branch**: `git checkout -b feature/my-feature` or `fix/my-bug`
4. Make your changes
5. **Test** your changes: `swift test --disable-sandbox`
6. Open a **Pull Request** against `main`

## Development Setup

```bash
cd TodoBoard
open Package.swift   # Xcode opens the SPM package as a macOS App project
```

Run tests from the command line:

```bash
HOME=$PWD/.home CLANG_MODULE_CACHE_PATH=$PWD/.cache/clang \
  swift test --disable-sandbox --build-path .build-local
```

## Code Guidelines

- **Language**: Swift 6.1, targeting macOS 14+
- **Concurrency**: Use `async/await` and `@MainActor` — avoid DispatchQueue on the main thread
- **No third-party dependencies**: Keep the project dependency-free
- **Data layer**: All persistent state lives in `~/Documents/TodoBoard/`; do not introduce other storage mechanisms
- **Tests**: Add tests for any new storage parsing/serialization logic

## Commit Messages

Use imperative mood: `Add tag filter`, `Fix crash on empty project`, not `Added` / `Fixed`.

## Pull Request Guidelines

- Keep PRs focused — one feature or fix per PR
- Update `CHANGELOG.md` under `[Unreleased]`
- Ensure `swift build` and `swift test` pass before submitting

## Reporting Issues

- Use the [bug report template](.github/ISSUE_TEMPLATE/bug_report.md) for bugs
- Use the [feature request template](.github/ISSUE_TEMPLATE/feature_request.md) for ideas
- Search existing issues before opening a new one

## License

By contributing, you agree that your contributions will be licensed under the [MIT License](LICENSE).
