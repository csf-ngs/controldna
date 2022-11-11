
process SUBDIR {
    tag '$util'
    cpus =  1
    time   = '1h'

    input:
      val(subdir)
      path(folders)   //[folders]

    output:
      path subdir, emit: dir

    when:
    task.ext.when == null || task.ext.when

    script:
    """
      mkdir ${subdir}
      mv * ${subdir} || true
    """
}
