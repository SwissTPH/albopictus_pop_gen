#===============================================================================
# Plot observed heterozygosity calculated by VCFtools (global dataset)
# 23.06.2026
# Sarah Marmorosch
#===============================================================================

library(dplyr)
library(ggplot2)
library(forcats)
library(svglite)
library(openxlsx)

# set directories
setwd("U:/Sarah/Genomic Analysis TM/Analyses/diversity_metrics/230_observed_heterozygosity/global")
path <- "U:/Sarah/Genomic Analysis TM/Analyses/diversity_metrics/230_observed_heterozygosity/global"

# load heterozygosity table calculated with VCFtools
het <- read.table("obs_heterozygosity_global.het", header = TRUE)

# load population map
popmap <- read.table("U:/Sarah/Genomic Analysis TM/Analyses/popmap_albo_country.txt")
colnames(popmap) <- c("IID", "pop","native_invasive")

# compute observed heterozygosity per individual
het <- het %>%
  mutate(Ho=(N_SITES-O.HOM.)/N_SITES)

# merge popmap with het table
het <- het %>%
  left_join(popmap, by = c("INDV"="IID"))

# remove populations with n=1-3
het <- het %>%
  filter(!pop %in% c("Bulgaria", "Liechtenstein", "Sri_Lanka", "Fiji", "Mauritius", "Germany", "Singapore", "Philippines"))

# add label with sample size
het <- het %>%
  group_by(pop) %>%
  mutate(pop_label = paste(pop, "( n = ", n(), ")")) %>%
  ungroup()

#-------------------------------------------------------------------------------
# create boxplot of observed heterozygosity, sorted alphabetically
ho_plot <- ggplot(het, aes(x=Ho, y=pop_label)) +
  geom_boxplot(fill="grey", outlier.shape=NA, alpha=0.7) +
  geom_jitter(height=0.05, size=1, alpha=0.4) +
  theme_bw() +
  ylab("Country") +
  xlab("Observed Heterozygosity (Ho)") +
  xlim(c(0.01, 0.07)) +
  theme(axis.text.y=element_text(size=9))

ho_plot

ggsave(file.path(path, "ho_plot_global.png"), ho_plot, width = 9, height = 10, dpi = 600)
ggsave(file.path(path, "ho_plot_global.svg"), ho_plot, width = 9, height = 10, dpi = 600)


#-------------------------------------------------------------------------------
# create boxplot of observed heterozygosity, sorted by Ho
ho_plot <- ggplot(het, aes(x=Ho, y=reorder(pop_label, Ho, median))) +
  geom_boxplot(fill="grey", outlier.shape=NA, alpha=0.7) +
  geom_jitter(height=0.05, size=1, alpha=0.4) +
  theme_bw() +
  ylab("Country") +
  xlab("Observed Heterozygosity (Ho)") +
  xlim(c(0.02, 0.06)) +
  theme(axis.text.y=element_text(size=11))

ho_plot

ggsave(file.path(path, "ho_plot_ordered_Ho_global.png"), ho_plot, width = 9, height = 10, dpi = 600)
ggsave(file.path(path, "ho_plot_ordered_Ho_global.svg"), ho_plot, width = 9, height = 10, dpi = 600)


#-------------------------------------------------------------------------------
# create boxplot of observed heterozygosity, sorted by native/invasive and Ho

# reorder population label
het_ordered <- het %>%
  group_by(pop_label) %>%
  mutate(median_Ho = median(Ho, na.rm = TRUE)) %>%
  ungroup() %>%
  arrange(desc(native_invasive), median_Ho) %>% # sort by range first (native vs invasive), then by median Ho within those ranges
  mutate(pop_label = fct_inorder(pop_label)) # keep this order for ggplot

ho_plot <- ggplot(het_ordered, aes(x = Ho, y = pop_label)) +
  geom_boxplot(fill = "grey", outlier.shape = NA, alpha = 0.7) +
  geom_jitter(height = 0.05, width = 0, size = 1, alpha = 0.4) +
  facet_grid(native_invasive ~ ., scales = "free_y", space = "free_y") + # split the plot into native and invasive panel
  theme_bw() +
  ylab("Country") +
  xlab("Observed Heterozygosity (Ho)") +
  xlim(c(0.02, 0.06))+
  theme(axis.text.y = element_text(size = 11))

