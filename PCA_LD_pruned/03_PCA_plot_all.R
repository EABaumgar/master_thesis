##install.packages("BiocManager")
##library(BiocManager)
##BiocManager::install("SNPRelate")
##BiocManager::install("SeqArray")

library("ggplot2")
library("gdsfmt")
library("SNPRelate")
library("MASS")
library("tidyverse")
library("ggtext")
library("ggrepel")


# set working directory
setwd("/share/pool/ek/project.bumblebee.evolution/bombus_pop_gen_eva/08_LD_pruning/")


# input .gds file 
#inputfile="Bter_resequenced_islands_mainland_genomasterlist.filtered.excl_repeats.excl_het_min_two.gds"
#inputfile="Bter_resequenced_islands_mainland_genomasterlist.filtered.subset_female.n122.excl_repeats.gds"
inputfile="Bter_resequenced_islands_mainland_genomasterlist.filtered.subset_without_unclear_sex.excl_repeats.gds"

#### Eckarts code for PCA:

#updated_tab=read.csv("Bter_resequenced_island_mainland.filtered.excl_repeats.csv", header = TRUE, fill = TRUE)
#updated_tab=read.csv("Bter_resequenced_island_mainland.filtered.subset_female.excl_repeats.csv", header = TRUE, fill = TRUE)
updated_tab=read.csv("Bter_resequenced_island_mainland.filtered.subset_without_unclear_sex.excl_repeats.csv", header = TRUE, fill = TRUE)

genofile = snpgdsOpen(inputfile)

pca <- snpgdsPCA(genofile, autosome.only = FALSE)
pc.percent <- pca$varprop * 100
pc.percent.rounded <- round(pc.percent, 2)

# Store values of PC's
PCA1 <- head(pc.percent.rounded, 1)
PCA2 <- tail((head(pc.percent.rounded, 2)), 1)
PCA3 <- tail((head(pc.percent.rounded, 3)), 1)
PCA4 <- tail((head(pc.percent.rounded, 4)), 1)
PCA5 <- tail((head(pc.percent.rounded, 5)), 1)
pcas <- paste(
  "PCAs 1-5: ", PCA1, " , ", PCA2, " , ", PCA3, " , ", PCA4,
  " , ", PCA5,  sep = ""
)
print(pcas)


# create x and y labs
#Xlabs <- paste("PC2 ", PCA2, "%", sep = "")
#Ylabs <- paste("PC1 ", PCA1, "%", sep = "")
Xlabs <- paste("PC1 ", PCA1, "%", sep = "")
Ylabs <- paste("PC2 ", PCA2, "%", sep = "")


# extract PCA results and merge with table
pca_EVs <- data.frame(sample.id = pca$sample.id,
                                  PC1 = pca$eigenvect[,1],
                                  PC2 = pca$eigenvect[,2])
                              
pca_EVs_merged <- merge(pca_EVs, updated_tab, by = "sample.id")


######### PCA plot by species

pca_plot = ggplot(data = pca_EVs_merged %>% arrange(desc(Subspecies)), aes(x = PC1, y = PC2, group = Subspecies)) +
#pca_plot = ggplot(pca_EVs_merged, aes(x = PC1, y = PC2, group = Subspecies)) +
  geom_point(aes(color = Subspecies, stroke = 2, shape = Subspecies), 
    alpha = 0.5, size = 10
  ) +
  #scale_shape_manual(values = c(0, 1, 2, 3, 4)) +
  scale_shape_manual(values = c(21, 24, 3, 22, 4)) +
  #scale_color_manual(values = c("#ffbf00", "#228b22", "#6a5acd", "#17becf", "#ff7f0e")) +
  scale_color_manual(values = c("#000000", "#ff0600", "#d87904", "#891bce", "#f71ae6", "#2bc100")) +
  guides(fill = "none", alpha = "none", size = "none") + 
ggtitle("B. terrestris subspecies") +
  labs(x = Xlabs, y = Ylabs) +
  theme(plot.title = element_text(face = "italic"), legend.text = element_markdown(size = 13), legend.title = element_text(size = 14),
        axis.title.x = element_text(size = 18), axis.title.y = element_text(size = 18), axis.text.x = element_text(size = 16), axis.text.y = element_text(size = 16))
pca_plot
  
ggsave("PCA_terrestris.subset_without_unclear_sex.excl_repeats.pdf", width = 10, height = 10, limitsize=F)
ggsave("PCA_terrestris.subset_without_unclear_sex.excl_repeats.png", width = 10, height = 10, limitsize=F)

