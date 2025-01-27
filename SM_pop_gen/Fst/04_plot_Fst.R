######### Plotting FST values using x = BP and y = FST #########################
################ REF : JOE Genomic signatures 2022 + EK + NB ###################

#work_dir <- "C:/Users/evaad/Desktop/Master'in life/Data/RStudio/05_PopGen/SimonMartin/EK_script_manhatten_FST"
work_dir <- "C:/Users/evaad/Desktop/Master'in life/Data/RStudio/05_PopGen/SimonMartin/01_FST"


setwd(work_dir)
list.files(path = work_dir)



library(ggplot2)
library(tidyr)
library(purrr)
library(dplyr)
library(scales)
library(ggplot2)
library(readr)
library(dplyr)
library(qqman)
#library(manhattanly)
#library(magrittr)


INFILE <- "Bter_resequenced_islands_mainland_genomasterlist.subset_without_unclear_sex.excl_repeats.excl_het.filter.popPairDist.csv"
#INFILE <- "Bter_resequenced_islands_mainland_genomasterlist.subset_female.n122.excl_repeats.excl_het.filter.popPairDist.csv"

data <- read_csv(INFILE,na = c("NaN", "NA"), col_names = TRUE)


#Parsed with column specification:
# male
cols(scaffold = col_character(),
     start = col_double(),
     end = col_double(),
     mid = col_double(),
     sites = col_double(),
     dxy_hybrid_sassaricus = col_double(),
     dxy_hybrid_terrestris = col_double(),
     dxy_hybrid_xanthopus = col_double(),
     #dxy_calabricus_hybrid = col_double(),
     dxy_sassaricus_terrestris = col_double(),
     dxy_sassaricus_xanthopus = col_double(),
     #dxy_calabricus_sassaricus = col_double(),
     dxy_terrestris_xanthopus = col_double(),
     #dxy_calabricus_terrestris = col_double(),
     #dxy_calabricus_xanthopus = col_double(),
     Fst_hybrid_sassaricus = col_double(),
     Fst_hybrid_terrestris = col_double(),
     Fst_hybrid_xanthopus = col_double(),
     #Fst_calabricus_hybrid = col_double(),
     Fst_sassaricus_terrestris = col_double(),
     Fst_sassaricus_xanthopus = col_double(),
     #Fst_calabricus_sassaricus = col_double(),
     Fst_terrestris_xanthopus = col_double(),) 
     #Fst_calabricus_terrestris = col_double(),
     #Fst_calabricus_xanthopus = col_double(),)

#female and all
cols(scaffold = col_character(),
     start = col_double(),
     end = col_double(),
     mid = col_double(),
     sites = col_double(),
     dxy_hybrid_sassaricus = col_double(),
     dxy_hybrid_terrestris = col_double(),
     dxy_hybrid_xanthopus = col_double(),
     dxy_calabricus_hybrid = col_double(),
     dxy_sassaricus_terrestris = col_double(),
     dxy_sassaricus_xanthopus = col_double(),
     dxy_calabricus_sassaricus = col_double(),
     dxy_terrestris_xanthopus = col_double(),
     dxy_calabricus_terrestris = col_double(),
     dxy_calabricus_xanthopus = col_double(),
     Fst_hybrid_sassaricus = col_double(),
     Fst_hybrid_terrestris = col_double(),
     Fst_hybrid_xanthopus = col_double(),
     Fst_calabricus_hybrid = col_double(),
     Fst_sassaricus_terrestris = col_double(),
     Fst_sassaricus_xanthopus = col_double(),
     Fst_calabricus_sassaricus = col_double(),
     Fst_terrestris_xanthopus = col_double(), 
     Fst_calabricus_terrestris = col_double(),
     Fst_calabricus_xanthopus = col_double(),)

# convert Chromosomal IDs to numbers

data$scaffoldID <- data$scaffold


# Group data by scaffold
data <- data %>%
  group_by(scaffold) %>%
  mutate(scaffold = cur_group_id()) %>%
  ungroup


