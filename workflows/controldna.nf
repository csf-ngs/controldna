/*
========================================================================================
    VALIDATE INPUTS
========================================================================================
*/

def summary_params = NfcoreSchema.paramsSummaryMap(workflow, params)

// Validate input parameters
WorkflowControldna.initialise(params, log)

// TODO nf-core: Add all file path parameters for the pipeline to the list below
// Check input path parameters to see if they exist
def checkPathParamList = [ params.input, params.multiqc_config, params.fasta ]
for (param in checkPathParamList) { if (param) { file(param, checkIfExists: true) } }

// Check mandatory parameters
if (params.input) { ch_input = file(params.input) } else { exit 1, 'Input samplesheet not specified!' }

def bwa_index = params.genome ? params.genomes[ params.genome ].bwa ?: false : false
if(bwa_index == false){
    log.error("no valid bwa index found for genome build: ${params.genome}")
    System.exit(1)
} else {
    log.info("bwa index: ${bwa_index}")
}

// Save AWS IGenomes file containing annotation version
def anno_readme = params.genomes[params.genome]?.readme
if (anno_readme && file(anno_readme).exists()) {
    file("${params.outdir}/genome/").mkdirs()
    file(anno_readme).copyTo("${params.outdir}/genome/")
}

def subsample_str = params.subsample ?: "0"


/*
========================================================================================
    CONFIG FILES
========================================================================================
*/

ch_multiqc_config        = file("$projectDir/assets/multiqc_config.yaml", checkIfExists: true)
ch_multiqc_custom_config = params.multiqc_config ? Channel.fromPath(params.multiqc_config) : Channel.empty()

/*
========================================================================================
    IMPORT LOCAL MODULES/SUBWORKFLOWS
========================================================================================
*/

//
// SUBWORKFLOW: Consisting of a mix of local and nf-core/modules
//
include { INPUT_CHECK   } from '../subworkflows/local/input_check'
include { TRIM_CUTADAPT } from '../subworkflows/local/trim_cutadapt'
include { MAP_BWAMEM    } from '../subworkflows/local/map_bwamem'
include { BAM_DNA_QC    } from '../subworkflows/local/bam_dna_qc'
include { SUBDIR        } from '../modules/local/subdir'
include { REPORTDIR     } from '../modules/local/reportdir'

/*
========================================================================================
    IMPORT NF-CORE MODULES/SUBWORKFLOWS
========================================================================================
*/

//
// MODULE: Installed directly from nf-core/modules
//

include { FASTQC as  FASTQC_TRIMMED   } from '../modules/nf-core/fastqc/main'
include { MULTIQC                     } from '../modules/nf-core/multiqc/main'
include { CUSTOM_DUMPSOFTWAREVERSIONS } from '../modules/nf-core/custom/dumpsoftwareversions/main'
/*
========================================================================================
    RUN MAIN WORKFLOW
========================================================================================
*/

// Info required for completion email and summary
def multiqc_report = []

