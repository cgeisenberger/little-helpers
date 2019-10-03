#!/usr/bin/env bash

# Counts Barcodes in Undetermined.fastq
#
# Arguments: file (default: Undetermined_R1.fastq)
# Input: Undetermined.fastq file
# Output: undeterminedBc.txts

if [ -z "$1" ]
  then
    file="Undetermined.R1.fastq"
  else
    file=$1
fi

echo "Extract barcodes..."
cat $file | awk -F ":" '$1 ~ /@/ {print $NF}' > barcodes_temp.txt

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
