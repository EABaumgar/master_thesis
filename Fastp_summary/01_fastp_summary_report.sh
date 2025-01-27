# length of reference genome
# terrestris
REFLENGTH=392962041


# set variables
INDIR="/share/pool/ek/project.bumblebee.evolution/bombus_pop_gen_eva/02_filtered_reads"
OUTPUT="/share/pool/ek/project.bumblebee.evolution/bombus_pop_gen_eva/02_filtered_reads/summary_fastp_results"
mkdir -p ${OUTPUT}
OUTPUT="/share/pool/ek/project.bumblebee.evolution/bombus_pop_gen_eva/02_filtered_reads/summary_fastp_results/Resequenced_samples.tsv"


# create output-file with header line
printf "SampleID\tState\tReadlength\tReads\tBases\tExpectedCoverage\n" > $OUTPUT


## loop over all fastp-reports
FILES="/share/pool/ek/project.bumblebee.evolution/bombus_pop_gen_eva/00_test_processing/Clumpify_script_raw_reads/file_list_2.txt"
file_list=($(cat $FILES | tr "\n" " "))
for filename in "${file_list[@]}"
do


Report=${INDIR}/${filename}.fastp.json

# extract mean read-length before and after filtering from fastp-report
Read_length_preF=$(cat $Report | grep read1_mean_length | head -1 | tr -d , | cut -f 2 -d ':')
Read_length_postF=$(cat $Report | grep read1_mean_length | head -2 | tail -1 | tr -d , | cut -f 2 -d ':')


# extract number of reads and bases before and after filtering from fastp-report
Reads_preF=$(cat $Report | grep total_reads | head -1 | tr -d , | cut -f 2 -d ':')
Reads_postF=$(cat $Report | grep total_reads | head -2 | tail -1 | tr -d , | cut -f 2 -d ':')
Bases_preF=$(cat $Report | grep total_bases | head -1 | tr -d , | cut -f 2 -d ':')
Bases_postF=$(cat $Report | grep total_bases | head -2 | tail -1 | tr -d , | cut -f 2 -d ':')


# calculate expected coverage before and after filtering by by dividing number of bases through length of reference genome
Cov_preF=$(($Bases_preF/$REFLENGTH))
Cov_postF=$(($Bases_postF/$REFLENGTH))


# write line for data before filtering to output-file
printf "%s\tpre_F\t%s\t%s\t%s\t%s\n" $filename $Read_length_preF $Reads_preF $Bases_preF $Cov_preF >> $OUTPUT


# write line for data after filtering to output-file
printf "%s\tpost_F\t%s\t%s\t%s\t%s\n" $filename $Read_length_postF $Reads_postF $Bases_postF $Cov_postF >> $OUTPUT


done
