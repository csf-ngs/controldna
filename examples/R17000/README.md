
generate

```
../../scripts/create_samples_csv.py --inputfolder /scratch/csfs/ido/tmp/undemultiplexed/22KKCYLT3_2_R17000_20240415/demultiplexed  --outputpath R17000_novax.csv --subsample 4Mf
../../scripts/create_samples_csv.py --inputfolder /scratch/csfs/ido/tmp/undemultiplexed/2409503170_0_R17000_20240910/demultiplexed  --outputpath R17000_aviti.csv --subsample 4Mf

cat R17000_novax.csv R17000_aviti.csv > R17000.csv

/groups/vbcf-ngs/misc/reports/other/analysis/ido/aviti_novax/R17000

```