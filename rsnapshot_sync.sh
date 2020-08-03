#!/bin/sh

# Wraps rsnapshot sync command to ignore warnings (exit code 2) as set in env

rsnapshot sync "$@"

RETURN_CODE=$?

if [ $RETURN_CODE -eq 0 ]; then
    exit 0
fi

if [ $BACKUP_SYNC_IGNORE_WARNINGS -eq 1 ] && [ $RETURN_CODE -eq 2 ]; then
    echo "Ignoring rsnapshot sync warnings" | logger
    exit 0
fi

exit $RETURN_CODE
