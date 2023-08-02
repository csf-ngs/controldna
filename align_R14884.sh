#sbatch --qos=long --time=5-00:00:00 run_cluster.sh  R14884  /users/ido.tamir/work/pipelines/nf-core-controldna/R14884.csv GRCh38 R14884 0
#sbatch --qos=long --time=5-00:00:00 run_cluster.sh  R14884_000  /users/ido.tamir/work/pipelines/nf-core-controldna/R14884_0.csv GRCh38 R14884_000 0
#sbatch --qos=medium  --time=2-00:00:00 run_cluster.sh  R14884_010  /users/ido.tamir/work/pipelines/nf-core-controldna/R14884_10.csv GRCh38 R14884_010 0
sbatch --qos=medium --time=2-00:00:00 run_cluster.sh  R14884_050  /users/ido.tamir/work/pipelines/nf-core-controldna/R14884_50.csv GRCh38 R14884_050 0
sbatch --qos=medium --time=2-00:00:00 run_cluster.sh  R14884_100  /users/ido.tamir/work/pipelines/nf-core-controldna/R14884_100.csv GRCh38 R14884_100 0
#sbatch --qos=long --time=5-00:00:00 run_cluster.sh  R14884_200  /users/ido.tamir/work/pipelines/nf-core-controldna/R14884_200.csv GRCh38 R14884_200 0
#sbatch --qos=long --time=5-00:00:00 run_cluster.sh  R14884_000_noumi  /users/ido.tamir/work/pipelines/nf-core-controldna/R14884_0.noumi.csv GRCh38 R14884_000_noumi 0
#sbatch --qos=long --time=5-00:00:00 run_cluster.sh  R14884_010_noumi  /users/ido.tamir/work/pipelines/nf-core-controldna/R14884_10M.noumi.csv GRCh38 R14884_010_noumi 0
#sbatch --qos=medium --time=2-00:00:00 run_cluster.sh R14884_010_aviti  /users/ido.tamir/work/pipelines/nf-core-controldna/aviti_10.csv GRCh38 R14884_010_aviti 0
sbatch --qos=medium --time=2-00:00:00 run_cluster.sh R14884_050_aviti  /users/ido.tamir/work/pipelines/nf-core-controldna/aviti_50.csv GRCh38 R14884_050_aviti 0
sbatch --qos=medium --time=2-00:00:00 run_cluster.sh R14884_100_aviti  /users/ido.tamir/work/pipelines/nf-core-controldna/aviti_100.csv GRCh38 R14884_100_aviti 0
#sbatch --qos=medium --time=2-00:00:00 run_cluster.sh R14884_200_IA  /users/ido.tamir/work/pipelines/nf-core-controldna/R14884_200A.csv GRCh38 R14884_200_IA 0
sbatch --qos=medium --time=2-00:00:00 run_cluster.sh R14884_200_IA_noumi  /users/ido.tamir/work/pipelines/nf-core-controldna/R14884_200A.noumi.csv GRCh38 R14884_200_IA_noumi 0
