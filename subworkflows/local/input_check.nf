//
// Check input samplesheet and get read channels
//

include { SAMPLESHEET_CHECK } from '../../modules/local/samplesheet_check'

workflow INPUT_CHECK {
    take:
    samplesheet // file: /path/to/samplesheet.csv

    main:
    SAMPLESHEET_CHECK ( samplesheet )
        .csv
        .splitCsv ( header:true, sep:',' )
        .map { create_fastq_channels(it) }
        .set { reads }

    emit:
    reads                                     // channel: [ val(meta), [ reads ] ]
    versions = SAMPLESHEET_CHECK.out.versions // channel: [ versions.yml ]
}

// Function to get list of [ meta, [ fastq_1, fastq_2 ] ]
def create_fastq_channels(LinkedHashMap row) {
    def meta = [:]
    meta.id           = row.sample

    def array = []
    if (!file(row.fastq_1).exists()) {
        exit 1, "ERROR: Please check input samplesheet -> Read 1 FastQ file does not exist!\n${row.fastq_1}"
    } else {
        rg = extract_rg(row.fastq_1)
        meta.read_group = rg
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
    return array
}


def extract_rg(path) {
    def ex = "${projectDir}/bin/extract_read_group.sh ${path}".execute()
    ex.in.text
}
