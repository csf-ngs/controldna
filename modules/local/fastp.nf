process FASTP {
    tag "$meta.id"
    label 'process_medium'
    
    conda (params.enable_conda ? 'bioconda::fastp=0.23.4' : null)
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/fastp:0.23.4--h5f740d0_0' :
        'biocontainers/fastp:0.23.4--h5f740d0_0' }"

    input:
    tuple val(meta), path(reads)

    output:
    tuple val(meta), path("*.fastq.gz")     , emit: reads
    tuple val(meta), path('*.json')         , emit: json
    tuple val(meta), path('*.log')          , emit: log //fastp log is huge and not needed
    path "versions.yml"                     , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def trueseq = "-a AGATCGGAAGAGCACACGTCTGAACTCCAGTCA " + ( meta.single_end ? "" : " -A AGATCGGAAGAGCGTCGTGTAGGGAAAGAGTGT" )
    def nextera = "-a CTGTCTCTTATACACATCT " + ( meta.single_end ? "" : " -A CTGTCTCTTATACACATCT" )

    //default trueseq
    def trim_string = trueseq

    //TODO: still copied from cutadapt must be adapted
    if(meta.adapter){  
        switch(meta.adapter.toLowerCase()) {            
            case "trueseq":
                trim_string = trueseq
                break;
             case "nextera":
                 trim_string = nextera
                 break; 
            default: 
                 log.error("ERROR: unknown adapter type declared for sample: ${meta.id} ${meta.adapter}")
                 System.exit(1)
                 break;
        }
    }

    def prefix = task.ext.prefix ?: "${meta.id}_trimmed"
    //for consistent naming of files in multiqc report (otherwise input file name)
    def freads = meta.single_end ? "-i ${reads[0]}" : "-i ${reads[0]} -I ${reads[1]}"
    def oreads = meta.single_end ? "-o ${prefix}.fastq.gz" : "-o ${prefix}_1.fastq.gz -O ${prefix}_2.fastq.gz"
    def detect_pe = meta.single_end ? "" : "--detect_adapter_for_pe"
    def trim_poly = " --trim_poly_g --trim_poly_x "
    def extra_args = params.extra_fastp_args ?: ""


    """
    fastp \\
        --thread $task.cpus \\
        --html ${prefix}.fastp.html \\
        --json ${prefix}.fastp.json \\
        $trim_poly \\
        $extra_args \\
        $freads \\
        $oreads \\
        $detect_pe \\
        > ${prefix}.fastp.log
    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        fastp: \$(fastp --version 2>&1 | sed -e "s/fastp //g")
    END_VERSIONS
    """

    stub:
    def prefix = task.ext.prefix ?: "${meta.id}_trimmed"
    """
    touch ${prefix}_1.fastq.gz
    touch ${prefix}_2.fastq.gz
    touch ${prefix}.fastp.log
    touch ${prefix}.fastp.html
    touch ${prefix}.fastp.json

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        fastp: \$(fastp --version 2>&1 | sed -e "s/fastp //g")
    END_VERSIONS

    """
}
