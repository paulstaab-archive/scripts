#!/bin/bash
#

tmpdir=`mktemp -d`
bucket="$1"

function error_exit {
  echo "Error: $1."
  rm -r "$tmpdir"
  exit 1
}

function backup_folder {
  event=${PWD##*/}
  echo "Uploading: $event"
  if [ ! "$(ls -A .)" ]; then
    echo "Warning: Directory is empty."
    continue
  fi

  archive="$tmpdir"/"$event".tar.gz

  tar -zcf "$archive" * || error_exit "Failed to create archive"
  gpg -r Backup -e "$archive" || error_exit "Encryption failed"
  s3cmd put --multipart-chunk-size-mb=1024 "$archive.gpg" "$bucket/$yname/" || error_exit "Upload failed"
  rm "$archive" "$archive.gpg"
  find . -type f -not -name '.*' -print0 | xargs -0 sha256sum > .s3backup.sha256
}

for year in ~/Pictures/*; do
  [[ -d $year ]] || continue
  yname=${year##*/}
  for event in "$year"/*; do
    [[ -d $event ]] || continue
    cd "$event"
    
    [ -f .s3backup.sha256 ] || backup_folder
    [ "$(find . -type f -not -name '.*' | grep -c ^)" == "$(grep -c ^ .s3backup.sha256)" ] || backup_folder
    sha256sum -c .s3backup.sha256 > /dev/null || backup_folder
  done
done

rm -r "$tmpdir"
