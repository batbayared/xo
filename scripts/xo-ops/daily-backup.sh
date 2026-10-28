#!/usr/bin/env bash
set -euo pipefail

# Daily off-instance copy for an XO pilot instance.
# 1. Takes a fresh DB dump with `paperclipai db:backup` (the server also dumps hourly on its own).
# 2. Copies the instance files that the dump does not cover (secrets master key, company
#    storage, projects, workspaces, run logs) plus the dump directory into
#    $XO_BACKUP_DEST/<YYYY-MM-DD>/, then prunes copies older than $XO_BACKUP_KEEP_DAYS.
# The live postgres directory (db/) is never copied: a file copy of a running cluster is not
# a usable backup. Restore from the SQL dump instead (see docs/xo/pilot-checklist.md).
#
# Env:
#   XO_HOME              instance home (default: /Users/Shared/xo)
#   XO_INSTANCE_ID       instance id (default: xo-pilot)
#   XO_BACKUP_DEST       destination root (default: /Users/Shared/xo-backups)
#   XO_BACKUP_KEEP_DAYS  daily copies to keep (default: 14)
#   XO_REPO              XO checkout (default: ~/dev/xo)

XO_HOME="${XO_HOME:-/Users/Shared/xo}"
XO_INSTANCE_ID="${XO_INSTANCE_ID:-xo-pilot}"
XO_BACKUP_DEST="${XO_BACKUP_DEST:-/Users/Shared/xo-backups}"
XO_BACKUP_KEEP_DAYS="${XO_BACKUP_KEEP_DAYS:-14}"
XO_REPO="${XO_REPO:-$HOME/dev/xo}"

INSTANCE_DIR="$XO_HOME/instances/$XO_INSTANCE_ID"
DUMP_DIR="$INSTANCE_DIR/data/backups"
TARGET="$XO_BACKUP_DEST/$(date +%F)"

log() { printf '%s [xo-backup] %s\n' "$(date '+%F %T')" "$*"; }

[ -d "$INSTANCE_DIR" ] || { log "instance dir not found: $INSTANCE_DIR"; exit 1; }

log "db dump -> $DUMP_DIR"
(cd "$XO_REPO" && XO_HOME="$XO_HOME" XO_INSTANCE_ID="$XO_INSTANCE_ID" \
  pnpm --silent paperclipai db:backup --config "$INSTANCE_DIR/config.json" --dir "$DUMP_DIR")

umask 077
mkdir -p "$TARGET"
log "copy -> $TARGET"
rsync -a --delete \
  --exclude 'db/' --exclude 'runtime-services/' --exclude 'node_modules/' \
  "$INSTANCE_DIR/" "$TARGET/instance/"

log "prune copies older than $XO_BACKUP_KEEP_DAYS days"
find "$XO_BACKUP_DEST" -mindepth 1 -maxdepth 1 -type d -name '20??-??-??' \
  -mtime +"$XO_BACKUP_KEEP_DAYS" -exec rm -rf {} +

log "done ($(du -sh "$TARGET" | cut -f1))"
