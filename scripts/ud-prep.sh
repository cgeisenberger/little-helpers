# Finds "Undetermined" files from Illumina sequencing run
# in dir supplied as command line argument or PWD (default)
# Concatenates files and saves them in working directory
# ud-count.sh and ud-demux.sh can be used to assess and 
# extract reads, respectively

if [ -z "$1" ]
  then
    dir=$PWD
  else
    dir=$1
fi

echo "Find files..."
files1=$(find $dir -type f -name Undetermined*R1*fastq.gz)
files2=$(find $dir -type f -name Undetermined*R2*fastq.gz)

echo "Concatenate files..."
zcat $files1 > Undetermined.R1.fastq
zcat $files2 > Undetermined.R2.fastq

echo "Zip files..."
gzip Undetermined.R1.fastq
gzip Undetermined.R2.fastq
