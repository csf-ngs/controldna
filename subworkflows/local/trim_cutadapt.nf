//
// cutadapt adapter trimming
//
include { CUTADAPT } from '../../modules/nf-core/cutadapt'


workflow TRIM_CUTADAPT {

    take:
    reads         // channel: [ val(meta), [ reads ] ]
    skip_trimming // boolean: true/false
    adaptor_r1    // [str]
    adaptor_r2    // [str]

    main:
    ch_versions = Channel.empty()

    trim_reads = reads
    trim_log   = Channel.empty()

    if (!skip_trimming) {
        CUTADAPT ( reads ).reads.set { trim_reads }
        trim_log    = CUTADAPT.out.log
        ch_versions = ch_versions.mix(CUTADAPT.out.versions.first())
    }


    emit:
    reads = trim_reads // channel: [ val(meta), [ reads ] ]

    trim_log           // channel: [ val(meta), [ txt ] ]

    versions = ch_versions.ifEmpty(null) // channel: [ versions.yml
}


