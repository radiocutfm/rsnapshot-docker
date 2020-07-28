FROM alpine

MAINTAINER Helmuth Breitenfellner <helmuth@breitenfellner.at>

VOLUME /backup
VOLUME /data

ENV BACKUP_NAME=localhost
ENV BACKUP_SOURCE=/data
ENV BACKUP_OPTS=one_fs=1
ENV BACKUP_SYNC_FIRST=1
ENV BACKUP_HOURLY=0
ENV BACKUP_DAILY=3
ENV BACKUP_WEEKLY=3
ENV BACKUP_MONTHLY=3
ENV BACKUP_YEARLY=3
ENV CRON_HOURLY="0 * * * *"
ENV CRON_DAILY="30 05 * * *"
ENV CRON_WEEKLY="0 03 * * 0"
ENV CRON_MONTHLY="30 03 1 * *"
ENV CRON_YEARLY="0 04 1 1 *"

RUN touch /ssh-id && touch /backup.cfg

RUN apk add --update rsnapshot tzdata curl

ADD entry.sh /entry.sh
ADD metrics.sh /metrics.sh

CMD ["/bin/sh", "/entry.sh"]
