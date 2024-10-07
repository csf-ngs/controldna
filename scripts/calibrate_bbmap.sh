#!/usr/bin/env bash
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1 ## for multithreaded change here
###SBATCH --mem-per-cpu=5G
#SBATCH --mem=20G
#SBATCH -J calibrate_bqsr
#SBATCH -o "%x"."%j".out
#SBATCH -e "%x"."%j".err

#  long: 8d  (8-00:00:00) , medium: 2d  (2-00:00:00) , short: 8h (8:00:00), rapid: 1h (1:00:00)
##SBATCH --qos=rapid
##SBATCH --time=1:00:00
#SBATCH --qos=short
#SBATCH --time=8:00:00
##SBATCH --qos=medium
##SBATCH --time=2-00:00:00
##SBATCH --qos=long
##SBATCH --time=8-00:00:00

#calibrate BQSR script

SING=/groups/vbcf-ngs/misc/infra/singularity/amd64/pipeline/preprocess_latest.sif

apptainer exec $SING  


