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
  echo === $(basename $file) ===
  grep ">" $file | wc -l 
  awk '!/>/{gsub("-", "",$0); gsub(" ", "", $0); gsub("\\n", "", $0); print $0}' $file | wc -c 
  
done
