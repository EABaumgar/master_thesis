## scalculate nSL with selscan for each subspecies per chromosome

# load needed modules
module load htslib/1.10.2
module load bcftools/1.19
module load selscan/2.0.3


# load variables
DIR="/share/pool/ek/project.bumblebee.evolution/bombus_pop_gen_eva/11_selection"
IN="/share/pool/ek/project.bumblebee.evolution/bombus_pop_gen_eva/04_sorting_repeats_Ho_He_SNPs/02_homo_hetero_snps/reheader_filtered_vcf/$2.subset_without_unclear_sex.subset_$1.vcf.gz"
OUT="/share/pool/ek/project.bumblebee.evolution/bombus_pop_gen_eva/11_selection/${1}_biallelic_file.vcf.gz"

## remove non-biallelic sites from vcf-file
bcftools view -m2 -M2 -v snps --exclude-uncalled --threads $NSLOTS $IN | bgzip -f -@ $NSLOTS -c /dev/stdin > $OUT

## create index file for vcf (bcftools filter needs that)
tabix -fp vcf $OUT

mkdir ${1}_vcfs
mkdir ${1}_nSL

## split by chromosome & retain biallelic SNPs only
chrs_list=($(cat chromosome_list.txt | tr "\n" " "))

for ID in "${chrs_list[@]}"
do
## extract SNPs for respective chromosome
bcftools filter $OUT -r $ID | bgzip -f -@ $NSLOTS -c /dev/stdin > ${1}_vcfs/$ID.biallelic.vcf.gz
# filter missing sites per chromosome
bcftools view -e 'F_MISSING > 0' ${1}_vcfs/$ID.biallelic.vcf.gz --threads $NSLOTS | bgzip -f -@ $NSLOTS -c /dev/stdin > ${1}_vcfs/$ID.biallelic.excl_missing_sites.vcf.gz

selscan-2.0.3 --unphased --threads $NSLOTS --nsl --vcf ${1}_vcfs/$ID.biallelic.excl_missing_sites.vcf.gz --out ${1}_nSL/$ID.biallelic.excl_missing_sites


done


## normalise output
norm --nsl --files $1_nSL/*out
