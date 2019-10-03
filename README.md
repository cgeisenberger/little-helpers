# Sequencing Data

Demultiplex Undetermined.fastq.gz files (see [barcodes](./files/rpix.csv)

```bash
# Find and concatenate input files
find $PWD -type f -name Und*R1*fastq.gz | xargs zcat > Undetermined.R1.fastq
find $PWD -type f -name Und*R2*fastq.gz | xargs zcat > Undetermined.R1.fastq

# Count barcodes (ouputs undeterminedBc.txt)
ud-count.sh Undetermined.R1.fastq

# Extract data
ud-demux.sh Barcode1 Barcode2

```

# SGE cluster / qsub

Execute script in multiple subdirectories

```bash
for d in $(find $PWD/PATTERN* -type d); do qsub -wd $d script.sh; done
```
