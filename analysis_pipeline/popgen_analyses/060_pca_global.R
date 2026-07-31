#===============================================================================
# PCA on global dataset
#
# 31.07.2026
# Sarah Marmorosch
#===============================================================================

library(vcfR)
library(adegenet)
library(ggplot2)

# read VCF
vcf <- read.vcfR("U:/Sarah/Genomic Analysis TM/Analyses/FM_0.65_mD_3_MD_30_FMi_0.3_LD_thin.vcf")

# convert to genlight
gl <- vcfR2genlight(vcf)

# add metadata
popmap <- read.table("U:/Sarah/Genomic Analysis TM/Analyses/popmap_albo_country.txt", header = FALSE)
colnames(popmap) <- c("IID", "pop", "native_invasive")
pop(gl) <- popmap$pop[match(indNames(gl), popmap$IID)]

# Run PCA
pca <- glPca(gl, nf = 50)

scores <- as.data.frame(pca$scores)

scores$Population <- pop(gl)
scores$Sample <- indNames(gl)

#-------------------------------------------------------------------------------
# plot PC1 vs PC2
ggplot(scores, aes(PC1, PC2, color = Population)) +
  geom_point(size = 2.5) +
  theme_classic() +
  labs(x = paste0("PC1 (", round(pca$eig[1]/sum(pca$eig)*100,1), "%)"),
       y = paste0("PC2 (", round(pca$eig[2]/sum(pca$eig)*100,1), "%)"))

# create scree plot to assess how many PCs to retain for PCA
var.explained <- 100 * pca$eig / sum(pca$eig)
var.explained

plot(var.explained, type = "b", pch = 19, xlab = "Principal Component", ylab = "Variance explained (%)")
