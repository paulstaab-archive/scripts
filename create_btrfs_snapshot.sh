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
sudo btrfs subvolume snapshot "$volume" "$snapshot_dir/$volume-`date +%Y%m%d`"
