############## Script for plotting Simon Martin Abba-baba #####################

work_dir <- "C:/Users/evaad/Desktop/Master'in life/Data/RStudio/05_PopGen/SimonMartin/04_Abba_baba"

setwd(work_dir)
list.files(path = work_dir)

# load packages
library(ggplot2)
library(tidyr)
library(purrr)
library(dplyr)
library(readr)
library(dplyr)



# load file
NFILE <- "Bter_resequenced_islands_mainland_genomasterlist.subset_without_unclear_sex.with_outgroup.excl_repeats.excl_het.filter.abba_baba.SXT.csv"



data <- read_csv(INFILE,na = c("NaN", "NA"), col_names = TRUE)


# parse column specification
cols(scaffold = col_character(),
     start = col_double(),
     end = col_double(),
     mid = col_double(),
     sites = col_double(),
     sitesUsed = col_double(),
     ABBA = col_double(),
     BABA = col_double(),
     D = col_double(),
     fd = col_double(),
     fdM = col_double(),)


# convert fd to 0 when D is negative
data_neg <- data
for (x in 1:length(data_neg)){
  data_neg$fd = ifelse(data_neg$D < 0, 0, data_neg$fd)
}


# convert Chromosomal IDs to numbers

data$scaffoldID <- data$scaffold


# Group data by scaffold
data <- data %>%
  group_by(scaffold) %>%
  mutate(scaffold = cur_group_id()) %>%
  ungroup

tmp <- data


# give new colnames
colnames(tmp) <- c("CHR","BIN_START","BIN_END","BP","N_VARIANTS","N_VARIANTSUSED","ABBA","BABA","D","fd","fdM")

SNP<-c(1:(nrow(tmp)))
manhattandataframe<-data.frame(SNP,tmp)
manhattandataframe <- within(manhattandataframe, BP <- ifelse(!is.na(BP),BP,(BIN_END+BIN_START)/2))


## Convert CHR to factor and sort
manhattandataframe$CHR <- factor(manhattandataframe$CHR, levels = unique(manhattandataframe$CHR))


## Convert SNP to numeric
manhattandataframe$SNP <- as.numeric(manhattandataframe$SNP)


## Try linking axis
axis_prep <- manhattandataframe %>%
  group_by(CHR) %>%
  summarise(chr_len = max(BP)) %>%
  mutate(tot = cumsum(chr_len) - chr_len) %>%
  select(-chr_len) %>%
  left_join(manhattandataframe, ., by =c("CHR" = "CHR")) %>%
  arrange(CHR, BP) %>%
  mutate(BPcum = BP + tot) 

## Prep Axis
axis_set <- axis_prep %>%
  group_by(CHR) %>%
  summarize(center = (max(BPcum) + min(BPcum)) / 2)


# means and medians
ALLMEANS <- manhattandataframe %>% group_by(CHR) %>% summarise_at(.vars = names(.)[8:12],.funs = mean, na.rm = TRUE)
ALLMEDIANS <- manhattandataframe %>% group_by(CHR) %>% summarise_at(.vars = names(.)[8:12],.funs = median, na.rm = TRUE)
GENOMICMEAN <- manhattandataframe %>% summarise_at(.vars = names(.)[8:12],.funs = mean, na.rm = TRUE)
GENOMICMEDIAN <- manhattandataframe %>% summarise_at(.vars = names(.)[8:12],.funs = median, na.rm = TRUE)


# calculate mean
DMEAN <- round(GENOMICMEAN$D, digits = 2)
fdMEAN <- round(GENOMICMEAN$fd, digits = 2)
fdMMEAN <- round(GENOMICMEAN$fdM, digits = 2)
ABBAMEAN <- round(GENOMICMEAN$ABBA, digits = 2)
BABAMEAN <- round(GENOMICMEAN$BABA, digits = 2)

