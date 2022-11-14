//
// cutadapt adapter trimming - will be also UMI extract -> CUTADAPT
//
include { CUTADAPT     } from '../../modules/local/cutadapt'
include { UMI_PROCESS  } from './umi_process'

workflow TRIM_CUTADAPT {

    take:
    reads         // channel: [ val(meta), [ reads ] ]
    skip_trimming // boolean: true/false

    main:
    ch_versions = Channel.empty()
    
    reads.branch { m, r ->
        umi: m.umi != ""
        no_umi: true
    }
    .set { reads_umi }

    UMI_PROCESS(reads_umi.umi)

    umi_processed = reads_umi.no_umi.mix(UMI_PROCESS.out.reads)

    trim_reads = umi_processed
    trim_log   = Channel.empty()

    if (!skip_trimming) {
        CUTADAPT ( umi_processed ).reads.set{ trim_reads }
        trim_log    = CUTADAPT.out.log
        ch_versions = ch_versions.mix(CUTADAPT.out.versions.first())
    }


    emit:
    reads = trim_reads // channel: [ val(meta), [ reads ] ]

    trim_log           // channel: [ val(meta), [ txt ] ]

    versions = ch_versions.ifEmpty(null) // channel: [ versions.yml
}


