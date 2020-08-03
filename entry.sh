#! /bin/sh

# Entry point for rsnapshot backup
# This will create the config file (using environment variables),
# a crontab, and start cron

# First part of rsnapshot config
cat > /etc/rsnapshot.conf <<EOF
config_version	1.2
snapshot_root	/backup/
no_create_root	1
cmd_postexec	/metrics.sh
cmd_cp		/bin/cp
cmd_rm		/bin/rm
cmd_rsync	/usr/bin/rsync
cmd_ssh		/usr/bin/ssh
cmd_logger	/usr/bin/logger
one_fs	1
ssh_args	-i /ssh-id -o StrictHostKeychecking=no ${BACKUP_SSH_ARGS}
verbose		1
lockfile	/var/run/rsnapshot.pid
sync_first	${BACKUP_SYNC_FIRST}
backup		${BACKUP_SOURCE}	${BACKUP_NAME}/	${BACKUP_OPTS}
EOF

# prepare crontab for root
echo "${CRON_HOURLY} /metrics.sh" > /etc/crontabs/root

RSNAPSHOT_SYNC_COMMAND=""
if [ "${BACKUP_SYNC_FIRST}" -eq 1 ]; then
  RSNAPSHOT_SYNC_COMMAND="/rsnapshot_sync.sh &&"
fi


# Dynamic parts - depending on the retain settings
# This will also create the crontab
if [ "${BACKUP_HOURLY}" -gt 0 ]
then
  echo "retain	hourly	${BACKUP_HOURLY}">> /etc/rsnapshot.conf
  echo "${CRON_HOURLY} $RSNAPSHOT_SYNC_COMMAND rsnapshot hourly" >> /etc/crontabs/root
  RSNAPSHOT_SYNC_COMMAND=""
fi
if [ "${BACKUP_DAILY}" -gt 0 ]
then
  echo "retain	daily	${BACKUP_DAILY}">> /etc/rsnapshot.conf
  echo "${CRON_DAILY} $RSNAPSHOT_SYNC_COMMAND rsnapshot daily" >> /etc/crontabs/root
  RSNAPSHOT_SYNC_COMMAND=""
fi
if [ "${BACKUP_WEEKLY}" -gt 0 ]
then
  echo "retain	weekly	${BACKUP_WEEKLY}">> /etc/rsnapshot.conf
  echo "${CRON_WEEKLY} $RSNAPSHOT_SYNC_COMMAND rsnapshot weekly" >> /etc/crontabs/root
  RSNAPSHOT_SYNC_COMMAND=""
fi
if [ "${BACKUP_MONTHLY}" -gt 0 ]
then
  echo "retain	monthly	${BACKUP_MONTHLY}">> /etc/rsnapshot.conf
  echo "${CRON_MONTHLY} $RSNAPSHOT_SYNC_COMMAND rsnapshot monthly" >> /etc/crontabs/root
  RSNAPSHOT_SYNC_COMMAND=""
fi
if [ "${BACKUP_YEARLY}" -gt 0 ]
then
  echo "retain	yearly	${BACKUP_YEARLY}">> /etc/rsnapshot.conf
  echo "${CRON_YEARLY} $RSNAPSHOT_SYNC_COMMAND rsnapshot yearly" >> /etc/crontabs/root
  RSNAPSHOT_SYNC_COMMAND=""
fi

# Add the user-provided config file
cat /backup.cfg >> /etc/rsnapshot.conf

# Connect syslog to container log
busybox syslogd -S -O /proc/1/fd/1

# start cron - we should be done!
/usr/sbin/crond -f
