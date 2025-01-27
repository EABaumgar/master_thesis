module load fastp/0.20.0


#module load anaconda3/2023.03
#conda activate fastp_env

FILES="/share/pool/ek/project.bumblebee.evolution/bombus_pop_gen_eva/00_test_processing/Clumpify_script_raw_reads/file_list_2.txt"
DIR="/share/pool/ek/project.bumblebee.evolution/bombus_pop_gen_eva/02_filtered_reads/resequenced_samples_merged/"
OUT="/share/pool/ek/project.bumblebee.evolution/bombus_pop_gen_eva/02_filtered_reads/resequenced_samples_merged_filtered_adapters_cut/"
LENGTH=100

mkdir -p ${OUT}

# set file names
file_list=($(cat $FILES | tr "\n" " "))
#e.g. NBP1-10_3_C10

for FILE in "${file_list[@]}"
do
echo $FILE

#quality filtering
#fastp --in1 ${DIR}${FILE}_combined_R1.dedupe.fastq.gz --in2 ${DIR}${FILE}_combined_R2.dedupe.fastq.gz --out1 ${OUT}${FILE}_combined_R1.dedupe.filtered.fastq.gz --out2 ${OUT}${FILE}_combined_R2.dedupe.filtered.fastq.gz --thread $NSLOTS --json ${OUT}${FILE}_combined.fastp.json --html ${OUT}${FILE}_combined.fastp.html --detect_adapter_for_pe --trim_poly_x -l ${LENGTH} --cut_front --cut_tail -W 4 -M 25
# trying with exact adapters to see if it works better
fastp --in1 ${DIR}${FILE}_combined_R1.dedupe.fastq.gz --in2 ${DIR}${FILE}_combined_R2.dedupe.fastq.gz --out1 ${OUT}${FILE}_combined_R1.dedupe.filtered.fastq.gz --out2 ${OUT}${FILE}_combined_R2.dedupe.filtered.fastq.gz --thread $NSLOTS --json ${OUT}${FILE}_combined.fastp.json --html ${OUT}${FILE}_combined.fastp.html --adapter_sequence AGATCGGAAGAGCACACGTCTGAACTCCAGTCA --adapter_sequence_r2 AGATCGGAAGAGCGTCGTGTAGGGAAAGAGTGT --trim_poly_x -l ${LENGTH} --cut_front --cut_tail -W 4 -M 25

done


#conda deactivate
