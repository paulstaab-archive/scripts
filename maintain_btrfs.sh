#!/bin/bash
#
# %title%
# %description%
# 
# Author:   Paul R. Staab 
# Email:    staab (at) bio.lmu.de
# Date:     2014-06-16
# Licence:  GPLv3 or later
#


echo "Checking File Integrity..."
btrfs scrub start -B /

echo "Defragmenting Filesystem..."
btrfs filesystem defragment -r /

echo "Balacing Filesystem..."
btrfs balance start /
