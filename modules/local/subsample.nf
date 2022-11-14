process SEQTK_SAMPLE {
    tag "$meta.id"
    label 'process_low'

    conda (params.enable_conda ? "bioconda::seqtk=1.3" : null)
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/seqtk:1.3--h5bf99c6_3' :
        'quay.io/biocontainers/seqtk:1.3--h5bf99c6_3' }"

    input:
    tuple val(meta), path(reads)
    val sample_size

    output:
    tuple val(meta), path("*.fastq.gz"), emit: reads
    path "versions.yml"                , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}_subsample"
    def sample(readsfile, suffix) = "seqtk sample $args -2 $readsfile $sample_size | gzip --no-name > ${prefix}.${suffix}"
    if (meta.single_end) {
        if(sample_size == 0){
            """
            cp $reads ${prefix}.fastq.gz

            cat <<-END_VERSIONS > versions.yml
            "${task.process}":
                    seqtk: \$(echo \$(seqtk 2>&1) | sed 's/^.*Version: //; s/ .*\$//')
            END_VERSIONS
            """

        } else {

        """
        ${sample(reads, ".fastq.gz")}
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
        if(sample_size == 0){
            """
            cp ${reads[0]} ${prefix}_1.fastq.gz
            cp ${reads[1]} ${prefix}_2.fastq.gz

            cat <<-END_VERSIONS > versions.yml
            "${task.process}":
                    seqtk: \$(echo \$(seqtk 2>&1) | sed 's/^.*Version: //; s/ .*\$//')
            END_VERSIONS
            """
        } else {
        """
        ${sample(reads[0], "_1.fastq.gz")}
        ${sample(reads[1], "_2.fastq.gz")}

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
