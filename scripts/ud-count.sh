#!/usr/bin/env bash

# Finds and concatenates "Undetermined" files from sequencing run
# Input: Directory to search (DEFAULT: pwd)
# Output:
#   undeterminedBc.txt: Barcode counts in Undetermined files
#   Undetermined.R{1,2}.fastq: for further processing (demultiplexing)

# scan directory, defaults to $PWD if none supplied

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

echo "Extract barcodes..."
cat Undetermined.R1.fastq | awk -F ":" '$1 ~ /@/ {print $NF}' > barcodes_temp.txt

echo "Sort barcodes..."
sort barcodes_temp.txt | uniq -c > bc-counts-temp.txt
rm barcodes_temp.txt

echo "Count barcodes..."

# Write R file for analysis (deleted afterwards)
cat > ./count.R <<'DELIM'
fr <- "/hpc/hub_oudenaarden/cgeisenberger/barcodes/rpix.csv"
fu <- "./bc-counts-temp.txt"

rpix <- read.csv(fr)

dat <- read.table(fu, header = F)
colnames(dat) <- c("counts", "barcode")
dat <- dat[, c(2, 1)]

counts <- dat$counts[match(rpix$seq, dat$barcode)]
counts[is.na(counts)] <- 0

rpix = cbind(rpix, counts)
write.table(rpix, file = "./undeterminedBc.txt", quote = FALSE, row.names = F, sep = "\t")
DELIM

# Output table, delete files
Rscript count.R
rm count.R
rm bc-counts-temp.txt

echo "Done!"
