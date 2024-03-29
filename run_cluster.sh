#!/usr/bin/env bash
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1 ## for multithreaded change here
###SBATCH --mem-per-cpu=5G
#SBATCH --mem=20G
#SBATCH -J wf_control_dna_align
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

## commands specific for CBE
## on other compute environments you might have to use other commands to have nextflow available
ml purge &> /dev/null
ml build-env/f2022
ml git/2.33.1-gcccore-11.2.0-nodocs
ml nextflow/22.10.7

CALLDIR=$(pwd)

PROJECT=$1
SAMPLES=$2 #absolute path to samples.csv
GENOME=$3  #"hg38 GRCm38 TAIR10 WBcel235 BDGP6 #https://emea.support.illumina.com/sequencing/sequencing_software/igenome.html  lambda 1993-04-28
TITLE=$4
SUB=$5



#STUB="-stub-run"
STUB=""

ALIGN_WF_BASEDIR=/scratch/${USER}/ngs_alignments/control_dna/${PROJECT}

echo "WORK: ${ALIGN_WF_BASEDIR}"

export NXF_ASSETS="${ALIGN_WF_BASEDIR}"
export NXF_WORK="${NXF_ASSETS}/work"
export NXF_TEMP="${NXF_ASSETS}/temp"
export NXF_ANSI_LOG=false # false is a viable alternative
export NXF_OPTS='-Xms2g -Xmx8g'

mkdir -p ${ALIGN_WF_BASEDIR}
cd ${ALIGN_WF_BASEDIR}

REPORT=/groups/vbcf-ngs/misc/reports/other/dna_indel

nextflow run ~/work/pipelines/nf-core-controldna --input ${SAMPLES} --genome ${GENOME} --multiqc_title ${TITLE} --subsample ${SUB} --reportdir $REPORT -resume -profile cbe $STUB


