#===============================================================================
# Calculating Dps for neighbor net network
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

# set directories
setwd("U:/Sarah/Genomic Analysis TM/Analyses/network/240_Dps_matrix_europe")
path <- "U:/Sarah/Genomic Analysis TM/Analyses/network/240_Dps_matrix_europe"

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

# convert to hierfstat format at filter populations
hf_data <- genind2hierfstat(gen)

basic_stats <- basic.stats(hf_data)

#-------------------------------------------------------------------------------
# calculate pairwise proportion of shared alleles (Dps) for european dataset

# add population to sample_ID
new_ids <- paste(pop(gen), indNames(gen), sep = "_")
indNames(gen) <- new_ids
head(indNames(gen))

PS <- propShared(gen) # propShared() computes a similarity matrix, so we need to substract it from 1 to get Dps
Dps <- 1-PS

# export matrix 
write.xlsx(Dps, file.path(path, "Dps_europe.xlsx"), rowNames=TRUE)

# export as nexus file, that seems to work better in SplitsTree
Dps_dist <- as.dist(Dps)
write.nexus.dist(Dps_dist, "Dps_europe.nex")



#===============================================================================
# calculate Dps matrix for a subset of the samples (Eastern Europe + Israel)
#===============================================================================

# Subset genind object for selected populations
subset_pops <- c("GRC-South", "GRC-North", "Albania", "Montenegro", 
                 "Croatia", "Slovenia", "TUR-East", "TUR-West", "Israel", "Serbia")

# Filter genind object to keep only target populations
gen_sub <- gen[pop(gen) %in% subset_pops]

# Convert to hierfstat format and calculate basic stats for the subset
hf_sub <- genind2hierfstat(gen_sub)
basic_stats_sub <- basic.stats(hf_sub)

#-------------------------------------------------------------------------------
# calculate pairwise proportion of shared alleles (Dps) for subset

# add population to sample_ID for clear node labeling in SplitsTree
new_ids <- paste(pop(gen_sub), indNames(gen_sub), sep = "_")
indNames(gen_sub) <- new_ids
head(indNames(gen_sub))

# Calculate distance matrix (Dps = 1 - Proportion of Shared Alleles)
PS <- propShared(gen_sub) 
Dps <- 1 - PS

# export matrix 
write.xlsx(Dps, file.path(path, "Dps_eastern_europe.xlsx"), rowNames = TRUE)

# export as nexus file for Splits Tree
Dps_dist <- as.dist(Dps)
write.nexus.dist(Dps_dist, file.path(path, "Dps_eastern_europe.nex"))








