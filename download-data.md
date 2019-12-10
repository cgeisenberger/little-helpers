# Data Download

A little How To on downloading data from the
* [European Nucleotide Archive (ENA)](https://www.ebi.ac.uk/ena/browser/home) and
* NCBI's [Sequence Read Archive (SRA)](https://www.ncbi.nlm.nih.gov/sra).


## Download from ENA

**Note**: IBMs Aspera needs to be installed in order for this to work. Download [here](https://downloads.asperasoft.com/en/downloads/8?list).

First, figure out the ENA accession ID. Then use the code below to query ENAs API to get a list of files (**make sure to replace the accession ID**, documentation [here](https://www.ebi.ac.uk/ena/portal/api/#/Portal_API)). Extract the FTP links and download using Aspera. **Important**: Depending on whether the study authors uploaded fastq or other file types, the entries will end up in different columns. This means the ```cut -f``` in the code block has to be adjusted!

See also [this post](https://www.biostars.org/p/325010/) on Biostars for more information. 

```bash
# Download tab-delimited file with information about data
curl -X GET "https://www.ebi.ac.uk/ena/portal/api/filereport?accession=PRJEB23051&result=read_run&fields=study_accession,sample_accession,experiment_accession,run_accession,tax_id,scientific_name,fastq_ftp,submitted_ftp,sra_ftp&format=tsv" -H "accept: */*" -o accessions.txt  

# extract FTP links
awk 'FS="\t", OFS="\t" { gsub("ftp.sra.ebi.ac.uk", "era-fasp@fasp.sra.ebi.ac.uk:"); print }' accessions.txt | cut -f 8 | awk -F ";" 'OFS="\n" {print $1, $2}' | awk NF | awk 'NR > 1, OFS="\n" {print "ascp -QT -l 300m -P33001 -i $HOME/.aspera/connect/etc/asperaweb_id_dsa.openssh" " " $1 " ."}' > download.txt

# download (use screen!)
while read LIST; do echo $LIST | sh; done < download.txt

# could also be run in parallel (option currently not available on HPC)
cat download.txt | parallel "{}"

```

## Download from SRA 

Most journals require authors to upload their data to a repository. In the majority of cases, this means depositing data to the NCBI's [Gene Expression Omnibus (GEO)](https://www.ncbi.nlm.nih.gov/geo/). Every dataset is assigned a unique accession number (such as **GSE56879**). For sequencing experiments, raw data is hosted on yet another platform called [Sequencing Read Archive (SRA)](https://www.ncbi.nlm.nih.gov/sra). The files hosted on SRA are assigned accession numbers which start with **SRR**. After obtaining a list of accessions, the below script can be used to download the files. As a last step, the fastq files have to be extracted using `fastq-dump`. Download the SRA toolkit [here](https://github.com/ncbi/sra-tools) if the command is not available.

As some of the tools are not very well documented, some useful links for further reading:  

* [Biostars post on downloading raw data](https://www.biostars.org/p/111040/)  
* [More information on fastq-dump options](https://edwards.sdsu.edu/research/fastq-dump/)   
* [SRA documentation: Using command line tools to access data](https://www.ncbi.nlm.nih.gov/books/NBK158899/?report=reader)  


### Obtain accession numbers

1. Go to https://www.ncbi.nlm.nih.gov/geo/
2. Search for accesion no (e.g. GSE56879)
3. Note the linked SRP no. (SRP041257)
4. Fire up the Run Selector (https://www.ncbi.nlm.nih.gov/Traces/study/)
5. Search for GSE numbers
6. Download accession file (click on *Accession List*)
7. Save as *accessions.txt*


### Download files

1. Download this [script](./scripts/download-srr.sh)
2. Run script: ```download_srr.sh accessions.txt /outputdir/```
3. Wait for download to finish

### Extract fastq data

> NB: Single-cell data from 10x Genomics might require removing the `--skip-technical` option!
> 
> Check out this [blog post](https://edwards.sdsu.edu/research/fastq-dump/) for more info

```bash
# Run locally:
for i in $(ls *.sra); do fastq-dump --gzip --skip-technical --readids --split-3 $i; done

# Run on server:
for i in $(ls *.sra); do echo "fastq-dump --gzip --skip-technical --readids --split-3 $i" | qsub -V -cwd -l h_rt="2:00:00"; done

```
