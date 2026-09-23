# tmux-config

My [tmux](https://github.com/tmux/tmux) configuration — a **solid green**
centered status bar and green pane borders, plus sensible defaults, vi
copy-mode (Wayland `wl-copy`), and TPM-managed plugins.

## Features

- **Prefix**: `Ctrl-a`
- Green status bar, centered window list (`absolute-centre`)
- Active pane border in green (`#a6e3a1`); `heavy` border lines
- Vi copy-mode, mouse support, 50k scrollback, true color
- Splits keep the current path (`|` and `-`)
- Alt+arrows to move between panes (no prefix)
- Plugins via TPM: sensible, resurrect, continuum (auto-save/restore),
  fingers, fzf

## Install

```sh
git clone https://github.com/NBAFrigge/tmux-config /tmp/tmux-config \
  && /tmp/tmux-config/install.sh
```

The installer:

1. Backs up any existing `~/.tmux.conf`.
2. Deploys this repo's `.tmux.conf`.
3. Installs TPM and the declared plugins.
4. Reloads a running tmux server.

Flags:

```sh
./install.sh --symlink   # symlink instead of copy (edits track the repo)
./install.sh --dry-run   # print actions, change nothing
TMUX_CONF=/custom/path ./install.sh
```

## Requirements

- `tmux` and `git`
- A **Nerd Font** (e.g. JetBrainsMono Nerd Font) for the status-bar glyphs
- Wayland `wl-clipboard` for `y`/`Y` yank-to-clipboard (optional)

## After install

Open tmux; if plugins didn't auto-install, press `prefix + I`.
Reload the config anytime with `prefix + r`.
