process ADD_UMI_TO_BAM {
    tag "$meta.id"
    label 'process_medium'

    conda (params.enable_conda ? "bioconda::umi_tools=1.1.2" : null)
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/umi_tools:1.1.2--py38h4a8c8d9_0' :
        'quay.io/biocontainers/umi_tools:1.1.2--py38h4a8c8d9_0' }"

    input:
    tuple val(meta), path(bam)

    output:
    tuple val(meta), path("*_umi*.fastq.gz"), emit: reads
    path "versions.yml"                , emit: versions
//TODO: stats on UMI distribution histogram etc.. in after markduplicates
//historgram 0, 1, 2 error distance.

    when:
    task.ext.when == null || task.ext.when

    script:
    def prefix = task.ext.prefix ?: "${meta.id}_umi"

    """
    umi_to_bam.py $bam ${prefix}.bam
    
    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
            umitools: \$(umi_tools --version 2>&1 | sed 's/^.*UMI-tools version://; s/ *\$//')
    END_VERSIONS

    """

    stub:
    def prefix = task.ext.prefix ?: "${meta.id}_umi"
    """
    touch ${prefix}.bam

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
            umitools: \$(umi_tools --version 2>&1 | sed 's/^.*UMI-tools version://; s/ *\$//')
    END_VERSIONS

    """


}
