#!/bin/bash
## merge chunks of *ccs.bam
##first argument: raw read bam file(it does not use the raw reads, it only uses the name)
## Mojtaba jahani September 2020

#SBATCH --time=03:00:00
#SBATCH --cpus-per-task=32
#SBATCH --mem=128000M
#SBATCH --account=def-rieseber
#SBATCH --job-name=merge_bam
#SBATCH --output=%j_%x.out

##
JOBINFO=${SLURM_JOB_ID}_${SLURM_JOB_NAME}
echo "Starting run at: $(date)" >>$JOBINFO

# Load conda environment for CCS calculation
source ~/miniconda3/bin/activate PB

BAM=$1 
NAME=${BAM%%bam}

# merge and index 
pbmerge -o ${NAME%%subreads.}ccs.bam ${NAME}*.bam #merge bam files
pbindex ${NAME%%subreads.}ccs.bam #index the merge bam
#
#clean up
rm ${NAME}[0-9]*.bam*
rm *_report.txt
rm *json.gz
##
echo "Program finished with exit code $? at: $(date)" >>$JOBINFO

