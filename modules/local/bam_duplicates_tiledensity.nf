process BAM_DUPLICATES_TILEDENSITY {
    tag "$meta.id"
    label 'process_low'
    

    input:
    tuple val(meta), path(bam)

    output:
    tuple val(meta), path("*.tiledensity.tab") , emit: tab
    path "versions.yml"                        , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    def bin="/groups/vbcf-ngs/bin/preprocessing/bam_pos"
     """
       $bin  duplicates  --bampath ${bam} --outpath ${prefix}_tiledensity.tab --id ${meta.id}

       cat <<-END_VERSIONS > versions.yml
       "${task.process}":
            bam_pos: \$(echo \$($bin --version 2>&1) | head -n 1)
       END_VERSIONS
     """

    stub:
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    touch ${prefix}_tiledensity.tab 

    cat <<-END_VERSIONS > versions.yml
       "${task.process}":
            fastq: \$(echo \$($fq --version 2>&1) | head -n 1)
    END_VERSIONS
    """
}
