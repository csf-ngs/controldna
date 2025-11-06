process PICARD_UMI_MQC {
    tag "umi_mqc"
    label 'process_low'
    
    container "${ params.pipgencontainer }"

    input:
    path(metrics)

    output:
    path("*.yaml") , emit: mqc_metrics
    path("duplications_tiles.html")     , emit: html
    path("versions.yml")                , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''

    """
       picard_umi_metrics mqc --metrics_dir . --outpath_base . 

       cat <<-END_VERSIONS > versions.yml
       "${task.process}":
            picard_umi_metrics: 0.1
       END_VERSIONS
    """

    stub:
    """
    touch duplication_histogram_mqc.yaml
    touch umi_metrics_table_mqc.yaml
    touch duplication_metrics_table_mqc.yaml

    cat <<-END_VERSIONS > versions.yml
       "${task.process}":
            picard_umi_metrics: 0.1
    END_VERSIONS
    """
}