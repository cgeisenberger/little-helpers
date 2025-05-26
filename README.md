# Collections

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


## Content

* [BASH oneliners](#BASH-oneliners)
* [Sequencing Data](Sequencing-Data)
  - [Saturation analysis](Saturation-analysis)
  - [Working with SAM/BAM files](#Working-with-SAM/BAM-files)
* [Folder Structure for Data Science and Bioinformatics](#Folder-Structure-for-Data-Science-and-Bioinformatics)


## BASH oneliners

```bash
# find and copy files
find dir1 -type f -name "PATTERN*" -exec cp {} dir2 \;

# batch rename files (like idats)
rename -n 's/GSM[^_]*_//' GSM*

# remove prefix from multiple files
for file in prefix*; do mv "$file" "${file#prefix}"; done
```

## Sequencing Data

### Saturation analysis 

Uses [preseq](http://smithlabresearch.org/software/preseq/) published in [Nature Methods 2013](http://www.nature.com/nmeth/journal/vaop/ncurrent/full/nmeth.2375.html).

```bash
preseq lc_extrap -e 10000000 -s 200000 -o future_yield.txt -B infile.bam

# -e = max. no of extrapolated reads
# -s = stepsize
```

### Working with SAM/BAM files

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


## Folder Structure for Data Science and Bioinformatics

A good, reproducible data‐science or bioinformatics project usually follows a “convention over configuration” layout. The rough idea is to keep raw inputs, intermediate outputs, analysis code, and final reports nicely separated, with a single top‐level Git repository that tracks everything except large or sensitive data.

Here’s a canonical structure:

```
my_project/
├── .git/                   ← Git repository lives at the root
├── .gitignore              ← exclude large data, credentials, env files
├── LICENSE                 
├── README.md               ← overview, install+usage instructions
├── environment.yml /       ← Conda, pip-requirements.txt, or Dockerfile
│   requirements.txt        
│
|–– annotation/             ← annotation for data and / or samples
|
├── data/
│   ├── raw/                ← immutable “gold‐standard” inputs
│   ├── processed/          ← cleaned, filtered, normalized data
│   └── external/           ← data from other teams or repos
│
├── notebooks/              ← exploratory analyses, Rmd or .ipynb files
│   ├── 01-explore.ipynb    
│   └── 02-model-building.ipynb
│
├── src/                    ← all reusable code: modules, functions, scripts
│   ├── __init__.py
│   ├── data_processing.py
│   └── analysis.py
│
├── scripts/                ← executable wrappers for long jobs / pipelines
│   ├── run_pipeline.sh
│   └── submit_cluster.qsub
│
├── results/                ← figures, tables, model outputs, logs
│   ├── figures/
│   └── tables/
│
└── docs/                   ← detailed protocol, design docs, slides, reports
    ├── protocol.md
    └── presentation.pptx
```

Key points

1. **One Repo, One Project.**
   The `.git/` directory and your `README.md` live at the **root** of `my_project/`. Everything you want versioned (code, small configs, docs) goes under here.

2. **Don’t check in large data.**
   Use the `.gitignore` to exclude `data/raw/` if your raw files are hundreds of MB or larger. Consider [Git LFS](https://git-lfs.github.com/) or storing large files in an S3 bucket or FTP server and retrieving them via a download script in `scripts/`.

3. **Environment on par with code.**
   Capture your software stack in `environment.yml` (Conda), `requirements.txt` (pip) or a `Dockerfile`. That way anyone cloning your GitHub repo can reproduce your exact computational environment.

4. **Modularize and reuse.**
   Put all reusable functions/packages in `src/` and keep your “one‐off” exploratory work in `notebooks/`. This makes it easy to refactor successful analyses into production‐quality scripts later.

5. **Results are outputs, not inputs.**
   You may track small figures in Git; larger ones can be auto‐generated by your pipeline and needn’t be versioned. Just make sure your scripts (in `scripts/` or `src/`) know how to regenerate them.

