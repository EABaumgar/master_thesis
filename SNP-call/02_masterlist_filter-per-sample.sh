# load needed modules and environments
module load anaconda3/2023.03
module load htslib/1.19.1
module load samtools/1.19.2
module load parallel/20201222
#conda activate genomictools_envs
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
SAMPLES=/share/pool/ek/project.bumblebee.evolution/bombus_pop_gen_eva/04_SNP-call/Freebayes/01_vcf-master/raw/$1 ## raw vcf file output after snp_masterlist.sh??


# create outputfolder
mkdir -p $DIR/01_vcf-master/filtered


#### filter steps
# filter all master vcf-files (one per sample) and keep only those SNPs with a Quality > 30
# then split multibase alleles into several SNP records (Decomposition) using bcftools norm, save previous records in the INFO-fields with the tag PREDECOMPOSED
# sort vcf-files according to position with vcfstreamsort
# normalize variants with bcftools norm (all variants must be parsimonius and left aligned to be normal) safe old record in the INFO-fields with the tag PRENORMALIZED
# update allele statistics with vcffixup
# remove duplicate alleles within one record with vcfuniqalleles
# remove Indels
# calculate number of alternative alleles for each SNP
# convert null-genotypes to ./.
# sort again and  keep only unique genotypes
# update statistics again
# remove biallelic entries where the alternative allele is found 10 times or more but always on the same strand, assuming these entries might be artefacts
# then compress and index
cat $SAMPLES | parallel --no-notice -j $NSLOTS \
"zcat $DIR/01_vcf-master/raw_reheader/{}.vcf.gz |\
vcffilter -f 'QUAL > 15' |\
bcftools norm --atomize --old-rec-tag PREDECOMPOSE - |\
vcfstreamsort |\
bcftools norm -f $REF --old-rec-tag PRENORMALIZE - |\
vcffixup - |\
vcfuniqalleles |\
vcfnoindels |\
vcfnumalt - |\
vcfnulldotslashdot |\
vcfstreamsort -a |\
vcfuniq |\
vcffixup -|\
bcftools view -e 'NUMALT=1 && INFO/AO>=10 && (INFO/SAF<1 || INFO/SAR<1)' - |
bgzip -f -@ 10 -c /dev/stdin > $DIR/01_vcf-master/filtered/{}.vcf.gz \
&& tabix -fp vcf $DIR/01_vcf-master/filtered/{}.vcf.gz"
echo "filtering done" 


# deactivate environment
#conda deactivate
