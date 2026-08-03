#===============================================================================
# PCA on global dataset
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

setwd("U:/Sarah/Genomic Analysis TM/Analyses/PCA/200_pca_global")
path <- "U:/Sarah/Genomic Analysis TM/Analyses/PCA/200_pca_global"

# read VCF
vcf <- read.vcfR("U:/Sarah/Genomic Analysis TM/Analyses/FM_0.65_mD_3_MD_30_FMi_0.3_LD_thin_no_LIE_BGR.vcf")

# convert to genlight
gl <- vcfR2genlight(vcf)

# add metadata
popmap <- read.table("U:/Sarah/Genomic Analysis TM/Analyses/popmap_albo_country.txt", header = FALSE)
colnames(popmap) <- c("IID", "pop", "native_invasive")
pop(gl) <- popmap$pop[match(indNames(gl), popmap$IID)]

# Run PCA
pca <- glPca(gl, nf = 50)
pca_scaled <- glPca(gl, nf = 50, center = TRUE, scale = TRUE)

df_all <- as.data.frame(pca_scaled$scores)
df_all$pop <- pop(gl) # add population IDs
df_all$IID <- indNames(gl) # add samples IDs

# calculate variance explained
pc_var <- 100 * pca_scaled$eig / sum(pca_scaled$eig)

# create scree plot to assess how many PCs to retain for PCA
plot(pc_var, type = "b", pch = 19, xlab = "Principal Component", ylab = "Variance explained (%)")

#-------------------------------------------------------------------------------
# define colors and shapes for countries

color_map <- c(
  "Germany"         = "lightskyblue", 
  "Malta"           = "cadetblue4",
  "Serbia"          = "lightcyan3", 
  "Turkey"          = "deepskyblue", 
  "France"          = "#08306b",
  "Switzerland"     = "lightblue1",
  "Italy"           = "royalblue2",
  "Spain"           = "steelblue",
  "Montenegro"      = "steelblue4", 
  "Albania"         = "turquoise4", 
  "USA"             = "cyan", 
  "Slovenia"        = "#8c96c6",
  "Greece"          = "slateblue4", 
  "Israel"          = "darkseagreen4",
  "Croatia"         = "blue", 
  
  "Taiwan"          = "gold",
  "China"           = "yellow",
  "La_Réunion"      = "yellow3",
  "Mauritius"       = "darkgoldenrod4", 
  "Philippines"     = "khaki3",
  "Vietnam"         = "#ffaac6f2",
  
  "Brazil"          = "#ff34b3f2",  
  "Cameroon"        = "#d02090f2",
  "Vanuatu"         = "red1", 
  "Singapore"       = "#eca2d1f2",
  "Christmas_Island"= "orangered4",
  "Fiji"            = "#f1bfd0f2", 
  "Malaysia"        = "tomato", 
  "Sri_Lanka"       = "magenta",
  
  "Indonesia"       = "#7f8c8d"
)


# Optimized shape map utilizing fillable shapes (21-25) to create sharp outlines
shape_map <- c(
  "Indonesia"       = 21,
  
  "Germany"         = 25,
  "Malta"           = 22,
  "Serbia"          = 21,
  "Turkey"          = 22,
  "France"          = 21,  
  "Switzerland"     = 22,  
  "Italy"           = 24,  
  "Spain"           = 24,  
  "Montenegro"      = 25,  
  "Albania"         = 21,  
  "USA"             = 21,  
  "Slovenia"        = 23,  
  "Greece"          = 22,  
  "Israel"          = 25,  
  "Croatia"         = 22,  
  
  "Taiwan"          = 24,
  "China"           = 21,
  "La_Réunion"      = 22,
  "Mauritius"       = 25,
  "Philippines"     = 23,  
  "Vietnam"         = 22,  
  
  "Brazil"          = 21,
  "Cameroon"        = 22,
  "Vanuatu"         = 23,
  "Singapore"       = 24,
  "Christmas_Island" = 25, 
  "Fiji"            = 21,  
  "Malaysia"        = 22,  
  "Sri_Lanka"        = 23  
  
)

# define order of population levels (in PCA plot)
population_order <- c(
  "Indonesia",
  
  "Malaysia",
  "Brazil",
  "Cameroon",
  "Singapore",
  "Sri_Lanka",
  "Vanuatu",
  "Fiji",
  "Christmas_Island",
  
  "Vietnam",
  "China",
  "Taiwan",
  "Philippines",
  "La_Réunion",
  "Mauritius",
  
  "Albania",
  "Israel",
  "Germany",
  "Spain",
  "Slovenia",
  "France",
  "Malta",
  "Italy",
  "Greece",
  "Montenegro",  
  "Switzerland",
  
  "Turkey",
  "Serbia",
  "Croatia",
  "USA"  
)

# define order of countries in legend
legend_order <- c("Indonesia", "Brazil", "Cameroon", "Christmas_Island", "Fiji", "Malaysia", "Singapore", "Sri_Lanka", "Vanuatu", "Vietnam", "China", "La_Réunion", "Mauritius", "Philippines", "Taiwan",
                  "Albania", "Croatia", "France", "Germany", "Greece", "Israel", "Italy", "Malta", "Montenegro", "Serbia", "Slovenia", "Spain", "Switzerland", "Turkey", "USA")

# 2. Hardcode this custom layout order into your dataset column
df_all$pop <- factor(df_all$pop, levels = population_order)
df_all <- df_all[order(match(df_all$pop, population_order)), ]


