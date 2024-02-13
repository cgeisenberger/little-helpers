# Collections

* Sequencing technology
  - [Ambry Genetics Webinar](https://www.youtube.com/watch?v=6jf_6STEnI4)
* Workflow managers
  - [Nextflow](https://www.nextflow.io)
  - [snakemake](https://snakemake.readthedocs.io/en/stable/)
* R Programming
  - [List of useful ressources](./r-programming.md)
  - [Package Development](./posts/packages.md)
* Bioinformatics
  - [Ressources / Bookmarks](./bioinformatics.md)
  - [Downloading data from Repositories (ENA/SRA)](./download-data.md)
  - [Sequencing Data Workflows](./analysis.md)
  - [10X Genomics scRNA-Seq Data](./analyse-10x-data.md)
* Single-cell 
  - [Data Analysis Workflows](./analysis.md)
  - list of software: [awesome-single-cell](https://github.com/seandavi/awesome-single-cell)
* Visualization
  - [Hive plots](http://www.hiveplot.com)


# One-liners

## Command Line 

```bash
# find and copy files
find dir1 -type f -name "PATTERN*" -exec cp {} dir2 \;

# batch rename files (like idats)
rename -n 's/GSM[^_]*_//' GSM*

# remove prefix from multiple files
for file in prefix*; do mv "$file" "${file#prefix}"; done
```

## Conda

```python
conda info
conda env list
conda list
conda install -n [env] <package>
````


## Github 

```
# Step 1: commit all changes, including .gitignore
# Step 2: Clean repo (does not! remove files)
git rm -r --cached .
# Step 3: Re-add everything
git add .
# Step 4: commit & update
git commit -m ".gitignore fix"
git push origin master
```


## Sequencing Data

### Sequencing saturation analysis 

Uses [preseq](http://smithlabresearch.org/software/preseq/) published in [Nature Methods 2013](http://www.nature.com/nmeth/journal/vaop/ncurrent/full/nmeth.2375.html).

```bash
preseq lc_extrap -e 10000000 -s 200000 -o future_yield.txt -B infile.bam

# -e = max. no of extrapolated reads
# -s = stepsize
```

### SAM and BAM files

```bash
# count reads in (zipped) fastq files
for f in *R1*fastq.gz; do i=$(zcat $f | wc -l);echo $f $i >> counts.txt; done

# sort and index bam files
for f in *.bam; do o=$(basename -s .bam ${f}); samtools sort $f -o "$o.sorted.bam"; done
for f in *.sorted.bam; do samtools index $f; done

# Sample first 1000 reads from BAM 
samtools view -h in.bam | head -n 1000 | samtools view -bS - > out.bam

# Subsample fraction f from BAM file (takes longer than sampling first n reads)
samtools view -s f -b in.bam > out.sam

# SAM to BAM conversion
samtools view -S -b in.sam > out.bam

# Split based on value in <tag> (such as cell barcodes)
bamtools split -tag SM -in tagged.bam

# convert to BigWig
bamCoverage --bam infile.bam --outFileName coverage.bigWig --numberOfProcessors 4
```
