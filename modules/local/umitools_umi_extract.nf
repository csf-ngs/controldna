process UMITOOLS_UMI_EXTRACT {
    tag "$meta.id"
    label 'process_medium'

    conda (params.enable_conda ? "bioconda::umi_tools=1.1.2" : null)
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/umi_tools:1.1.2--py38h4a8c8d9_0' :
        'quay.io/biocontainers/umi_tools:1.1.2--py38h4a8c8d9_0' }"

    input:
    tuple val(meta), path(reads)

    output:
    tuple val(meta), path("*_umi*.fastq.gz"), emit: reads
    path "versions.yml"                , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}_umi"
    def umi_file = meta.umi_file //TODO: maybe make to optional path input to get linked in
    def pattern = meta.umi
    def fq = "/groups/vbcf-ngs/bin/preprocessing/fastq umi"
    """
    ${fq} --umifile ${umi_file} --readfile ${reads[0]} --outfile ${prefix}_1.fastq.gz --pattern ${pattern}
    ${fq} --umifile ${umi_file} --readfile ${reads[1]} --outfile ${prefix}_2.fastq.gz --pattern ${pattern}

    cat <<-END_VERSIONS > versions.yml
       "${task.process}":
            fastq: \$(echo \$($fq --version 2>&1) | head -n 1)
    END_VERSIONS
    """

    stub:
    def prefix = task.ext.prefix ?: "${meta.id}_umi"
    """
    touch ${prefix}_1.fastq.gz
    touch ${prefix}_2.fastq.gz

    cat <<-END_VERSIONS > versions.yml
       "${task.process}":
            fastq: \$(echo \$($fq --version 2>&1) | head -n 1)
    END_VERSIONS

    """


}
