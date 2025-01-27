### script for filtering males with heterozygous snps 

# load needed modules
module load htslib/1.19.1
module load samtools/1.19.2
module load bedtools/2.29.2
module load bcftools/1.19



# create variables
DIR="/share/pool/ek/project.bumblebee.evolution/bombus_pop_gen_eva/04_sorting_repeats_Ho_He_SNPs/01_repeats"
IN="Bter_resequenced_islands_mainland_genomasterlist.filtered.subset_without_unclear_sex"
OUTDIR="/share/pool/ek/project.bumblebee.evolution/bombus_pop_gen_eva/04_sorting_repeats_Ho_He_SNPs/02_homo_hetero_snps"


##### create subset of male samples

bcftools view -S males_resequenced_islands_mainland.txt $DIR/$IN.excl_repeats.vcf.gz --threads $NSLOTS | bgzip -f -@ $NSLOTS -c /dev/stdin > $OUTDIR/$IN.excl_repeats.subset_male.vcf.gz

##### extract all SNPs with min. 1 heterozygous in a vcf

bcftools view --genotype het --threads $NSLOTS $OUTDIR/$IN.excl_repeats.subset_male.vcf.gz | bgzip -f -@ $NSLOTS -c /dev/stdin > $OUTDIR/$IN.excl_repeats.subset_male.het.vcf.gz

##### filter heterozygous snps based on #samples they are present in

ACHET=${OUTDIR}/${IN}.excl_repeats.subset_male.het.ac_het.vcf.gz

## updata AC-tags
bcftools +fill-tags $OUTDIR/$IN.excl_repeats.subset_male.het.vcf.gz -- --tags AC,AC_Het | bgzip -f -@ $NSLOTS -c /dev/stdin > $ACHET

## exclude based on number of samples

#bcftools view --include 'SUM(INFO/AC_Het[0-]) >= 1' $ACHET | bgzip -f -@ $NSLOTS -c /dev/stdin > ${DIR}/${IN}.subset_male.het.ac_het.min_one.vcf.gz
#bcftools view --include 'SUM(INFO/AC_Het[0-]) >= 2' $ACHET | bgzip -f -@ $NSLOTS -c /dev/stdin > ${OUTDIR}/${IN}.excl_repeats.subset_male.het.ac_het.min_two.vcf.gz

##### exclude heterozygous SNPs from vcf-file

## exlude all heterozygous SNPs
bedtools intersect -a $DIR/$IN.excl_repeats.vcf.gz \
-b $ACHET -v -header | bgzip -f -@ $NSLOTS -c /dev/stdin > $OUTDIR/$IN.excl_repeats.excl_all_het.vcf.gz

## update tags again
bcftools +fill-tags $OUTDIR/$IN.excl_repeats.excl_all_het.vcf.gz -- --tags AC,AC_Het | bgzip -f -@ $NSLOTS -c /dev/stdin > $OUTDIR/$IN.excl_repeats.excl_all_het_f.vcf.gz


## exclude heterozygous SNPs
#bedtools intersect -a $DIR/$IN.excl_repeats.vcf.gz \
#-b $OUTDIR/$IN.excl_repeats.subset_male.het.ac_het.min_two.vcf.gz -v -header > $OUTDIR/$IN.excl_repeats.excl_het_min_two.vcf.gz
