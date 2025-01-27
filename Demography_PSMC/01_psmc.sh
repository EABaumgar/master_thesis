# Script for infering population size history from diploid sequence
# https://github.com/lh3/psmc

#load all 3 programmes either via module load or conda activate as the case may be (newer versions of samtools do not have samtools mpileup -v -u flag)
module load samtools/1.8
module load bcftools/1.10.2
module load miniforge/24.3.0
module load gnuplot/5.2.8

#load environment for psmc
conda activate psmc


#Paths for input files and output directory, use full paths
FILES="/share/pool/ek/project.bumblebee.evolution/bombus_pop_gen_eva/09_Demography/PSMC/$1.txt"
H1_genome="/home/ebaumgarten/dysgu_test_data/GCF_910591885.1/GCF_910591885.1_iyBomTerr1.2_genomic.fna" #Reference genome
OUTDIR="/share/pool/ek/project.bumblebee.evolution/bombus_pop_gen_eva/09_Demography/PSMC/standard_para_test" #changed to new_test


# Create list of scaffolds that are larger than 500 kb from reference genome
awk '$2 >= 500000 {print $1}' ${H1_genome}.fai > scaffolds_500kb.txt


#Generate consensus fastq from the .bam files using a combination of samtools mpileup, bcftools call and vcfutils.pl vcf2fq
#This run is in parallel, resulting in multiple consensus fastq files according to the number of chromosomes present
# Q: minimum base quality
# q: minimum map quality
# c: bcftyools consensus caller
# d: minimum depth
# D: Maximum depth
for file in $(cat $FILES);
do
    Bam=$(echo ${file} | rev |cut -f 1 -d '/' | cut -f 2 -d '.' | rev)
    mkdir -p ${2}/${Bam}
    exec 3< scaffolds_500kb.txt
    while read -u 3 scaffold;
    do
    echo "Processing scaffold: $scaffold"
    samtools mpileup  -f ${H1_genome} -q 30 -Q 30 -r ${scaffold} -v -u ${file} |
    bcftools call -c |
    vcfutils.pl vcf2fq -d 10 -D 60 -Q 30 > ${OUTDIR}/${Bam}/${Bam}.${scaffold}.fq
    done
    exec 3<&-
done


# Merge output per chromosome fq files for consensus fq
#cat ${OUTDIR}/*.fq > ${OUTDIR}/.consensus.fq
for dir in ${OUTDIR}/${3}/;
do
    dirname=$(basename "$dir")
    cat "${dir}"*.fq > "${OUTDIR}/${dirname}/${dirname}.consensus.fq"
    echo "Created consensus file: ${OUTDIR}/${dirname}/${dirname}.consensus.fq"
    fq2psmcfa -q20 ${OUTDIR}/${dirname}/${dirname}.consensus.fq > ${OUTDIR}/${dirname}/${dirname}.psmcfa
    echo "Created psmcfa file: ${OUTDIR}/${dirname}/${dirname}.psmcfa"
    splitfa ${OUTDIR}/${dirname}/${dirname}.psmcfa > ${OUTDIR}/${dirname}/${dirname}.split.psmcfa
    echo "Created split psmcfa file for bootstrapping: ${OUTDIR}/${dirname}/${dirname}.split.psmcfa"
done


#Then finally run the main psmc analysis on 100 randomly sampled sequences from the of the split psmcfa
# -b: ensures random sampling
# -t: mutation rate of each species; found -t 7 and -r 2 Lozier et al. 2022
# -r: ratio of recombination rate to mutation rate of each species; if unknown default is 1;
# -p to 2+2+25*2+4+6 change to reduce peak 10000 years; -t5 for bombus if humans have -t15 - scaling mutation rate?
for i in $(seq 1 100)
do
  psmc -N25 -t15 -r5 -p "2+2+25*2+4+6" -o ${OUTDIR}/${3}/${3}_${i}.psmc_split.psmc -b ${OUTDIR}/${3}/${3}.split.psmcfa
done

#Merge all 100 bootstrap results in readiness for plotting

cat ${OUTDIR}/${3}/*.psmc > ${OUTDIR}/${3}/${3}_bootstrap.psmc


## comment out the plotting part and run PSMC, then after merging is complete, run the plot part separately
#Plot with psmc_plot.pl
#-p .psmc : output file name
#-g : generation interval in years (depends on your species)
#-u : mutation rate (Can be estimated but usually, mutation rates from close relatives works)
#psmc_plot.pl -R -u 3.6e-09 -g 1 -p ${OUTDIR}/NBP5-51_1_A6/NBP5-51_1_A6_bootstrap_plot ${OUTDIR}/NBP5-51_1_A6/NBP5-51_1_A6_bootstrap.psmc

for dir in ${OUTDIR}/*/;
do
    dirname=$(basename "$dir")
    echo "Creating plot for: ${OUTDIR}/${dirname}/${dirname}_bootstrap.psmc"
    psmc_plot.pl -R -u 3.6e-09 -g 1 -p ${OUTDIR}/${dirname}/${dirname}_bootstrap_plot ${OUTDIR}/${dirname}/${dirname}_bootstrap.psmc
done


# deactivate environment
conda deactivate
