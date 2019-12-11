# 10x Genomics Data Analysis


## Obtaining sequencing data

In addition to their scRNA-Seq platform, 10x Genomics has published its own suite of analysis tools which consist mainly of the **cellranger** software and some additional tools. Cellranger is capable of performing the full workflow from raw data produced by Illumina sequencers to count matrices (plus some additional steps for visualization etc.). Consider looking into the documentation [here](https://support.10xgenomics.com/single-cell-gene-expression/software/overview/welcome). 

However, a number of different data formats may be encountered if downloading data from public repositories such as the sequencing read archive (SRA) or the European Nucleotide Archive (ENA). More information on how to download data can be found [here](./download-data.md).

The main data types are: 

* BCL files
  - raw sequencing output
  - need to be demultiplexed with Illuminas `bcl2fastq` or `cellranger mkfastq`
* SRA files
  - format of data stored in the GEO/SRA database
  - fastq files can be extracted with `fastq-dump`
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


## Extract Fastq files from BAM

> Make sure requested cores in qsub header matches `--nthreads`  
> **supply `--cr11` flag if BAMs were produced with cellranger ≤ 1.1**

```bash
#! /bin/bash
#$ -V
#$ -cwd
#$ -l h_rt=24:00:00
#$ -l h_vmem=32G
#$ -pe threaded 4

bamtofastq --nthreads=4 --cr11 *_Cerebella.bam ./fastq
```

For older data without RG tags, `bamtofastq` will place the output in `/fastq/gemgroup001`. Use the following two-liner to clean up a little bit.

```bash
for d in P*; do mv ${d}/fastq/gemgroup001/* ${d}/fastq; done
rmdir */fastq/gemgroup001
```


## Directory Organization

A coherent folder structure facilites data analysis later on because the same script can be re-used for qsub submissions. The following directory tree is a suggestion, and the scripts later on are tailored to work within this structure. 

```
├── study-A
|   ├── dataset-1
|       ├── fastq
|           ├── sample1_S1_L000_R1_001.fastq.gz
|           ├── sample1_S1_L000_R2_001.fastq.gz
|   └── dataset-2
|       ├── fastq
|           ├── sample2_S1_L000_R1_001.fastq.gz
|           ├── sample2_S1_L000_R2_001.fastq.gz
|   └── dataset-3
|       ├── fastq
|           ├── sample3_S1_L000_R1_001.fastq.gz
|           ├── sample3_S1_L000_R2_001.fastq.gz
├── study-B
|   ├── dataset-1
|       ├── fastq
|           ├── sample4_S1_L000_R1_001.fastq.gz
|           ├── sample4_S1_L000_R2_001.fastq.gz
|   └── dataset-2
|       ├── fastq
|           ├── sample5_S1_L000_R1_001.fastq.gz
|           ├── sample5_S1_L000_R2_001.fastq.gz
```

## Run cellranger

```bash
#! /bin/bash
#$ -V
#$ -cwd
#$ -l h_rt=48:00:00
#$ -l h_vmem=120G
#$ -pe threaded 8


#ref="/hpc/hub_oudenaarden/cgeisenberger/genomes/refdata-cellranger-GRCh38-and-mm10-3.1.0/"
#ref="/hpc/hub_oudenaarden/cgeisenberger/genomes/refdata-cellranger-GRCh38-3.0.0/"
ref="/hpc/hub_oudenaarden/cgeisenberger/genomes/refdata-cellranger-mm10-3.0.0/"

cellranger count --localcores=8 --id=output --transcriptome=$ref --fastqs="./fastq"
```

Copy the contents above into the script `run-cellranger.sh`. Run the following command **in the root directory** of your data to start one job per dataset:

```bash
# if you can, make the following wildcard more specific according to your folder names:
for d in *; do echo qsub -wd $PWD/$d run-cellranger.sh; done
```

## Merge multiple datasets

[Dave Tang: Merging datasets](https://davetang.org/muse/2018/01/24/merging-two-10x-single-cell-datasets/)  
[Dave Tang: Seurat Intro](https://davetang.org/muse/2017/08/01/getting-started-seurat/)

