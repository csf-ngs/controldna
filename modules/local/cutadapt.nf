

process CUTADAPT {
    tag "$meta.id"
    label 'process_medium'
    
    conda (params.enable_conda ? 'bioconda::cutadapt=3.4' : null)
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/cutadapt:3.4--py39h38f01e4_1' :
        'quay.io/biocontainers/cutadapt:3.4--py39h38f01e4_1' }"

    input:
    tuple val(meta), path(reads)

    output:
    tuple val(meta), path('*.trim.fastq.gz'), emit: reads
    tuple val(meta), path('*.log')          , emit: log
    path "versions.yml"                     , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def trueseq = "-a AGATCGGAAGAGCACACGTCTGAACTCCAGTCA " + ( meta.single_end ? "" : " -A AGATCGGAAGAGCGTCGTGTAGGGAAAGAGTGT" )
    def nextera = "-a CTGTCTCTTATACACATCT " + ( meta.single_end ? "" : " -A CTGTCTCTTATACACATCT" )

    //default trueseq
    def trim_string = meta.single_end ? trueseq_sr : trueseq_pe

    if(meta.adapter){  
        switch(meta.adapter.toLowerCase()) {            
            case "trueseq":
                trim_string = trueseq
                break;
             case "nextera":
                 trim_string = nextera
                 break; 
            default: 
                 log.error("ERROR: unknown adapter type declared for sample: ${meta.id} ${meta.adapter} ${reads}")
                 System.exit(1)
                 break;
        }
    }

    def prefix = task.ext.prefix ?: "${meta.id}_trimmed"
    def trimmed  = meta.single_end ? "-o ${prefix}.fastq.gz" : "-o ${prefix}_1.fastq.gz -p ${prefix}_2.fastq.gz"
    //for consistent naming of files in multiqc report (otherwise input file name)
    def link_input = link_input(meta.single_end, prefix, reads)
    def lreads = linked_reads(meta.single_end, prefix, reads)
    """
    $link_input

    cutadapt \\
        --cores $task.cpus \\
        $trim_string \\
        $trimmed \\
        $lreads \\
        > ${prefix}.cutadapt.log
    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        cutadapt: \$(cutadapt --version)
    END_VERSIONS
    """

    stub:
    def prefix = task.ext.prefix ?: "${meta.id}_trimmed"
    """
    touch ${prefix}_1.fastq.gz
    touch ${prefix}_2.fastq.gz
    touch ${prefix}.cutadapt.log

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