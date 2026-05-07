# CodexMaxx

Minimal macOS menu bar app for tracking and switching Codex accounts.

CodexMaxx reads local Codex OAuth credentials from your machine, fetches Codex usage windows, and lets you switch between stored Codex profiles from the menu bar.

## Features

- Combined or active-account menu bar usage.
- Session and weekly Codex quota display.
- Account switching without a CLI.
- Optional email hiding for privacy.
- Text, stacked-bar, and circular menu bar display modes.
- Local profile storage under `~/.codexmaxx`.

## Build

```bash
swift build -c release --product CodexMaxx
```

## Install Locally

```bash
./Scripts/package_app.sh
open CodexMaxx.app
```

## Privacy

CodexMaxx stores copied Codex profile files in `~/.codexmaxx/profiles/codex` and backs up switched files under `~/.codexmaxx/backups`.

Do not commit `~/.codex`, `~/.codexmaxx`, `auth.json`, or local release credentials.

## License

MIT
