#!/bin/bash
#
# %title%
# %description%
# 
# Author:   Paul R. Staab 
# Email:    staab (at) bio.lmu.de
# Date:     2014-04-29
# Licence:  GPLv3 or later
#

btrfs_root=/media/btrfs
volume=root
snapshot_dir=snapshots

cd $btrfs_root

# Ensure we have root rights
if [[ $EUID -ne 0 ]]; then
  sudo echo blub > /dev/null
fi

# Ensure the subvolmune to backup exists
if [ ! -d $volume ]; then
  echo "$volume not found; trying to mount $btrfs_root"
  sudo mount $btrfs_root || (echo Failed to mount $btrfs_root; exit 1)
fi

# Numerate snapshots for each day
i=1
while [ -d "$snapshot_dir/$volume-`date +%Y%m%d`-$i" ]; do
  ((i++))
done

# Create snapshot
sudo btrfs subvolume snapshot "$volume" "$snapshot_dir/$volume-`date +%Y%m%d`-$i"

sync
