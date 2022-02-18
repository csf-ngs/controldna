include { PICARD_COLLECTWGSMETRICS         } from '../../modules/nf-core/modules/picard/collectwgsmetrics/main'
include { PICARD_COLLECTMULTIPLEMETRICS    } from '../../modules/nf-core/modules/picard/collectmultiplemetrics/main'

workflow BAM_DNA_QC {
    take:
        bam         // channel: [ val(meta), [ bam ] ]
        bai         // channel: [ val(meta), [ bai ] ]
        fasta

    main:

      ch_versions       = Channel.empty()

      PICARD_COLLECTWGSMETRICS(bam, fasta)
      ch_versions = ch_versions.mix(PICARD_COLLECTWGSMETRICS.out.versions.first())

      PICARD_COLLECTMULTIPLEMETRICS(bam, fasta)
      ch_versions = ch_versions.mix(PICARD_COLLECTMULTIPLEMETRICS.out.versions.first())    

    emit:
        wgs           = PICARD_COLLECTWGSMETRICS.out.metrics              //  channel: [ val(meta), met ]
        multiple     = PICARD_COLLECTMULTIPLEMETRICS.out.metrics           // channel: [ val(meta), met ]
        versions      = ch_versions
}

