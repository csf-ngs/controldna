process PICARD_UMIAWAREMARKDUPLICATESWITHMATECIGAR {
    tag "$meta.id"
    label 'process_medium'

    conda (params.enable_conda ? "bioconda::picard=2.26.10" : null)
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/picard:2.26.10--hdfd78af_0' :
        'quay.io/biocontainers/picard:2.26.10--hdfd78af_0' }"

    input:
    tuple val(meta), path(bam)

    output:
    tuple val(meta), path("*.bam")        , emit: bam
    tuple val(meta), path("*.bai")        , optional:true, emit: bai
    tuple val(meta), path("*.metrics.txt"), emit: metrics
    path  "versions.yml"                  , emit: versions

    when:
    task.ext.when == null || task.ext.when
//No MINIMAL_DISTANCE like in  MarkDuplicatesWithMateCigar so I don't know if this is really MarkDuplicatesWithMateCigar or more like MarkDuplicates
    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    def avail_mem = 3
    def umi = " --UMI_TAG_NAME "
    def max_edit = meta.umi_edit_dist ?: 1
    if (!task.memory) {
        log.info '[Picard UMIAwareMarkDuplicatesWithMateCigar] Available memory not known - defaulting to 3GB. Specify process memory requirements to change this.'
    } else {
        avail_mem = task.memory.giga
    }
    """
    picard \\
        -Xmx${avail_mem}g \\
        UmiAwareMarkDuplicatesWithMateCigar \\
        $args \\
        MAX_EDIT_DISTANCE_TO_JOIN=${max_edit} \\
        OPTICAL_DUPLICATE_PIXEL_DISTANCE=2500 \\
        I=$bam \\
        O=${prefix}.md.bam \\
        M=${prefix}.MarkDuplicates.metrics.txt \\
        UMI_METRICS=${prefix}.MD_umi.metrics.txt



    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        picard: \$(echo \$(picard UmiAwareMarkDuplicatesWithMateCigar --version 2>&1) | grep -o 'Version:.*' | cut -f2- -d:)
    END_VERSIONS
    """

    stub:
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    touch ${prefix}.MarkDuplicates.metrics.txt
    touch ${prefix}.md.bam
    touch ${prefix}.md.bam.bai

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        picard: \$(echo \$(picard UmiAwareMarkDuplicatesWithMateCigar --version 2>&1) | grep -o 'Version:.*' | cut -f2- -d:)
    END_VERSIONS

    """

}