workflow CONTROLDNA {

    ch_versions = Channel.empty()



    //
    // SUBWORKFLOW: Read in samplesheet, validate and stage input files
    //
    INPUT_CHECK (
        ch_input
    )
    ch_versions = ch_versions.mix(INPUT_CHECK.out.versions)


    //
    //SUBWORKFLOW trim cutadapt
    // todo false => param.skipTrim
    TRIM_CUTADAPT(
        INPUT_CHECK.out.reads, false, subsample_str
    )
    ch_versions = ch_versions.mix(TRIM_CUTADAPT.out.versions.first())

    FASTQC_TRIMMED (
        TRIM_CUTADAPT.out.reads
    )
    ch_versions = ch_versions.mix(FASTQC_TRIMMED.out.versions.first())


    MAP_BWAMEM(
        TRIM_CUTADAPT.out.reads, Channel.fromPath(bwa_index).collect()
    )
    ch_versions = ch_versions.mix(MAP_BWAMEM.out.versions.first())

    //move up with stopifnot
    def fasta = params.genome ? params.genomes[ params.genome ].fasta : ""
    BAM_DNA_QC(
        MAP_BWAMEM.out.bam_bai, fasta
    )
    ch_versions = ch_versions.mix(BAM_DNA_QC.out.versions.first())

    CUSTOM_DUMPSOFTWAREVERSIONS (
        ch_versions.unique().collectFile(name: 'collated_versions.yml')
    )

    //
    // MODULE: MultiQC
    //
    workflow_summary    = WorkflowControldna.paramsSummaryMultiqc(workflow, summary_params)
    ch_workflow_summary = Channel.value(workflow_summary)
 

    ch_multiqc_files = Channel.empty()
    ch_multiqc_files = ch_multiqc_files.mix(Channel.from(ch_multiqc_config))
    ch_multiqc_files = ch_multiqc_files.mix(ch_multiqc_custom_config.collect().ifEmpty([]))
    ch_multiqc_files = ch_multiqc_files.mix(ch_workflow_summary.collectFile(name: 'workflow_summary_mqc.yaml'))
    ch_multiqc_files = ch_multiqc_files.mix(CUSTOM_DUMPSOFTWAREVERSIONS.out.mqc_yml.collect())
    ch_multiqc_files = ch_multiqc_files.mix(TRIM_CUTADAPT.out.fastqc.collect{it[1]}.ifEmpty([]))
    ch_multiqc_files = ch_multiqc_files.mix(TRIM_CUTADAPT.out.trim_log.collect{it[1]}.ifEmpty([]))
    ch_multiqc_files = ch_multiqc_files.mix(FASTQC_TRIMMED.out.zip.collect{it[1]}.ifEmpty([]))
    ch_multiqc_files = ch_multiqc_files.mix(MAP_BWAMEM.out.dup_metrics.collect{it[1]}.ifEmpty([]))
    ch_multiqc_files = ch_multiqc_files.mix(MAP_BWAMEM.out.spatial_lines_json)
    ch_multiqc_files = ch_multiqc_files.mix(BAM_DNA_QC.out.wgs.collect{it[1]}.ifEmpty([]))
    ch_multiqc_files = ch_multiqc_files.mix(BAM_DNA_QC.out.multiple.collect{it[1]}.ifEmpty([]))
    ch_multiqc_files = ch_multiqc_files.mix(BAM_DNA_QC.out.ccurve.collect{it[1]}.ifEmpty([]))
    ch_multiqc_files = ch_multiqc_files.mix(BAM_DNA_QC.out.c_curve.collect{it[1]}.ifEmpty([]))
    ch_multiqc_files = ch_multiqc_files.mix(BAM_DNA_QC.out.mosdepth_global.collect{it[1]}.ifEmpty([]))
    ch_multiqc_files = ch_multiqc_files.mix(BAM_DNA_QC.out.mosdepth_summary.collect{it[1]}.ifEmpty([]))

    SUBDIR("stats", ch_multiqc_files.collect())

    MULTIQC (
        ch_multiqc_files.collect()
    )
    ch_multiqc_report = MULTIQC.out.report
    ch_versions    = ch_versions.mix(MULTIQC.out.versions)


    if(params.reportdir && params.multiqc_title){
       ch_report_mqc = ch_multiqc_report.mix(MULTIQC.out.data)
       ch_report_data = MAP_BWAMEM.out.spatial_html.mix(MAP_BWAMEM.out.spatial_tabs.flatten())
       ch_report = ch_report_mqc.mix(ch_report_data).toList()
       REPORTDIR(params.reportdir+"/"+params.multiqc_title, ch_report)
    }

}

/*
========================================================================================
    COMPLETION EMAIL AND SUMMARY
========================================================================================
*/

workflow.onComplete {
    if (params.email || params.email_on_fail) {
        NfcoreTemplate.email(workflow, params, summary_params, projectDir, log, multiqc_report)
    }
    NfcoreTemplate.summary(workflow, params, log)
}

/*
========================================================================================
    THE END
========================================================================================
*/