# calculate 99 percentile
# Percentiles used in calculation
#p <- c(.25,.5,.75)
p <- .99
#p_names <- paste0(p*100, "%")
#p_funs <- map(p, ~partial(quantile, probs = .x, na.rm = TRUE)) %>% set_names(nm = p_names)
p_funs <- map(p, ~partial(quantile, probs = .x, na.rm = TRUE))
str(manhattandataframe)
GENOMICPERCENTILE99 <- manhattandataframe %>% summarize_at(.vars = names(.)[8:12], p_funs)

Dx99 <- round(GENOMICPERCENTILE99$D, digits = 2)
fdx99 <- round(GENOMICPERCENTILE99$fd, digits = 2)
fdMx99 <- round(GENOMICPERCENTILE99$fdM, digits = 2)
ABBAx99 <- round(GENOMICPERCENTILE99$ABBA, digits = 2)
BABAx99 <- round(GENOMICPERCENTILE99$BABA, digits = 2)


# create max Y value
YMAXD=max(manhattandataframe$D,na.rm=TRUE)
YMAXfd=max(manhattandataframe$fd,na.rm=TRUE)
YMAXfdM=max(manhattandataframe$fdM,na.rm=TRUE)
YMAXABBA=max(manhattandataframe$ABBA,na.rm=TRUE)
YMAXBABA=max(manhattandataframe$BABA,na.rm=TRUE)


# round max Y value
YMAXDROUNDED=ceiling(YMAXD*10)/10
YMAXfdROUNDED=ceiling(YMAXfd*10)/10
YMAXfdMROUNDED=ceiling(YMAXfdM*10)/10
YMAXABBAROUNDED=ceiling(YMAXABBA*10)/10
YMAXBABAROUNDED=ceiling(YMAXBABA*10)/10



# Add column for SNP density ---> this start CHR1 and end CHR18
axis_prep2 <- axis_prep %>%
  mutate(SNP_density = SNP / (BIN_END - BIN_START))


# Normalize density (optional??)
axis_prep2 <- axis_prep2 %>%
  mutate(SNP_density_norm = (SNP_density - min(SNP_density)) / (max(SNP_density) - min(SNP_density)))

axis_prep3 <- axis_prep2 %>%
  group_by(CHR) %>%
  mutate(SNP_density = SNP / (BIN_END - BIN_START)) %>%
  ungroup()

# Normalize the SNP density per chromosome
axis_prep3 <- axis_prep3 %>%
  group_by(CHR) %>%
  mutate(SNP_density_norm = (SNP_density - min(SNP_density)) / (max(SNP_density) - min(SNP_density))) %>%
  ungroup()


#################### PLOT D using GGPLOT2 #########################################
TITLE1="D_SXT"
PLOTTITLE1="Gene flow between SXT"
png(paste(OUTFILE,".",TITLE1,".png",sep=""),width = 1700, height = 800)
(ggplot(axis_prep3, aes(x = BPcum, y = D)) +
    geom_point(aes(color = factor(CHR), alpha = SNP_density_norm), size = 3) +
    scale_color_manual(values = rep(c("black", "grey"), length(unique(axis_prep$CHR)))) +
    labs(title = PLOTTITLE1, x = "Chromosome (20kb windows)", y = "D (ABBA-BABA)") +
    scale_x_continuous(breaks = axis_set$center, labels = axis_set$CHR) +
    theme_minimal() +
    theme(
      legend.position = "none",
      panel.border = element_blank(),
      plot.title = element_text(size = 20, face = "bold.italic", hjust = 0.5),
      axis.title.x = element_text(size = 22, face = "bold"),
      axis.title.y = element_text(size = 22, face = "bold"),
      axis.text = element_text(size = 20, face = "plain", colour = "black")
    ) +
    ylim(-1, 1) +
    #geom_hline(yintercept = Dx99, color = "blue", linetype = "dashed", linewidth = 0.8) +
    geom_hline(yintercept = DMEAN, color = "red", linetype = "dashed", linewidth = 0.8) +
    scale_alpha_continuous(range = c(0.3, 1)))
dev.off()
