X=$1
N=$2

if [[ -z $X ]]; then
  X=$(pwd)
fi

if [[ -z $N ]]; then
  N=0
fi

files=$(find $X -type f -name "*.fa" -or -name "*.fasta")
echo "Fasta file count: $(ls $files | wc -l)"  

for file in $files; do
  seq_count=$(grep ">" $file | wc -l) # Count how many titles we have
  if [[ $seq_count -gt 0 ]]; then # If the file doesn't have titles, skip it
    echo === $(basename $file) === # Header with the file name, maybe just use $file if we use find
    echo "Sequence count: $seq_count" # Echo of how many sequences we have counted
    # We are getting all the sequences of the file without the titles, removing the gaps, spaces and newlines(?)
    # I don't think we need the \n, as awk already deals with it
    sequences=$(awk '!/>/{gsub("-", "",$0); gsub(" ", "", $0); gsub("\n", "", $0); print $0}' $file) 
    echo "Total length of sequences: $(echo $sequences | wc -c)" # We print the length of characters of all sequences in our file
    for sequence in $sequences; do # Looping through each individual sequence in the file
      is_nuc=true # Boolean to check if the sequence is a nucleotide or amino acid
      for char in $(echo $sequence | grep -o .); do # Looping through each character
        if [[ $char != [ATGC] ]]; then # If the character isn't part of this array (for nucleotides), we set the boolean to false 
          is_nuc=false # Setting the boolean to false
          break # Breaking of the for loop, as we won't need to check all the other characters
        fi
      done
      echo "Is this sequence a nucelotide?: $is_nuc" # We print if the sequence is a nucleotide or not
      break # TODO - Remove this as we are only doing the first sequence of each file for testing reason
    done
    line_count=$(wc -l < $file) # Here we check if the file is empty or not to print out the N number of lines to print
    if [[ -z $line_count ]]; then # TODO - I don't think we need this because of our file not having titles being skipped
      echo "File is empty"
    elif [[ $line_count -le 2*$N ]]; then # If the file is less than 2*N, we just print all the file
      cat $file
    else # Print the file using N in head and tail with ... in between
      head -n $N $file
      echo "..."
      tail -n $N $file
    fi
  fi
done
