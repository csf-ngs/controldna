include { SEQTK_SAMPLE  } from '../../modules/local/subsample'
include { CUTADAPT     } from '../../modules/local/cutadapt'
include { UMI_PROCESS  } from './umi_process'
include { FASTQC       } from '../../modules/nf-core/fastqc/main'

workflow TRIM_CUTADAPT {

    take:
    reads         // channel: [ val(meta), [ reads ] ]
    skip_trimming // boolean: true/false
    subsample_nr //str+G M K

    main:
    ch_versions = Channel.empty()
    

    reads.branch { m, r ->
        umi: m.umi && m.umi != ""
        no_umi: true
    }
    .set { reads_umi }

    UMI_PROCESS(reads_umi.umi)
    ch_versions = ch_versions.mix(UMI_PROCESS.out.versions.first())

    umi_processed = reads_umi.no_umi.mix(UMI_PROCESS.out.reads)


    SEQTK_SAMPLE (
         umi_processed, subsample_nr
    )
    ch_versions = ch_versions.mix(SEQTK_SAMPLE.out.versions.first())

    //
    // MODULE: Run FastQC
    //
    FASTQC (
         SEQTK_SAMPLE.out.reads
    )
    ch_versions = ch_versions.mix(FASTQC.out.versions.first())

    

    trim_reads = SEQTK_SAMPLE.out.reads
    trim_log   = Channel.empty()

    if (!skip_trimming) {
        CUTADAPT ( SEQTK_SAMPLE.out.reads ).reads.set{ trim_reads }
        trim_log    = CUTADAPT.out.log
        ch_versions = ch_versions.mix(CUTADAPT.out.versions.first())
    }


    emit:
    reads = trim_reads // channel: [ val(meta), [ reads ] ]
    fastqc = FASTQC.out.zip //
    trim_log           // channel: [ val(meta), [ txt ] ]

    versions = ch_versions.ifEmpty(null) // channel: [ versions.yml
}


