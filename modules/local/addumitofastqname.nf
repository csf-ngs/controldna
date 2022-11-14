///hackisch and probably wrong!!

process ADDUMITOFASTQNAME {
    tag "$meta.id"
    label 'process_low'

    input:
    tuple val(meta), path(reads)

    output:
    tuple val(meta), path("*.fastq.gz"), emit: reads
    path "versions.yml"                , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}_withumi"
    if (meta.single_end) {
            """
            paste <(gunzip -c ${reads[0]}) <(gunzip -c ${reads[1]} | tail -n +2) | awk '{ if(NR % 4 == 1){ print \$1 "_" \$3 }else{ print \$1 }}' > ${prefix}_1.fastq.gz

            cat <<-END_VERSIONS > versions.yml
            "${task.process}":
                    bash: \$(echo \$(bash --version 2>&1) | head -n 1
            END_VERSIONS
            """

    } else {

        """
        paste <(gunzip -c ${reads[0]}) <(gunzip -c ${reads[2]} | tail -n +2) | awk '{ if(NR % 4 == 1){ print \$1 "_" \$3 }else{ print \$1 }}' > ${prefix}_1.fastq.gz
        paste <(gunzip -c ${reads[1]}) <(gunzip -c ${reads[2]} | tail -n +2) | awk '{ if(NR % 4 == 1){ print \$1 "_" \$3 }else{ print \$1 }}' > ${prefix}_2.fastq.gz

        cat <<-END_VERSIONS > versions.yml
        "${task.process}":
            bash: \$(echo \$(bash --version 2>&1) | head -n 1
        END_VERSIONS
        """
    }
    
    stub:
    def prefix = task.ext.prefix ?: "${meta.id}_withumi"
    """
    touch ${prefix}_1.fastq.gz
    touch ${prefix}_2.fastq.gz

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        bash: \$(echo \$(bash --version 2>&1) | head -n 1
    END_VERSIONS

    """

}

