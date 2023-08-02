include { GATK4_BASERECALIBRATOR  as GBU      } from '../../modules/nf-core/gatk4/baserecalibrator/main'
include { GATK4_BASERECALIBRATOR  as GBC      } from '../../modules/nf-core/gatk4/baserecalibrator/main'
include { GATK4_APPLYBQSR                     } from '../../modules/nf-core/gatk4/applybqsr/main'
//include { SAMTOOLS_INDEX                      } from '../../modules/nf-core/samtools/index/main'

//just one Baserecalibrator run is sufficient for multiqc plot

workflow RECALIBRATE {
    take:
        bams         // channel: [ val(meta), val(bam), val(bai) ]
        fasta
    //fai,dict
    main:

    ch_versions       = Channel.empty()

    GATK_BASE = "/resources/references/igenomes/Homo_sapiens/GATK/GRCh38/Annotation/GATKBundle/"
    ch_known_sites = Channel.empty() // Channel.fromPath( ["${GATK_BASE}/dbsnp_146.hg38.vcf.gz","${GATK_BASE}/beta/Homo_sapiens_assembly38.known_indels.vcf.gz","${GATK_BASE}/Mills_and_1000G_gold_standard.indels.hg38.vcf.gz"] )

    GBU(bams, fasta, ch_known_sites.toList())//, "_uncalibrated")
    ch_versions = ch_versions.mix(GBU.out.versions.first())

    GATK4_APPLYBQSR(GBU.out.bam_table, fasta)
    ch_versions = ch_versions.mix(GATK4_APPLYBQSR.out.versions.first())

    //SAMTOOLS_INDEX(GATK4_APPLYBQSR.out.bam)
    //calibrated_bam_bai = GATK4_APPLYBQSR.out.bam.join(SAMTOOLS_INDEX.out.bai)

    GBC(GATK4_APPLYBQSR.out.bam, fasta, ch_known_sites.toList())//removed stage, "_recalibrated")

    ch_calibration_tables = GBU.out.calibration_table.mix(GBC.out.calibration_table)

    emit:
        calibration_tables = ch_calibration_tables
        versions    = ch_versions
}