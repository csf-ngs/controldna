include { PICARD_COLLECTWGSMETRICS         } from '../../modules/nf-core/picard/collectwgsmetrics/main'
include { PICARD_COLLECTMULTIPLEMETRICS    } from '../../modules/nf-core/picard/collectmultiplemetrics/main'
include { PRESEQ_LCEXTRAP                  } from '../../modules/nf-core/preseq/lcextrap/main'
include { MOSDEPTH                         } from '../../modules/nf-core/mosdepth/main'

workflow BAM_DNA_QC {
    take:
        bam_bai     // channel: [ val(meta), [ (bam, bai) ] ]
        fasta

    main:

      ch_versions       = Channel.empty()

      PICARD_COLLECTWGSMETRICS(bam_bai, fasta)
      ch_versions = ch_versions.mix(PICARD_COLLECTWGSMETRICS.out.versions.first())

      bam = bam_bai.map{ m, bam, bai -> 
          tuple(m, bam)
      }

      m_bam_bai = bam_bai.map{ m, bam, bai -> 
           tuple(m, bam, bai)
      }
      
      MOSDEPTH(m_bam_bai)

      PICARD_COLLECTMULTIPLEMETRICS(bam, fasta)
      ch_versions = ch_versions.mix(PICARD_COLLECTMULTIPLEMETRICS.out.versions.first(),MOSDEPTH.out.versions.first())
         
      PRESEQ_LCEXTRAP(bam)
      ch_versions = ch_versions.mix(PRESEQ_LCEXTRAP.out.versions.first())

    emit:
        wgs               = PICARD_COLLECTWGSMETRICS.out.metrics            //  channel: [ val(meta), met ]
        multiple          = PICARD_COLLECTMULTIPLEMETRICS.out.metrics       // channel: [ val(meta), met ]
        ccurve            = PRESEQ_LCEXTRAP.out.ccurve                      // channel: [ val(meta), met ]
        mosdepth_summary  = MOSDEPTH.out.summary_txt                        // channel: [ val(meta), met ]
        mosdepth_global   = MOSDEPTH.out.global_txt                        // channel: [ val(meta), met ]
        versions     = ch_versions
  
}

