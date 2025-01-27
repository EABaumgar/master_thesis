# load modules and environment
module load anaconda3/2023.03
module load htslib/1.19.1
module load samtools/1.19.2
module load parallel/20201222
#conda activate genomictools_env
module load bcftools/1.19
module load vcftools/0.1.16
module load vcflib/1.0.3


# print commands to stderr
set -x


# define vcf-folder
DIR=/share/pool/ek/project.bumblebee.evolution/bombus_pop_gen_eva/04_SNP-call/Freebayes/


# define reference-genome file
REF=/share/pool/ek/project.bumblebee.evolution/bombus_pop_gen_eva/03_mapping/00_reference_genomes/Bombus_terrestris_ncbi/GCF_910591885.1_iyBomTerr1.2_genomic.fna


# set list of input samples as 2nd argument
SAMPLES=/share/pool/ek/project.bumblebee.evolution/bombus_pop_gen_eva/04_SNP-call/Freebayes/02_vcf-genotyping/raw/$1


# create outputfolder
mkdir -p $DIR/02_vcf-genotyping/filtered


#### filter steps
# filter all master vcf-files (one for each region) and keep only those SNPs with a Quality > 15
# then split multibase alleles into several records (one for each base) with vcfbcftools norm and mark those ones as Decomposed;
# sort vcf-files according to position with vcfstreamsort
# normalize variants with bcftools norm (all variants must be parsimonius and left aligned to be normal)
# update allele statistics with fixup
# remove duplicate allele records (probably stemming from several input files?) with vcfuniqalleles
# remove Indels
# calculate number of alternative alleles for each SNP
# convert null-genotypes to ./.
# sort again and  keep only unique genotypes
# update allele statistics with fixup and then recalculate some statistics with bcftools +fill-tags
# then compress and index
cat $SAMPLES | parallel --no-notice -j $NSLOTS \
"zcat $DIR/02_vcf-genotyping/raw_reheader/{}.vcf.gz |\
bcftools sort --output-type v --temp-dir $HOME/tmp/ - |\
vcfuniq |\
bcftools norm --multiallelics + - |\
vcfuniqalleles |\
vcffixup - |\
vcfnumalt - |\
bcftools +fill-tags /dev/stdin -- --tags AC,AF,AN,MAF |\
vcfnulldotslashdot |\
sed 's/=DPR,Number=A/=DPR,Number=R/g' |\
bgzip -f -@ 14 -c /dev/stdin > $DIR/02_vcf-genotyping/filtered/{}.vcf.gz \
&& tabix -fp vcf $DIR/02_vcf-genotyping/filtered/{}.vcf.gz"
echo "filtering done"


# deactivate environment
#conda deactivate
