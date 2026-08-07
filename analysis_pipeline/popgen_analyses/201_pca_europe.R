#===============================================================================
# PCA on European dataset (EU, USA, ISR)
#
# 31.07.2026
# Sarah Marmorosch
#===============================================================================

# load packages
library(vcfR)
library(adegenet)
library(ggplot2)
library(plotly)
library(htmlwidgets)

setwd("C:/Users/marmsa/OneDrive - Swiss TPH/Albopictus_ddRAD/analyses/popgen_analyses/201_pca_europe")
path <- "C:/Users/marmsa/OneDrive - Swiss TPH/Albopictus_ddRAD/analyses/popgen_analyses/201_pca_europe"

# read VCF
vcf <- read.vcfR("U:/Sarah/Genomic Analysis TM/Analyses/FM_0.65_mD_3_MD_30_FMi_0.3_LD_thin_EU_no_BGR_GER.vcf")

# convert to genlight
gl <- vcfR2genlight(vcf)

# add metadata
popmap <- read.table("U:/Sarah/Genomic Analysis TM/Analyses/popmap_albo_region.txt", header = FALSE)
colnames(popmap) <- c("IID", "pop", "native_invasive")
pop(gl) <- popmap$pop[match(indNames(gl), popmap$IID)]

# run PCA
pca_centered <- glPca(gl, nf = 50, center = TRUE) # glPca centers the data by default, so theoretically I don't need to specify
pca_scaled <- glPca(gl, nf = 50, center = TRUE, scale = TRUE)


df_europe <- as.data.frame(pca_scaled$scores)
df_europe$pop <- pop(gl) # add population IDs
df_europe$IID <- indNames(gl) # add samples IDs

# calculate variance explained
pc_var <- 100 * pca_scaled$eig / sum(pca_scaled$eig)

# create scree plot to assess how many PCs to retain for PCA
plot(pc_var, type = "b", pch = 19, xlab = "Principal Component", ylab = "Variance explained (%)")

#-------------------------------------------------------------------------------
# define colors and shapes for regions

color_map <- c(
  "ESP-North"         = "chocolate",
  "ESP-South"         = "orange",
  "ESP-Valencia"      = "yellow",
  "ESP-Mallorca"      = "#FFE57F",
  
  "FRA-Central"       = "#5d0a92f2",
  "FRA-South"         = "#572caff2",
  "CH-North"          = "#c154fff2",
  "CH-South"          = "#e0aafff2",
  
  "Albania"           = "springgreen3",
  "Croatia"           = "#31572C",
  "Montenegro"        = "#88dd42f2",
  "Serbia"            = "green3",
  "Slovenia"          = "#ccdf93f2",
  
  "TUR-East"          = "#fd66cbf2",
  "TUR-West"          = "maroon1",
  
  "ITA-North/Central" = "blue",
  "ITA-Sicily"        = "#43a4fff2",
  "GRC-North"         = "cyan",
  "GRC-South"         = "#00babaf2", 
  "Malta"             = "#3762fff2",
  
  "Israel"            = "grey20",
  "USA"               = "grey"
)

# define shapes
shape_map <- c(
  "ESP-North"         = 21,
  "ESP-South"         = 22,
  "ESP-Valencia"      = 23,
  "ESP-Mallorca"      = 24,
  
  "FRA-Central"       = 21,
  "FRA-South"         = 22,
  "CH-North"          = 24,
  "CH-South"          = 25,
  
  "Albania"           = 21,
  "Croatia"           = 22,
  "Montenegro"        = 23,
  "Serbia"            = 24,
  "Slovenia"          = 25,
  
  "TUR-East"          = 21,
  "TUR-West"          = 22,
  
  "ITA-North/Central" = 21,
  "ITA-Sicily"        = 22,
  "GRC-North"         = 23,
  "GRC-South"         = 24,
  "Malta"             = 25,
  
  "Israel"            = 21,
  "USA"               = 22
)

legend_order <- c("ESP-North", "ESP-South", "ESP-Valencia", "ESP-Mallorca", "FRA-Central", "FRA-South", "CH-North", "CH-South", "Albania", "Croatia", "Montenegro", "Serbia", "Slovenia", "TUR-East", "TUR-West", "ITA-North/Central", "ITA-Sicily", "GRC-North", "GRC-South", "Malta", "Israel", "USA")

# define population order in pca plot (levels)
population_order <- c("Malta", "ESP-North", "ESP-South", "ESP-Valencia", "ESP-Mallorca", "FRA-Central", "FRA-South", "CH-North", "CH-South", "ITA-North/Central", "ITA-Sicily", "Albania", "Croatia", "Montenegro", "Serbia", "Slovenia", "TUR-East", "TUR-West", "Israel", "GRC-North", "GRC-South", "USA")

# hardcode this order into the dataset
df_europe$pop <- factor(df_europe$pop, levels = population_order)
df_europe <- df_europe[order(match(df_europe$pop, population_order)), ]


#-------------------------------------------------------------------------------
# plot PC1 vs PC2

# axis labels
xlab_pc1 <- paste0("PC1 (", round(pc_var[1], 1), "%)")
ylab_pc2 <- paste0("PC2 (", round(pc_var[2], 1), "%)")

