### run population genomics analysis as in Simon Martin's scripts
##  https://github.com/simonhmartin/genomics_general

# load modules
module load htslib/1.10.2
module load vcflib/1.0.3
module load vcftools/0.1.16
module load bcftools/1.19
module load miniforge/24.3.0
conda activate conda_env


# set variables and directories
SCRIPTSPATH="/home/ebaumgarten/general_genomics_SM/genomics_general"
POPGENSCRIPT="$SCRIPTSPATH/popgenWindows.py"
GENOFOLDER="/share/pool/ek/project.bumblebee.evolution/bombus_pop_gen_eva/05_pop_gen/Genofiles_resequenced_islands_mainland_subset_males.n40"
FILENAME="${1}"
FILE="$GENOFOLDER/$FILENAME.subset_males.n40.excl_repeats.excl_het.filter"


## file (list) defining populations e.g. colormorphs/subspecies
POPFILE="/share/pool/ek/project.bumblebee.evolution/bombus_pop_gen_eva/05_pop_gen/subset_males_terrestris_mainland_islands_popfile.txt"


### run analysis with a window size of 20000 bp for females and subset all
##  run popgenWindows.py for B. terrestris
#python $POPGENSCRIPT --windType coordinate --windSize 20000 -f phased -T $NSLOTS --minData 0.4 --roundTo 8 \
# -p hybrid -p sassaricus -p terrestris -p xanthopus -p calabricus \    
#--popsFile $POPFILE --genoFile $FILE.geno.gz -o $FILE.popDist.csv.gz --analysis popDist
#
#python $POPGENSCRIPT --windType coordinate --windSize 20000 -f phased -T $NSLOTS --minData 0.4 --roundTo 8 \
# -p hybrid -p sassaricus -p terrestris -p xanthopus -p calabricus \
#--popsFile $POPFILE --genoFile $FILE.geno.gz -o $FILE.popPairDist.csv.gz --analysis popPairDist
#
#python $POPGENSCRIPT --windType coordinate --windSize 20000 -f phased -T $NSLOTS --minData 0.4 --roundTo 8 \
# -p hybrid -p sassaricus -p terrestris -p xanthopus -p calabricus \
#--popsFile $POPFILE --genoFile $FILE.geno.gz -o $FILE.indHet.csv.gz --analysis indHet
#
#python $POPGENSCRIPT --windType coordinate --windSize 20000 -f phased -T $NSLOTS --minData 0.4 --roundTo 8 \
# -p hybrid -p sassaricus -p terrestris -p xanthopus -p calabricus \
#--popsFile $POPFILE --genoFile $FILE.geno.gz -o $FILE.hapStats.csv.gz --analysis hapStats --hapDist 0.2


### run analysis with a window size of 20000 bp for males with adapted subspecies
##  run popgenWindows.py for B. terrestris
python $POPGENSCRIPT --windType coordinate --windSize 20000 -f phased -T $NSLOTS --minData 0.4 --roundTo 8 \
 -p hybrid -p sassaricus -p terrestris -p xanthopus \    
--popsFile $POPFILE --genoFile $FILE.geno.gz -o $FILE.popDist.csv.gz --analysis popDist

python $POPGENSCRIPT --windType coordinate --windSize 20000 -f phased -T $NSLOTS --minData 0.4 --roundTo 8 \
 -p hybrid -p sassaricus -p terrestris -p xanthopus \
--popsFile $POPFILE --genoFile $FILE.geno.gz -o $FILE.popPairDist.csv.gz --analysis popPairDist

python $POPGENSCRIPT --windType coordinate --windSize 20000 -f phased -T $NSLOTS --minData 0.4 --roundTo 8 \
 -p hybrid -p sassaricus -p terrestris -p xanthopus \
--popsFile $POPFILE --genoFile $FILE.geno.gz -o $FILE.indHet.csv.gz --analysis indHet

python $POPGENSCRIPT --windType coordinate --windSize 20000 -f phased -T $NSLOTS --minData 0.4 --roundTo 8 \
 -p hybrid -p sassaricus -p terrestris -p xanthopus \
--popsFile $POPFILE --genoFile $FILE.geno.gz -o $FILE.hapStats.csv.gz --analysis hapStats --hapDist 0.2



# deactivate environment
conda deactivate

