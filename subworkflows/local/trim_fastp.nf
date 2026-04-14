include { SEQTK_SAMPLE  } from '../../modules/local/subsample'
include { FASTP         } from '../../modules/local/fastp'
include { UMI_PROCESS  } from './umi_process'
include { FASTQC       } from '../../modules/nf-core/fastqc/main'

workflow TRIM_FASTP {

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

    //TODO: try to shift smart subsample before UMI processing
    //problem is that we might need 3-4 fastq files, not the 2 standard ones


    //use random seed per sample (subsampling study) or fixed seed for all samples
    //def DO_RANDOM = params.subsample_random_seed ?: false not implemented
    def DO_RANDOM = true
    def RANDOM_SEED = 42
    def random = new Random(RANDOM_SEED)
    umi_processed.map { meta, reads ->
        if(DO_RANDOM){
            rs = random.nextInt(10000)
        } else {
            rs = RANDOM_SEED
        }
        tuple( meta, reads, subsample_nr, rs )
    }.set { umi_processed_with_seed }
    SEQTK_SAMPLE( umi_processed_with_seed )
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
        FASTP ( SEQTK_SAMPLE.out.reads ).reads.set{ trim_reads }
        trim_log    = FASTP.out.json
        ch_versions = ch_versions.mix(FASTP.out.versions.first())
    }


    emit:
    reads = trim_reads // channel: [ val(meta), [ reads ] ]
    fastqc = FASTQC.out.zip //
    trim_log           // channel: [ val(meta), [ txt ] ]

    versions = ch_versions.ifEmpty(null) // channel: [ versions.yml
}



