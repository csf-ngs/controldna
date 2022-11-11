include { PICARD_COLLECTWGSMETRICS         } from '../../modules/nf-core/picard/collectwgsmetrics/main'
include { PICARD_COLLECTMULTIPLEMETRICS    } from '../../modules/nf-core/picard/collectmultiplemetrics/main'
include { SAMTOOLS_NOSUPPLEMENTARY         } from '../../modules/local/samtoolsnosupplementary'
include { PRESEQ_LCEXTRAP                  } from '../../modules/nf-core/preseq/lcextrap/main'
include { PRESEQ_CCURVE                    } from '../../modules/nf-core/preseq/ccurve/main'
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
    
      //preseq can not handle supplementary alignments, must remove them
      SAMTOOLS_NOSUPPLEMENTARY(bam)

      PRESEQ_LCEXTRAP(SAMTOOLS_NOSUPPLEMENTARY.out.bam)
      ch_versions = ch_versions.mix(PRESEQ_LCEXTRAP.out.versions.first())

      PRESEQ_CCURVE(SAMTOOLS_NOSUPPLEMENTARY.out.bam)
      ch_versions = ch_versions.mix(PRESEQ_CCURVE.out.versions.first())


    emit:
        wgs               = PICARD_COLLECTWGSMETRICS.out.metrics            //  channel: [ val(meta), met ]
        multiple          = PICARD_COLLECTMULTIPLEMETRICS.out.metrics       // channel: [ val(meta), met ]
        ccurve            = PRESEQ_LCEXTRAP.out.ccurve                      // channel: [ val(meta), met ]
        c_curve           = PRESEQ_CCURVE.out.c_curve                      // channel: [ val(meta), met ]
        mosdepth_summary  = MOSDEPTH.out.summary_txt                        // channel: [ val(meta), met ]
        mosdepth_global   = MOSDEPTH.out.global_txt                        // channel: [ val(meta), met ]
        versions     = ch_versions
  
}

