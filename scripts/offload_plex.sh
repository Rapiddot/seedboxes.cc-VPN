#!/bin/bash
# RClone Config file
RCLONE_CONFIG=/home/user/.apps/plex/.config/rclone/rclone.conf
export RCLONE_CONFIG
LOCKFILE="/var/lock/`basename $0`"

touch /home/user/.apps/plex/.config/rclone/upload_excludes

(
  # Wait for lock for 5 seconds
  flock -x -w 5 200 || exit 1

# Move older local files to the cloud
/usr/bin/rclone move /home/user/files/Plex/ plex-gdrive:Plex/ -P --checkers 3 --log-file /home/user/.apps/plex/.config/rclone/upload_rclone.log -v --tpslimit 3 --transfers 3 --drive-chunk-size 32M --exclude-from /home/user/.apps/plex/.config/rclone/upload_excludes --delete-empty-src-dirs
mkdir -p /home/user/files/Plex/TV /home/user/files/Plex/Movies /home/user/files/Plex/Music
) 200> ${LOCKFILE}