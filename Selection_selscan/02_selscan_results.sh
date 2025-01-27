## convert selscan results and create list of gene IDs with |nSL| >=2

# create variables
DIR="/share/pool/ek/project.bumblebee.evolution/bombus_pop_gen_eva/11_selection/${1}_nSL"


## add chromosomes name to each selscan output file
chrs_list=($(cat chromosome_list.txt | tr "\n" " "))

for CHR in "${chrs_list[@]}"
do
sed s/^\./$CHR/g $DIR/$CHR.biallelic.excl_missing_sites.nsl.out.100bins.norm > $DIR/$CHR.biallelic.excl_missing_sites.nsl.out.100bins.norm.chr
done


## combine output files per chromosome into one file
cat $DIR/*.norm.chr > $DIR/${1}_chrs18.biallelic.excl_missing_sites.nsl.out.100bins.norm
IN=$DIR/${1}_chrs18.biallelic.excl_missing_sites.nsl.out.100bins.norm


## extract SNPs with standardized nSL of >2 or <-2
## return bed: CHR BP BP nSL(name/info)
BED=$DIR/${1}_chrs18.biallelic.excl_missing_sites.nsl.out.100bins.norm.cutoff_2.bed
awk '$7>=2 || $7<=-2 {print $1,$2,$2,$7}' $IN | tr " " "\t" > $BED


## search bed in gff
GFF=/share/pool/ek/project.bumblebee.evolution/bombus_pop_gen/02_mapping/00_reference/bombus_terrestris/GCF_910591885.1_iyBomTerr1.2_genomic.gff.gz
OUT=$DIR/${1}_chrs18.biallelic.excl_missing_sites.nsl.out.100bins.norm.cutoff_2.genes

bedtools intersect -a $BED -b $GFF -wb > $OUT
cut -f5-13 $OUT > $OUT.gff


## create directory for genes of interest
mkdir -p $DIR/genes_of_interest


## extract gene IDs (e.g. LOC...) from gff
awk '$3=="gene" {print $9}' $OUT.gff | cut -f3 -d";" | cut -f2 -d"=" | sort | uniq > $DIR/genes_of_interest/${1}_chrs18.biallelic.excl_missing_sites.nsl.out.100bins.norm.cutoff_2.gene_ids
