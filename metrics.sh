#!/bin/sh

set -eu

METRICS_FILE=/tmp/metrics
PUSHGATEWAY_URL=${PUSHGATEWAY_URL:-}

echo '# TYPE rsnapshot_last_backup_time GAUGE' > "$METRICS_FILE"

for backup_level in hourly daily weekly monthly yearly; do
    if [ -d "/backup/${backup_level}.0" ]; then
        backup_ts=$(stat -c '%Y' "/backup/${backup_level}.0")
    else
        backup_ts=0
    fi

    cat <<EOF >> "$METRICS_FILE"
rsnapshot_last_backup_time{backup="$BACKUP_NAME", level="$backup_level"} $backup_ts
EOF
done

if [ -n "$PUSHGATEWAY_URL" ]; then
    curl -sS --data-binary @$METRICS_FILE "$PUSHGATEWAY_URL/metrics/job/rsnapshot/backup/$BACKUP_NAME"
else
    cat "$METRICS_FILE" | logger
fi
