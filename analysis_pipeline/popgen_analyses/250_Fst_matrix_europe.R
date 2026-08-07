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
library(adegenet)
library(openxlsx)
library(ape)
library(svglite)
library(heatmaply)
library(htmlwidgets)
library(ComplexHeatmap)
library(circlize)
library(grid)

# set directories
setwd("C:/Users/marmsa/OneDrive - Swiss TPH/Albopictus_ddRAD/analyses/popgen_analyses/250_fst_europe")
path <- "C:/Users/marmsa/OneDrive - Swiss TPH/Albopictus_ddRAD/analyses/popgen_analyses/250_fst_europe"

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
pairwise_fst <- pairwise.WCfst(hf_data) # Weir & Cockerham (1984) method

# calculate 95% CI
fst_boot <- boot.ppfst(hf_data, nboot = 1000, quant=c(0.025,0.975), diploid=TRUE)

# extract upper (97.5%) and lower (2.5%) CI matrices
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

saveWorkbook(wb, file.path(path, "Pairwise_FST_results_europe.xlsx"), overwrite = TRUE)


#===============================================================================
# create a clustered FST Heatmap with Dendrograms using ComplexHeatmap (without any values in cells)
#===============================================================================

# color palette for the heatmap
col_fun = colorRamp2(c(0, 0.08, 0.16), c("grey90", "orange", "firebrick"))

# create the heatmap
Heatmap(pairwise_fst, name = "FST", col = col_fun,
        cluster_rows = TRUE, cluster_columns = TRUE, show_row_dend = TRUE, show_column_dend = TRUE, # add dendrogram              
        show_row_names = TRUE, show_column_names = TRUE, row_names_side = "right", column_names_rot = 90, # add labels
        rect_gp = gpar(col = "white", lwd = 0.5)) # add grid lines


#-------------------------------------------------------------------------------
# create an interactive heatmap
interactive_plot <- heatmaply(
  pairwise_fst,
  colors = c("grey90", "orange", "firebrick"), # Your exact color scheme
  label_names = c("Pop 1", "Pop 2", "FST Value"), # Customizes the hover text box
  grid_gap = 0.5,                                  # Keeps your clean white borders
  showticklabels = c(TRUE, TRUE),
  width = 1200,
  height = 1100
)

interactive_plot

# save interactive plot
htmlwidgets::saveWidget(interactive_plot, "FST_interactive_heatmap_EU.html")


#===============================================================================
# create fst/CI heatmap, populations are sorted based on clustering
#===============================================================================

# make matrices symmetric (hierfstat leaves one triangle as NA)
symmetrize <- function(m) {
  m <- as.matrix(m)
  m[is.na(m)] <- t(m)[is.na(m)]
  m
}

fst_mat <- symmetrize(pairwise_fst)
ll_mat  <- symmetrize(fst_ll)
ul_mat  <- symmetrize(fst_ul)

# make sure CI matrices have same row/col order as fst_mat
ll_mat <- ll_mat[rownames(fst_mat), colnames(fst_mat)]
ul_mat <- ul_mat[rownames(fst_mat), colnames(fst_mat)]

#-------------------------------------------------------------------------------
# define order of populations based on average Fst value
hc <- hclust(as.dist(fst_mat), method = "average")
ord <- hc$order

#-------------------------------------------------------------------------------
# create heatmap, populations are ordered based on average Fst value
col_fun <- colorRamp2(c(0, 0.08, 0.16), c("grey90", "orange", "firebrick"))

fst_heatmap <- Heatmap(fst_mat, name = "FST", col = col_fun,
                       cluster_rows = as.dendrogram(hc),
                       cluster_columns = as.dendrogram(hc),
                       show_row_dend = TRUE, show_column_dend = TRUE,
                       show_row_names = TRUE, show_column_names = TRUE,
                       row_names_side = "right", column_names_rot = 90,
                       rect_gp = gpar(col = "white", lwd = 0.5),
                       cell_fun = function(j, i, x, y, width, height, fill) {
                         # i, j here are indices into the original (unclustered) matrix
                         if (i == j) return(invisible(NULL))  # skip diagonal
                         
                         rank_i <- match(i, ord)   # visual row position
                         rank_j <- match(j, ord)   # visual column position
                         
                         if (rank_i > rank_j) {
                           # visually lower-left triangle -> FST value
                           grid.text(sprintf("%.3f", fst_mat[i, j]), x, y,
                                     gp = gpar(fontsize = 10))
                         } else if (rank_i < rank_j) {
                           # visually upper-right triangle -> CI
                           grid.text(sprintf("%.3f-\n%.3f", ll_mat[i, j], ul_mat[i, j]), x, y,
                                     gp = gpar(fontsize = 8))
                         }
                       })
