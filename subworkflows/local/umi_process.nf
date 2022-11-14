include { UMITOOLS_UMI_EXTRACT     } from '../../modules/local/umitools_umi_extract'

workflow UMI_PROCESS {

    take:
    reads         // channel: [ val(meta), [ reads ] ]

    main:
    ch_versions = Channel.empty()

    reads.branch { m, r ->
        r2: m.umi_file =~ /R2/
        unknown: true 
    }
    .set { reads_umi }
  
    UMITOOLS_UMI_EXTRACT(reads_umi.r2)
    

    umi_log   = Channel.empty()


    emit:
    reads = UMITOOLS_UMI_EXTRACT.out.reads // channel: [ val(meta), [ reads ] ]

    umi_log           // channel: [ val(meta), [ txt ] ]

    versions = ch_versions.ifEmpty(null) // channel: [ versions.yml
}