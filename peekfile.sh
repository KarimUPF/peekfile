#!/bin/bash
file=$1
lines=$2

head -n "$lines" "$file"
echo "..."
tail -n "$lines" "$file"
