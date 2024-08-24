#!/bin/bash
# randomly select 100k reads per sample
# yilei wu


# 1. cat a sample's reads together
base_dir="folder contains sample folders which have fastq files"
out_dir="output folder"

# here use it to submit jobs, if you do not use slurm please ignore SLURM_ARRAY_TASK_ID
# sample_dirs: sample folders, like barcode1/2/3/4/...
sample_dirs=("$base_dir"/barcode*/)
sample_dir=${sample_dirs[$SLURM_ARRAY_TASK_ID]} 
sample_name=$(basename "$sample_dir")

# find all fastq files in this sample folder
fq_files=$(find "$sample_dir" -maxdepth 1 -name "*.fastq" | tr '\n' ' ')

# check, cat them together
if [ -n "$fq_files" ]; then
	cat $fq_files > $out_dir${sample_name}.fastq
else
  echo "No .fastq files found in $sample_dir"
fi
echo "Finished cat for sample $sample_name."

# 2. use perl script subsample_single.pl provided by Richard Leggett
pscript="Path to the perl script"
perl $pscript -a $out_dir${sample_name}.fastq -c "output1000000reads.fastq" -n 100000 -q
echo "Finished select for sample $sample_name."
