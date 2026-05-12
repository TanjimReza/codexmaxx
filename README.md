# CodexMaxx

macOS app for switching Codex accounts, tracking usage, load balancing profiles, and monitoring active Codex sessions.

<img src="docs/codexmaxx-dashboard.jpg" alt="CodexMaxx dashboard and settings windows" width="900">

CodexMaxx reads local Codex OAuth credentials from your machine, fetches Codex usage windows, and lets you switch between stored Codex profiles from the menu bar or the main window.

## Download

Download the latest stable build from [releaseflow.net/kitze/codexmaxx](https://releaseflow.net/kitze/codexmaxx).

## Features

- Combined or active-account menu bar usage.
- Session and weekly Codex quota display.
- Account switching without a CLI, including click-to-switch account cards.
- Main dashboard with account grid, weekly usage chart, and GitHub-style activity graph.
- Active Codex session monitoring with session count, optional menu bar status, idle blinking, and idle beep alerts.
- Optional Codex-only load balancing across stored profiles.
- Configurable load balancer strategies: capacity weighted, usage weighted, or round robin.
- Main window and settings window for when the menu bar is crowded.
- Optional email hiding for privacy.
- Text, stacked-bar, and circular menu bar display modes.
- Local profile storage under `~/.codexmaxx`.
- Separate Dev variant storage under `~/.codexmaxx-dev`.

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

## Credits

CodexMaxx was inspired by [CodexBar](https://github.com/steipete/codexbar) by [@steipete](https://github.com/steipete) and account-switching ideas from [aisw](https://github.com/burakdede/aisw) by [Burak Dede](https://burakdede.com/).

## License

MIT
