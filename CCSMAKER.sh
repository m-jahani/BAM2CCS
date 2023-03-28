#!/bin/bash
#Generates CCS reads from subread.bam file
#runs as: bash CCSMAKER.sh subread.bam 

SUBREADBAM=$1

#index the subread.bam file
jid1=$(sbatch  /home/mjahani/bin/scripts/pbindex.sh $SUBREADBAM)

#calculate ccs in 20 chunk
jid2=$(sbatch --dependency=afterany:${jid1/Submitted batch job /} /home/mjahani/bin/scripts/pbccs_parallel.sh  $SUBREADBAM)

#merge CCS chunks
jid3=$(sbatch --dependency=afterany:${jid2/Submitted batch job /} /home/mjahani/bin/scripts/pbmerge.sh ${SUBREADBAM})

#calculate stats and draw a plot
sbatch --dependency=afterany:${jid3/Submitted batch job /} /home/mjahani/bin/scripts/ccs.stat.sh  ${SUBREADBAM%%subreads.bam}ccs.bam 


