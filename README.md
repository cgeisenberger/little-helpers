# Sequencing Data

Get barcode counts from Undetermined.fastq.gz files

```bash

# Find and concatenate Undetermined files
ud-prep.sh $PWD

# Extract and count barcodes (saved as bc-counts.txt)
echo "Extract barcodes..."
zcat Undetermined.R1.fastq | awk -F ":" '$1 ~ /@/ {print $NF}' > barcodes_temp.txt

echo "Count barcodes..."
sort barcodes_temp.txt | uniq -c > bc-counts.txt
rm barcodes_temp.txt
```

# SGE cluster / qsub

Execute script in multiple subdirectories

```bash
for d in $(find $PWD/PATTERN* -type d); do qsub -wd $d script.sh; done
```
