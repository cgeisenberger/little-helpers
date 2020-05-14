# Workflows for single-cell data analysis

* [Demultiplexing](#demultiplexing)
* [Trimming](#adapter-trimming)
* [Mapping](#mapping)
* [BAM Tagging](#bam-tagging)
* [Data extraction](#extract-data)
* [QC & Download](#qc-and-download)



## Demultiplexing 

> All *fastq.gz* files need to be in the same root directory  
> Commands assume that files are split by lane (**-merge _** flag added)  
> add *-ignoreMethods none* flag if processing Nla-Bisulfite libraries

```bash
# create folder for raw data and move files
mkdir raw
find /path/to/files -name "CG*" -type f | xargs -I % mv % ./raw
cd raw
```

### Sequential Processing

```bash
ve="/hpc/hub_oudenaarden/bdebarbanson/virtualEnvironments/py36/bin/activate"
submission.py -y --nenv "source $ve; demux.py *.fastq.gz -merge _ --y"
```

### Parallel processing

copy and paste [demultiplexing script](./scripts/demux.sh), then run `./demux.sh`



## Adapter trimming

> **NB: If cutadapt throws error, this might be caused by loading Python 2.7**  
> If dealing with 26 / 60 bp transcriptome reads, use `--length 0`

```bash

#! /bin/bash
#$ -V
#$ -cwd
#$ -l h_rt=8:00:00

trim_galore --path_to_cutadapt $pathCa --fastqc --gzip --paired demultiplexedR1.fastq.gz demultiplexedR2.fastq.gz
mv demultiplexedR1_val_1.fq.gz trimmed.R1.fastq.gz
mv demultiplexedR2_val_2.fq.gz trimmed.R2.fastq.gz

# deprecated: --clip_R2 9 --three_prime_clip_R1 3 --three_prime_clip_R2 3
```


## Mapping 


### Transcriptome data

```bash
#! /bin/bash
#$ -V
#$ -cwd
#$ -l h_rt=12:00:00
#$ -l h_vmem=120G
#$ -pe threaded 8

# CHANGE REF AND ANNO TO FIT MODEL SYSTEM!
#ref="/hpc/hub_oudenaarden/group_references/ensembl/97/homo_sapiens/NOMASK_star_index_75"
#anno="/hpc/hub_oudenaarden/group_references/ensembl/97/homo_sapiens/annotations.gtf"

ref="/hpc/hub_oudenaarden/group_references/ensembl/97/mus_musculus/NOMASK_star_index_75"
anno="/hpc/hub_oudenaarden/group_references/ensembl/97/mus_musculus/annotations.gtf"


STAR --runThreadN 8 --outSAMattributes All --readFilesCommand zcat --outSAMtype BAM \
SortedByCoordinate --outMultimapperOrder Random --outSAMmultNmax 5 \
--outFilterMultimapNmax 5 --genomeDir $ref \
--readFilesIn ./trimmed.R2.fastq.gz --outFileNamePrefix STAR_mapped

mv STAR_mappedAligned.sortedByCoord.out.bam sorted.bam
samtools index sorted.bam
```

### Genomic Data


```bash
#! /bin/bash
#$ -V
#$ -cwd
#$ -l h_rt=12:00:00
#$ -l h_vmem=120G
#$ -pe threaded 8

# choose reference
# ref="/hpc/hub_oudenaarden/gene_models/human_gene_models/hg38_clean.fa"
# ref="/hpc/hub_oudenaarden/gene_models/mouse_gene_models/mm10.fa"

bwa mem -t 8 $ref trimmed.R1.fastq.gz trimmed.R2.fastq.gz | samtools view -Sb > unsorted.bam

samtools sort -T ./temp_sort -@ 8 ./unsorted.bam > ./sorted.unfinished.bam
mv ./sorted.unfinished.bam ./sorted.bam; 
samtools index ./sorted.bam
rm ./unsorted.bam
```


### Bisulfite Data

Adjust **ref** argument!


#### Paired End

```bash
#! /bin/bash
#$ -V
#$ -cwd
#$ -l h_rt=12:00:00
#$ -l h_vmem=120G
#$ -pe threaded 8

# run mapping
#ref="/hpc/hub_oudenaarden/cgeisenberger/genomes/mm10/"
#ref="/hpc/hub_oudenaarden/cgeisenberger/genomes/danRer10"

ref="/hpc/hub_oudenaarden/cgeisenberger/genomes/hg38-clean"
bismark --multicore 8 --non_directional --genome $ref -1 trimmed.R1.fastq.gz -2 trimmed.R2.fastq.gz
```

#### Single End

```bash
#! /bin/bash
#$ -V
#$ -cwd
#$ -l h_rt=12:00:00
#$ -l h_vmem=120G
#$ -pe threaded 8

# run mapping
#ref="/hpc/hub_oudenaarden/cgeisenberger/genomes/mm10/"
#ref="/hpc/hub_oudenaarden/cgeisenberger/genomes/danRer10"

ref="/hpc/hub_oudenaarden/cgeisenberger/genomes/hg38-clean"
bismark --multicore 8 --non_directional --genome $ref trimmed.R2.fastq.gz
```


## BAM Tagging


### Transcriptome data

Perform *feature counting* first, then use `bamtagmultiome.py` to annotate molecules

```bash
#! /bin/bash
#$ -V
#$ -cwd
#$ -l h_rt=12:00:00
#$ -l h_vmem=60G
#$ -pe threaded 4

# ADJUST ANNO
anno="/hpc/hub_oudenaarden/group_references/ensembl/97/mus_musculus/annotations.gtf"

featureCounts -t exon -O -s 1 -T 4 \
--fraction -R BAM -a $anno -p -o fcounts ./sorted.bam

samtools sort -T ./temp_sort -@ 4 sorted.bam.featureCounts.bam -o resorted.featureCounts.bam
samtools index resorted.featureCounts.bam
```

```bash
#! /bin/bash
#$ -cwd 
#$ -V 
#$ -l h_rt=12:00:00
#$ -l h_vmem=32G

source /hpc/hub_oudenaarden/bdebarbanson/virtualEnvironments/py36/bin/activate
bamtagmultiome.py -method from_featurecounts_tagged -o tagged.bam ./resorted.featureCounts.bam
```


### ChIC Data

Adjust **reference genome** and universalBamTagger **arguments**!

```bash
#! /bin/bash
#$ -cwd 
#$ -V 
#$ -l h_rt=36:00:00
#$ -l h_vmem=32G

# source environment
source /hpc/hub_oudenaarden/bdebarbanson/virtualEnvironments/py36/bin/activate

# supply reference genome
# ref="/hpc/hub_oudenaarden/gene_models/mouse_gene_models/mm10.fa"
ref="/hpc/hub_oudenaarden/gene_models/human_gene_models/hg38_clean.fa"

# select method
bamtagmultiome.py -ref $ref -method nla_no_overhang -o tagged.bam sorted.bam 
bamtagmultiome.py -ref $ref -method nla -o tagged.bam sorted.bam 
bamtagmultiome.py -ref $ref -method chic -o tagged.bam sorted.bam 
```


## Extract Data


### Count tables transcriptome

```bash

bamToCountTable.py -o count-table.csv -featureTags XT -sampleTags SM -head 1000 tagged.bam

```


### Count tables scChIC

```bash
#! /bin/bash
#$ -cwd 
#$ -V 
#$ -l h_rt=4:00:00
#$ -l h_vmem=16G

# source environment
source /hpc/hub_oudenaarden/bdebarbanson/virtualEnvironments/py36/bin/activate

# adjust "-bin" parameter to choose bin size
# add "-sliding" parameter for moving bins

bamToCountTable.py -minMQ 30 --filterXA ./tagged/sorted.bam -o ./count_table.csv \
-joinedFeatureTags reference_name -sampleTags SM -bin 250_000 -binTag DS --dedup
```

## QC and Download

### Run libraryStatistics.py

```bash
for d in CG*; do echo "source /hpc/hub_oudenaarden/bdebarbanson/virtualEnvironments/py36/bin/activate; libraryStatistics.py $d" | qsub -V -cwd -l h_rt="4:00:00"; done
```


### Collect scChiC-Seq data

Extract count tables and library statistics for multiple experiments

```bash
# navigate to root directory
mkdir data-tables lib-plots lib-stats

# copy plots
for d in CG*; do mkdir ./lib-plots/$d; cp $d/plots/* ./lib-plots/$d; done

# copy library stats
find CG*/tables -type f -name "*.csv" -exec cp {} lib-stats/ \;

# copy data tables
for d in CG*; do cp $d/count_table.csv ./data-tables/${d}.csv; done
```