fst_heatmap


# export heatmap as an svg file
svglite(file.path(path, "FST_heatmap_clustering_europe.svg"), width = 12, height = 11)
draw(fst_heatmap)
dev.off()

# write a nexus-format distance matrix for SplitsTree
write.nexus.dist(fst_mat, file = file.path(path, "FST_matrix_europe.nex"))


#===============================================================================
# create fst/CI heatmap, populations are sorted based on geographic location
#===============================================================================

# make matrices symmetric (hierfstat leaves one triangle as NA)
symmetrize <- function(m) {
  m <- as.matrix(m)
  m[is.na(m)] <- t(m)[is.na(m)]
  m
}

fst_mat <- symmetrize(pairwise_fst)
ll_mat  <- symmetrize(fst_ll)
ul_mat  <- symmetrize(fst_ul)

#-------------------------------------------------------------------------------
# define population order based on geographic location
pop_order <- c(
  "ESP-North", 
  "ESP-South", 
  "ESP-Valencia", 
  "ESP-Mallorca",
  "FRA-Central",
  "FRA-South",
  "CH-North",
  "CH-South",
  "ITA-North/Central",
  "ITA-Sicily",
  "Malta",
  "Slovenia",
  "Croatia",
  "Montenegro",
  "Albania",
  "Serbia",
  "GRC-North",
  "GRC-South",
  "TUR-East",
  "TUR-West",
  "Israel",
  "USA"
)

# check if order matches (should return character(0))
setdiff(pop_order, rownames(fst_mat))
setdiff(rownames(fst_mat), pop_order)

# reorder matrices to match desired order
fst_mat <- fst_mat[pop_order, pop_order]
ll_mat  <- ll_mat[pop_order, pop_order]
ul_mat  <- ul_mat[pop_order, pop_order]

#-------------------------------------------------------------------------------
# create heatmap with predefined order of populations
col_fun <- colorRamp2(c(0, 0.08, 0.16), c("grey90", "orange", "firebrick"))

fst_heatmap_geography <- Heatmap(fst_mat, name = "FST", col = col_fun,
              cluster_rows = FALSE, cluster_columns = FALSE,   # no dendrograms, fixed order
              row_order = pop_order, column_order = pop_order,
              show_row_names = TRUE, show_column_names = TRUE,
              row_names_side = "right", column_names_rot = 90,
              rect_gp = gpar(col = "white", lwd = 0.5),
              cell_fun = function(j, i, x, y, width, height, fill) {
                if (i == j) return(invisible(NULL))  # skip diagonal
                if (i > j) {
                  # lower-left triangle -> FST value
                  grid.text(sprintf("%.3f", fst_mat[i, j]), x, y,
                            gp = gpar(fontsize = 10))
                } else {
                  # upper-right triangle -> CI
                  grid.text(sprintf("%.3f-\n%.3f", ll_mat[i, j], ul_mat[i, j]), x, y,
                            gp = gpar(fontsize = 8))
                }
              })
fst_heatmap_geography

# export heatmap as an svg file
svglite(file.path(path, "FST_heatmap_geography_europe.svg"), width = 12, height = 11)
draw(fst_heatmap_geography)
dev.off()


#===============================================================================
# create a Neighbor-Joining tree based on the FST matrix
#===============================================================================

# Use symmetric FST matrix
fst_tree_mat <- fst_mat

# Replace negative FST values by zero
fst_tree_mat[fst_tree_mat < 0] <- 0

# Set diagonal to zero
diag(fst_tree_mat) <- 0

# Check matrix
range(fst_tree_mat)
sum(is.na(fst_tree_mat))

# Convert to distance matrix
fst_dist <- as.dist(fst_tree_mat)

# Build Neighbor-Joining tree
fst_nj_tree <- nj(fst_dist)

# Plot tree
plot(fst_nj_tree, main = "Neighbor-Joining tree based on pairwise FST", cex = 0.8)
add.scale.bar(x=0, y=1, length = 0.01, lwd = 2, cex = 0.8)

fst_nj_tree$edge.length

#-------------------------------------------------------------------------------
# export tree

svglite(file.path(path, "FST_nj_tree_europe.svg"), width = 8, height = 8)

plot(fst_nj_tree, main = "", cex = 0.8)
add.scale.bar(x=0, y=1, length = 0.01, lwd = 2, cex = 0.8)

dev.off()


png(file.path(path, "FST_neighbor_joining_tree_europe.png"), width = 2400, height = 2400, res = 300)

plot(fst_nj_tree, main = "", cex = 0.8)
add.scale.bar(x=0, y=1, length = 0.01, lwd = 2, cex = 0.8)

dev.off()


