library(adegenet)
library(pegas)


setwd('/scicore/home/muellepi/GROUP/202407_Aalbopictus_SNPs_analysis_by_wandrille/')

vcfFile = '051_relatedness_computation_with_vcftools_and_plink/FM_0.70_mD_2_MD_30_FMi_0.35/FM_0.70_mD_2_MD_30_FMi_0.35_LD_thin.renamed.vcf.gz'

# reading files in adegenet format: https://cran.r-project.org/web/packages/pegas/vignettes/ReadingFiles.pdf
loci_data = read.vcf( vcfFile , to=20000 )
genind_data = loci2genind(loci_data)
genind_data


# adegenet DAPC tutorial https://raw.githubusercontent.com/thibautjombart/adegenet/master/tutorials/tutorial-dapc.pdf

#grp <- find.clusters(genind_data, max.n.clust=50)
# keep 432 PCs (all)
# keep 3 clusters (min BIC)
grp <- find.clusters(genind_data, max.n.clust=50, n.pca = 432, n.clust = 3)


dapc1 <- dapc( genind_data , grp$grp , n.pca = 432 , n.da = 2)
scatter(dapc1)


scatter(dapc1, scree.da=FALSE, bg="white", pch=20, cell=0, cstar=0, 
        cex=3,clab=0, leg=TRUE, txt.leg=paste("Cluster",1:3))


grp <- find.clusters(genind_data, max.n.clust=50, n.pca = 20 )
dapc1 <- dapc( genind_data , grp$grp , n.pca = 20 )

scatter(dapc1, posi.da="bottomright", bg="white",
        pch=17:22, cstar=0,  scree.pca=TRUE,
        posi.pca="bottomleft")


names( genind_data )

genind_data[1:3,]
genind_data

sub = genind_data[ grp$grp == 2 , ]

grp_sub = find.clusters( sub , n.pca = 100 , n.clust = 4)
dapc_sub <- dapc( sub , grp_sub$grp )
scatter(dapc_sub)


