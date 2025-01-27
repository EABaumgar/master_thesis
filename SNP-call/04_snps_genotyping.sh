# load modules and environments
#module load bcftools/1.10.2
module load samtools/1.19.2
module load htslib/1.19.1
module load bcftools/1.19
module load parallel/20201222
module load pigz/2.7
module load anaconda3/2023.03

# when newer version/different version of freebayes then only first CHR is analysed
conda activate freebayes_v1.0.2.29


# stop on any error and print commands to stderr
set -x
# increase number of files that can be opened 
ulimit -n 4096


# set variables
REF=/share/pool/ek/project.bumblebee.evolution/bombus_pop_gen_eva/03_mapping/00_reference_genomes/Bombus_terrestris_ncbi/GCF_910591885.1_iyBomTerr1.2_genomic.fna
FAI=/share/pool/ek/project.bumblebee.evolution/bombus_pop_gen_eva/03_mapping/00_reference_genomes/Bombus_terrestris_ncbi/GCF_910591885.1_iyBomTerr1.2_genomic.fna.fai
OUT=/share/pool/ek/project.bumblebee.evolution/bombus_pop_gen_eva/04_SNP-call/Freebayes/


# set sample IDs in file as 1st parameter
FILES=/share/pool/ek/project.bumblebee.evolution/bombus_pop_gen_eva/04_SNP-call/Freebayes/terrestris_italy_islands_missing_samples_geno.txt


# create new directories
mkdir -p ${OUT}02_vcf-genotyping/raw
mkdir -p ${OUT}02_vcf-genotyping/raw_reheader


# decompress Master SNP list into RAMdisk for faster access
cp ${OUT}01_vcf-master/merged/$1.filtered.light.vcf.gz /dev/shm/
unpigz -p $NSLOTS /dev/shm/$1.filtered.light.vcf.gz
REFVCF=/dev/shm/$1.filtered.light.vcf


#SNP-call parameters
MINALTFRAC=0.25
MINALTN=2
MINCOV=3


# perform SNP-call by Sample, compress and index resulting vcf-file files
cat $FILES | parallel --no-notice -k -j $NSLOTS "echo {} && freebayes \
--fasta-reference $REF \
--ploidy 2 \
--variant-input $REFVCF \
--only-use-input-alleles \
--report-genotype-likelihood-max \
--use-mapping-quality \
--genotype-qualities \
--haplotype-length -1 \
--min-mapping-quality 40 \
--min-base-quality 30 \
--min-alternate-fraction $MINALTFRAC \
--min-alternate-total $MINALTN \
--min-coverage $MINCOV \
--bam {} |\
bgzip -f -@ $NSLOTS -c /dev/stdin > ${OUT}02_vcf-genotyping/raw/{/.}.vcf.gz \
&& tabix -fp vcf ${OUT}02_vcf-genotyping/raw/{/.}.vcf.gz \
&& bcftools reheader --fai $FAI ${OUT}02_vcf-genotyping/raw/{/.}.vcf.gz > ${OUT}02_vcf-genotyping/raw_reheader/{/.}.vcf.gz"


# remove ramdisc
rm /dev/shm/$1.filtered.light.vcf


# deactivate environment
conda deactivate
