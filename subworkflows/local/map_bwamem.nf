include { BWA_MEM                     } from '../../modules/nf-core/modules/bwa/mem/main'
include { SAMTOOLS_INDEX                  } from '../../modules/nf-core/modules/samtools/index/main'
include { SAMTOOLS_MERGE                  } from '../../modules/nf-core/modules/samtools/merge/main'
include { SAMTOOLS_SORT                   } from '../../modules/nf-core/modules/samtools/sort/main'
include { PICARD_MARKDUPLICATES           } from '../../modules/local/picardmarkduplicates'
include { SAMTOOLS_SORTNAME               } from '../../modules/local/samtoolssortname'
//include { PICARD_MARKDUPLICATES           } from '../../modules/local/picardmarkduplicates'
include { PICARD_SORTBAM                  } from '../../modules/local/picardsortbam'


workflow MAP_BWAMEM {
    take:
        reads         // channel: [ val(meta), [ reads ] ]
        genome

    main:

    bam_from_aligner  = Channel.empty()
    ch_versions       = Channel.empty()

    BWA_MEM(reads, genome, true)
    ch_versions = ch_versions.mix(BWA_MEM.out.versions.first())

    PICARD_SORTBAM(BWA_MEM.out.bam, "queryname")
    ch_versions = ch_versions.mix(PICARD_SORTBAM.out.versions.first())

    PICARD_MARKDUPLICATES(PICARD_SORTBAM.out.bam)
    ch_versions = ch_versions.mix(PICARD_MARKDUPLICATES.out.versions.first())
 
    SAMTOOLS_SORT(PICARD_MARKDUPLICATES.out.bam)
    ch_versions = ch_versions.mix(SAMTOOLS_SORT.out.versions.first())

    SAMTOOLS_INDEX(SAMTOOLS_SORT.out.bam)
    bam_indexed = SAMTOOLS_INDEX.out.bai
    
    metrics = PICARD_MARKDUPLICATES.out.metrics
     

    emit:
        bam         = SAMTOOLS_SORT.out.bam               //  channel: [ val(meta), bai ]
        bai = SAMTOOLS_INDEX.out.bai       // channel: [ val(meta), bam ]
        duplicate_metrics = metrics
        versions    = ch_versions
}