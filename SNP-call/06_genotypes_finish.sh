# load modules and environment
module load anaconda3/2023.03
module load htslib/1.19.1
module load samtools/1.19.2
module load bcftools/1.10.2
module load vcflib/1.0.3
module load vcftools/0.1.16
conda activate vt_env



# increase limit for number of temporary files to be opened simultanously
ulimit -n 4096
# print commands to stderr
set -x


# set input directory
DIR=/share/pool/ek/project.bumblebee.evolution/bombus_pop_gen_eva/04_SNP-call/Freebayes/02_vcf-genotyping/merged


# cat fused vcf-file, filter out sites where the reference is N
# sort fused file
# remove identical records
# join biallelic into multiallelic records
# remove duplicated alleles
# recalculate some statistics for fused file
# compress and index resulting file
#zcat ${DIR}/merged_genotyping_$1_selected.vcf.gz |\
zcat ${DIR}/$1.vcf.gz |\
bcftools sort -O v -T . - |\
vcfuniq |\
bcftools norm --multiallelics + - |\
vcfuniqalleles |\
bcftools view --trim-alt-alleles --exclude-uncalled |\
vcfnumalt - |\
bcftools +fill-tags /dev/stdin -- --tags AC,AF,AN,MAF,NS |\
#bgzip -f -@ $NSLOTS -c /dev/stdin > ${DIR}/merged_genotyping_$1_selected.filtered.vcf.gz
#tabix -fp vcf ${DIR}/merged_genotyping_$1_selected.filtered.vcf.gz
bgzip -f -@ $NSLOTS -c /dev/stdin > ${DIR}/$1.filtered.vcf.gz
tabix -fp vcf ${DIR}/$1.filtered.vcf.gz


# run vt peek on finished file to obtain some allele statistics
vt peek ${DIR}/$1.filtered.vcf.gz 2>${DIR}/$1.filtered.peek
#vt peek ${DIR}/merged_genotyping_$1_FIXED.vcf.gz 2>${DIR}/merged_genotyping_$1_FIXED.peek


# deactivate environment
conda deactivate
