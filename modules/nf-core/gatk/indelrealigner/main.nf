process GATK_INDELREALIGNER {
    tag "$meta.id"
    label 'process_single'

    conda "bioconda::gatk=3.5"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/gatk:3.5--hdfd78af_11':
        'biocontainers/gatk:3.5--hdfd78af_11' }"

    input:
    tuple val(meta), path(bam), path(bai), path(intervals)
    path(fasta)
    path(fai)
    path(dict)
    path(known_vcf)
    path(known_vcf_tbi)

    output:
    tuple val(meta), path("*.bam"), path("*.bai"), emit: bam
    path "versions.yml"           , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    def known = known_vcf ? "-known ${known_vcf}" : ""

    if ("$bam" == "${prefix}.bam") error "Input and output names are the same, set prefix in module configuration to disambiguate!"

    def avail_mem = 3072
    if (!task.memory) {
        log.info '[GATK IndelRealigner] Available memory not known - defaulting to 3GB. Specify process memory requirements to change this.'
    } else {
        avail_mem = (task.memory.mega*0.8).intValue()
    }

    """
    gatk3 \\
        -Xmx${avail_mem}M \\
        -T IndelRealigner \\
        -R ${fasta} \\
        -I ${bam} \\
        --targetIntervals ${intervals} \\
        ${known} \\
        -o ${prefix}.bam \\
        $args

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        gatk: \$(echo \$(gatk3 --version))
    END_VERSIONS
    """
}
