//
// Check input samplesheet and get read channels
//

include { SAMPLESHEET_CHECK } from '../../modules/local/samplesheet_check'

workflow INPUT_CHECK {
    take:
    samplesheet // file: /path/to/samplesheet.csv

    main:
    Channel
        .from( samplesheet )
        .splitCsv ( header:true, sep:',' )
        .map { create_fastq_channels(it) }
        .set { reads }

    emit:
    reads                                     // channel: [ val(meta), [ reads ] ]
    versions = "1.0" // channel: [ versions.yml ]
}

// Function to get list of [ meta, [ fastq_1, fastq_2 ] ]
def create_fastq_channels(LinkedHashMap row) {
    def meta = [:]
    meta.id           = row.sample

    meta << row

    def array = []
    if (!file(row.fastq_1).exists()) {
        exit 1, "ERROR: Please check input samplesheet -> Read 1 FastQ file does not exist!\n${row.fastq_1}"
    } else {
        rg = meta.id//extract_rg(row.fastq_1) does not work with aviti
        meta.read_group = "@RG\tID:${meta.id}\tSM:${meta.id}\tLB:${meta.id}\tPL:ILLUMINA"
    }
    if (row.fastq_2 != null) {
        meta.single_end = false
        if(file(row.fastq_2).exists()) {
            array = [ meta, [ file(row.fastq_1), file(row.fastq_2) ] ]
        } else {
            exit 1, "ERROR: Please check input samplesheet -> Read 2 FastQ file does not exist!\n${row.fastq_2}"
        }
    } else {
        meta.single_end = true
        array = [ meta, [ file(row.fastq_1) ] ]
    }
    println(row)
    println(meta)
    //println(array)
    return array
}


def extract_rg(path) {
    def ex = "${projectDir}/bin/extract_read_group.sh ${path}".execute()
    ex.in.text
}
