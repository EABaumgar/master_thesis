# load conda environment 
## modules bcftools in old version - functional script
module load anaconda3/2023.03
module load htslib/1.19.1
module load samtools/1.19.2
module load bcftools/1.10.2
module load vcflib/1.0.3
module load vcftools/0.1.16
conda activate vt_env



# print commands to stderr
set -x
# increase limit for number of temporary files to be opened simultanously
ulimit -n 4096


# set input directory????
DIR=/share/pool/ek/project.bumblebee.evolution/bombus_pop_gen_eva/04_SNP-call/Freebayes/01_vcf-master/merged


# cat fused vcf-file, filter out sites where the reference is N
# sort fused file
# remove identical records
# join biallelic into multiallelic records
# remove duplicated alleles
# recalculate some statistics for fused file
# compress and index resulting file
zcat ${DIR}/${1}.vcf.gz |\
awk '$4 != "N"' |\
bcftools sort -O v -T . - |\
vcfuniq |\
bcftools norm --multiallelics + - |\
vcfuniqalleles |\
vcfnumalt - |\
bcftools +fill-tags /dev/stdin -- --tags AC,AF,AN,MAF,NS |\
bgzip -f -@ $NSLOTS -c /dev/stdin > ${DIR}/${1}.filtered.vcf.gz
tabix -fp vcf ${DIR}/${1}.filtered.vcf.gz


# extract header of vcf
tabix -H ${DIR}/${1}.filtered.vcf.gz | grep "^##" > ${DIR}/${1}.filtered.light.vcf


# extract head of table and append to light vcf
tabix -H ${DIR}/${1}.filtered.vcf.gz | grep -m1 "^#CHROM" | cut -f 1-9 >> ${DIR}/${1}.filtered.light.vcf


# extract records without single sample information and append to light vcf
zcat ${DIR}/${1}.filtered.vcf.gz | grep -v "^#" | cut -f 1-9 >> ${DIR}/${1}.filtered.light.vcf


# sort light file, compress and index light file     -
cat ${DIR}/${1}.filtered.light.vcf |\
bcftools sort -O v -T . ${DIR}/${1}.filtered.light.vcf |\
bgzip -f -@ $NSLOTS -c /dev/stdin > ${DIR}/${1}.filtered.light.vcf.gz 
tabix -fp vcf ${DIR}/${1}.filtered.light.vcf.gz


# run vt peek on finished file to obtain some allele statistics
vt peek ${DIR}/${1}.filtered.light.vcf.gz 2> ${DIR}/${1}.filtered.light.peek


# deactivate environment
conda deactivate
