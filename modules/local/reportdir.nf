process REPORTDIR {
    tag '$util'
    cpus =  1
    time   = '1h'

    input:
      val(reportdir)
      path(folders)   //[folders]

    output:
      path("SUCCESS"), emit: success

    when:
    task.ext.when == null || task.ext.when

    script:
    def today = new java.util.Date().format( 'yyyyMMdd' )
    def outdir = "${reportdir}_${today}"
    """
      mkdir -p ${outdir}
      cp -rfL * ${outdir} || true
      touch SUCCESS
    """

}