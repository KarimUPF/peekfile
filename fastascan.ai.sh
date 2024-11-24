#!/bin/bash

# Arguments:
# X = Directory containing fasta files
# N = Number of lines to print from file contents

X=${1:-$(pwd)}  # Default to current directory if not provided
N=${2:-0}       # Default to 0 if not provided

# Validate directory
if [[ ! -d $X ]]; then
  echo "ERROR: Directory '$X' does not exist!"
  exit 1
fi

# Validate N
if [[ $N -lt 0 ]]; then
  echo "ERROR: N must be a non-negative integer!"
  exit 1
fi

# Find all .fa or .fasta files in the directory (including subdirectories)
files=$(find "$X" -type f \( -name "*.fa" -o -name "*.fasta" \))

# Header for report
echo "=== Report Information ==="

# Count and list fasta files
file_count=$(echo "$files" | wc -l)
echo "@ Fasta file count: $file_count"

# Count unique fasta IDs
unique_ids=$(awk -F" " '/^>/{print $1}' $files 2>/dev/null | sort -u | wc -l)
echo "@ Unique fasta IDs: $unique_ids"
echo ""

# Loop through files for detailed information
for file in $files; do
  if [[ ! -e $file ]]; then
    echo "ERROR: File '$file' does not exist!"
    continue
  fi

  # File header
  echo "=== File: $file ==="

  # Check if file is a symbolic link
  if [[ -h $file ]]; then
    if [[ ! -e $file ]]; then
      echo "- File type: Broken symbolic link. Skipping..."
      continue
    fi
    echo "- File type: Symbolic link"
  fi

  # Sequence count
  seq_count=$(grep -c "^>" "$file")
  if [[ $seq_count -eq 0 ]]; then
    echo "- No sequences found in the file. Skipping..."
    continue
  fi
  echo "- Sequence count: $seq_count"

  # Total sequence length (ignoring gaps and spaces)
  total_length=$(awk '!/^>/{gsub(/[ \n-]/, "", $0); print}' "$file" | wc -c)
  echo "- Total length of sequences: $total_length"

  # Sequence type (Nucleotide, Amino Acid, or Invalid)
  first_sequence=$(awk '!/^>/{gsub(/[ \n-]/, "", $0); print; exit}' "$file")
  if [[ $first_sequence =~ ^[ATGCNUatgcnu]*$ ]]; then
    echo "- Sequence type: Nucleotide"
  elif [[ $first_sequence =~ ^[ARNDCQEGHILKMFPSTWYVarncdqegkhilkmfpstwyv]*$ ]]; then
    echo "- Sequence type: Amino Acid"
  else
    echo "- Sequence type: Invalid"
  fi

  # Display first/last N lines if N > 0
  if [[ $N -gt 0 ]]; then
    line_count=$(wc -l < "$file")
    if [[ $line_count -le $((2 * N)) ]]; then
      echo "- Displaying full content:"
      cat "$file"
    else
      echo "- Displaying first/last $N lines:"
      head -n "$N" "$file"
      echo "..."
      tail -n "$N" "$file"
    fi
  fi

  echo ""
done

