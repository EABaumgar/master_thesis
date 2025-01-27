##install.packages("BiocManager")
##library(BiocManager)
##BiocManager::install("SNPRelate")


# load needed modules
.libPaths("/home/ebaumgarten/.conda/envs/R_envs/lib/R/library")
library(SNPRelate)
library(gdsfmt)

# set working directory
setwd("/share/pool/ek/project.bumblebee.evolution/bombus_pop_gen_eva/04_sorting_repeats_Ho_He_SNPs/02_homo_hetero_snps")
#setwd("/share/pool/ek/project.bumblebee.evolution/bombus_pop_gen_eva/04_sorting_repeats_Ho_He_SNPs/01_repeats")

inputfile="Bter_resequenced_islands_mainland_genomasterlist.filtered.excl_repeats.excl_het.vcf"


# read in data and title, convert to gds
input.gds <- gsub(".vcf", ".gds", inputfile)
snpgdsVCF2GDS(inputfile, input.gds, method = "biallelic.only")

snpgdsSummary(input.gds)
genofile <- snpgdsOpen(input.gds)

set.seed(1000)
snpset <- snpgdsLDpruning(genofile, num.thread=20, autosome.only=FALSE)

names(snpset)
head(snpset$chr1)

# get SNP ids
snp.id <- unlist(snpset)

# print summary of genofile
snpgdsSummary(genofile)
