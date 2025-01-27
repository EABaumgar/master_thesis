### filter out repeats for B.terrestris vcf-files after SNP-call; using Bed-file


# load modules
module load bedtools/2.29.2
module load htslib/1.19.1
module load miniforge/24.3.0


# activate environment
conda activate vt_env


# create variables
INDIR="/share/pool/ek/project.bumblebee.evolution/bombus_pop_gen_eva/04_SNP-call/Freebayes/02_vcf-genotyping/merged"
OUTDIR="/share/pool/ek/project.bumblebee.evolution/bombus_pop_gen_eva/04_sorting_repeats_Ho_He_SNPs/01_repeats"
REF="/share/pool/ek/project.bumblebee.evolution/bombus_pop_gen/03_repeats/03_repeatmasker/GCF_910591885.1_iyBomTerr1.2_genomic.fna.unreliable.bed.gz"


# filter out repeats using bedtools
bedtools intersect -a ${INDIR}/$1.filtered.subset_unclear_sex_outliers3.vcf.gz \
-b ${REF} -v -header > ${OUTDIR}/$1.filtered.subset_unclear_sex_outliers3.excl_repeats.vcf


# zip filtered file
#bgzip ${OUTDIR}/$1.filtered.subset_unclear_sex_outliers3.excl_repeats.vcf


# use vt
vt peek ${OUTDIR}/$1.filtered.subset_males.n40.excl_repeats.vcf.gz 2> ${OUTDIR}/$1..filtered.subset_males.n40.excl_repeats.peek


# deactivate environment
conda deactivate
