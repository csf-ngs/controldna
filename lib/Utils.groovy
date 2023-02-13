//
// This file holds several Groovy functions that could be useful for any Nextflow pipeline
//

import org.yaml.snakeyaml.Yaml

class Utils {

    //
    // When running with -profile conda, warn if channels have not been set-up appropriately
    //
    public static void checkCondaChannels(log) {
        Yaml parser = new Yaml()
        def channels = []
        try {
            def config = parser.load("conda config --show channels".execute().text)
            channels = config.channels
        } catch(NullPointerException | IOException e) {
            log.warn "Could not verify conda channel configuration."
            return
        }

        // Check that all channels are present
        def required_channels = ['conda-forge', 'bioconda', 'defaults']
        def conda_check_failed = !required_channels.every { ch -> ch in channels }

        // Check that they are in the right order
        conda_check_failed |= !(channels.indexOf('conda-forge') < channels.indexOf('bioconda'))
        conda_check_failed |= !(channels.indexOf('bioconda') < channels.indexOf('defaults'))

        if (conda_check_failed) {
            log.warn "=============================================================================\n" +
                "  There is a problem with your Conda configuration!\n\n" +
                "  You will need to set-up the conda-forge and bioconda channels correctly.\n" +
                "  Please refer to https://bioconda.github.io/user/install.html#set-up-channels\n" +
                "  NB: The order of the channels matters!\n" +
                "==================================================================================="
        }
    }


    /**
    *  fixed = "top ${fixed}" (*4 !!!)
    *  sample = subsample
    * String because of BigInteger
    * easier alternative would have been automatic fixed > 100M
    */
    public static Tuple2<String,String> string_number(str_num){
        def fixed = str_num.toLowerCase().endsWith("f")
        def fr = fixed ? "fixed" : "sample"
        def str_num_clean = fixed ? str_num.substring(0,str_num.length()-1) : str_num
        if (str_num_clean.isInteger()) {
              return new Tuple2(fr, str_num)
        } else {
              def count = BigInteger.valueOf(0)
              def l = str_num_clean.toLowerCase()
              if(l.endsWith("m")){
                    count = BigInteger.valueOf(l.replace("m","") as Integer).multiply(BigInteger.valueOf(1000000))
              } else if(l.endsWith("k")){
                    count = BigInteger.valueOf(l.replace("k","") as Integer).multiply(BigInteger.valueOf(1000))
              }
              count = fixed ? count.multiply(BigInteger.valueOf(4)) : count
              def cs = count.toString()
              return new Tuple2(fr, count)
        }
   }


   /**
   * meta string if present else global number
   *
   **/
   public static Tuple2<String,String> subsample_number(meta_str_num, global_str_num){
        if (meta_str_num) {
            string_number(meta_str_num)
        } else {
            string_number(global_str_num)
        }
   }

}
