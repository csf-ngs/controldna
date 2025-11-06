# $1= project name
# $4= multiqc title

sbatch --qos=medium --time=2-00:00:00 /users/ido.tamir/work/pipelines/nf-core-controldna/run_cluster.sh R19648_100M_noumi /users/ido.tamir/work/pipelines/nf-core-controldna/examples/R19648/R19648_noumi.csv GRCh38 R19648_100M_noumi  0
sbatch --qos=medium --time=2-00:00:00 /users/ido.tamir/work/pipelines/nf-core-controldna/run_cluster.sh R19648_100M_umi /users/ido.tamir/work/pipelines/nf-core-controldna/examples/R19648/R19648_umi.csv GRCh38 R19648_100M_umi  0
sbatch --qos=medium --time=2-00:00:00 /users/ido.tamir/work/pipelines/nf-core-controldna/run_cluster.sh R19648_100M_umi_500 /users/ido.tamir/work/pipelines/nf-core-controldna/examples/R19648/R19648_umi.csv GRCh38 R19648_100M_500  0