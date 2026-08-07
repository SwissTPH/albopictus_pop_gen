#===============================================================================
# Admixture analysis (global dataset)
#
# 03.07.2026
# Sarah Marmorosch
#===============================================================================

library(ggplot2)
library(tidyr)
library(dplyr)
library(svglite)

setwd("C:/Users/marmsa/OneDrive - Swiss TPH/Albopictus_ddRAD/analyses/popgen_analyses/220_Admixture")
path <- "C:/Users/marmsa/OneDrive - Swiss TPH/Albopictus_ddRAD/analyses/popgen_analyses/220_Admixture"

# plot CV errors
cv <- read.table("CV_error.txt", header=TRUE)

cv$K <- as.numeric(cv$K)

CV_plot <- ggplot(cv, aes(K, CV_Error))+
  geom_point(size=3)+
  scale_x_continuous(breaks=cv$K)+
  geom_line()+
  theme_classic()+
  labs(x="K", y="Cross Validation Error (CV)")

CV_plot

ggsave(file.path(path, "CV_error_plot.png"), CV_plot, width = 7, height = 7)

#-------------------------------------------------------------------------------
# Admixture plot for K=2 all populations
#-------------------------------------------------------------------------------

# define colors for clusters
color_map <- c(
  "Ancestry_1" = "tomato1", 
  "Ancestry_2" = "steelblue2"
)

K <- 2

# load and process files
Q <- read.table("LD_thin_all_pops_no_LIE_BGR_num.K2.seed2.Q")
fam <- read.table("LD_thin_all_pops_no_LIE_BGR.fam")

# adjust the sampleID in the fam file from the PLINK (double ID)
colnames(fam) <- c("FID", "IID", "PAT", "MAT", "SEX", "PHEN")

#---------------------------
# load metadata and merge files

meta <- read.table("U:/Sarah/Genomic Analysis TM/Analyses/popmap_albo_country.txt")
colnames(meta) <- c("IID", "pop","native_invasive")

# Combine IID (from fam) with ancestry proportions (from Q)
df <- cbind(IID = fam$IID, Q)
colnames(df)[-1] <- paste0("Ancestry_", seq_len(K)) # Rename ancestry columns

df <- merge(df, meta, by = "IID", all.x = TRUE) # Merge metadata with df


#==========
# sort populations based on ancestry
#==========

pop_order <- df %>%
  group_by(pop) %>%
  summarise(mean_A1 = mean(Ancestry_1), .groups = "drop") %>%
  arrange(desc(mean_A1))

df <- df %>%
  mutate(pop = factor(pop, levels = pop_order$pop)) %>%
  arrange(pop, desc(Ancestry_1))

df_long <- df %>%
  pivot_longer(
    cols = starts_with("Ancestry_"),
    names_to = "Cluster",
    values_to = "Proportion"
  )

#==========
# create admixture plot
#==========

admx2 <- ggplot(df_long, aes(x = IID, y = Proportion, fill = Cluster))+
  geom_bar(stat = "identity", width = 1)+
  facet_grid(~ pop, scales = "free_x", space = "free")+
  theme_classic()+
  scale_fill_manual(values = color_map) +
  theme(
    axis.text.x = element_blank(),
    axis.ticks.x = element_blank(),
    panel.spacing = unit(0.1, "lines"),
    strip.background = element_blank(),
    strip.text = element_text(size=12),
    strip.text.x = element_text(angle = 90, hjust = 0, vjust = 0.5, size = 12),
  )+
  labs(
    x = "Individuals",
    y = "Ancestry proportion",
    title = "K=2"
  )

admx2

ggsave(file.path(path, "admixture_K2_sorted.png"), admx2, width = 21, height = 7)


#-------------------------------------------------------------------------------
# Admixture plot for K=3 all populations
#-------------------------------------------------------------------------------

K <- 3

# load and process files
Q <- read.table("LD_thin_all_pops_no_LIE_BGR_num.K3.seed7.Q") 
fam <- read.table("LD_thin_all_pops_no_LIE_BGR.fam")

# adjust the sampleID in the fam file from the PLINK (double ID)
colnames(fam) <- c("FID", "IID", "PAT", "MAT", "SEX", "PHEN")

#---------------------------
# load metadata and merge files

meta <- read.table("U:/Sarah/Genomic Analysis TM/Analyses/popmap_albo_country.txt")
colnames(meta) <- c("IID", "pop","native_invasive")

# Combine IID (from fam) with ancestry proportions (from Q)
df <- cbind(IID = fam$IID, Q)
colnames(df)[-1] <- paste0("Ancestry_", seq_len(K)) # Rename ancestry columns

