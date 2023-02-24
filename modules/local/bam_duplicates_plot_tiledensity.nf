process BAM_DUPLICATES_PLOT_TILEDENSITY {
    tag "$meta.id"
    label 'process_low'
    
    container "/groups/vbcf-ngs/misc/infra/singularity/amd64/pipeline/pipgen_latest.sif" //markdown, ggplot viridis, collectcontrolresults

    input:
    tuple val(meta), path(bam)

    output:
    tuple val(meta), path("*.duplications_tiles_lines_mqc.json") , emit: json
    tuple val(meta), path("*.duplications_tiles_report.html") , emit: html
    tuple val(meta), path('*.log')          , emit: log
    path "versions.yml"                     , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def trueseq = "-a AGATCGGAAGAGCACACGTCTGAACTCCAGTCA " + ( meta.single_end ? "" : " -A AGATCGGAAGAGCGTCGTGTAGGGAAAGAGTGT" )
    def nextera = "-a CTGTCTCTTATACACATCT " + ( meta.single_end ? "" : " -A CTGTCTCTTATACACATCT" )

    //default trueseq
    def trim_string = trueseq

    if(meta.adapter){  
        switch(meta.adapter.toLowerCase()) {            
            case "trueseq":
                trim_string = trueseq
 //make line graph json of means across swaths for multiqc
 //make complete html report collecting all samples with good plots separately