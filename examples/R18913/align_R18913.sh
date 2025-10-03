#sbatch --qos=medium --time=2-00:00:00 /users/ido.tamir/work/pipelines/nf-core-controldna/run_cluster.sh R18913a /users/ido.tamir/work/pipelines/nf-core-controldna/examples/R18913/R18913.csv GRCh38 R18913  0

sbatch --qos=long --time=4-00:00:00 /users/ido.tamir/work/pipelines/nf-core-controldna/run_cluster.sh R18913b /users/ido.tamir/work/pipelines/nf-core-controldna/examples/R18913/R18913.csv GRCh38 R18913  0
