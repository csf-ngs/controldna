

process EXTRACT_READGROUP {
    tag "$meta.id"
    label 'process_low'
    
   
    conda (params.enable_conda ? "YOUR-TOOL-HERE" : null)
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/YOUR-TOOL-HERE':
        'quay.io/biocontainers/YOUR-TOOL-HERE' }"

    input:
    tuple val(meta), path(fastq)

    output:
    tuple val(meta), stdout(rg), emit: rg
    path "versions.yml" , emit: versions

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"

    """
    extract_read_group.sh ${fastq}

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        extractreadgroup: 0.1
    END_VERSIONS
    """
}