df <- merge(df, meta, by = "IID", all.x = TRUE) # Merge metadata with df

#==========
# sort populations based on ancestry
#==========

pop_order <- df %>%
  group_by(pop) %>%
  summarise(
    mean_A1 = mean(Ancestry_1),
    mean_A2 = mean(Ancestry_2), # Assuming Ancestry_2 is your grey cluster
    .groups = "drop"
  ) %>%
  arrange(desc(mean_A1), mean_A2)

df <- df %>%
  mutate(pop = factor(pop, levels = pop_order$pop)) %>%
  arrange(pop, Ancestry_1, Ancestry_2, Ancestry_3)

df_long <- df %>%
  pivot_longer(
    cols = starts_with("Ancestry_"),
    names_to = "Cluster",
    values_to = "Proportion"
  )

#==========
# create admixture plot
#==========

# define colors for ancestries
color_map <- c(
  "Ancestry_1" = "tomato1", 
  "Ancestry_2" = "gray90", 
  "Ancestry_3" = "steelblue2"
)

admx3 <- ggplot(df_long, aes(x = IID, y = Proportion, fill = Cluster))+
  geom_bar(stat = "identity", width = 1)+
  facet_grid(~ pop, scales = "free_x", space = "free")+
  theme_classic()+
  scale_fill_manual(values = color_map) +
  theme(
    axis.text.x = element_blank(),
    axis.ticks.x = element_blank(),
    panel.spacing = unit(0.1, "lines"),
    strip.background = element_blank(),
    strip.text = element_text(size=12),
    strip.text.x = element_text(angle = 90, hjust = 0, vjust = 0.5, size = 12),
  )+
  labs(
    x = "Individuals",
    y = "Ancestry proportion",
    title = "K=3"
  )

admx3

ggsave(file.path(path, "admixture_K3_sorted.png"), admx3, width = 21, height = 7)


#-------------------------------------------------------------------------------
# Admixture plot for K=4 all populations
#-------------------------------------------------------------------------------

K <- 4

Q <- read.table("LD_thin_all_pops_no_LIE_BGR_num.K4.seed9.Q") # Q file contains, each line corresponds to the proportion of an individual
fam <- read.table("LD_thin_all_pops_no_LIE_BGR.fam")

# adjust the sampleID in the fam file from the PLINK (double ID)
colnames(fam) <- c("FID", "IID", "PAT", "MAT", "SEX", "PHEN")

#==========
# load metadata and merge files
#==========

meta <- read.table("U:/Sarah/Genomic Analysis TM/Analyses/popmap_albo_country.txt")
colnames(meta) <- c("IID", "pop","native_invasive")

# Combine IID (from fam) with ancestry proportions (from Q)
df <- cbind(IID = fam$IID, Q)
colnames(df)[-1] <- paste0("Ancestry_", seq_len(K)) # Rename ancestry columns

df <- merge(df, meta, by = "IID", all.x = TRUE) # Merge metadata with df

#==========
# Create population-level table grouped by their dominant ancestry
#==========

pop_order <- df %>%
  group_by(pop) %>%
  summarise(
    mean_A1 = mean(Ancestry_1),
    mean_A2 = mean(Ancestry_2),
    mean_A3 = mean(Ancestry_3),
    mean_A4 = mean(Ancestry_4),
    .groups = "drop"
  ) %>%
  rowwise() %>%
  mutate(
    dominant_cluster = c("A1", "A2", "A3", "A4")[which.max(c(mean_A1, mean_A2, mean_A3, mean_A4))]
  ) %>%
  ungroup() %>%
  mutate(cluster_order = factor(dominant_cluster, levels = c("A1", "A4", "A2", "A3"))) %>%
  arrange(
    cluster_order, 
    desc(mean_A1),
    desc(mean_A4), 
    desc(mean_A2), 
    mean_A3 
  )

# Apply the new factor levels to your main data frame
df <- df %>%
  mutate(pop = factor(pop, levels = pop_order$pop)) %>%
  arrange(pop, desc(Ancestry_1), desc(Ancestry_3), desc(Ancestry_2), desc(Ancestry_4))

df_long <- df %>%
  pivot_longer(
    cols = starts_with("Ancestry_"),
    names_to = "Cluster",
    values_to = "Proportion"
  )

#==========
# create admixture plot
#==========

# define colors for ancestries
color_map <- c(
  "Ancestry_1" = "dodgerblue1", 
  "Ancestry_2" = "tomato1", 
  "Ancestry_3" = "grey",
  "Ancestry_4" = "gold1"
)

