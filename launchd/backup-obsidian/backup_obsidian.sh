#!/bin/bash

SOURCE="/Users/prometheus/Documents/obsidian/Mind"
DESTINATION="sean@memorylane:/var/services/homes/sean/Documents/Obsidian/Backup/$(date +%Y%m%dT%H%M%S)"
RSYNC_FLAGS="--stats --progress -avh"

if [[ $1 == "--dry-run" ]]; then
    RSYNC_FLAGS+="n" # Append 'n' to flags for a dry run
    echo "Performing a dry run..."
else
    echo "Performing real backup..."
fi

rsync $RSYNC_FLAGS "$SOURCE" "$DESTINATION"

echo "Backup completed."