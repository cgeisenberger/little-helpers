#! /bin/bash

ve="/hpc/hub_oudenaarden/bdebarbanson/virtualEnvironments/py36/bin/activate"

for f in *L001_R1_001.fastq.gz
do
        b=$(basename --suffix="_L001_R1_001.fastq.gz" ${f})
        submission.py -y --nenv "source $ve; demux.py ${b}*.fastq.gz -merge _ --y"
done
