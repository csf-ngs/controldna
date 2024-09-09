process PRIMER_CONTAMINANTS {
    tag "$meta.id"
    label 'process_rapid_1'
    errorStrategy 'ignore'

    module= [ "build-env/2020", 'bbmap/38.26-foss-2018b' ]

    input:
    tuple val(meta), path(reads)
    val processRun

    output:
    tuple val(meta), path("*.stats"), emit: stats
    path  "versions.yml"           , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def dimerc = "${baseDir}/resources/adapter_dimers.fa"
    """
    bbduk.sh -Xms3G -Xmx8G in=${reads[0]} rcomp=false threads=${task.cpus} hammingdistance=1 k=12 restrictleft=13 overwrite=true ref=${dimerc} ${reads_max} stats=${meta.id}_adapterdimers.stats #1bp insert + 1mm allowed
      
    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        BBMap: \$( bbversion.sh )
    END_VERSIONS
    """

}