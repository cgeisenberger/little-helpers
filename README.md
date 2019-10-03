# Sequencing Data

Demultiplex Undetermined.fastq.gz files

```bash

# Count barcodes (ouputs undeterminedBc.txt)
ud-count.sh *dir*

# Extract and count barcodes (saved as bc-counts.txt)
ud-demux.sh *ACAGTG*

```

# SGE cluster / qsub

Execute script in multiple subdirectories

```bash
for d in $(find $PWD/PATTERN* -type d); do qsub -wd $d script.sh; done
```
