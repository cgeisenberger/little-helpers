# Contents

* [Data Analysis](#data-analysis)
* [Raw Sequencing Data](#raw-sequencing-data)
* [SGE cluster](#sge-cluster)


# Data Analysis

# Raw Sequencing Data

## Demultiplex Undetermined.fastq.gz files

RPI barcodes can be found [here](./files/rpix.csv).  
Code for [ud-count.sh](./scripts/ud-count.sh) and [ud-demux.sh](./scripts/ud-demux.sh)

```bash
# Find and concatenate input files
find $PWD -type f -name Und*R1*fastq.gz | xargs zcat > Undetermined.R1.fastq
find $PWD -type f -name Und*R2*fastq.gz | xargs zcat > Undetermined.R2.fastq

# Count barcodes (ouputs undeterminedBc.txt)
ud-count.sh Undetermined.R1.fastq

# Extract data
ud-demux.sh Barcode1 Barcode2
```

# SGE cluster

## Generic qsub header

```bash
#! /bin/bash
#$ -V
#$ -cwd
#$ -l h_rt=1:00:00
#$ -l h_vmem=10G
```

## Execute script in multiple subdirectories

```bash
for d in $(find $PWD/PATTERN* -type d); do qsub -wd $d script.sh; done
```
