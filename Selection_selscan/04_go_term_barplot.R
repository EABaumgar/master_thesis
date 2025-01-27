# Load libraries; install from scratch if needed
libraries <- c("ggplot2",
               "lattice",
               "ggpubr",
               "RColorBrewer")
for (lib in libraries) {
  if (require(package = lib, character.only = TRUE)) {
    print("Successful")
  } else {
    print("Installing")
    source("https://bioconductor.org/biocLite.R")
    library(lib, character.only = TRUE)
  }
}


## Read in biological processes GO terms:
INFILEbp <- "BP_top50.tsv"
INFILEmf <- "MF_top50.tsv"
INFILEcc <- "CC_top50.tsv"
bp_terms <- read.table(INFILEbp,
                       header = TRUE, sep = "\t")
bp_terms$category <- "BP"

## Read in molecular function GO terms:
mf_terms <- read.table(INFILEmf,
                       header = TRUE, sep = "\t")
mf_terms$category <- "MF"

## Read in molecular function GO terms:
cc_terms <- read.table(INFILEcc,
                       header = TRUE, sep = "\t")
cc_terms$category <- "CC"


## Combine GO terms:
combined_terms <- rbind(bp_terms,
                        mf_terms,
                        cc_terms)
## Remove NA-values
combined_terms <- na.omit(combined_terms)

combined_terms$category <- factor(combined_terms$category)

## Set order of GO categories to plot
levels(combined_terms$category) <- c("Biological process", "Molecular function", "Cellular component")

## Log transform p values for plotting:
#str(combined_terms)
#combined_terms$weight_ks_adjusted <- -log(combined_terms$weight_ks_adjusted)
combined_terms$weight_fisher_adjusted <- -log(combined_terms$weight_fisher_adjusted)



## For plotting, update GO term names to include total number of annotated terms:
combined_terms$updated_terms <- paste(combined_terms$Term,
                                      " ",
                                      "(",
                                      combined_terms$Annotated,
                                      ")",
                                      sep = "")

## Remove underscore:
combined_terms$updated_terms <- gsub("_", " ", combined_terms$updated_terms)
str(combined_terms)



## Generate plot:
(combined_terms_plot <- ggbarplot(combined_terms,
                                 x = "updated_terms",
                                 y = "weight_fisher_adjusted",
                                 position = position_dodge(0.1),
                                 fill = "category",
                                 color = "category",
                                 palette = 'Dark2',
                                 sort.val = "desc",
                                 sort.by.groups = TRUE,
                                 ylab = "-log10(p)",
                                 xlab = "GO terms of genes with strongest nsl scores in xanthopus",
                                 legend.title = "Gene Ontology",
                                 lab.col = "black",
                                 lab.size = 2,
                                 lab.vjust = 0.5,
                                 lab.hjust = 1,
                                 short.panel.labs = FALSE,
                                 legend = "top",
                                 rotate = FALSE,
                                 ggtheme = theme_minimal()))

## Make font bigger and bold:
(combined_terms_plot <- combined_terms_plot +
  labs(x = expression(bold("GO terms of genes with strongest nSL scores in")~bolditalic("xanthopus"))) +
  theme(axis.text.x = element_text(size = 10,
                                   angle = 90,
                                   hjust = 1,
                                   vjust = 0.2,
                                   face = "bold"),
        axis.text = element_text(size = 15),
        axis.title.x = element_text(size = 15,
                                    face = "bold"),
        axis.title.y = element_text(size = 15,
                                    face = "bold"),
        axis.text.y = element_text(size = 10,
                                   face = "bold"),
        legend.text = element_text(size = 12),
        legend.title = element_blank(),
        legend.position = "top"))

## Save picture:
ggsave(file = "xanthopus_combined_go_terms_barchart.png",
       height = 10,
       width = 15)

## Save picture:
ggsave(file = "xanthopus_combined_go_terms_barchart.pdf",
       dpi = 600,
       height = 10,
       width = 15)
