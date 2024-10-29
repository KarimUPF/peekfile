#!/bin/bash
file=$1
lines=$2

if [[ -z $lines ]]; then
  lines=3
fi

if [[ $(wc -l < $file) -le 2*$lines ]]; then
  cat $file
else
  head -n "$lines" "$file"
  echo "..."
  tail -n "$lines" "$file"
fi
