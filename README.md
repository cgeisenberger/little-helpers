# Sequencing Data

Get barcode counts from Undetermined.fastq.gz files

```bash
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

echo "Extract barcodes..."
zcat Undetermined.R1.fastq | awk -F ":" '$1 ~ /@/ {print $NF}' > barcodes_temp.txt

echo "Count barcodes..."
sort barcodes_temp.txt | uniq -c > barcodes.txt
rm barcodes_temp.txt
```

# SGE cluster / qsub

Execute script in multiple subdirectories

```bash
for d in $(find $PWD/PATTERN* -type d); do qsub -wd $d script.sh; done
```
