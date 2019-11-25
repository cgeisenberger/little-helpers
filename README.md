# Contents

* [Data Download from SRA / ENA](#data-download)
* [Data Analysis](#data-analysis)
* [Raw Sequencing Data](#raw-sequencing-data)
* [SGE cluster](#sge-cluster)


# Data Download

A little How To about download data from the [European Nucleotide Archive (ENA)](https://www.ebi.ac.uk/ena/browser/home) and
NCBI's [Sequence Read Archive (SRA)](https://www.ncbi.nlm.nih.gov/sra).


## Downloading from ENA

**Note**: IBMs Aspera needs to be installed in order for this to work. Download [here](https://downloads.asperasoft.com/en/downloads/8?list)

First, figure out the ENA accession ID. Then use the code below to query ENAs API to get a list of files (**make sure to replace the accesion ID**, documentation [here](https://www.ebi.ac.uk/ena/portal/api/#/Portal_API)). Extract the FTP links and download using Aspera. 

See also [this post](https://www.biostars.org/p/325010/) on Biostars for more information. 

```bash
# Download tab-delimited file with information about data
curl -X GET "https://www.ebi.ac.uk/ena/portal/api/filereport?accession=PRJEB23051&result=read_run&fields=study_accession,sample_accession,experiment_accession,run_accession,tax_id,scientific_name,fastq_ftp,submitted_ftp,sra_ftp&format=tsv" -H "accept: */*" -o file_list.txt

# extract FTP links
awk 'FS="\t", OFS="\t" { gsub("ftp.sra.ebi.ac.uk", "era-fasp@fasp.sra.ebi.ac.uk:"); print }' accessions.txt | cut -f 8 | awk -F ";" 'OFS="\n" {print $1, $2}' | awk NF | awk 'NR > 1, OFS="\n" {print "ascp -QT -l 300m -P33001 -i $HOME/.aspera/connect/etc/asperaweb_id_dsa.openssh" " " $1 " ."}' > download.txt

# download (use screen!)
while read LIST; do echo $LIST | sh; done < download.txt

# could also be run in parallel (option currently not available on HPC)
cat download.txt | parallel "{}"

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
