#!/bin/bash
##calculate HIFI stats and draw a read_quality plot
##first argument: ccs bam file
## Mojtaba jahani September 2020

#SBATCH --time=12:00:00
#SBATCH --cpus-per-task=32
#SBATCH --mem=128000M
#SBATCH --account=def-rieseber
#SBATCH --job-name=ccs_stat
#SBATCH --output=%j_%x.out

##
JOBINFO=${SLURM_JOB_ID}_${SLURM_JOB_NAME}
echo "Starting run at: $(date)" >>$JOBINFO

#Load conda environment for CCS calculation
source ~/miniconda3/bin/activate PB

CCSBAM=$1 
NAME=${CCSBAM%%.bam}

#convert bam to sam
samtools view -h -o ${NAME}.sam $CCSBAM

#extract quality and number of passes
grep -v ^@SQ ${NAME}.sam |awk -F "\t" '{print $1"\t"$14"\t"$15}' > ${NAME}.aligned.sorted.MAPQ

#convert bam to fastq
samtools fastq $CCSBAM > ${NAME}.fastq

#sequence length
bioawk -c fastx '{print $name"\t"length($seq)}' ${NAME}.fastq > ${NAME}.read.length

#convert bam to fasta
samtools fasta $CCSBAM > ${NAME}.fasta

#plot
Rscript /home/mjahani/bin/scripts/length_Q_plot.R ${NAME}.aligned.sorted.MAPQ ${NAME}.read.length ${NAME}
##
echo "Program finished with exit code $? at: $(date)" >>$JOBINFO
