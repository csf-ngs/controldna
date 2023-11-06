#sbatch --qos=medium --time=2-00:00:00 run_cluster.sh novaX_l1_0_noumi  /users/ido.tamir/work/pipelines/nf-core-controldna/novax_pcrfree_l1_0.noumi.csv GRCh38 novaX_l1_0_noumi 0
sbatch --qos=medium --time=2-00:00:00 run_cluster.sh novaX_l1l2_0_noumi  /users/ido.tamir/work/pipelines/nf-core-controldna/novax_pcrfree_l1l2m_0.noumi.csv GRCh38 novaX_l1l2_0_noumi 0
sbatch --qos=medium --time=2-00:00:00 run_cluster.sh novaX_l1l2_370Mf_noumi  /users/ido.tamir/work/pipelines/nf-core-controldna/novax_pcrfree_l1l2m_370Mf.noumi.csv GRCh38 novaX_l1l2_370Mf_noumi 370Mf
sbatch --qos=medium --time=2-00:00:00 run_cluster.sh novax_pcrfree_vbcf_370Mf_noumi /users/ido.tamir/work/pipelines/nf-core-controldna/novax_pcrfree_vbcf_370Mf.noumi.csv GRCh38 novaX_vbcf_370Mf_noumi 370Mf
sbatch --qos=medium --time=2-00:00:00 run_cluster.sh novax_pcrfree_vbcf_200Mf_noumi /users/ido.tamir/work/pipelines/nf-core-controldna/novax_pcrfree_vbcf_200Mf.noumi.csv GRCh38 novaX_vbcf_200Mf_noumi 200Mf
