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

setwd("C:/Users/marmsa/OneDrive - Swiss TPH/Albopictus_ddRAD/analyses/popgen_analyses/210_dapc_global")
path <- "C:/Users/marmsa/OneDrive - Swiss TPH/Albopictus_ddRAD/analyses/popgen_analyses/210_dapc_global"

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

#                   1  2  3  4
# Albania           0  6  0  0
# Brazil            5  0  0  0
# Cameroon          6  0  0  0
# Christmas_Island  4  0  0  0
# Croatia           0  9  0  0
# Fiji              2  0  0  0
# France            0 15  0  0
# Germany           0  2  0  0
# Greece            2  5  0  0
# China             0  0 38  0
# Israel            0  3  1  0
# Italy             1 22  0  0
# La_Réunion        0  0  7  0
# Malta             0  4  0  0
# Mauritius         0  0  3  0
# Montenegro        0  4  0  0
# Serbia            0  5  0  0
# Slovenia          0  4  0  0
# Spain             0 31  2  0
# Sri_Lanka         3  0  0  0
# Switzerland       0 41  0  0
# Taiwan            0  0 14  0
# Turkey            0 16  0  0
# USA               0  6  0  0
# Vanuatu           5  0  0  0
# Indonesia         0  0  0 31
# Malaysia         34  0  0  0
# Philippines       0  0  2  0
# Singapore         2  0  0  0
# Vietnam           4  0  2  0

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
