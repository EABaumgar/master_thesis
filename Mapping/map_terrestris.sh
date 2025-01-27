# load needed modules
module load bwa-mem2/2.2.1
module load samtools/1.10


# stop if errors occur in between
set -uex 

## set input directory
INDIR=/share/pool/ek/project.bumblebee.evolution/bombus_pop_gen_eva/02_filtered_reads/resequenced_samples_merged_filtered


## set output directory
OUTDIR=/share/pool/ek/project.bumblebee.evolution/bombus_pop_gen_eva/03_mapping


## set reference & index reference-fasta (.fna)
REF=/share/pool/ek/project.bumblebee.evolution/bombus_pop_gen_eva/03_mapping/00_reference_genomes/Bombus_terrestris_ncbi/GCF_910591885.1_iyBomTerr1.2_genomic.fna
#bwa-mem2 index $REF


## set sample IDs in file as 1st parameter
FILE=/share/pool/ek/project.bumblebee.evolution/bombus_pop_gen_eva/00_test_processing/Clumpify_script_raw_reads/file_list.txt
file_list=($(cat $FILE | tr "\n" " "))
# e.g. NBP1-10_3_C10

for ID in "${file_list[@]}"
do


## define fw/rev input files
FWD=$INDIR/${ID}_combined_R1.dedupe.filtered.fastq.gz
REV=$INDIR/${ID}_combined_R2.dedupe.filtered.fastq.gz


## create output folder
mkdir $OUTDIR/${ID}_combined


## do mapping and directly sort the file to convert it into bam format
#bwa2 mem -t $NSLOTS -P $REF $FWD $REV | samtools fixmate -m --threads $NSLOTS - - | samtools sort -l 8 -m 1024M -@ $NSLOTS -T $HOME/tmp/ - | samtools view --threads $NSLOTS --reference $REF -F 0x4 -u - | samtools markdup -S -s --reference $REF -@ $NSLOTS --write-index -f $OUTDIR/$ID/${ID}.markdup_stats - $OUTDIR/$ID/${ID}.bam
bwa2 mem -t $NSLOTS $REF $FWD $REV | samtools view --threads $NSLOTS --reference $REF -b -u - | samtools fixmate -m --threads $NSLOTS - - | samtools sort -l 5 -m 1024M -@ $NSLOTS -T $HOME/tmp/ - | samtools markdup -S -s --reference $REF -@ $NSLOTS --write-index -f $OUTDIR/${ID}_combined/${ID}.markdup_stats - $OUTDIR/${ID}_combined/${ID}.bam


## Index the bam-file
BAM=$OUTDIR/${ID}_combined/${ID}.bam
samtools index -@ $NSLOTS $BAM


## create stats
OUTSTATS=/share/pool/ek/project.bumblebee.evolution/bombus_pop_gen_eva/03_mapping
samtools flagstat -@ $NSLOTS $BAM > ${OUTSTATS}/${ID}_combined.flagstat
samtools flagstat -@ $NSLOTS -O tsv $BAM > ${OUTSTATS}/${ID}_combined.flagstat.tsv

done
