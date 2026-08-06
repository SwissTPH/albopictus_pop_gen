#===============================================================================
# Calculating FST (European dataset)
#
# Europe + USA + Israel (no Bulgaria and Germany due to n=1)
# 
# 22.07.2026
# Sarah Marmorosch
#===============================================================================

library(hierfstat)
library(vcfR)
library(ggplot2)
library(adegenet)
library(openxlsx)
library(dplyr)
library(tidyr)
library(phangorn)
library(svglite)
library(ComplexHeatmap)
library(circlize)
library(grid)

# set directories
setwd("U:/Sarah/Genomic Analysis TM/Analyses/FST")
path <- "U:/Sarah/Genomic Analysis TM/Analyses/FST"

#-------------------------------------------------------------------------------
# reading the vcf file
vcf <- read.vcfR("U:/Sarah/Genomic Analysis TM/Analyses/FM_0.65_mD_3_MD_30_FMi_0.3_LD_thin_EU_no_BGR_GER.vcf")

# convert VCF to genind
gen <- vcfR2genind(vcf)

# reading the metadata file
popmap <- read.table("U:/Sarah/Genomic Analysis TM/Analyses/popmap_albo_region.txt")
colnames(popmap) <- c("IID", "pop","native_invasive")

# match populations to samples
pop_vector <- popmap$pop[match(indNames(gen), popmap$IID)]
pop(gen) <- pop_vector

# convert to hierfstat format
hf_data <- genind2hierfstat(gen)

basic_stats <- basic.stats(hf_data)

#-------------------------------------------------------------------------------
# calculate FST

fst_boot <- boot.ppfst(hf_data, nboot = 1000, quant=c(0.025,0.975), diploid=TRUE)

# Extract upper (97.5%) and lower (2.5%) CI matrices from bootstrap output
fst_ll <- fst_boot$ll
fst_ul <- fst_boot$ul

#-------------------------------------------------------------------------------
# create excel file with FST matrix and 95% CI
wb <- createWorkbook()
addWorksheet(wb, "Pairwise_FST")
addWorksheet(wb, "CI_Lower_2.5")
addWorksheet(wb, "CI_Upper_97.5")

writeData(wb, "Pairwise_FST", pairwise_fst, rowNames = TRUE)
writeData(wb, "CI_Lower_2.5", fst_ll, rowNames = TRUE)
writeData(wb, "CI_Upper_97.5", fst_ul, rowNames = TRUE)

saveWorkbook(wb, file.path(path, "Pairwise_FST_Results.xlsx"), overwrite = TRUE)

