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

module load build-env/f2021
module load gatk/4.2.6.1-gcccore-10.2.0-java-13

FA=/resources/references/igenomes/Homo_sapiens/GATK/GRCh38/Sequence/WholeGenomeFasta/Homo_sapiens_assembly38.fasta
DBSNP=/resources/references/igenomes/Homo_sapiens/GATK/GRCh38/Annotation/GATKBundle/dbsnp_146.hg38.vcf.gz
INDELS=/resources/references/igenomes/Homo_sapiens/GATK/GRCh38/Annotation/GATKBundle/beta/Homo_sapiens_assembly38.known_indels.vcf.gz
GOLD=/resources/references/igenomes/Homo_sapiens/GATK/GRCh38/Annotation/GATKBundle/Mills_and_1000G_gold_standard.indels.hg38.vcf.gz



BAM=$1

gatk BaseRecalibrator \
   -I $BAM \
   -R $FA \
   --known-sites $DBSNP \
   --known-sites $INDELS \
   --known-sites $GOLD \
   -O recal_data.table


gatk ApplyBQSR \
   -I $BAM \
   --bqsr-recal-file recal_data.table \
   -O recal.bam


gatk BaseRecalibrator \
   -I recal.bam \
   -R $FA \
   --known-sites $DBSNP \
   --known-sites $INDELS \
   --known-sites $GOLD \
   -O adjusted_data.table



# multiqc ..
