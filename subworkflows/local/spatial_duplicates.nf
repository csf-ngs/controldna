include { PICARD_MARKDUPLICATES  } from '../../modules/local/picardmarkduplicates'
include { BAM_DUPLICATES_TILEDENSITY  } from '../../modules/local/bam_duplicates_tiledensity'
include { BAM_DUPLICATES_PLOT_TILEDENSITY  } from '../../modules/local/bam_duplicates_plot_tiledensity'


workflow SPATIAL_DUPLICATES {
    take:
        bams        // channel: [ val(meta), [ bam ] ]

    main:

    tile_duplication_tabs  = Channel.empty()
    ch_versions       = Channel.empty()

    PICARD_MARKDUPLICATES(bams)
    ch_versions = ch_versions.mix(PICARD_MARKDUPLICATES.out.versions.first())
    
    BAM_DUPLICATES_TILEDENSITY(PICARD_MARKDUPLICATES.out.bam)
    ch_versions = ch_versions.mix(BAM_DUPLICATES_TILEDENSITY.out.versions.first())

    BAM_DUPLICATES_PLOT_TILEDENSITY(BAM_DUPLICATES_TILEDENSITY.out.tab.toList())    
    ch_versions = ch_versions.mix(BAM_DUPLICATES_PLOT_TILEDENSITY.out.versions.first())

    emit:
        tabs        = BAM_DUPLICATES_TILEDENSITY.out.tab.toList()     // channel: [ val(meta), path("*.tiledensity.tab")  ]
        lines_json   = BAM_DUPLICATES_PLOT_TILEDENSITY.out.json         //  channel: tiles.json 
        report_html = BAM_DUPLICATES_PLOT_TILEDENSITY.out.html  // channel: [ report.html ]
        versions    = ch_versions
}