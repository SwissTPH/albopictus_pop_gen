#===============================================================================
# Calculate various metrics of genetic diversity (at Global and European level)
# 23.06.2026
# Sarah Marmorosch
#===============================================================================

library(dplyr)
library(ggplot2)
library(forcats)
library(openxlsx)
library(vcfR)
library(adegenet)
library(hierfstat)

# set directories
setwd("C:/Users/marmsa/OneDrive - Swiss TPH/Albopictus_ddRAD/analyses/popgen_analyses/230_diversity_metrics/global")
path <- "C:/Users/marmsa/OneDrive - Swiss TPH/Albopictus_ddRAD/analyses/popgen_analyses/230_diversity_metrics/global"


#-------------------------------------------------------------------------------
# calculate observed heterozygosity (global dataset)

excluded_pops_global <- c("Bulgaria", "Liechtenstein", "Sri_Lanka", "Fiji", "Mauritius", "Germany", "Singapore", "Philippines")

# load heterozygosity table calculated with VCFtools
het <- read.table("obs_heterozygosity_global.het", header = TRUE)

# load population map
popmap <- read.table("C:/Users/marmsa/OneDrive - Swiss TPH/Albopictus_ddRAD/data/population_maps/popmap_albo_country.txt")
colnames(popmap) <- c("IID", "pop","native_invasive")

# compute observed heterozygosity per individual
het <- het %>%
  mutate(Ho=(N_SITES-O.HOM.)/N_SITES)

# merge popmap with het table
het <- het %>%
  left_join(popmap, by = c("INDV"="IID"))

# remove populations with n=1-3
het <- het %>%
  filter(!pop %in% excluded_pops_global)

# add label with sample size
het <- het %>%
  group_by(pop) %>%
  mutate(pop_label = paste(pop, "(n = ", n(),")")) %>%
  ungroup()

# calculate mean Ho summary table per country
ho_summary <- het %>%
  group_by(pop, native_invasive) %>%
  summarise(
    N_samples = n(),
    Mean_Ho = round(mean(Ho, na.rm = TRUE), 3),
    .groups = "drop")


#-------------------------------------------------------------------------------
# Calculate expected heterozygosity (global dataset)

# read VCF and convert to genind
vcf <- read.vcfR("U:/Sarah/Genomic Analysis TM/Analyses/FM_0.65_mD_3_MD_30_FMi_0.3_LD_thin.vcf")
gen <- vcfR2genind(vcf)

# Match metadata and filter populations
pop(gen) <- popmap$pop[match(indNames(gen), popmap$IID)]
gen <- gen[!(pop(gen) %in% excluded_pops_global)]

# Convert to hierfstat format and run basic stats
hf_data <- genind2hierfstat(gen)
basic_stats <- basic.stats(hf_data)

# Compute mean He (Hs) across loci per population
He_matrix <- basic_stats$Hs
mean_He <- colMeans(He_matrix, na.rm = TRUE)

he_summary <- data.frame(
  pop = names(mean_He),
  Mean_He = round(as.numeric(mean_He), 3))


#-------------------------------------------------------------------------------
# Merge Ho and He tables and export combined table (global dataset)

combined_summary <- ho_summary %>%
  left_join(he_summary, by = "pop") %>%
  rename(Country = pop) %>%
  arrange(Country)

# Export combined tables
write.xlsx(combined_summary, file.path(path, "Global_Heterozygosity_Summary_Ho_He.xlsx"), rowNames = FALSE)
write.csv(combined_summary, file.path(path, "Global_Heterozygosity_Summary_Ho_He.csv"), row.names = FALSE)

#-------------------------------------------------------------------------------
# create plots for observed heterozygosity (global dataset)

# boxplot sorted alphabetically
ho_plot1 <- ggplot(het, aes(x = Ho, y = pop_label)) +
  geom_boxplot(fill = "grey", outlier.shape = NA, alpha = 0.7) +
  geom_jitter(height = 0.05, size = 1, alpha = 0.4) +
  theme_bw() +
  ylab("Country") +
  xlab("Observed Heterozygosity (Ho)") +
  xlim(c(0.01, 0.07)) +
  theme(axis.text.y = element_text(size = 9))

ho_plot1

ggsave(file.path(path, "ho_plot_global.png"), ho_plot1, width = 9, height = 10, dpi = 600)
ggsave(file.path(path, "ho_plot_global.svg"), ho_plot1, width = 9, height = 10, dpi = 600)

