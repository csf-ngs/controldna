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
    """
      mkdir -p ${reportdir}
      cp -rf * ${reportdir} || true
    """

}