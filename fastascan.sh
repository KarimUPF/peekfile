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
    echo "This directory does not exist!"
    exit 1
  fi 
fi


# If the argument is null, we want our default value to be 0.
if [[ -z $N ]]; then
  N=0
else 
  # TODO - Comment
  if [[ $N -lt 0 ]]; then
    # TODO
  fi
fi

# Using find, we check the directory and it's subfolders of all the fasta/fa files.
files=$(find $X -type f -name "*.fa" -or -name "*.fasta")

# We want to count how many such files are there
echo "Fasta file count: $(ls $files | wc -l)"

# We want to check how many unique fasta IDs are contained in the files in total
# Using the space seperator on the header of the files
echo "Unique fasta IDs: $(awk -F" " '/>/{print $1}' $files | sort | uniq -c | wc -l)"

# echo "All fasta IDs: $(awk -F" " '/>/{print $1}' $files | wc -l)" TODO - Used for testing

# Looping through the files found to get some report information of each.
for file in $files; do
  # Count how many titles we have (annotated at the beginning of the line ("^") with ">")
  seq_count=$(grep "^>" $file | wc -l) 
  
  # If the file doesn't have titles, skip it
  if [[ $seq_count -gt 0 ]]; then  
    # Check if the file exists
    if [[ ! -e $file ]]; then
      echo "This file does not exist!"
      continue
    fi
    
    # Header with the file name, maybe just use $file if we use find TODO
    echo === $(basename $file) === 
    
    # Check if the file is a symbolic link
    if [[ -h $file ]]; then
      echo "This file is a symbolic link"
    fi
    
    # Check how many sequences we have counted inside the file
    echo "Sequence count: $seq_count" 
    
    # We are getting all the sequences of the file without the titles, removing the gaps, spaces and newlines(?)
    # I don't think we need the \n, as awk already deals with it
    sequences=$(awk '!/>/{gsub("-", "",$0); gsub(" ", "", $0); gsub("\n", "", $0); print $0}' $file) 
    
    # We print the length of characters of all sequences in our file
    echo "Total length of sequences: $(echo $sequences | wc -c)" 
    
    # Looping through each individual sequence in the file
    for sequence in $sequences; do 
      # TODO - There are files that have non capital letters, aka atgc || TODO -i to ignore case
      is_nuc=$(echo "$sequence" | grep -qvi '[^ATGCU]' && echo true || echo false) # TODO - Adding U for RNA sequences
      is_aa=$(echo "$sequence" | grep -qvi '[^ARNDCQEGHILKMFPSTWYV]' && echo true || echo false)
      
      $is_nuc && echo "This sequence is a nucelotide" # We print if the sequence is a nucleotide
      $is_nuc || ($is_aa && echo "This sequence is a aminoacid") # We print if the sequence is a aminoacid
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
