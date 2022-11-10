//
// cutadapt adapter trimming - will be also UMI extract -> CUTADAPT
//
include { CUTADAPT } from '../../modules/local/cutadapt'


workflow TRIM_CUTADAPT {

    def trueseq_pe = "-a AGATCGGAAGAGCACACGTCTGAACTCCAGTCA -A AGATCGGAAGAGCGTCGTGTAGGGAAAGAGTGT"
    def trueseq_sr = "-a AGATCGGAAGAGCACACGTCTGAACTCCAGTCA"
    def nextera_pe = "-a CTGTCTCTTATACACATCT"

    take:
    reads         // channel: [ val(meta), [ reads ] ]
    skip_trimming // boolean: true/false

    main:
    ch_versions = Channel.empty()
    
    reads.map {
        meta, fastq ->
            //log.debug("${meta} ${fastq}")
            meta.single_end ? trueseq_sr : trueseq_pe
    }.set{ trimstring }

    trim_reads = reads
    trim_log   = Channel.empty()

    if (!skip_trimming) {
        CUTADAPT ( reads, trimstring ).reads.set{ trim_reads }
        trim_log    = CUTADAPT.out.log
        ch_versions = ch_versions.mix(CUTADAPT.out.versions.first())
    }


    emit:
    reads = trim_reads // channel: [ val(meta), [ reads ] ]

    trim_log           // channel: [ val(meta), [ txt ] ]

    versions = ch_versions.ifEmpty(null) // channel: [ versions.yml
}


