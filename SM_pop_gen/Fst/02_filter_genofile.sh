### filter geno-file as in Simon Martin's scripts
##  https://github.com/simonhmartin/genomics_general

# load modules
module load htslib/1.10.2
module load vcflib/1.0.3
module load vcftools/0.1.16
module load bcftools/1.19
module load miniforge/24.3.0
# conda activate /home/ebaumgarten/.conda/env/numpy_env
conda activate numpy_1-26-4

conda list
python test.py


# set directories and variables
SCRIPTSPATH="/home/ebaumgarten/general_genomics_SM/genomics_general"
FILTERSCRIPT="filterGenotypes.py"


GENOFOLDER="/share/pool/ek/project.bumblebee.evolution/bombus_pop_gen_eva/05_pop_gen/Genofiles_resequenced_islands_mainland_subset_female.n122"
FILENAME="${1}"
#FILENAME="${1}_genofile"


# use a file (list) defining populations
#POPFILE="/share/pool/ek/project.bumblebee.evolution/bombus_pop_gen_eva/05_pop_gen/terrestris_mainland_islands_without_unclear_sex_popfile.txt"
POPFILE="/share/pool/ek/project.bumblebee.evolution/bombus_pop_gen_eva/05_pop_gen/subset_female_terrestris_mainland_islands_popfile.txt"


# filter geno-file
## "populations" in terrestris as found in Italy/ associated islands: calabricus, hybrid, sassaricus, terrestris, xanthopus
python3 $SCRIPTSPATH/$FILTERSCRIPT --threads $NSLOTS --podSize 1000000 --inputGenoFormat phased --outputGenoFormat phased --ploidy 2 --forcePloidy --minAlleles 2 --minCalls 10 \
 -p calabricus -p hybrid -p sassaricus -p terrestris -p xanthopus --popsFile $POPFILE --minPopCalls 1 -i $GENOFOLDER/$FILENAME.filtered.subset_female.n122.excl_repeats.excl_het.geno.gz -o $GENOFOLDER/$FILENAME.subset_female.n122.excl_repeats.excl_het.filter.geno.gz
# -p outgroup

# deactivate environment
conda deactivate





### Additional info
#--thinDist 100
#--include CM009931.2
#--inputGenoFormat diplo
#--outputGenoFormat (count,coded,randomAllele,alleles,bases,diplo,phased)
#--inputGenoFormat (diplo,phased,bases,alleles)
#--alleleOrder
#--samples sample1,sample4,sample10
#--excludeSamples sample100,sample200
#--pop popName --> PopName and optionallysamplenames
#--popsFile POPFILE.lst (samplename pop)
#--keepAllSamples (keep all, not just specified pops)
#--ploidy PLOIDY  /    --ploidyFile
#--forcePloidy
#--partialToMissing
#--include/--includeFile/--exclude/--excludeFile contigs/scaffolds
#--minCalls - min. Number of individuals with non-missing N/N genotypes at a site
#--minAlleles /--maxAlleles Number of alleles observed at a site across all individuals
#--minVarCount Minor allele count
#--thinDist Distance between sites for thinning
#--maxHet 0.2 proportion of htz genotypes (max)
#--minFeq/--maxFreq variant frequency
#--HWE P-Value 'top' / 'bottom' / 'both'
#--minPopCalls number of good genotype calls per pop
#--minPopAlleles/maxPopAlleles
#--fixedDiffs only variants where differences are fixed between any pops
#--nearlyFixedDiff NUMBER diff btw pops is > x
#--podSize 100000 lines to analyze per thread
### Additional info end
