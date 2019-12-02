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
