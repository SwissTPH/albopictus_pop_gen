#===============================================================================
# DAPC on global dataset
# 
# 21.07.2026
# Sarah Marmorosch
#===============================================================================

library(adegenet)
library(pegas)
library(poppr)
library(svglite)

setwd("U:/Sarah/Genomic Analysis TM/Analyses/DAPC/210_dapc_global")
path <- "U:/Sarah/Genomic Analysis TM/Analyses/DAPC/210_dapc_global"

#-------------------------------------------------------------------------------

# reading files in adegenet format: https://cran.r-project.org/web/packages/pegas/vignettes/ReadingFiles.pdf
loci_data = read.vcf("U:/Sarah/Genomic Analysis TM/Analyses/FM_0.65_mD_3_MD_30_FMi_0.3_LD_thin_no_LIE_BGR.vcf" , to=20000 )
genind_data = loci2genind(loci_data)
genind_data

# add population data
pop_table <- read.table("U:/Sarah/Genomic Analysis TM/Analyses/popmap_albo_country.txt")
colnames(pop_table) <- c("indID", "population","nativeInvasive")

rownames(pop_table) <- paste(pop_table$indID)

pop(genind_data) <- pop_table[rownames(genind_data@tab), "population"]
table(pop(genind_data))

# preparing the table with the samples in the expected order for further selection of native/invasive
pop_table <- pop_table[rownames(genind_data@tab), ]

# genotype imputation with mean allele frequencies to replace missing values: for PCA we need a complete genotype matrix
genind_imp <- missingno(genind_data, type = "mean")

#-------------------------------------------------------------------------------
# perform DAPC

grp <- find.clusters(genind_imp, max.n.clust=50, n.pca = 170)

grp <- find.clusters(genind_imp, max.n.clust=50, n.pca = 340, n.clust=4)
table(pop(genind_imp), grp$grp)

#-------------------------------------------------------------------------------
# use cross-validation to define the number of PCs to retain
xval <- xvalDapc(genind_imp, grp$grp, 
                 n.pca=10:120, 
                 n.da=3, 
                 training.set=0.9, 
                 result="groupMean", 
                 n.rep=30,
                 xval.plot=TRUE)

# inspect the cross-validation results
xval
xval$`Number of PCs Achieving Highest Mean Success` 
# 22 PCs gives the lowest RMSE (root mean squared error), suggested optimum n.pca of adegenet


# create DAPC cross-validation plot again
success <- xval$`Mean Successful Assignment by Number of PCs of PCA`

plot(as.numeric(names(success)), success,
     type="b",
     xlab="Number of PCs retained",
     ylab="Mean successful assignment",
     main="DAPC cross-validation",
     pch=19)

abline(v=as.numeric(xval$`Number of PCs Achieving Highest Mean Success`),
       lty=2)

abline(v=as.numeric(xval$`Number of PCs Achieving Lowest MSE`),
       lty=2)

#-------------------------------------------------------------------------------
# plot dapc
dapc <- dapc(genind_imp, grp$grp, n.pca=22, n.da=3)
scatter(dapc)

# define colors for each cluster (according to ADMIXTURE and PCA clusters) 
colors <- c("red", "dodgerblue1", "gold1",  "grey50")

#-------------------------------------------------------------------------------
# export dapc plot as png and svg file

svg("DAPC_global.svg", width = 7, height = 6)
png("DAPC_global.png", width = 7, height = 6, units = "in", res = 300)

scatter(dapc, scree.da=FALSE, scree.pca=TRUE, posi.pca="bottomright", col=colors)

dev.off()
