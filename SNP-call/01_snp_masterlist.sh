# load needed modules and environments
module load bcftools/1.19
module load samtools/1.19.2
module load htslib/1.19.1
module load parallel/20201222
# module load anaconda3/2023.03
module load miniforge/24.3.0

# set name for environment
# alternative: Use the path to the enviroment
conda activate freebayesEnv

# stop on any error and print commands to stderr
set -x
# increase number of files that can be opened 
ulimit -n 4096


REF=/share/pool/ek/project.bumblebee.evolution/bombus_pop_gen_eva/03_mapping/00_reference_genomes/Bombus_terrestris_ncbi/GCF_910591885.1_iyBomTerr1.2_genomic.fna
FAI=/share/pool/ek/project.bumblebee.evolution/bombus_pop_gen_eva/03_mapping/00_reference_genomes/Bombus_terrestris_ncbi/GCF_910591885.1_iyBomTerr1.2_genomic.fna.fai
OUT=/share/pool/ek/project.bumblebee.evolution/bombus_pop_gen_eva/04_SNP-call/Freebayes/


## set sample IDs in file as 1st parameter
FILES=/share/pool/ek/project.bumblebee.evolution/bombus_pop_gen_eva/04_SNP-call/Freebayes/$1

mkdir -p ${OUT}01_vcf-master/raw_test
mkdir -p ${OUT}01_vcf-master/raw_reheader_test

#SNP-call parameters
MINALTFRAC=0.30
MINALTN=2
MINCOV=6

# perform SNP-call by Sample, compress and index resulting vcf-file files
cat $FILES | parallel --no-notice -k -j $NSLOTS "echo {} && freebayes \
--fasta-reference $REF \
--ploidy 2 \
--report-genotype-likelihood-max \
--use-mapping-quality \
--genotype-qualities \
--use-best-n-alleles 4 \
--haplotype-length 3 \
--min-mapping-quality 40 \
--min-base-quality 30 \
--min-alternate-fraction $MINALTFRAC \
--min-alternate-total $MINALTN \
--min-coverage $MINCOV \
--bam {} |\
bgzip -f -@ 5 -c /dev/stdin > ${OUT}01_vcf-master/raw_test/{/.}.vcf.gz\
&& tabix -fp vcf ${OUT}01_vcf-master/raw_test/{/.}.vcf.gz\
&& bcftools reheader --fai $FAI ${OUT}01_vcf-master/raw_test/{/.}.vcf.gz > ${OUT}01_vcf-master/raw_reheader_test/{/.}.vcf.gz"

##--use-best-n-alleles 20 \ --> set to 4
##--min-mapping-quality 20 \ --> used by Johanna

conda deactivate
