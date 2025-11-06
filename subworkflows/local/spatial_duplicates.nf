include { BAM_DUPLICATES_TILEDENSITY  } from '../../modules/local/bam_duplicates_tiledensity'
include { BAM_DUPLICATES_PLOT_TILEDENSITY  } from '../../modules/local/bam_duplicates_plot_tiledensity'


workflow SPATIAL_DUPLICATES {
    take:
        marked_bams        // channel: [ val(meta), [ bam ] ]

    main:

    tile_duplication_tabs  = Channel.empty()
    ch_versions       = Channel.empty()
    
    BAM_DUPLICATES_TILEDENSITY(marked_bams)
    ch_versions = ch_versions.mix(BAM_DUPLICATES_TILEDENSITY.out.versions.first())

    ch_duplicates_tab = BAM_DUPLICATES_TILEDENSITY.out.tab.map{ m, tab -> tab}.toList()
    BAM_DUPLICATES_PLOT_TILEDENSITY(ch_duplicates_tab)
    ch_versions = ch_versions.mix(BAM_DUPLICATES_PLOT_TILEDENSITY.out.versions.first())

    emit:
        tabs        =  ch_duplicates_tab
        lines_json  = BAM_DUPLICATES_PLOT_TILEDENSITY.out.json         //  channel: tiles.json 
        report_html = BAM_DUPLICATES_PLOT_TILEDENSITY.out.html  // channel: [ report.html ]
        versions    = ch_versions
}