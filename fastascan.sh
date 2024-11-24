#!/bin/bash

# Arguments of the script

# X is the directory of where we are searching the fasta files in
X=$1

# N is the number of lines we want to print of it's content
N=$2

# If the argument is null, we want to set the default to the current folder
if [[ -z $X ]]; then
  X=$(pwd)
else 
  # If the argument is non-null, we want to check if the directory exists, if not, we exit the script and error out
  if [[ ! -d $X ]]; then
    echo "ERROR: This directory does not exist!"
    exit 1
  fi 
fi


# If the argument is null, we want our default value to be 0.
if [[ -z $N ]]; then
  N=0
else 
  # Make it necessary to input a non-negative integer
  if [[ $N -lt 0 ]]; then
    echo "ERROR: N must be a non-negative integer"
    exit 1
  fi
fi

# Using find, we check the directory and it's subfolders of all the fasta/fa files.
files=$(find $X -type f -name "*.fa" -or -name "*.fasta")

# 
echo === "Report information:" ===

# We want to count how many such files are there
echo "@ Fasta file count: $(ls $files | wc -l)"

# We want to check how many unique fasta IDs are contained in the files in total
# Using the space seperator on the header of the files
echo "@ Unique fasta IDs: $(awk -F" " '/>/{print $1}' $files | sort | uniq -c | wc -l)"

# Newline for clarity
echo ''

# Looping through the files found to get some report information of each.
for file in $files; do
  # Count how many titles we have (annotated at the beginning of the line ("^") with ">")
  seq_count=$(grep "^>" $file | wc -l) 
  
  # If the file doesn't have titles, skip it
  if [[ $seq_count -gt 0 ]]; then  
    # Check if the file exists
    if [[ ! -e $file ]]; then
      echo "ERROR: This $file does not exist!"
      continue
    fi
    
    # Header for our file
    echo === $file === 
    
    # Check if the file is a symbolic link
    if [[ -h $file ]]; then
      if [[ ! -e $file ]]; then
        echo "ERROR: This is a broken symbol link. Skipping..."
        continue
      fi
      echo "- File type: Symbolic link"
    fi
    
    # Check how many sequences we have counted inside the file
    echo "- Sequence count: $seq_count" 
    
    # We are getting all the sequences of the file without the titles, removing the gaps, spaces and newlines(?)
    # I don't think we need the \n, as awk already deals with it
    sequences=$(awk '!/^>/{gsub("-", "",$0); gsub(" ", "", $0); gsub("\n", "", $0); print $0}' $file) 
    
    # We print the length of characters of all sequences in our file
    echo "- Total length of sequence(s): $(echo $sequences | wc -c)" 
    
    # Looping through each individual sequence in the file
    # TODO - No for loop if we are only checking the first sequence
    for sequence in $sequences; do 
      # There are files that have non capital letters, aka atgc
      # Adding U for RNA sequences. Adding N for unknown letters
      is_nucleotide=$(echo $sequence | grep -qvi '[^ATGCNU]' && echo true || echo false)
      is_amino_acid=$(echo $sequence | grep -qvi '[^ARNDCQEGHILKMFPSTWYV]' && echo true || echo false)

      if [[ $is_nucleotide == true ]]; then
        echo "- Sequence type: Nucleotide"
        break
      elif [[ $is_amino_acid == true ]]; then
        echo "- Sequence type: Aminoacid"
      else
        echo "- Sequence type: Invalid"
      fi
      break
    done
    
    # Here we check if the file is empty or not to print out the N number of lines to print
    line_count=$(wc -l $file | awk '{print $1}')
    
    if [[ $N -ne 0 ]]; then
      if [[ -z $line_count ]]; then
        echo "File is empty"
      elif [[ $line_count -le 2*$N ]]; then # If the file is less than 2*N, we just print all the file
        echo "- Displaying full content:"
        cat $file
      else # Print the file using N in head and tail with ... in between
        echo "- Displaying First/Last $N lines:"
        head -n $N $file
        echo "..."
        tail -n $N $file
      fi
    fi
    
  fi
done
