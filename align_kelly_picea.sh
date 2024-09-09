#sbatch --qos=medium --time=2-00:00:00 run_cluster.sh kelly_aviti_0M /users/ido.tamir/work/pipelines/nf-core-controldna/kelly_aviti_prelim.csv Picea kelly_aviti_0M 0
#sbatch --qos=medium --time=2-00:00:00 run_cluster.sh kelly_novax_0M /users/ido.tamir/work/pipelines/nf-core-controldna/kelly_nx_prelim.csv Picea kelly_novax_0M 0

sbatch --qos=medium --time=2-00:00:00 run_cluster.sh kelly_aviti_6M /users/ido.tamir/work/pipelines/nf-core-controldna/kelly_aviti_prelim.csv Picea kelly_aviti_6M 6M
sbatch --qos=medium --time=2-00:00:00 run_cluster.sh kelly_novax_6M /users/ido.tamir/work/pipelines/nf-core-controldna/kelly_nx_prelim.csv Picea kelly_novax_6M 6M