tmp <- data
# male
colnames(tmp) <- c("CHR","BIN_START","BIN_END","BP","N_VARIANTS","DXY1","DXY2","DXY3","DXY4","DXY5","DXY6","FST1","FST2","FST3","FST4","FST5","FST6")
# female and all
colnames(tmp) <- c("CHR","BIN_START","BIN_END","BP","N_VARIANTS","DXY1","DXY2","DXY3","DXY4","DXY5","DXY6","DXY7","DXY8","DXY9","DXY10",
                   "FST1","FST2","FST3","FST4","FST5","FST6","FST7","FST8","FST9","FST10")

SNP<-c(1:(nrow(tmp)))


manhattandataframe<-data.frame(SNP,tmp)
manhattandataframe <- within(manhattandataframe, BP <- ifelse(!is.na(BP),BP,(BIN_END+BIN_START)/2))
#manhattandataframe = read_csv("manhattandataframe.terrestris.excl_repeats.csv")



###################### Try different link of x-axis to CHR #####################
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






########################### calculate means per chromosome #####################
#manhattandataframe %>% group_by(CHR) %>% mutate(FST_Mean = mean(P))
#ALLMEANS <- manhattandataframe %>% group_by(CHR) %>% summarise_at(.vars = names(.)[6:12],.funs = c(mean="mean"))
#ALLMEDIANS <- manhattandataframe %>% group_by(CHR) %>% summarise_at(.vars = names(.)[6:12],.funs = c(median="median"))

ALLMEANS <- manhattandataframe %>% group_by(CHR) %>% summarise_at(.vars = names(.)[7:26],.funs = mean, na.rm = TRUE) #7:18 males 7:26 females and all
ALLMEDIANS <- manhattandataframe %>% group_by(CHR) %>% summarise_at(.vars = names(.)[7:26],.funs = median, na.rm = TRUE)
GENOMICMEAN <- manhattandataframe %>% summarise_at(.vars = names(.)[7:26],.funs = mean, na.rm = TRUE)
GENOMICMEDIAN <- manhattandataframe %>% summarise_at(.vars = names(.)[7:26],.funs = median, na.rm = TRUE)
fst1MEDIAN <- round(GENOMICMEDIAN$FST1, digits = 4)
fst2MEDIAN <- round(GENOMICMEDIAN$FST2, digits = 4)
fst3MEDIAN <- round(GENOMICMEDIAN$FST3, digits = 4)
fst4MEDIAN <- round(GENOMICMEDIAN$FST4, digits = 4)
fst5MEDIAN <- round(GENOMICMEDIAN$FST5, digits = 4)
fst6MEDIAN <- round(GENOMICMEDIAN$FST6, digits = 4)
fst7MEDIAN <- round(GENOMICMEDIAN$FST7, digits = 4)
fst8MEDIAN <- round(GENOMICMEDIAN$FST8, digits = 4)
fst9MEDIAN <- round(GENOMICMEDIAN$FST9, digits = 4)
fst10MEDIAN <- round(GENOMICMEDIAN$FST10, digits = 4)
dxy1MEDIAN <- round(GENOMICMEDIAN$DXY1, digits = 2)
dxy2MEDIAN <- round(GENOMICMEDIAN$DXY2, digits = 2)
dxy3MEDIAN <- round(GENOMICMEDIAN$DXY3, digits = 2)
dxy4MEDIAN <- round(GENOMICMEDIAN$DXY4, digits = 2)
dxy5MEDIAN <- round(GENOMICMEDIAN$DXY5, digits = 2)
dxy6MEDIAN <- round(GENOMICMEDIAN$DXY6, digits = 2)
dxy7MEDIAN <- round(GENOMICMEDIAN$DXY7, digits = 2)
dxy8MEDIAN <- round(GENOMICMEDIAN$DXY8, digits = 2)
dxy9MEDIAN <- round(GENOMICMEDIAN$DXY9, digits = 2)
dxy10MEDIAN <- round(GENOMICMEDIAN$DXY10, digits = 2)


# percentile

# Percentiles used in calculation
#p <- c(.25,.5,.75)
p <- .99
#p_names <- paste0(p*100, "%")
#p_funs <- map(p, ~partial(quantile, probs = .x, na.rm = TRUE)) %>% set_names(nm = p_names)
p_funs <- map(p, ~partial(quantile, probs = .x, na.rm = TRUE))
str(manhattandataframe)
GENOMICPERCENTILE99 <- manhattandataframe %>% summarize_at(.vars = names(.)[7:26], p_funs)

