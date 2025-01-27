### merge vcf-files based on filenames in a list into on single vcf-file
#load needed modules
module load htslib/1.19.1
module load samtools/1.19.2
module load bcftools/1.19
module load anaconda3/2023.03
# bcftools 1.13
conda activate vt_env


## rename SNP vcf samples for masterlist
# set variables
#DIR=/share/pool/ek/project.bumblebee.evolution/bombus_pop_gen_eva/04_SNP-call/Freebayes/01_vcf-master/renamed-vcfs
#INDIR=/share/pool/ek/project.bumblebee.evolution/bombus_pop_gen_eva/04_SNP-call/Freebayes/01_vcf-master/renamed-vcfs
#OUTDIR=/share/pool/ek/project.bumblebee.evolution/bombus_pop_gen_eva/04_SNP-call/Freebayes/01_vcf-master/merged
#OUTPUT=$1


## rename genotypes vcf samples
# set variables
DIR=/share/pool/ek/project.bumblebee.evolution/bombus_pop_gen_eva/04_SNP-call/Freebayes/01_vcf-master/renamed-vcfs
INDIR=/share/pool/ek/project.bumblebee.evolution/bombus_pop_gen_eva/04_SNP-call/Freebayes/02_vcf-genotyping/renamed-vcfs
OUTDIR=/share/pool/ek/project.bumblebee.evolution/bombus_pop_gen_eva/04_SNP-call/Freebayes/02_vcf-genotyping/merged
#OUTPUT=$1


## sample IDs in file
FILES=/share/pool/ek/project.bumblebee.evolution/bombus_pop_gen_eva/04_SNP-call/Freebayes/01_vcf-master/filtered/vcf_filtered_file_list.txt
file_list+=($(cat $FILES | tr "\n" " "))
#printf "%s\n" "${file_list[@]}" > ${INDIR}/file_list.txt


# create missing directory
mkdir -p ${OUTDIR}


## merge files from list and compress them to output-file in output-directory  {INDIR}/$2 
bcftools merge --file-list ${INDIR}/$2 --threads $NSLOTS | bgzip -f -@ $NSLOTS -c /dev/stdin > ${OUTDIR}/${OUTPUT}.vcf.gz


## index the merged file 
tabix -fp vcf ${OUTDIR}/${OUTPUT}.vcf.gz


# use vt
vt peek ${OUTDIR}/${OUTPUT}.vcf.gz 2> ${OUTDIR}/${OUTPUT}.peek


# deactivate environment
conda deactivate
