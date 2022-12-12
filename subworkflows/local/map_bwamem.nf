include { BWA_MEM                             } from '../../modules/nf-core/bwa/mem/main'
include { SAMTOOLS_INDEX                      } from '../../modules/nf-core/samtools/index/main'
include { SAMTOOLS_MERGE                      } from '../../modules/nf-core/samtools/merge/main'
include { SAMTOOLS_SORT                       } from '../../modules/nf-core/samtools/sort/main'
include { PICARD_MARKDUPLICATESWITHMATECIGAR  } from '../../modules/local/picardmarkduplicateswithmatecigar'
include { PICARD_UMIAWAREMARKDUPLICATESWITHMATECIGAR  } from '../../modules/local/picardumiawaremarkduplicateswithmatecigar'
include { SAMTOOLS_SORTNAME                   } from '../../modules/local/samtoolssortname'
include { PICARD_SORTBAM                      } from '../../modules/local/picardsortbam'
include { ADD_UMI_TO_BAM                      } from '../../modules/local/add_umi_to_bam'


//TODO: switch to BWA MEM2
workflow MAP_BWAMEM {
    take:
        reads         // channel: [ val(meta), [ reads ] ]
        genome

    main:

    bam_from_aligner  = Channel.empty()
    ch_versions       = Channel.empty()

    BWA_MEM(reads, genome, true)
    ch_versions = ch_versions.mix(BWA_MEM.out.versions.first())

    PICARD_SORTBAM(BWA_MEM.out.bam, "coordinate", "aligned")
    ch_versions = ch_versions.mix(PICARD_SORTBAM.out.versions.first())

    PICARD_SORTBAM.out.bam.branch { m, r ->
        umi: m.umi && m.umi != ""
        no_umi: true
    }
    .set { bam_umi }


    ADD_UMI_TO_BAM(bam_umi.umi)
    PICARD_UMIAWAREMARKDUPLICATESWITHMATECIGAR(ADD_UMI_TO_BAM.out.bam)
    ch_versions = ch_versions.mix(PICARD_UMIAWAREMARKDUPLICATESWITHMATECIGAR.out.versions.first())

    PICARD_MARKDUPLICATESWITHMATECIGAR(bam_umi.no_umi)
    ch_versions = ch_versions.mix(PICARD_MARKDUPLICATESWITHMATECIGAR.out.versions.first())

    marked_bams = PICARD_MARKDUPLICATESWITHMATECIGAR.out.bam.mix(PICARD_UMIAWAREMARKDUPLICATESWITHMATECIGAR.out.bam)

    SAMTOOLS_SORT(marked_bams)
    ch_versions = ch_versions.mix(SAMTOOLS_SORT.out.versions.first())

    SAMTOOLS_INDEX(SAMTOOLS_SORT.out.bam)
    bam_indexed = SAMTOOLS_INDEX.out.bai
    
    bam_bai =  SAMTOOLS_SORT.out.bam.join(SAMTOOLS_INDEX.out.bai)

    emit:
        bam_bai     = bam_bai
        bam         = SAMTOOLS_SORT.out.bam        //  channel: [ val(meta), bai ]
        bai         = SAMTOOLS_INDEX.out.bai       // channel: [ val(meta), bam ]
        dup_metrics = PICARD_MARKDUPLICATESWITHMATECIGAR.out.metrics.mix(PICARD_UMIAWAREMARKDUPLICATESWITHMATECIGAR.out.metrics)
        versions    = ch_versions
}