## script to run admixture

# load needed modules
module load bcftools/1.19
module load htslib/1.19.1
module load plink/1.90beta6.16


# create needed variables
SCRIPTSPATH="/home/ebaumgarten/admixture"
VCFFOLDER="/share/pool/ek/project.bumblebee.evolution/bombus_pop_gen_eva/04_sorting_repeats_Ho_He_SNPs/02_homo_hetero_snps/reheader_filtered_vcf"
#VCFFOLDER="/share/pool/ek/project.bumblebee.evolution/bombus_pop_gen_eva/04_SNP-call/Freebayes/02_vcf-genotyping/merged"
DIR="/share/pool/ek/project.bumblebee.evolution/bombus_pop_gen_eva/07_SNP_analysis/Admixture"
VCF=$VCFFOLDER/$1.vcf.gz


### create subset with 18 CHR
# create index file for vcf
tabix -fp vcf $VCF
bcftools filter $VCF -r NC_063269.1,NC_063270.1,NC_063271.1,NC_063272.1,NC_063273.1,NC_063274.1,NC_063275.1,NC_063276.1,NC_063277.1,NC_063278.1,NC_063279.1,NC_063280.1,NC_063281.1,NC_063282.1,NC_063283.1,NC_063284.1,NC_063285.1,NC_063286.1 -o $DIR/$1.filtered.vcf.gz


# create new variable for filtered vcf
NEWVCF=$DIR/$1.filtered.vcf.gz


#### create index file for new vcf (bcftools filter needs that)
tabix -fp vcf $NEWVCF


### rename chromosomes/scaffolds
bcftools annotate --rename-chrs terrestris_chromosomes.rename2.txt $NEWVCF | bgzip -f -@ $NSLOTS -c /dev/stdin > $DIR/$1.renamed.vcf.gz


### filter missing genotypes for admixture
bcftools view -e 'F_MISSING > 0' $DIR/$1.renamed.vcf.gz -o $DIR/$1.filteredmissing.vcf
#bcftools view -e 'F_MISSING > 0.2' $DIR/$1.renamed.vcf.gz -o $DIR/$1.filteredmissing.vcf
bgzip $DIR/$1.filteredmissing.vcf
bcftools index $DIR/$1.filteredmissing.vcf.gz
bcftools +fill-tags $DIR/$1.filteredmissing.vcf.gz -- --tags all | bgzip -f -@ $NSLOTS -c /dev/stdin > $DIR/$1.filteredmissing_t.vcf.gz

bgzip -d $DIR/$1.filteredmissing_t.vcf.gz

#### convert vcf to plink-format
## causes both family and within-family IDs to be set to the sample ID.
plink --vcf $DIR/$1.filteredmissing_t.vcf --double-id --allow-extra-chr --out $DIR/$1.t.plink


#### run ADMIXTURE using plink-format
#### admixture [options] inputFile K
#### input = bed/ped , K = # populations
  
#### find best value for K
for K in 1 2 3 4 5 6
do
## run admixture with respective K value
 $SCRIPTSPATH/admixture -j$NSLOTS --cv $DIR/$1.t.plink.bed $K | tee log${K}.t.terrestris.out
done
