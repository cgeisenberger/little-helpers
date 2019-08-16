# SGE cluster / qsub

Execute script in multiple subdirectories

'''
for d in $(find $PWD/PATTERN* -type d); do qsub -wd $d script.sh; done
'''
