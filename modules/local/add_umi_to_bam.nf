process ADD_UMI_TO_BAM {
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
//TODO: stats on UMI distribution histogram etc.. in after markduplicates
//historgram 0, 1, 2 error distance.

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}_umi"
    def umi_file = meta.umi_file //TODO: maybe make to optional path input to get linked in
    def pattern = meta.umi.replaceAll(".*:","")

    """
    umi_tools extract --bc-pattern=${pattern} --stdin=${umi_file} --read2-in=${reads[0]} --stdout=dummy1 --read2-out=${prefix}_1.fastq.gz
    umi_tools extract --bc-pattern=${pattern} --stdin=${umi_file} --read2-in=${reads[1]} --stdout=dummy2 --read2-out=${prefix}_2.fastq.gz

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
            umitools: \$(umi_tools --version 2>&1 | sed 's/^.*UMI-tools version://; s/ *\$//')
    END_VERSIONS

    """

    stub:
    def prefix = task.ext.prefix ?: "${meta.id}_umi"
    """
    touch ${prefix}_1.fastq.gz
    touch ${prefix}_2.fastq.gz

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
            umitools: \$(umi_tools --version 2>&1 | sed 's/^.*UMI-tools version://; s/ *\$//')
    END_VERSIONS

    """


}