admx4 <- ggplot(df_long, aes(x = IID, y = Proportion, fill = Cluster))+
  geom_bar(stat = "identity", width = 1)+
  facet_grid(~ pop, scales = "free_x", space = "free")+
  theme_classic()+
  scale_fill_manual(values = color_map) +
  theme(
    axis.text.x = element_blank(),
    axis.ticks.x = element_blank(),
    panel.spacing = unit(0.1, "lines"),
    strip.background = element_blank(),
    strip.text = element_text(size=12),
    strip.text.x = element_text(angle = 90, hjust = 0, vjust = 0.5, size = 12),
  )+
  labs(
    x = "Individuals",
    y = "Ancestry proportion",
    title = "K=4"
  )

admx4

ggsave(file.path(path, "admixture_K4_sorted.png"), admx4, width = 21, height = 7)
ggsave(file.path(path, "admixture_K4_sorted.svg"), admx4, width = 21, height = 7)

#-------------------------------------------------------------------------------
# Admixture plot for K=5 all populations
#-------------------------------------------------------------------------------

K <- 5

# Updated to read the K5 Q file
Q <- read.table("LD_thin_all_pops_no_LIE_BGR_num.K5.seed4.Q") # Q file contains, each line corresponds to the proportion of an individual
fam <- read.table("LD_thin_all_pops_no_LIE_BGR.fam")

# adjust the sampleID in the fam file from the PLINK (double ID)
colnames(fam) <- c("FID", "IID", "PAT", "MAT", "SEX", "PHEN")

#==========
# load metadata and merge files
#==========

meta <- read.table("U:/Sarah/Genomic Analysis TM/Analyses/popmap_albo_country.txt")
colnames(meta) <- c("IID", "pop","native_invasive")

# Combine IID (from fam) with ancestry proportions (from Q)
df <- cbind(IID = fam$IID, Q)
colnames(df)[-1] <- paste0("Ancestry_", seq_len(K)) # Rename ancestry columns

df <- merge(df, meta, by = "IID", all.x = TRUE) # Merge metadata with df

View(df)

#==========
# Create population-level table grouped by their dominant ancestry
#==========

pop_order <- df %>%
  group_by(pop) %>%
  summarise(
    mean_A1 = mean(Ancestry_1),
    mean_A2 = mean(Ancestry_2),
    mean_A3 = mean(Ancestry_3),
    mean_A4 = mean(Ancestry_4),
    mean_A5 = mean(Ancestry_5),
    .groups = "drop"
  ) %>%
  rowwise() %>%
  mutate(
    dominant_cluster = c("A1", "A2", "A3", "A4", "A5")[which.max(c(mean_A1, mean_A2, mean_A3, mean_A4, mean_A5))] # Added A5 to pool
  ) %>%
  ungroup() %>%
  mutate(cluster_order = factor(dominant_cluster, levels = c("A1", "A3", "A2", "A4", "A5"))) %>%
  arrange(
    cluster_order, 
    desc(mean_A1), 
    desc(mean_A3), 
    desc(mean_A2), 
    desc(mean_A4),
    desc(mean_A5)
  )

df <- df %>%
  mutate(pop = factor(pop, levels = pop_order$pop)) %>%
  arrange(pop, desc(Ancestry_1), desc(Ancestry_3), desc(Ancestry_2), desc(Ancestry_4), desc(Ancestry_5))

df_long <- df %>%
  pivot_longer(
    cols = starts_with("Ancestry_"),
    names_to = "Cluster",
    values_to = "Proportion"
  )

#==========
# create admixture plot
#==========

# define colors for ancestries
color_map <- c(
  "Ancestry_1" = "#7fc97f", 
  "Ancestry_2" = "gold1", 
  "Ancestry_3" = "steelblue2",
  "Ancestry_4" = "tomato1",
  "Ancestry_5" = "grey"  # Picked a clean neutral gray/slate for the fifth color
)

admx5 <- ggplot(df_long, aes(x = IID, y = Proportion, fill = Cluster))+
  geom_bar(stat = "identity", width = 1)+
  facet_grid(~ pop, scales = "free_x", space = "free")+
  theme_classic()+
  scale_fill_manual(values = color_map) +
  theme(
    axis.text.x = element_blank(),
    axis.ticks.x = element_blank(),
    panel.spacing = unit(0.1, "lines"),
    strip.background = element_blank(),
    strip.text = element_text(size=12),
    strip.text.x = element_text(angle = 90, hjust = 0, vjust = 0.5, size = 12),
  )+
  labs(
    x = "Individuals",
    y = "Ancestry proportion",
    title = "K=5"
  )

admx5

ggsave(file.path(path, "admixture_K5_sorted.png"), admx5, width = 21, height = 7)

