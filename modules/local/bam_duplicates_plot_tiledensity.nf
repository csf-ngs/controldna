process BAM_DUPLICATES_PLOT_TILEDENSITY {
    tag "$meta.id"
    label 'process_low'
    
    container "/groups/vbcf-ngs/misc/infra/singularity/amd64/pipeline/pipgen_latest.sif" //markdown, ggplot viridis, collectcontrolresults

    input:
    tuple val(meta), path(tabs)

    output:
    tuple val(meta), path("duplications_tiles_mqc.json") , emit: json
    tuple val(meta), path("duplications_tiles.html") , emit: html
    path "versions.yml"                     , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    """
       tile_density_report.R --outputbase duplications_tiles --outputdir \$(pwd)  --knitdir \$(pwd) --intermediates \$(pwd) \$(pwd) '*tab'

       cat <<-END_VERSIONS > versions.yml
       "${task.process}":
            collectcontrolresults: 0.1
       END_VERSIONS
    """

    stub:
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    touch duplications_tiles_mqc.json
    touch duplications_tiles.html

    cat <<-END_VERSIONS > versions.yml
       "${task.process}":
            collectcontrolresults: 0.1
    END_VERSIONS
    """