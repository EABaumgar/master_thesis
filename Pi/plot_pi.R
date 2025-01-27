################################################################################
############## Script for PI-Values POPGEN #####################################
################################################################################


# load needed packages
library(ggplot2)
library(readr)
library(purrr) #map
library(grid)
library(ggtext)
library(tidyverse)
library(dplyr)
library(patchwork)

# set identity
cols(CHROM = col_character(),
     BIN_START = col_double(),
     BIN_END = col_double(),
     N_VARIANTS = col_double(),
     PI = col_double())


# convert Chromosomal IDs to numbers
data$scaffoldID <- data$CHROM


# group data by scaffold
data <- data %>%
  group_by(CHROM) %>%
  mutate(scaffold = cur_group_id()) %>%
  ungroup


# create tmp dataframe with new column names
tmp <- data
colnames(tmp) <- c("CHR","BIN_START","BIN_END","N_VARIANTS","pi1",
                    "ScaffoldID")
tmp$BP <- "NA"

SNP<-c(1:(nrow(tmp)))

# create dataframe for manhattanplot with SNP column included
manhattandataframe<-data.frame(SNP,tmp)#manhattandataframe$BP <- within(manhattandataframe, BP <- ifelse(!is.na(BP),BP,(BIN_END+BIN_START)/2))
manhattandataframe$BP <- (manhattandataframe$BIN_END+manhattandataframe$BIN_START) / 2



# calculate mean SNP for CHR labels on x-axis
axis_set2 = manhattandataframe %>% 
  group_by(NA.) %>% 
  summarize(center = mean(SNP))

axis_set2 <- axis_set2[-c(19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33), ]

# calculate general means and medians
ALLMEANS <- manhattandataframe %>% group_by(CHR) %>% summarise_at(.vars = names(.)[6:6],.funs = mean, na.rm = TRUE)
ALLMEDIANS <- manhattandataframe %>% group_by(CHR) %>% summarise_at(.vars = names(.)[6:6],.funs = median, na.rm = TRUE)
GENOMICMEAN <- manhattandataframe %>% summarise_at(.vars = names(.)[6:6],.funs = mean, na.rm = TRUE)
GENOMICMEDIAN <- manhattandataframe %>% summarise_at(.vars = names(.)[6:6],.funs = median, na.rm = TRUE)


# calculate individual pi-value medians
pi1MEDIAN <- round(GENOMICMEDIAN$pi1, digits = 8)


# calculate individual pi-value means
pi1MEAN <- round(GENOMICMEAN$pi1, digits = 8)


# calculate ymax for plotting accordingly later
YMAXpi1=max(manhattandataframe$pi1,na.rm=TRUE)
YMAXpi1ROUNDED=ceiling(YMAXpi1*10)/10


# Percentiles used in calculation
#p <- c(.25,.5,.75)
p <- .99
#p_names <- paste0(p*100, "%")
#p_funs <- map(p, ~partial(quantile, probs = .x, na.rm = TRUE)) %>% set_names(nm = p_names)
p_funs <- map(p, ~partial(quantile, probs = .x, na.rm = TRUE))
GENOMICPERCENTILE99 <- manhattandataframe %>% summarize_at(.vars = names(.)[6:6], p_funs)


pi1x99 <- round(GENOMICPERCENTILE99$pi1, digits = 8)

YMAXall <- 0.0075

################################################################################
######### Plot Pi values individually ##########################################
################################################################################


## Create a Manhattan plot with ggplot2
#pi1
OUTFILE="Bter_italy_islands_mainland.subset_without_unclear_sex.excl_repeats.excl_het.piall"
TITLE1="pi_calabricus"
PLOTTITLE1="Nucleotide diversity (π) of calabricus" # of female hybrids alternatively
png(paste(OUTFILE,".",TITLE1,".png",sep=""),width = 1700, height = 800)
(plot_pi1 <- ggplot(manhattandataframe, aes(x = SNP, y = pi1)) +
    geom_point(aes(color = factor(CHR)), size = 3.5) +
    scale_color_manual(values = rep(c("black", "grey"), length(unique(manhattandataframe$CHR)))) +
    labs(title = PLOTTITLE1, x = "\nChromosome (20kb windows)", y = "Pi-value\n") +
    scale_x_continuous(breaks = axis_set2$center, labels = axis_set2$NA.) +
    theme_minimal() +
    theme(
      legend.position = "none",
      plot.title = element_text(size = 20, face = "bold.italic", hjust = 0.5),
      axis.title.x = element_text(size = 22, face = "bold"),
      axis.title.y = element_text(size = 22, face = "bold"),
      axis.text = element_text(size = 20, face = "bold", colour = "black")
    ) +
    #ylim(0, YMAXpi1ROUNDED) +
    ylim(0, YMAXall) +
    geom_hline(yintercept = pi1x99, color = "blue", linetype = "dashed", linewidth = 0.8) +
    geom_hline(yintercept = pi1MEDIAN, color = "red", linetype = "dashed", linewidth = 0.8))
dev.off()