#-------------------------------------------------------------------------------
# plot PC1 vs PC2

# axis labels
xlab_pc1 <- paste0("PC1 (", round(pc_var[1], 1), "%)")
ylab_pc2 <- paste0("PC2 (", round(pc_var[2], 1), "%)")

p12_global <- ggplot(df_all, aes(PC1, PC2, fill = pop, shape = pop, text = paste("IID:", IID, "<br>Population:", pop))) +
  # colour = "black" creates the outline, stroke controls its thickness
  geom_point(size = 4, alpha = 0.95, colour = "black", stroke = 0.4) +
  
  # Removed custom breaks so legend lists populations alphabetically
  scale_fill_manual(values = color_map, breaks = legend_order) +
  scale_shape_manual(values = shape_map, breaks = legend_order) +
  
  labs(x = xlab_pc1, y = ylab_pc2, fill = "Population", shape = "Population") +
  theme_classic() +
  theme(
    legend.text = element_text(size = 14),
    #legend.title = element_text(size = 16),
    axis.text = element_text(size = 12),
    axis.title = element_text(size = 14),
    plot.title = element_text(size = 18)
  ) +
  # Ensures the legend symbols show the neat black border correctly
  guides(fill = guide_legend(override.aes = list(colour = "black", stroke = 0.4)))

p12_global

ggsave(file.path(path, "pca12_global_countries.png"), p12_global, width = 12, height = 8)
ggsave(file.path(path, "pca12_global_countries.svg"), p12_global, width = 12, height = 8)

ggplotly(p12_global, tooltip = "text")

#convert ggplot to html and export it
p12_countries_html <- ggplotly(p12_global, tooltip = "text")
saveWidget(p12_countries_html, file.path(path, "pca12_global_countries.html"), selfcontained = TRUE)


#-------------------------------------------------------------------------------
# plot PC1 vs PC3

# axis labels
xlab_pc1 <- paste0("PC1 (", round(pc_var[1], 1), "%)")
ylab_pc3 <- paste0("PC3 (", round(pc_var[3], 1), "%)")

p13_global <- ggplot(df_all, aes(PC1, PC3, fill = pop, shape = pop, text = paste("IID:", IID, "<br>Population:", pop))) +
  # colour = "black" creates the outline, stroke controls its thickness
  geom_point(size = 4, alpha = 0.95, colour = "black", stroke = 0.4) +
  
  # Removed custom breaks so legend lists populations alphabetically
  scale_fill_manual(values = color_map, breaks = legend_order) +
  scale_shape_manual(values = shape_map, breaks = legend_order) +
  
  labs(x = xlab_pc1, y = ylab_pc3, fill = "Population", shape = "Population") +
  theme_classic() +
  theme(
    legend.text = element_text(size = 14),
    #legend.title = element_text(size = 16),
    axis.text = element_text(size = 12),
    axis.title = element_text(size = 14),
    plot.title = element_text(size = 18)
  ) +
  # Ensures the legend symbols show the neat black border correctly
  guides(fill = guide_legend(override.aes = list(colour = "black", stroke = 0.4)))

p13_global

ggsave(file.path(path, "pca13_global_countries.png"), p13_global, width = 12, height = 8)
ggsave(file.path(path, "pca13_global_countries.svg"), p13_global, width = 12, height = 8)

ggplotly(p13_global, tooltip = "text")

#convert ggplot to html and export it
p13_countries_html <- ggplotly(p13_global, tooltip = "text")
saveWidget(p13_countries_html, file.path(path, "pca13_global_countries.html"), selfcontained = TRUE)


#-------------------------------------------------------------------------------
# plot PC2 vs PC3

# axis labels
xlab_pc2 <- paste0("PC2 (", round(pc_var[2], 1), "%)")
ylab_pc3 <- paste0("PC3 (", round(pc_var[3], 1), "%)")

p23_global <- ggplot(df_all, aes(PC2, PC3, fill = pop, shape = pop, text = paste("IID:", IID, "<br>Population:", pop))) +
  # colour = "black" creates the outline, stroke controls its thickness
  geom_point(size = 4, alpha = 0.95, colour = "black", stroke = 0.4) +
  
  # Removed custom breaks so legend lists populations alphabetically
  scale_fill_manual(values = color_map, breaks = legend_order) +
  scale_shape_manual(values = shape_map, breaks = legend_order) +
  
  labs(x = xlab_pc2, y = ylab_pc3, fill = "Population", shape = "Population") +
  theme_classic() +
  theme(
    legend.text = element_text(size = 14),
    #legend.title = element_text(size = 16),
    axis.text = element_text(size = 12),
    axis.title = element_text(size = 14),
    plot.title = element_text(size = 18)
  ) +
  # Ensures the legend symbols show the neat black border correctly
  guides(fill = guide_legend(override.aes = list(colour = "black", stroke = 0.4)))

p23_global

ggsave(file.path(path, "pca23_global_countries.png"), p23_global, width = 12, height = 8)
ggsave(file.path(path, "pca23_global_countries.svg"), p23_global, width = 12, height = 8)

ggplotly(p23_global, tooltip = "text")

#convert ggplot to html and export it
p23_countries_html <- ggplotly(p23_global, tooltip = "text")
saveWidget(p23_countries_html, file.path(path, "pca23_global_countries.html"), selfcontained = TRUE)











