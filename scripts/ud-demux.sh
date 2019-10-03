#!/usr/bin/env bash

for bc in "$@"
do
    echo "grep -A 3 --no-group-separator "@.*:$bc$" Undetermined.R1.fastq > bc.${bc}_R1.fastq"
    echo "grep -A 3 --no-group-separator "@.*:$bc$" Undetermined.R2.fastq > bc.${bc}_R2.fastq"
done
  