fst1x99 <- round(GENOMICPERCENTILE99$FST1, digits = 2)
fst2x99 <- round(GENOMICPERCENTILE99$FST2, digits = 2)
fst3x99 <- round(GENOMICPERCENTILE99$FST3, digits = 2)
fst4x99 <- round(GENOMICPERCENTILE99$FST4, digits = 2)
fst5x99 <- round(GENOMICPERCENTILE99$FST5, digits = 2)
fst6x99 <- round(GENOMICPERCENTILE99$FST6, digits = 2)
fst7x99 <- round(GENOMICPERCENTILE99$FST7, digits = 2)
fst8x99 <- round(GENOMICPERCENTILE99$FST8, digits = 2)
fst9x99 <- round(GENOMICPERCENTILE99$FST9, digits = 2)
fst10x99 <- round(GENOMICPERCENTILE99$FST10, digits = 2)
dxy1x99 <- round(GENOMICPERCENTILE99$DXY1, digits = 2)
dxy2x99 <- round(GENOMICPERCENTILE99$DXY2, digits = 2)
dxy3x99 <- round(GENOMICPERCENTILE99$DXY3, digits = 2)
dxy4x99 <- round(GENOMICPERCENTILE99$DXY4, digits = 2)
dxy5x99 <- round(GENOMICPERCENTILE99$DXY5, digits = 2)
dxy6x99 <- round(GENOMICPERCENTILE99$DXY6, digits = 2)
dxy7x99 <- round(GENOMICPERCENTILE99$DXY7, digits = 2)
dxy8x99 <- round(GENOMICPERCENTILE99$DXY8, digits = 2)
dxy9x99 <- round(GENOMICPERCENTILE99$DXY9, digits = 2)
dxy10x99 <- round(GENOMICPERCENTILE99$DXY10, digits = 2)


# fetch specific chromosome's mean for FST1 values if needed
#meanchr1 <- ALLMEANS %>% filter(CHR == 1) %>% select(FST1)
#meanchr2 <- ALLMEANS %>% filter(CHR == 2) %>% select(FST1)

### collect means to plot later as subtitle
# means = paste("means"," "," All:",meanALL," chr1:",meanchr1," chr3:",meanchr3," chr15:",meanchr15," chr16:",meanchr16,sep="")
## calculate Y-Ais maximums (rounded up to next decimal) for scaling the plot
YMAXfst1=max(manhattandataframe$FST1,na.rm=TRUE)
YMAXfst2=max(manhattandataframe$FST2,na.rm=TRUE)
YMAXfst3=max(manhattandataframe$FST3,na.rm=TRUE)
YMAXfst4=max(manhattandataframe$FST4,na.rm=TRUE)
YMAXfst5=max(manhattandataframe$FST5,na.rm=TRUE)
YMAXfst6=max(manhattandataframe$FST6,na.rm=TRUE)
YMAXfst7=max(manhattandataframe$FST7,na.rm=TRUE)
YMAXfst8=max(manhattandataframe$FST8,na.rm=TRUE)
YMAXfst9=max(manhattandataframe$FST9,na.rm=TRUE)
YMAXfst10=max(manhattandataframe$FST10,na.rm=TRUE)
YMAXdxy1=max(manhattandataframe$DXY1,na.rm=TRUE)
YMAXdxy2=max(manhattandataframe$DXY2,na.rm=TRUE)
YMAXdxy3=max(manhattandataframe$DXY3,na.rm=TRUE)
YMAXdxy4=max(manhattandataframe$DXY4,na.rm=TRUE)
YMAXdxy5=max(manhattandataframe$DXY5,na.rm=TRUE)
YMAXdxy6=max(manhattandataframe$DXY6,na.rm=TRUE)
YMAXdxy7=max(manhattandataframe$DXY7,na.rm=TRUE)
YMAXdxy8=max(manhattandataframe$DXY8,na.rm=TRUE)
YMAXdxy9=max(manhattandataframe$DXY9,na.rm=TRUE)
YMAXdxy10=max(manhattandataframe$DXY10,na.rm=TRUE)
YMAXfst1ROUNDED=ceiling(YMAXfst1*10)/10
YMAXfst2ROUNDED=ceiling(YMAXfst2*10)/10
YMAXfst3ROUNDED=ceiling(YMAXfst3*10)/10
YMAXfst4ROUNDED=ceiling(YMAXfst4*10)/10
YMAXfst5ROUNDED=ceiling(YMAXfst5*10)/10
YMAXfst6ROUNDED=ceiling(YMAXfst6*10)/10
YMAXfst7ROUNDED=ceiling(YMAXfst7*10)/10
YMAXfst8ROUNDED=ceiling(YMAXfst8*10)/10
YMAXfst9ROUNDED=ceiling(YMAXfst9*10)/10
YMAXfst10ROUNDED=ceiling(YMAXfst10*10)/10
YMAXdxy1ROUNDED=ceiling(YMAXdxy1*10)/10
YMAXdxy2ROUNDED=ceiling(YMAXdxy2*10)/10
YMAXdxy3ROUNDED=ceiling(YMAXdxy3*10)/10
YMAXdxy4ROUNDED=ceiling(YMAXdxy4*10)/10
YMAXdxy5ROUNDED=ceiling(YMAXdxy5*10)/10
YMAXdxy6ROUNDED=ceiling(YMAXdxy6*10)/10
YMAXdxy7ROUNDED=ceiling(YMAXdxy7*10)/10
YMAXdxy8ROUNDED=ceiling(YMAXdxy8*10)/10
YMAXdxy9ROUNDED=ceiling(YMAXdxy9*10)/10
YMAXdxy10ROUNDED=ceiling(YMAXdxy10*10)/10