# boxplot sorted my median Ho
ho_plot2 <- ggplot(het, aes(x = Ho, y = reorder(pop_label, Ho, median))) +
  geom_boxplot(fill = "grey", outlier.shape = NA, alpha = 0.7) +
  geom_jitter(height = 0.05, size = 1, alpha = 0.4) +
  theme_bw() +
  ylab("Country") +
  xlab("Observed Heterozygosity (Ho)") +
  xlim(c(0.02, 0.06)) +
  theme(axis.text.y = element_text(size = 11))

ho_plot2

ggsave(file.path(path, "ho_plot_ordered_Ho_global.png"), ho_plot2, width = 9, height = 10, dpi = 600)
ggsave(file.path(path, "ho_plot_ordered_Ho_global.svg"), ho_plot2, width = 9, height = 10, dpi = 600)

# boxplot sorted by native and invasive range and descending Ho

het_ordered <- het %>%
  group_by(pop_label) %>%
  mutate(median_Ho = median(Ho, na.rm = TRUE)) %>%
  ungroup() %>%
  arrange(desc(native_invasive), median_Ho) %>%
  mutate(pop_label = fct_inorder(pop_label))

ho_plot3 <- ggplot(het_ordered, aes(x = Ho, y = pop_label)) +
  geom_boxplot(fill = "grey", outlier.shape = NA, alpha = 0.7) +
  geom_jitter(height = 0.05, width = 0, size = 1, alpha = 0.4) +
  facet_grid(native_invasive ~ ., scales = "free_y", space = "free_y") +
  theme_bw() +
  ylab("Country") +
  xlab("Observed Heterozygosity (Ho)") +
  xlim(c(0.02, 0.06)) +
  theme(axis.text.y = element_text(size = 11))

# boxplot sorted by native and invasive range and geographic location

invasive_geo_order <- c(
  "Switzerland", 
  "France", 
  "Spain",
  "Italy", 
  "Malta",
  "Slovenia", 
  "Croatia", 
  "Montenegro", 
  "Albania", 
  "Serbia", 
  "Greece", 
  "Turkey",
  "Israel",
  "USA", 
  "Brazil",
  "Cameroon", 
  "La_Réunion",
  "Christmas_Island", 
  "Vanuatu"
)

het_ordered <- het %>%
  group_by(pop) %>%
  mutate(median_Ho = median(Ho, na.rm = TRUE)) %>%
  ungroup() %>%
  mutate(
    geo_rank = case_when(native_invasive == "invaded" ~ match(pop, invasive_geo_order),
      TRUE ~ 100 + dense_rank(median_Ho)) # sort native range by Ho
  ) %>%
  arrange(native_invasive, desc(geo_rank)) %>%
  mutate(pop_label = fct_inorder(pop_label))


ho_plot4 <- ggplot(het_ordered, aes(x = Ho, y = pop_label)) +
  geom_boxplot(fill = "grey", outlier.shape = NA, alpha = 0.7) +
  geom_jitter(height = 0.05, width = 0, size = 1, alpha = 0.4) +
  facet_grid(native_invasive ~ ., scales = "free_y", space = "free_y") +
  theme_bw() +
  ylab("Country") +
  xlab("Observed Heterozygosity (Ho)") +
  xlim(c(0.02, 0.06)) +
  theme(
    axis.text.y = element_text(size = 11),
    strip.text = element_text(size = 11, face = "bold")
  )

ho_plot4


ggsave(file.path(path, "ho_plot_ordered_range_global_geography.png"), ho_plot4, width = 9, height = 10, dpi = 600)
ggsave(file.path(path, "ho_plot_ordered_range_global_geography.svg"), ho_plot4, width = 9, height = 10, dpi = 600)



#===============================================================================
# do the same with the European dataset, and calculate private alleles and FIS
#===============================================================================

# set directories
setwd("C:/Users/marmsa/OneDrive - Swiss TPH/Albopictus_ddRAD/analyses/popgen_analyses/230_diversity_metrics/europe")
path <- "C:/Users/marmsa/OneDrive - Swiss TPH/Albopictus_ddRAD/analyses/popgen_analyses/230_diversity_metrics/europe"

excluded_pops_europe <- c("GRC-South", "Montenegro")

#-------------------------------------------------------------------------------
# Calculate observed heterozygosity (european dataset)

# load heterozygosity table calculated with VCFtools
het <- read.table(file.path(path, "obs_heterozygosity_europe.het"), header = TRUE)

# load population map
popmap <- read.table("U:/Sarah/Genomic Analysis TM/Analyses/popmap_albo_region.txt")
colnames(popmap) <- c("IID", "pop","native_invasive")

# compute observed heterozygosity per individual
het <- het %>%
  mutate(Ho=(N_SITES-O.HOM.)/N_SITES)

# merge popmap with het table
het <- het %>%
  left_join(popmap, by = c("INDV"="IID"))

