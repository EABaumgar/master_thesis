### script for creating genofile for PCAs using vcf file excluding repeats and heterozygous snps

# load needed modules
module load anaconda3/2023.03
module load htslib/1.19.1
module load R/4.1.2
conda activate R_envs


# set variables
#VCFFOLDER="/share/pool/ek/project.bumblebee.evolution/bombus_pop_gen_eva/04_sorting_repeats_Ho_He_SNPs/01_repeats"
#VCFFOLDER="/share/pool/ek/project.bumblebee.evolution/bombus_pop_gen_eva/04_sorting_repeats_Ho_He_SNPs/02_homo_hetero_snps"
#INPUTVCF="$VCFFOLDER/$1"


# unzip file
#bgzip -d -@ $NSLOTS $INPUTVCF.vcf.gz
#bgzip -d -@ $NSLOTS $INPUTVCF.subset_female.vcf.gz


## Rscripts
#Rscript 01_snprelate.R
Rscript 03_PCA_plot_all.R
#Rscript 04_PCA_plot_subsets.R


# zip file again
#bgzip $INPUTVCF.vcf


# deactivate environment
conda deactivate

