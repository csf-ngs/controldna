

process CUTADAPT {
    tag "$meta.id"
    label 'process_medium'
    
    conda (params.enable_conda ? 'bioconda::cutadapt=3.4' : null)
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/cutadapt:3.4--py39h38f01e4_1' :
        'quay.io/biocontainers/cutadapt:3.4--py39h38f01e4_1' }"

    input:
    tuple val(meta), path(reads)
    val(trimstring)

    output:
    tuple val(meta), path('*.trim.fastq.gz'), emit: reads
    tuple val(meta), path('*.log')          , emit: log
    path "versions.yml"                     , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: trimstring
    def prefix = task.ext.prefix ?: "${meta.id}"
    def trimmed  = meta.single_end ? "-o ${prefix}.trim.fastq.gz" : "-o ${prefix}_1.trim.fastq.gz -p ${prefix}_2.trim.fastq.gz"
    //for consistent naming of files in multiqc report (otherwise input file name)
    def link_input = link_input(meta.single_end, prefix, reads)
    def lreads = linked_reads(meta.single_end, prefix, reads)
    """
    $link_input

    cutadapt \\
        --cores $task.cpus \\
        $args \\
        $trimmed \\
        $lreads \\
        > ${prefix}.cutadapt.log
    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        cutadapt: \$(cutadapt --version)
    END_VERSIONS
    """
}

def linked_reads(single_end, prefix, reads){
    single_end ? "${prefix}.fastq.gz" : "${prefix}_1.fastq.gz ${prefix}_2.fastq.gz"
}

def link_input(single_end, prefix, reads){
    if(single_end){
                """
                [ ! -f  ${prefix}.fastq.gz ] && ln -s $reads ${prefix}.fastq.gz
                """
     } else {
                """
                [ ! -f  ${prefix}_1.fastq.gz ] && ln -s ${reads[0]} ${prefix}_1.fastq.gz
                [ ! -f  ${prefix}_2.fastq.gz ] && ln -s ${reads[1]} ${prefix}_2.fastq.gz
                """
     }
}