# remove populations with n=1-3
het <- het %>%
  filter(!pop %in% excluded_pops_europe)

# add label with sample size
het <- het %>%
  group_by(pop) %>%
  mutate(pop_label = paste(pop, "( n = ", n(), ")")) %>%
  ungroup()

# calculate mean Ho summary table per country
ho_summary_europe <- het %>%
  group_by(pop, native_invasive) %>%
  summarise(
    N_samples = n(),
    Mean_Ho = round(mean(Ho, na.rm = TRUE), 3),
    .groups = "drop")

#-------------------------------------------------------------------------------
# create plots for observed heterozygosity (european dataset)

# boxplot sorted alphabetically
ho_plot1 <- ggplot(het, aes(x = Ho, y = pop_label)) +
  geom_boxplot(fill = "grey", outlier.shape = NA, alpha = 0.7) +
  geom_jitter(height = 0.05, size = 1, alpha = 0.4) +
  theme_bw() +
  ylab("Population") +
  xlab("Observed Heterozygosity (Ho)") +
  xlim(c(0.03, 0.1)) +
  theme(axis.text.y = element_text(size = 9))

ho_plot1

ggsave(file.path(path, "ho_plot_europe.png"), ho_plot1, width = 9, height = 10, dpi = 600)
ggsave(file.path(path, "ho_plot_europe.svg"), ho_plot1, width = 9, height = 10, dpi = 600)

# boxplot sorted my median Ho
ho_plot2 <- ggplot(het, aes(x = Ho, y = reorder(pop_label, Ho, median))) +
  geom_boxplot(fill = "grey", outlier.shape = NA, alpha = 0.7) +
  geom_jitter(height = 0.05, size = 1, alpha = 0.4) +
  theme_bw() +
  ylab("Population") +
  xlab("Observed Heterozygosity (Ho)") +
  xlim(c(0.03, 0.1)) +
  theme(axis.text.y = element_text(size = 11))

ho_plot2

ggsave(file.path(path, "ho_plot_ordered_Ho_europe.png"), ho_plot2, width = 9, height = 10, dpi = 600)
ggsave(file.path(path, "ho_plot_ordered_Ho_europe.svg"), ho_plot2, width = 9, height = 10, dpi = 600)

#-------------------------------------------------------------------------------
# Calculate expected heterozygosity (european dataset)

# read VCF and convert to genind
vcf <- read.vcfR("U:/Sarah/Genomic Analysis TM/Analyses/FM_0.65_mD_3_MD_30_FMi_0.3_LD_thin_EU_no_BGR_GER.vcf")
gen <- vcfR2genind(vcf)

# match metadata and filter populations
pop(gen) <- popmap$pop[match(indNames(gen), popmap$IID)]
gen <- gen[!(pop(gen) %in% excluded_pops_europe)]

# convert to hierfstat format and run basic stats
hf_data <- genind2hierfstat(gen)
basic_stats <- basic.stats(hf_data)

# compute mean He (Hs) across loci per population
He_matrix <- basic_stats$Hs
mean_He <- colMeans(He_matrix, na.rm = TRUE)

# create data frame
he_summary_europe <- data.frame(
  pop = names(mean_He),
  Mean_He = round(as.numeric(mean_He), 3))

#-------------------------------------------------------------------------------
# calculate private alleles count per population
pa_matrix <- private_alleles(gen, count.alleles = TRUE)
pa_matrix

# sum the private alleles across all loci for each population
pa_counts <- rowSums(pa_matrix, na.rm = TRUE)

# create data frame
pa_df <- data.frame(
  pop = names(pa_counts),
  Private_Alleles = as.numeric(pa_counts))

#-------------------------------------------------------------------------------
# extract inbreeding coefficient per population
Fis_matrix <- basic_stats$Fis

fis_df <- data.frame(
  pop = colnames(Fis_matrix),
  Mean_Fis = round(colMeans(Fis_matrix, na.rm = TRUE), 3)
)

#-------------------------------------------------------------------------------
# merge metrics tables and export combined table (european dataset)

combined_summary <- ho_summary_europe %>%
  left_join(he_summary_europe, by = "pop") %>%
  left_join(pa_df, by = "pop") %>%
  left_join(fis_df, by = "pop") %>%
  rename(Population = pop) %>%
  mutate(Private_Alleles = ifelse(is.na(Private_Alleles), 0, Private_Alleles)) %>%
  arrange(Population)

# export combined tables
write.xlsx(combined_summary, file.path(path, "Europe_metrics_summary.xlsx"), rowNames = FALSE)
write.csv(combined_summary, file.path(path, "Europe_metrics_summary.csv"), row.names = FALSE)




