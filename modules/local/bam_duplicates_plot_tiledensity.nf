process BAM_DUPLICATES_PLOT_TILEDENSITY {
    tag "plottiles"
    label 'process_low'
    
    container "/groups/vbcf-ngs/misc/infra/singularity/amd64/pipeline/pipgen_latest.sif" //markdown, ggplot viridis, collectcontrolresults

    input:
    path(tabs)

    output:
    path("duplications_tiles_mqc.json") , emit: json
    path("duplications_tiles.html")     , emit: html
    path("versions.yml")                , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    //def sing=/groups/vbcf-ngs/misc/infra/singularity/amd64/pipeline/pipgen_latest.sif
    """
       /tile_density_report.R --outputbase duplications_tiles --outputdir \$(pwd)  --knitdir \$(pwd) --intermediates \$(pwd) \$(pwd) '*tab'

       cat <<-END_VERSIONS > versions.yml
       "${task.process}":
            collectcontrolresults: 0.1
       END_VERSIONS
    """

    stub:
    """
    touch duplications_tiles_mqc.json
    touch duplications_tiles.html

    cat <<-END_VERSIONS > versions.yml
       "${task.process}":
            collectcontrolresults: 0.1
    END_VERSIONS
    """
}