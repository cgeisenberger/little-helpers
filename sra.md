

# Downloading data from the Sequencing Read Archive (SRA)

Throughout this tutorial, I will be using the single-cell bisulfite sequencing dataset from [Smallwood et al.](https://www.nature.com/articles/nmeth.3035) as an example. The corresponding GEO accession number is [GSE56879](https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSE56879). 


## Introduction 

Most journals require authors to upload their data to a repository. In the majority of cases, this means depositing data to the NCBI's [Gene Expression Omnibus (GEO)](https://www.ncbi.nlm.nih.gov/geo/). Every dataset is assigned a unique accession number (such as **GSE56879**). For sequencing experiments, raw data is hosted on yet another platform called [Sequencing Read Archive (SRA)](https://www.ncbi.nlm.nih.gov/sra). I will give a quick introduction on how to access data and provide a little script which can automate the process. The SRA hosts one file per sample, and their accession numbers start with **SRR**.

Basically, we need to go through a **three-step process**:

1. [Create a list of SRRs (for the samples of interest)](#obtain-a-list-of-srrs)
2. [Download the corresponding SRA files](#download-sra-files)
3. [Extract Fastq data](#extract-fastq-data)


## Helpful articles

Here is a list of resources I found helpful:

[Biostars post on downloading raw data](https://www.biostars.org/p/111040/)  
[More information on fastq-dump options](https://edwards.sdsu.edu/research/fastq-dump/)   
[SRA documentation: Using command line tools to access data](https://www.ncbi.nlm.nih.gov/books/NBK158899/?report=reader)  


## Obtain a list of SRRs

1. Navigate to the [SRA Run Selector](https://www.ncbi.nlm.nih.gov/Traces/study/)
2. Search for the studies' accession number (for example, GSE56879)
3. 

Example: GSE56879 

1. Go to https://www.ncbi.nlm.nih.gov/geo/
2. Search for accesion no (e.g. GSE56879)
3. Note the linked SRP no. (SRP041257)
4. Fire up the Run Selector (https://www.ncbi.nlm.nih.gov/Traces/study/)
5. Search for GSE numbers
6. Download accession file / select files from Run Table



wget ftp://ftp-trace.ncbi.nih.gov/sra/sra-instant/reads/ByRun/sra/SRR/SRR304/SRR304976/SRR304976.sra


## Download SRA files


```bash
# !/bin/bash
# Usage: download_srr.sh accession_list.txt /outputdir/
# Loops over list of SRR IDs in accession_list.txt and downloads them to /outputdir/
# NB: Will download to "./" if outputdir is omitted

filename=$1
output_dir="./"
if [ -n "$2" ]
  then
    output_dir=$2
fi

echo "Reading SRRs from $filename"
lines=$(cat $filename)

# loop over SRRs and download
for srr in $lines; do
    srr=$(echo $srr | tr -d '\r')
    echo "Starting download for $srr"
    prefix=$(echo $srr | cut -c1-6)
    add="ftp://ftp-trace.ncbi.nih.gov/sra/sra-instant/reads/ByRun/sra/SRR/$prefix/$srr/$srr.sra"
    wget -P $output_dir $add
    echo "Done"
done
```

## Extract Fastq data

fastq-dump --outdir fastq --gzip --skip-technical  --readids --read-filter pass --dumpbase --split-3 --clip SRR_ID

fastq-dump --gzip --skip-technical --readids --split-3 SRR_ID



```bash
# Run locally:
for i in $(ls *.sra); do fastq-dump --gzip --skip-technical --readids --split-3 $i; done

# Run on server:
for i in $(ls *.sra); do echo "fastq-dump --gzip --skip-technical --readids --split-3 $i" | qsub -V -cwd -l h_rt="2:00:00"; done

```

