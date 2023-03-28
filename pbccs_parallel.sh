#!/bin/bash
## Run to convert raw reads to CCS (parallel)
##first argument: raw read bam file
## Mojtaba jahani September 2020

#SBATCH --time=02:00:00
#SBATCH --cpus-per-task=32
#SBATCH --mem=128000M
#SBATCH --account=def-rieseber
#SBATCH --job-name=CCS
#SBATCH --output=%j_%x.out
#SBATCH --array=1-20

##
JOBINFO=${SLURM_JOB_ID}_${SLURM_JOB_NAME}
echo "Starting run at: $(date)" >>$JOBINFO

# Load conda environment for CCS calculation
source ~/miniconda3/bin/activate PB

BAM=$1
NAME=${BAM%%bam}
JOB=$SLURM_ARRAY_TASK_ID
# Run the Rscript
ccs $BAM  ${NAME}${JOB}.bam --minPasses 3 --min-rq 0.99 --min-length 1000  --chunk ${JOB}/20 -j 32
#
echo "Program finished with exit code $? at: $(date)" >>$JOBINFO

