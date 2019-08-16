# SGE cluster / qsub

Execute script in multiple subdirectories

```bash
for d in $(find $PWD/PATTERN* -type d); do qsub -wd $d script.sh; done
```
