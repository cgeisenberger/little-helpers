# Sequencing Data

Demultiplex Undetermined.fastq.gz files (see [barcodes](./files/rpix.csv))

```bash

# Count barcodes (ouputs undeterminedBc.txt)
ud-count.sh dir

# Extract data
ud-demux.sh BC1 BC2 BC3

```

# SGE cluster / qsub

Execute script in multiple subdirectories

```bash
for d in $(find $PWD/PATTERN* -type d); do qsub -wd $d script.sh; done
```
