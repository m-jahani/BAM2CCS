#!/bin/bash
## index the raw read bam to prepare it for parrallel concersion to CCS reads
##first argument: raw read bam file
## Mojtaba jahani September 2020


#SBATCH --time=06:00:00
#SBATCH --cpus-per-task=32
#SBATCH --mem=128000M
#SBATCH --account=def-rieseber
#SBATCH --job-name=bam_index
#SBATCH --output=%j_%x.out
##
JOBINFO=${SLURM_JOB_ID}_${SLURM_JOB_NAME}
echo "Starting run at: $(date)" >>$JOBINFO

# Load conda environment for CCS calculation
source ~/miniconda3/bin/activate PB

BAM=$1

# Run the Rscript
pbindex $BAM
##
echo "Program finished with exit code $? at: $(date)" >>$JOBINFO