################## PLOT ########################################################




## Create a Manhattan plot with ggplot2
#FST1
#OUTFILE="Bter_italy_islands_mainland.subset_without_unclear_sex.excl_repeats.BP"
#TITLE1="fst1_hybrid_sassaricus"
#PLOTTITLE1="Hybrids - Sassaricus"
#png(paste(OUTFILE,".",TITLE1,".png",sep=""),width = 2000, height = 600)
#(ggplot(axis_prep, aes(x = BPcum, y = FST1)) +
#    geom_point(aes(color = factor(CHR)), size = 1.5) +
#    scale_color_manual(values = rep(c("black", "grey"), length(unique(axis_prep$CHR)))) +
#    labs(title = PLOTTITLE1, x = "Chromosome (200kb windows)", y = "FST") +
#    scale_x_continuous(breaks = axis_set$center, labels = axis_set$CHR) +
#    theme_minimal() +
#    theme(
#      legend.position = "none",
#      panel.border = element_blank(),
#      plot.title = element_text(size = 17, face = "bold.italic", hjust = 0.5),
#      axis.title.x = element_text(size = 16, face = "bold"),
#      axis.title.y = element_text(size = 16, face = "bold"),
#      axis.text = element_text(size = 14, face = "plain", colour = "black")
#    ) +
#    ylim(0, YMAXfst1ROUNDED) +
#    geom_hline(yintercept = fst1x99, color = "blue", linetype = "dashed") +
#    geom_hline(yintercept = fst1MEDIAN, color = "red", linetype = "dashed"))
#dev.off()
#
#
################## PLOT ########################################################


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

# Set fst that fits all plots 
YMAXfstall <- 0.8


#FST1
OUTFILE="Bter_italy_islands_mainland.subset_without_unclear_sex.excl_repeats.excl_het.fstpres"
TITLE1="fst1_hybrid_sassaricus"
PLOTTITLE1="hybrids - sassaricus" #Female in front alternatively
png(paste(OUTFILE,".",TITLE1,".png",sep=""),width = 1700, height = 800)
ggplot(axis_prep3, aes(x = BPcum, y = FST1)) +
  geom_point(aes(color = factor(CHR), alpha = SNP_density_norm), size = 5) +
  scale_color_manual(values = rep(c("black", "grey"), length(unique(axis_prep$CHR)))) +
  labs(title = PLOTTITLE1, x = "Chromosome (20kb windows)", y = "FST") +
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
  #ylim(0, YMAXfst1ROUNDED) +
  ylim(0, YMAXfstall) +
  geom_hline(yintercept = fst1x99, color = "blue", linetype = "dashed", linewidth = 0.8) +
  geom_hline(yintercept = fst1MEDIAN, color = "red", linetype = "dashed", linewidth = 0.8) +
  scale_alpha_continuous(range = c(0.25, 1))
dev.off()