#python $POPGENSCRIPT --windType coordinate --windSize 20000 -f phased -T $NSLOTS --minData 0.4 --roundTo 2 \
#-p calabricus -p hybrid -p sassaricus -p terrestris -p xanthopus \
#--popsFile $POPFILE --genoFile $FILE.geno.gz -o $FILE.popDist.csv.gz --analysis popDist
#
#python $POPGENSCRIPT --windType coordinate --windSize 20000 -f phased -T $NSLOTS --minData 0.4 --roundTo 2 \
#-p calabricus -p hybrid -p sassaricus -p terrestris -p xanthopus \
#--popsFile $POPFILE --genoFile $FILE.geno.gz -o $FILE.popPairDist.csv.gz --analysis popPairDist
#
#python $POPGENSCRIPT --windType coordinate --windSize 20000 -f phased -T $NSLOTS --minData 0.4 --roundTo 2 \
#-p calabricus -p hybrid -p sassaricus -p terrestris -p xanthopus \
#--popsFile $POPFILE --genoFile $FILE.geno.gz -o $FILE.indHet.csv.gz --analysis indHet
#
#python $POPGENSCRIPT --windType coordinate --windSize 20000 -f phased -T $NSLOTS --minData 0.4 --roundTo 2 \
#-p calabricus -p hybrid -p sassaricus -p terrestris -p xanthopus \
#--popsFile $POPFILE --genoFile $FILE.geno.gz -o $FILE.hapStats.csv.gz --analysis hapStats --hapDist 0.2

### N species start
##  run popgenWindows.py for B. soroeensis
#python $POPGENSCRIPT --windType coordinate --windSize 20000 -f phased -T $NSLOTS --minData 0.4 --roundTo 2 \
#--population lapidarius-like --population other --population terrestris-like \
#--popsFile $POPFILE --genoFile $FILE.geno.gz -o $FILE.popDist.csv.gz --analysis popDist
#
#python $POPGENSCRIPT --windType coordinate --windSize 20000 -f phased -T $NSLOTS --minData 0.4 --roundTo 2 \
#--population lapidarius-like --population other --population terrestris-like \
#--popsFile $POPFILE --genoFile $FILE.geno.gz -o $FILE.popPairDist.csv.gz --analysis popPairDist
#
#python $POPGENSCRIPT --windType coordinate --windSize 20000 -f phased -T $NSLOTS --minData 0.4 --roundTo 2 \
#--population lapidarius-like --population other --population terrestris-like \
#--popsFile $POPFILE --genoFile $FILE.geno.gz -o $FILE.indHet.csv.gz --analysis indHet
#
#python $POPGENSCRIPT --windType coordinate --windSize 20000 -f phased -T $NSLOTS --minData 0.4 --roundTo 2 \
#--population lapidarius-like --population other --population terrestris-like \
#--popsFile $POPFILE --genoFile $FILE.geno.gz -o $FILE.hapStats.csv.gz --analysis hapStats --hapDist 0.2
#
#
##  run popgenWindows.py for B. lapidarius
#python $POPGENSCRIPT --windType coordinate --windSize 20000 -f phased -T $NSLOTS --minData 0.4 --roundTo 2 \
#-p caucasicus -p decipiens -p lapidarius \
#--popsFile $POPFILE --genoFile $FILE.geno.gz -o $FILE.popDist.csv.gz --analysis popDist
#
#python $POPGENSCRIPT --windType coordinate --windSize 20000 -f phased -T $NSLOTS --minData 0.4 --roundTo 2 \
#-p caucasicus -p decipiens -p lapidarius \
#--popsFile $POPFILE --genoFile $FILE.geno.gz -o $FILE.popPairDist.csv.gz --analysis popPairDist
#
#python $POPGENSCRIPT --windType coordinate --windSize 20000 -f phased -T $NSLOTS --minData 0.4 --roundTo 2 \
#-p caucasicus -p decipiens -p lapidarius \
#--popsFile $POPFILE --genoFile $FILE.geno.gz -o $FILE.indHet.csv.gz --analysis indHet
#
#python $POPGENSCRIPT --windType coordinate --windSize 20000 -f phased -T $NSLOTS --minData 0.4 --roundTo 2 \
#-p caucasicus -p decipiens -p lapidarius \
#--popsFile $POPFILE --genoFile $FILE.geno.gz -o $FILE.hapStats.csv.gz --analysis hapStats --hapDist 0.2
### N species end
