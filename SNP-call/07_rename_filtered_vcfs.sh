## rename sample in single vcf-files
# load needed modules
module load htslib/1.19.1

## rename SNP vcf samples for masterlist
# set up directories and paths
#IN=/share/pool/ek/project.bumblebee.evolution/bombus_pop_gen_eva/04_SNP-call/Freebayes/01_vcf-master/filtered/
#OUT=/share/pool/ek/project.bumblebee.evolution/bombus_pop_gen_eva/04_SNP-call/Freebayes/01_vcf-master/renamed-vcfs/


## rename genotypes vcf samples 
# set up directories and paths
IN=/share/pool/ek/project.bumblebee.evolution/bombus_pop_gen_eva/04_SNP-call/Freebayes/02_vcf-genotyping/filtered/
OUT=/share/pool/ek/project.bumblebee.evolution/bombus_pop_gen_eva/04_SNP-call/Freebayes/02_vcf-genotyping/renamed-vcfs/


#make new directory
mkdir -p ${OUT}


## rename SNP vcf samples for masterlist
## sample IDs in file
#FILES=/share/pool/ek/project.bumblebee.evolution/bombus_pop_gen_eva/04_SNP-call/Freebayes/01_vcf-master/filtered/vcf_filtered_file_list_mainland_resequenced.txt
#file_list=($(cat $FILES | tr "\n" " "))
## e.g. NBP1-10_3_C10


## rename genotypes vcf samples
FILES=/share/pool/ek/project.bumblebee.evolution/bombus_pop_gen_eva/04_SNP-call/Freebayes/02_vcf-genotyping/filtered/genotype_filtered_file_list_mainland_islands_resequenced.txt
file_list=($(cat $FILES | tr "\n" " "))
## e.g. NBP1-10_3_C10


# rename vcfs 
for ID in "${file_list[@]}"
do

zcat ${IN}${ID}.vcf.gz | sed s/unknown/${ID}/ | bgzip -@ $NSLOTS -c /dev/stdin > ${OUT}${ID}.vcf.gz
tabix -fp vcf ${OUT}${ID}.vcf.gz


done
