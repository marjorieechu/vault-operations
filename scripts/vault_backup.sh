#!/bin/bash

set -euo pipefail

# Configuration
BACKUP_DIR="./vault_backups"  # Use /opt/vault/backups for production
TIMESTAMP=$(date +"%Y-%m-%d-%H-%M")
BACKUP_PATH="${BACKUP_DIR}/vault-backup-${TIMESTAMP}"
LOGFILE="./vault-backup.log"  # Change to /var/log/vault-backup.log for prod

# Create backup directory
mkdir -p "$BACKUP_PATH"
chmod 700 "$BACKUP_PATH"

# Detect storage type
storage_type=$(vault status -format=json | jq -r '.storage_type')
if [[ "$storage_type" != "file" ]]; then
    echo "❌ Backup skipped: Vault is not using file storage (detected: $storage_type)"
    exit 0
fi

# Perform file-based backup using rsync
echo "📦 Starting file-based Vault backup..."
if rsync -a --delete "$VAULT_DATA_DIR/" "$BACKUP_PATH/"; then
    echo "$(date) - SUCCESS - Vault file backup saved to $BACKUP_PATH" >> "$LOGFILE"
else
    echo "$(date) - ERROR - Vault file backup failed" >> "$LOGFILE"
    exit 1
fi
