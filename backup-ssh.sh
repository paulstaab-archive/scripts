#!/bin/bash
# --------------------------------------------
# Creates a GPG encrypted backup of ~/.ssh
# 
# Author:   Paul R. Staab 
# Email:    staab (at) bio.lmu.de
# Licence:  MIT
# --------------------------------------------

# Usage
# ./backup-ssh.sh <pgp-key> <backup_path>
# e.g.
# ./backup-ssh.sh 08300842 ~/Backup/

cd ~/
target="$2/`cat /etc/hostname`.tar.gz.gpg"
tar -zcf - -C . .ssh | gpg -e -r "$1" -o "$target.tmp" && mv "$target.tmp" "$target"
