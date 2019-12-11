# Contents

* [Download from Data Repositories](#data-download)
* [Samtools Magic](#samtools-magic)
* [Data Analysis](#data-analysis)
* [Raw Sequencing Data](#raw-sequencing-data)
* [SGE cluster](#sge-cluster)
* [Analyzing 10x scRNA-Seq Data](#10x-genomics-data-analysis)
* [Miscellaneous](#miscellaneous)


# Data Download

look [here](./download-data.md)


# Samtools Magic

```bash
# sample first 1000 reads from BAM 
samtools view -h in.bam | head -n 1000 | samtools view -bS - > out.bam

# subsample fraction f from BAM file (takes longer than sampling first n reads)
samtools view -s f -b in.bam > out.sam

# SAM to BAM conversion
samtools view -S -b in.sam > out.bam
```


# Data Analysis

Extract count table and library statistics for multiple experiments

```bash
# navigate to root directory
mkdir data-tables lib-plots lib-stats

# copy plots
for d in CG*; do mkdir ./lib-plots/$d; cp $d/plots/* ./lib-plots/$d; done

# copy library stats
find CG*/tables -type f -name *.csv -exec cp {} lib-stats/ \;

# copy data tables
for d in CG*; do cp $d/count_table.csv ./data-tables/${d}.csv; done
```


# Raw Sequencing Data

## Count reads in raw data

```bash
for f in *R1*fastq.gz; do i=$(zcat $f | wc -l);echo $f $i >> counts.txt; done
```

## Demultiplex Undetermined.fastq.gz files

RPI barcodes can be found [here](./files/rpix.csv).  
Code for [ud-count.sh](./scripts/ud-count.sh) and [ud-demux.sh](./scripts/ud-demux.sh)

```bash
# Find and concatenate input files
find $PWD -type f -name "Und*R1*fastq.gz" | xargs zcat > Undetermined.R1.fastq
find $PWD -type f -name "Und*R2*fastq.gz" | xargs zcat > Undetermined.R2.fastq

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
# qsub -wd flag needs absolute path!
for d in CG*; do qsub -wd $PWD/$d script.sh; done
```

# 10x Genomics Data Analysis

look [here](./analyse-10x-data.md)


# Miscellaneous 

## Find and copy files

```bash
find dir1 -type f -name "PATTERN*" -exec cp {} dir2 \;
```
