# 10x Genomics Data Analysis


## Obtaining sequencing data

In addition to their scRNA-Seq platform, 10x Genomics has published its own suite of analysis tools which consist mainly of the **cellranger** software and some additional tools. Cellranger is capable of performing the full workflow from raw data produced by Illumina sequencers to count matrices (plus some additional steps for visualization etc.). Consider looking into the documentation [here](https://support.10xgenomics.com/single-cell-gene-expression/software/overview/welcome). 

However, a number of different data formats may be encountered if downloading data from public repositories such as the sequencing read archive (SRA) or the European Nucleotide Archive (ENA). More information [here](https://github.com/cgeisenberger/little-helpers/blob/master/download-data.md).

The main data types are: 

* BCL files
  - raw sequencing output
  - need to be demultiplexed with Illuminas `bcl2fastq` or `cellranger mkfastq`
* Fastq files
  - most published data
  - can be processed with `cellranger count`
* BAM files
  - sometimes uploaded instead of fastq files
  - cellranger cannot extract count matrices from BAM files directly
  - files need to be converted to fastq first via [bamtofastq](https://github.com/10XGenomics/bamtofastq)
  - NB: **make sure to supply cellranger version used to create BAM files if you use bamtofastq**
* Count matrices
  - Can be further analyzed with dedicated software such as [Seurat](https://satijalab.org/seurat/) or [Scanpy](https://scanpy.readthedocs.io/en/stable/#)
  - If multiple datasets need to be merged, it may be useful to obtain raw data and re-process


## Filename conventions

* fastq files need to adhere to a filename pattern for cellranger to work correctly
* example: `sample-xyz_S1_L000_R1_001.fastq.gz`

> NB: The sample name (sample-xyz) must **not** contain underscores!


## Directory Organization

A coherent folder structure facilites data analysis later on because the same script can be re-used for qsub submissions. The following directory tree is a suggestion, and the scripts later on are tailored to work within this structure. 

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

Copy the contents above into the script `run-cellranger.sh`. Run the following command to start one job per dataset:

```bash
for d in study*/ds*; do qsub -wd $PWD/$d run-cellranger.sh; done
```

## Merge multiple datasets

[Dave Tang: Merging datasets](https://davetang.org/muse/2018/01/24/merging-two-10x-single-cell-datasets/)  
[Dave Tang: Seurat Intro](https://davetang.org/muse/2017/08/01/getting-started-seurat/)

