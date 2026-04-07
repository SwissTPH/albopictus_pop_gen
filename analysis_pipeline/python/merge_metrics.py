import pandas as pd
import os
import sys

OUT_FOLDER=sys.argv[1]

#load files
MAF = pd.read_table(os.path.join(OUT_FOLDER, "allele_freq.frq"), sep='\t', header=None, skiprows=1)
MAF.columns = ["CHROM", "POS", "N_ALLELES", "N_CHR", "FRQ_ref", "FRQ_alt"]
balance = pd.read_table(os.path.join(OUT_FOLDER, "allele_balance.tsv"))
depth = pd.read_table(os.path.join(OUT_FOLDER, "site_depth.ldepth.mean"))
missing = pd.read_table(os.path.join(OUT_FOLDER, "site_missing.lmiss"))

#build merged table
merged = missing[["CHR", "POS"]].copy()
merged["F_MISS"] = missing.F_MISS
merged["MEAN_DEPTH"] = depth.MEAN_DEPTH
merged["balance"] = balance.AB
merged["MAF"] = MAF.FRQ_alt
merged["MAC"] = MAF.N_CHR * MAF.FRQ_alt

#save metrics table
metrics_table = os.path.join(OUT_FOLDER, "metrics_table.csv")
merged.to_csv(metrics_table, index=False)