######### PCA plot by location

pca_plot = ggplot(data = pca_EVs_merged %>% arrange(desc(Origin)), aes(x = PC1, y = PC2, group = Origin)) +
#pca_plot = ggplot(pca_EVs_merged, aes(x = PC1, y = PC2, group = Origin)) +
  geom_point(aes(color = Origin, stroke = 2, shape = Origin), 
    alpha = 0.5, size = 10
  ) +
  scale_shape_manual(values = c(0, 1, 2, 3, 4, 5, 6)) +
  scale_color_manual(values = c("#000000", "#ff0600", "#d87904", "#891bce", "#f71ae6", "#2bc100", "cyan")) +
  #scale_color_manual(values = c("#ffbf00", "#228b22", "#6a5acd", "#17becf", "#ff7f0e")) +
  guides(fill = "none", alpha = "none", size = "none") + 
ggtitle("B. terrestris subspecies") +
  labs(x = Xlabs, y = Ylabs) +
  theme(plot.title = element_text(face = "italic"), legend.text = element_markdown(size = 13), legend.title = element_text(size = 14),
        axis.title.x = element_text(size = 18), axis.title.y = element_text(size = 18), axis.text.x = element_text(size = 16), axis.text.y = element_text(size = 16))
pca_plot
  
ggsave("PCA_terrestris.location.subset_without_unclear_sex.excl_repeats.pdf", width = 10, height = 10, limitsize=F)
ggsave("PCA_terrestris.location.subset_without_unclear_sex.excl_repeats.png", width = 10, height = 10, limitsize=F)


pca_plot = ggplot(data = pca_EVs_merged %>% arrange(desc(Origin)), aes(x = PC1, y = PC2, group = Origin)) +
#pca_plot = ggplot(pca_EVs_merged, aes(x = PC1, y = PC2, group = Origin)) +
  geom_point(aes(color = Origin, stroke = 2, shape = Subspecies), 
    alpha = 0.5, size = 10
  ) +
  scale_shape_manual(values = c(0, 1, 2, 3, 4, 5, 6)) +
  scale_color_manual(values = c("#000000", "#ff0600", "#d87904", "#891bce", "#f71ae6", "#2bc100", "cyan")) +
  #scale_color_manual(values = c("#ffbf00", "#228b22", "#6a5acd", "#17becf", "#ff7f0e")) +
  guides(fill = "none", alpha = "none", size = "none") + 
ggtitle("B. terrestris subspecies") +
  labs(x = Xlabs, y = Ylabs) +
  theme(plot.title = element_text(face = "italic"), legend.text = element_markdown(size = 13), legend.title = element_text(size = 14),
        axis.title.x = element_text(size = 18), axis.title.y = element_text(size = 18), axis.text.x = element_text(size = 16), axis.text.y = element_text(size = 16))
pca_plot
  
ggsave("PCA_terrestris.location_subspecies.subset_without_unclear_sex.excl_repeats.pdf", width = 10, height = 10, limitsize=F)
ggsave("PCA_terrestris.location_subspecies.subset_without_unclear_sex.excl_repeats.png", width = 10, height = 10, limitsize=F)

############# show labels


pca_plot = ggplot(data = pca_EVs_merged %>% arrange(desc(Subspecies)), aes(x = PC1, y = PC2, group = Subspecies, label = sample.id)) +
#pca_plot = ggplot(pca_EVs_merged, aes(x = PC1, y = PC2, group = Subspecies, label = sample.id)) +
  geom_point(aes(color = Subspecies, stroke = 0.9, shape = Subspecies),
    alpha = 0.6, size = 2
  ) +
  scale_shape_manual(values = c(0, 1, 2, 3, 4)) +
  scale_color_manual(values = c("#ffbf00", "#228b22", "#6a5acd", "#17becf", "#ff7f0e")) +
  #guides(fill = FALSE, alpha = FALSE, size = FALSE) +
  ggtitle("B. terrestris subspecies") +
  labs(x = Xlabs, y = Ylabs) +
  geom_text()
pca_plot

ggsave("PCA_terrestris.with_labels.subset_without_unclear_sex_outliers.excl_repeats.pdf", width = 10, height = 10, limitsize=F)
ggsave("PCA_terrestris.with_labels.subset_without_unclear_sex_outliers.excl_repeats.png", width = 10, height = 10, limitsize=F)