ho_plot

ggsave(file.path(path, "ho_plot_ordered_range_global.png"), ho_plot, width = 9, height = 10, dpi = 600)
ggsave(file.path(path, "ho_plot_ordered_range_global.svg"), ho_plot, width = 9, height = 10, dpi = 600)


#-------------------------------------------------------------------------------
# create summary table of Ho per population

summary_tab <- het %>%
  group_by(pop, native_invasive) %>%
  summarise(
    sample_size = n(),
    mean_Ho = round(mean(Ho, na.rm = TRUE), 3),
    .groups = "drop"
  ) %>%
  arrange(desc(native_invasive), desc(mean_Ho))

write.csv(summary_tab, file = file.path(path, "global_ho_summary.csv"), row.names = FALSE)
write.xlsx(summary_tab, file = file.path(path, "global_ho_summary.xlsx"), rowNames = FALSE)

summary_tab


#===============================================================================
# do the same with the European dataset
#===============================================================================

# set directories
setwd("U:/Sarah/Genomic Analysis TM/Analyses/diversity_metrics/230_observed_heterozygosity/europe")
path <- "U:/Sarah/Genomic Analysis TM/Analyses/diversity_metrics/230_observed_heterozygosity/europe"

# load heterozygosity table calculated with VCFtools
het <- read.table("obs_heterozygosity_europe.het", header = TRUE)

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
  filter(!pop %in% c("GRC-South", "Montenegro"))

# add label with sample size
het <- het %>%
  group_by(pop) %>%
  mutate(pop_label = paste(pop, "( n = ", n(), ")")) %>%
  ungroup()

#-------------------------------------------------------------------------------
# create boxplot of observed heterozygosity, sorted alphabetically
ho_plot <- ggplot(het, aes(x=Ho, y=pop_label)) +
  geom_boxplot(fill="grey", outlier.shape=NA, alpha=0.7) +
  geom_jitter(height=0.05, size=1, alpha=0.4) +
  theme_bw() +
  ylab("Population") +
  xlab("Observed Heterozygosity (Ho)") +
  xlim(c(0.03, 0.1)) +
  theme(axis.text.y=element_text(size=9))

ho_plot

ggsave(file.path(path, "ho_plot_europe.png"), ho_plot, width = 9, height = 10, dpi = 600)
ggsave(file.path(path, "ho_plot_europe.svg"), ho_plot, width = 9, height = 10, dpi = 600)

#-------------------------------------------------------------------------------
# create boxplot of observed heterozygosity, sorted by Ho
ho_plot <- ggplot(het, aes(x=Ho, y=reorder(pop_label, Ho, median))) +
  geom_boxplot(fill="grey", outlier.shape=NA, alpha=0.7) +
  geom_jitter(height=0.05, size=1, alpha=0.4) +
  theme_bw() +
  ylab("Population") +
  xlab("Observed Heterozygosity (Ho)") +
  xlim(c(0.03, 0.1)) +
  theme(axis.text.y=element_text(size=11))

ho_plot

ggsave(file.path(path, "ho_plot_ordered_Ho_europe.png"), ho_plot, width = 9, height = 10, dpi = 600)
ggsave(file.path(path, "ho_plot_ordered_Ho_europe.svg"), ho_plot, width = 9, height = 10, dpi = 600)

#-------------------------------------------------------------------------------
# create summary table of Ho per population

summary_tab_europe <- het %>%
  group_by(pop, native_invasive) %>%
  summarise(
    sample_size = n(),
    mean_Ho = round(mean(Ho, na.rm = TRUE), 3),
    .groups = "drop"
  ) %>%
  arrange(desc(native_invasive), desc(mean_Ho))

write.csv(summary_tab_europe, file = file.path(path, "europe_ho_summary.csv"), row.names = FALSE)
write.xlsx(summary_tab_europe, file = file.path(path, "europe_ho_summary.xlsx"), rowNames = FALSE)

summary_tab_europe






