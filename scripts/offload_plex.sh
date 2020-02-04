#!/bin/bash
# RClone Config file
RCLONE_CONFIG=/home/user/.apps/plex/.config/rclone/rclone.conf
export RCLONE_CONFIG

# Lockfile
LOCKFILE="/var/lock/`basename $0`"

# Plex path and subfolders
PLEX_PATH="/home/user/files/Plex"
PLEX_SUBFOLDERS="*/"

# Rclone arguments
ARGS=(-P --checkers 3 --log-file /home/user/.apps/plex/.config/rclone/upload_rclone.log -v --tpslimit 3 --transfers 3 --drive-chunk-size 32M --exclude-from /home/user/.apps/plex/.config/rclone/upload_excludes --delete-empty-src-dirs --user-agent="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/60.0.3112.113 Safari/537.36")

# Create exclusion file
touch /home/user/.apps/plex/.config/rclone/upload_excludes


(
  # Wait for lock for 5 seconds
  flock -x -w 5 200 || exit 1

# Change path
cd $PLEX_PATH;

# Move older local files to the cloud
for folder in $PLEX_SUBFOLDERS
do
  # Check if user has implemented Plex to an encrypted Google drive location and offload content
  if grep -q plex-crypt $RCLONE_CONFIG; then
  rclone move "/home/user/files/Plex/$folder/" "plex-crypt:Plex/$folder" "${ARGS[@]}"
  else
  # Offload to unencrypted Plex inside Google drive
  rclone move "/home/user/files/Plex/$folder/" "plex-gdrive:Plex/$folder" "${ARGS[@]}"
  fi
done

) 200> ${LOCKFILE}
