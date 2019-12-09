# 10x Genomics Data Analysis

This assumes the input is fastq files downloaded from a sequencing archive. Check 10x Genomics [documentation](https://support.10xgenomics.com/single-cell-gene-expression/software/overview/welcome) on how to create fastq files from Illumina sequencer output.

## Some Basics

* You cannot extract count matrices from BAM files
  - convert to fastq first with [bam2fastq](https://github.com/10XGenomics/bamtofastq)
  - **supply correct cellranger version to the command line tool**
* cellranger input files require naming pattern
  - example: ```sample_S1_L000_R1_001.fastq.gz```
  * do **not** use underscores for *sample*

## Directory Organization

If you want to process multiple fastqs in parallel, save yourself some trouble and set up the folder structure like in the following schematic. This will allow you to re-use the same script without having to adjust any parameters.
  
```
├── study-A
|   ├── ds-1-name
|       ├── fastq
|           ├── input_S1_L000_R1_001.fastq.gz
|           ├── input_S1_L000_R2_001.fastq.gz
|   └── ds-2-name
|       ├── fastq
|           ├── input_S1_L000_R1_001.fastq.gz
|           ├── input_S1_L000_R2_001.fastq.gz
|   └── ds-3-name
|       ├── fastq
|           ├── input_S1_L000_R1_001.fastq.gz
|           ├── input_S1_L000_R2_001.fastq.gz
├── study-B
|   ├── ds-1-name
|       ├── fastq
|           ├── input_S1_L000_R1_001.fastq.gz
|           ├── input_S1_L000_R2_001.fastq.gz
|   └── ds-3-name
|       ├── _fastq
|           ├── input_S1_L000_R1_001.fastq.gz
|           ├── input_S1_L000_R2_001.fastq.gz
```

## Run cellranger

```bash
#! /bin/bash
#$ -V
#$ -cwd
#$ -l h_rt=48:00:00
#$ -l h_vmem=120G
#$ -pe threaded 8

#ref="/hpc/hub_oudenaarden/fblokzijl/data/cellranger/refdata-cellranger-GRCh38-3.0.0"
ref="/hpc/hub_oudenaarden/cgeisenberger/genomes/refdata-cellranger-GRCh38-and-mm10-3.1.0/"

cellranger count --localcores=8 --id=output --transcriptome=$ref --fastqs="./fastq" --sample=input
```

Copy the above script into ```run-cellranger.sh``` (or whatever). Copy the script into the study folders and run for all data sets like this:

```bash
for d in ds*; do qsub -wd $PWD/$d run-cellranger.sh; done
```

## Merge multiple datasets

[Dave Tang: Merging datasets](https://davetang.org/muse/2018/01/24/merging-two-10x-single-cell-datasets/)
[Dave Tang: Seurat Intro](https://davetang.org/muse/2017/08/01/getting-started-seurat/)

