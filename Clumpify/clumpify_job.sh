### remove optical duplicates from raw-reads ###
##  https://github.com/BioInfoTools/BBMap/blob/master/sh/clumpify.sh

# submission info
## qsub clumpify_job.sh


# load module
module load java/jdk-11.0.7
mkdir -p $HOME/tmp
export JDK_JAVA_OPTIONS="-Djava.io.tmpdir=$HOME/tmp"
java -XshowSettings:all


# create variables
FILES=file_list_2.txt
echo $FILES
IN="/share/pool/ek/raw.reads/2023.Dresden.Illumina/batch4/"
OUT="/share/pool/ek/project.bumblebee.evolution/bombus_pop_gen_eva/00_test_processing/Clumpify_script_raw_reads"
OUTPUT=$OUT/clumpify_summary.tsv


printf "ID\tReadsIn\tReadsOut\tDuplicatesFound\tDuplicatesFoundPercentage\n" > $OUTPUT


# correct file names
file_list=($(cat $FILES | tr "\n" " "))

for FILE in "${file_list[@]}"
do
echo $FILE


## use clumpify for optical filtering
# in1=${IN}${FILE}.R1.fastq.gz in2=${IN}${FILE}.R2.fastq.gz
/home/ebaumgarten/bbmap/clumpify.sh in1=${IN}${FILE}/${FILE}_MKDL240001942-1A_2253JMLT4_L7_1.fq.gz in2=${IN}${FILE}/${FILE}_MKDL240001942-1A_2253JMLT4_L7_2.fq.gz out1=${OUT}/${FILE}_R1.dedupe.fastq.gz out2=${OUT}/${FILE}_R2.dedupe.fastq.gz dedupe optical dupedist=12000 -Xmx50g passes=1 subs=1 k=31 spantiles=f 2> >(tee ${OUT}/${FILE}.optical_duplicates.log >&1)


## print table with summary of removed duplicates
#INPUT=$IN$FILE.optical_duplicates.log
INPUT=$OUT/$FILE.optical_duplicates.log
RIN=$(grep "Reads In" $INPUT | tr -s " " | cut -f3 -d" ")
ROU=$(grep "Reads Out" $INPUT | tr -s " " | cut -f3 -d" ")
DUP=$(grep "Duplicates Found" $INPUT | tr -s "\t" " " | cut -f3 -d" ")
DUPPER=$(grep "Duplicates Found" $INPUT | tr -s "\t%" " " | cut -f4 -d" ")

echo $FILE
echo $RIN
echo $ROU
echo $DUP
echo $DUPPER
printf "$FILE\t$RIN\t$ROU\t$DUP\t$DUPPER\n" >> $OUTPUT


done
