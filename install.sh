#!/usr/bin/env bash
#
# tmux-config installer
# ----------------------
# Deploys this repo's .tmux.conf to ~/.tmux.conf, installs TPM (tmux plugin
# manager) if missing, installs the declared plugins, and reloads any running
# tmux server.
#
# Usage:
#   ./install.sh            # back up existing config, deploy, install plugins
#   ./install.sh --symlink  # symlink instead of copy (edits track the repo)
#   ./install.sh --dry-run  # print actions, change nothing
#
# Safe to re-run: an existing ~/.tmux.conf is backed up first.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
SRC="$SCRIPT_DIR/.tmux.conf"
DEST="${TMUX_CONF:-$HOME/.tmux.conf}"
TPM_DIR="${TPM_DIR:-$HOME/.tmux/plugins/tpm}"

DRY_RUN=0
SYMLINK=0
for arg in "$@"; do
  case "$arg" in
    --dry-run) DRY_RUN=1 ;;
    --symlink) SYMLINK=1 ;;
    -h|--help) sed -n '2,17p' "$0"; exit 0 ;;
    *) echo "Unknown option: $arg" >&2; exit 2 ;;
  esac
done

if [ -t 1 ]; then
  B=$'\033[1;34m'; Y=$'\033[1;33m'; R=$'\033[1;31m'; G=$'\033[1;32m'; Z=$'\033[0m'
else B=""; Y=""; R=""; G=""; Z=""; fi
log()  { printf '%s==>%s %s\n'  "$B" "$Z" "$*"; }
ok()   { printf '%s ok %s %s\n' "$G" "$Z" "$*"; }
warn() { printf '%sWARN%s %s\n' "$Y" "$Z" "$*" >&2; }
die()  { printf '%sERR %s %s\n' "$R" "$Z" "$*" >&2; exit 1; }
run()  { if [ "$DRY_RUN" = 1 ]; then printf '  [dry-run] %s\n' "$*"; else eval "$@"; fi; }

# --- prerequisites --------------------------------------------------------
log "Checking prerequisites"
command -v git  >/dev/null 2>&1 || die "git not found — install git first."
command -v tmux >/dev/null 2>&1 || warn "tmux not found — install it to use the config (continuing anyway)."
[ -f "$SRC" ] || die "source .tmux.conf not found next to installer: $SRC"
ok "found source config"

# --- back up existing config ----------------------------------------------
if [ -e "$DEST" ] || [ -L "$DEST" ]; then
  BACKUP="$DEST.bak-$(date +%Y%m%d-%H%M%S)"
  log "Backing up existing $DEST -> $BACKUP"
  run "cp -a '$DEST' '$BACKUP'"
  ok "backup created"
fi

# --- deploy ---------------------------------------------------------------
if [ "$SYMLINK" = 1 ]; then
  log "Symlinking config -> $DEST"
  run "ln -sfn '$SRC' '$DEST'"
else
  log "Copying config -> $DEST"
  run "cp -a '$SRC' '$DEST'"
fi
ok "config deployed"

# --- TPM (tmux plugin manager) --------------------------------------------
if grep -q "tpm" "$SRC"; then
  if [ -d "$TPM_DIR/.git" ]; then
    ok "TPM already installed ($TPM_DIR)"
  else
    log "Installing TPM -> $TPM_DIR"
    run "git clone --depth 1 https://github.com/tmux-plugins/tpm '$TPM_DIR'"
    ok "TPM installed"
  fi

  # Install the plugins declared in the config (non-interactive).
  if [ "$DRY_RUN" = 0 ] && [ -x "$TPM_DIR/bin/install_plugins" ]; then
    log "Installing tmux plugins"
    "$TPM_DIR/bin/install_plugins" || warn "plugin install returned non-zero (open tmux and press prefix + I to retry)"
    ok "plugins installed"
  fi
fi

# --- reload running server ------------------------------------------------
if [ "$DRY_RUN" = 0 ] && command -v tmux >/dev/null 2>&1 && tmux info >/dev/null 2>&1; then
  log "Reloading live tmux server"
  tmux source-file "$DEST" && ok "reloaded" || warn "reload failed (restart tmux)"
fi

echo
ok "tmux-config installed."
cat <<EOF

Notes:
  - Prefix is Ctrl-a.
  - If plugins didn't auto-install, open tmux and press: prefix + I
  - Needs a Nerd Font (e.g. JetBrainsMono Nerd Font) for the powerline glyphs
    in the status bar.
EOF
