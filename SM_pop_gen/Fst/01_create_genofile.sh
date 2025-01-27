### generate geno-file from vcf-file as in Simon Martin's scripts
##  https://github.com/simonhmartin/genomics_general

# load modules
module load htslib/1.10.2
module load vcflib/1.0.3
module load vcftools/0.1.16
module load bcftools/1.19
module load miniforge/24.3.0
conda activate /home/ebaumgarten/.conda/env/numpy_env


# set directories and variables
SCRIPTSPATH="/home/ebaumgarten/general_genomics_SM/genomics_general"
VCFSCRIPT="VCF_processing/parseVCF.py"
FILTERSCRIPT="filterGenotypes.py"
POPGENSCRIPT="popgenWindows.py"


#VCFFOLDER="/share/pool/ek/project.bumblebee.evolution/bombus_pop_gen_eva/04_SNP-call/Freebayes/02_vcf-genotyping/merged"
VCFFOLDER="/share/pool/ek/project.bumblebee.evolution/bombus_pop_gen_eva/04_sorting_repeats_Ho_He_SNPs/02_homo_hetero_snps/reheader_filtered_vcf"
#INPUTVCF="$VCFFOLDER/$1.filtered.vcf.gz"
INPUTVCF="$VCFFOLDER/$1.filtered.subset_without_unclear_sex.with_outgroup.excl_repeats.excl_het.vcf.gz"
CHRFILE="/share/pool/ek/project.bumblebee.evolution/bombus_pop_gen_eva/05_pop_gen/chromosome_file.txt"


# create new directory for output
GENOFOLDER="/share/pool/ek/project.bumblebee.evolution/bombus_pop_gen_eva/05_pop_gen/Genofiles_with_outgroup"
mkdir -p $GENOFOLDER
FILENAME=$(ls $INPUTVCF | rev | cut -d"/" -f1 | cut -d"." -f4- | rev) && echo $FILENAME 

## use parseVCF.py to process vcf-file and output geno-file
#python3 $SCRIPTSPATH/$VCFSCRIPT -i $INPUTVCF --includeFile $CHRFILE --skipIndel --ploidyMismatchToMissing --addRefTrack | sed -e "s/\tN\t/\txxx\t/g" | sed "s/xxx/N\/N/g" | sed -e "s/\tN\t/\txxx\t/g" | sed -e "s/\tN$/\txxx/g" | sed "s/xxx/N\/N/g" | bgzip -f -@ $NSLOTS -c /dev/stdin > $GENOFOLDER/$FILENAME.geno.gz
python3 $SCRIPTSPATH/$VCFSCRIPT -i $INPUTVCF --includeFile $CHRFILE --skipIndel --ploidyMismatchToMissing --addRefTrack | sed -e "s/\tN\t/\txxx\t/g" | sed "s/xxx/N\/N/g" | sed -e "s/\tN\t/\txxx\t/g" | sed -e "s/\tN$/\txxx/g" | sed "s/xxx/N\/N/g" | bgzip -f -@ $NSLOTS -c /dev/stdin > $GENOFOLDER/$FILENAME.subset_without_unclear_sex.with_outgroup.excl_repeats.excl_het.geno.gz


## print samplename list into a file
#zcat $GENOFOLDER/$FILENAME.geno.gz | head -n1 | sed -r 's/\t/\n/g' | tail -n+3 > $GENOFOLDER/$FILENAME.geno.samplelist.lst
zcat $GENOFOLDER/$FILENAME.subset_without_unclear_sex.with_outgroup.excl_repeats.excl_het.geno.gz | head -n1 | sed -r 's/\t/\n/g' | tail -n+3 > $GENOFOLDER/$FILENAME.subset_without_unclear_sex.with_outgroup.excl_repeats.excl_het.geno.samplelist.lst

# deactive loaded environment
conda deactivate