p12_europe <- ggplot(df_europe, aes(PC1, PC2, fill = pop, shape = pop, text = paste("IID:", IID, "<br>Population:", pop))) +
  # colour = "black" creates the outline, stroke controls its thickness
  geom_point(size = 4, alpha = 0.95, colour = "black", stroke = 0.4) +
  
  # Removed custom breaks so legend lists populations alphabetically
  scale_fill_manual(values = color_map, breaks = legend_order) +
  scale_shape_manual(values = shape_map, breaks = legend_order) +
  
  labs(x = xlab_pc1, y = ylab_pc2, fill = "Population", shape = "Population") +
  theme_classic() +
  theme(
    legend.text = element_text(size = 14),
    legend.title = element_text(size = 16),
    axis.text = element_text(size = 12),
    axis.title = element_text(size = 14),
    plot.title = element_text(size = 18)
  ) +
  # Ensures the legend symbols show the neat black border correctly
  guides(fill = guide_legend(override.aes = list(colour = "black", stroke = 0.4)))

p12_europe

ggsave(file.path(path, "pca12_europe.png"), p12_europe, width = 12, height = 8)
ggsave(file.path(path, "pca12_europe.svg"), p12_europe, width = 12, height = 8)

ggplotly(p12_europe, tooltip = "text")

#convert ggplot to html and export it
p12_europe_html <- ggplotly(p12_europe, tooltip = "text")
saveWidget(p12_europe_html, file.path(path, "pca12_europe.html"), selfcontained = TRUE)


#-------------------------------------------------------------------------------
# plot PC1 vs PC3

# axis labels
xlab_pc1 <- paste0("PC1 (", round(pc_var[1], 1), "%)")
ylab_pc3 <- paste0("PC3 (", round(pc_var[3], 1), "%)")

p13_europe <- ggplot(df_europe, aes(PC1, PC3, fill = pop, shape = pop, text = paste("IID:", IID, "<br>Population:", pop))) +
  # colour = "black" creates the outline, stroke controls its thickness
  geom_point(size = 4, alpha = 0.95, colour = "black", stroke = 0.4) +
  
  # Removed custom breaks so legend lists populations alphabetically
  scale_fill_manual(values = color_map, breaks = legend_order) +
  scale_shape_manual(values = shape_map, breaks = legend_order) +
  
  labs(x = xlab_pc1, y = ylab_pc3, fill = "Population", shape = "Population") +
  theme_classic() +
  theme(
    legend.text = element_text(size = 14),
    legend.title = element_text(size = 16),
    axis.text = element_text(size = 12),
    axis.title = element_text(size = 14),
    plot.title = element_text(size = 18)
  ) +
  # Ensures the legend symbols show the neat black border correctly
  guides(fill = guide_legend(override.aes = list(colour = "black", stroke = 0.4)))

p13_europe

ggsave(file.path(path, "pca13_europe.png"), p13_europe, width = 12, height = 8)
ggsave(file.path(path, "pca13_europe.svg"), p13_europe, width = 12, height = 8)

ggplotly(p13_europe, tooltip = "text")

#convert ggplot to html and export it
p13_europe_html <- ggplotly(p13_europe, tooltip = "text")
saveWidget(p13_europe_html, file.path(path, "pca13_europe.html"), selfcontained = TRUE)


#-------------------------------------------------------------------------------
# plot PC2 vs PC3

# axis labels
xlab_pc2 <- paste0("PC2 (", round(pc_var[2], 1), "%)")
ylab_pc3 <- paste0("PC3 (", round(pc_var[3], 1), "%)")

p23_europe <- ggplot(df_europe, aes(PC2, PC3, fill = pop, shape = pop, text = paste("IID:", IID, "<br>Population:", pop))) +
  # colour = "black" creates the outline, stroke controls its thickness
  geom_point(size = 4, alpha = 0.95, colour = "black", stroke = 0.4) +
  
  # Removed custom breaks so legend lists populations alphabetically
  scale_fill_manual(values = color_map, breaks = legend_order) +
  scale_shape_manual(values = shape_map, breaks = legend_order) +
  
  labs(x = xlab_pc2, y = ylab_pc3, fill = "Population", shape = "Population") +
  theme_classic() +
  theme(
    legend.text = element_text(size = 14),
    legend.title = element_text(size = 16),
    axis.text = element_text(size = 12),
    axis.title = element_text(size = 14),
    plot.title = element_text(size = 18)
  ) +
  # Ensures the legend symbols show the neat black border correctly
  guides(fill = guide_legend(override.aes = list(colour = "black", stroke = 0.4)))

p23_europe

ggsave(file.path(path, "pca23_europe.png"), p23_europe, width = 12, height = 8)
ggsave(file.path(path, "pca23_europe.svg"), p23_europe, width = 12, height = 8)

ggplotly(p23_europe, tooltip = "text")

#convert ggplot to html and export it
p23_europe_html <- ggplotly(p23_europe, tooltip = "text")
saveWidget(p23_europe_html, file.path(path, "pca23_europe.html"), selfcontained = TRUE)




