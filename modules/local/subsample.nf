process SEQTK_SAMPLE {
    tag "$meta.id"

    label 'process_medium_memory'
    errorStrategy 'ignore'

    conda (params.enable_conda ? "bioconda::seqtk=1.3" : null)
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/seqtk:1.3--h5bf99c6_3' :
        'quay.io/biocontainers/seqtk:1.3--h5bf99c6_3' }"

    input:
    tuple val(meta), path(reads)
    val subsample_str

    output:
    tuple val(meta), path("*.fastq.gz"), emit: reads
    path "versions.yml"                , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}_subsample"
    def fq = "/groups/vbcf-ngs/bin/preprocessing/fastq head"
    //string because of bigint size
    def (fixed, subsample_size) = Utils.subsample_number(meta.subsample, subsample_str)

    if (meta.single_end) {
        if(subsample_size == "0"){
            """
            cp $reads ${prefix}.fastq.gz

            cat <<-END_VERSIONS > versions.yml
            "${task.process}":
                    seqtk: \$(echo \$(seqtk 2>&1) | sed 's/^.*Version: //; s/ .*\$//')
            END_VERSIONS
            """

        } else if (fixed == "sample"){

        """
        seqtk \\
            sample \\
            $args -2 \\
            $reads \\
            $subsample_size \\
            | gzip --no-name > ${prefix}.fastq.gz \\

        cat <<-END_VERSIONS > versions.yml
        "${task.process}":
            seqtk: \$(echo \$(seqtk 2>&1) | sed 's/^.*Version: //; s/ .*\$//')
        END_VERSIONS
        """
        } else {
        """
        ${fq} --inpath $reads --outpath ${prefix}.fastq.gz --snumber ${subsample_size}

                cat <<-END_VERSIONS > versions.yml
        "${task.process}":
            seqtk: \$(echo \$(seqtk 2>&1) | sed 's/^.*Version: //; s/ .*\$//')
        END_VERSIONS
        """
        }
    } else {
        if (!(args ==~ /.*-s[0-9]+.*/)) {
            args += " -s100 "
        }
        if(subsample_size == "0"){
            """
            cp ${reads[0]} ${prefix}_1.fastq.gz
            cp ${reads[1]} ${prefix}_2.fastq.gz

            cat <<-END_VERSIONS > versions.yml
            "${task.process}":
                    seqtk: \$(echo \$(seqtk 2>&1) | sed 's/^.*Version: //; s/ .*\$//')
            END_VERSIONS
            """
        } else if(fixed == "sample"){
        """
        seqtk \\
            sample \\
            $args -2 \\
            ${reads[0]} \\
            $subsample_size \\
            | gzip --no-name > ${prefix}_1.fastq.gz \\

        seqtk \\
            sample \\
            $args -2 \\
            ${reads[1]} \\
            $subsample_size \\
            | gzip --no-name > ${prefix}_2.fastq.gz \\

        cat <<-END_VERSIONS > versions.yml
        "${task.process}":
            seqtk: \$(echo \$(seqtk 2>&1) | sed 's/^.*Version: //; s/ .*\$//')
        END_VERSIONS
        """
        } else {
        """

        ${fq} --inpath ${reads[0]} --outpath ${prefix}_1.fastq.gz --snumber ${subsample_size}
        ${fq} --inpath ${reads[1]} --outpath ${prefix}_2.fastq.gz --snumber ${subsample_size}

        cat <<-END_VERSIONS > versions.yml
        "${task.process}":
            seqtk: \$(echo \$(seqtk 2>&1) | sed 's/^.*Version: //; s/ .*\$//')
        END_VERSIONS
        """
        }
    }
   

   stub:
   def prefix = task.ext.prefix ?: "${meta.id}_subsample"
   """
   touch ${prefix}_1.fastq.gz
   touch ${prefix}_2.fastq.gz

   cat <<-END_VERSIONS > versions.yml
   "${task.process}":
        seqtk: \$(echo \$(seqtk 2>&1) | sed 's/^.*Version: //; s/ .*\$//')
   END_VERSIONS

   """

}
