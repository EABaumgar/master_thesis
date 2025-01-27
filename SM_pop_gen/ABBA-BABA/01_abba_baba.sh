### run population genomics analysis as in Simon Martin's scripts
##  https://github.com/simonhmartin/genomics_general

# load needed modules and environments
module load htslib/1.10.2
module load vcflib/1.0.3
module load vcftools/0.1.16
module load bcftools/1.19
module load miniforge/24.3.0
conda activate conda_env


# set variables and directories
SCRIPTSPATH="/home/ebaumgarten/general_genomics_SM/genomics_general"
POPGENSCRIPT="$SCRIPTSPATH/ABBABABAwindows.py"
GENOFOLDER="/share/pool/ek/project.bumblebee.evolution/bombus_pop_gen_eva/05_pop_gen/Genofiles_with_outgroup"
FILENAME="${1}"
FILE="$GENOFOLDER/$FILENAME.subset_without_unclear_sex.with_outgroup.excl_repeats.excl_het.filter"


## file (list) defining populations e.g. colormorphs/subspecies
POPFILE="/share/pool/ek/project.bumblebee.evolution/bombus_pop_gen_eva/05_pop_gen/abba_baba_popfile.txt"


### run analysis with a window size of 20000 bp
# P1 closest to outgroup; P2 second sister taxon; P3 distant taxon, O outgroup
python $POPGENSCRIPT --windType coordinate --windSize 20000 -f phased -T $NSLOTS --minData 0.4 \
 -P1 sassaricus -P2 xanthopus -P3 terrestris -O outgroup --popsFile $POPFILE \
 --genoFile $FILE.geno.gz -o $FILE.abba_baba.SXT.csv.gz


# deactivate environment
conda deactivate 
