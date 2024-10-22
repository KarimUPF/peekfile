#!/bin/bash
file=$1
head -n 3 "$file"
echo "..."
tail -n 3 "$file"
