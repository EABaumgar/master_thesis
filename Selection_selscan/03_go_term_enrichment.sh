#!/bin/bash

## ./go_term_enrichment.sh SUBSPECIES
## for this download R-script "go_term_conversion.R" from:
## from: "https://github.com/LIB-insect-comparative-genomics/RNAseq-workshop2023/blob/main/RNAseq/05.GO/go_enrichment_analysis_fisher.R"

DIR=/path/to/working_directory

## get gene IDs (e.g. LOC...) from gff
mkdir genes_of_interest

## transfer gene_ids-file from cluster to server and copy it in "genes_of_interest"-folder
cp $1_chrs18.biallelic.excl_missing_sites.nsl.out.100bins.norm.cutoff_2.gene_ids genes_of_interest/$1.gene_ids

## creat database with GO-terms for B. terrestris
## wget "https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/910/591/885/GCF_910591885.1_iyBomTerr1.2/GCF_910591885.1_iyBomTerr1.2_gene_ontology.gaf.gz"
## file from: https://github.com/LIB-insect-comparative-genomics/RNAseq-workshop2023/blob/main/RNAseq/05.GO/go_term_conversion.R

#GAF=GCF_910591885.1_iyBomTerr1.2_gene_ontology.gaf.gz
#zcat $GAF | grep -v "^!" | cut -f3,5 > bombus_terrestris.ncbi.gene-ontologies.tsv
#Rscript go_term_conversion.R bombus_terrestris.ncbi.gene-ontologies.tsv bombus_terrestris.ncbi.gene-ontologies.db.txt
#cat bombus_terrestris.ncbi.gene-ontologies.db.txt | sed "s/ /\t/g" > bombus_terrestris.GOterms.tsv
DB=/scratch/nbrenner/04_GO_terms/Bombus_terrestris.GOterms.tsv

## run GO-term enrichment
GOTERMS="$DB"

ANALYSIS="$1" #subspecies
INDIR="$DIR"
GENEUNIVERSEgoTERMS="$GOTERMS"
TESTGENESET="$1.gene_ids"
TESTGENESETDIR="genes_of_interest"
OUTDIR="results.topGO.$ANALYSIS"
mkdir -p $OUTDIR

cat go_enrichment_analysis_fisher.R | sed "s,XXXXXX,$INDIR,g ; s,YYYYYY,$GENEUNIVERSEgoTERMS,g ; s,ZZZZZZ,$TESTGENESET,g ; s,FFFFFF,$TESTGENESETDIR,g ; s,OOOOOO,$OUTDIR,g" > go_enrichment_analysis_fisher.$ANALYSIS.R

Rscript go_enrichment_analysis_fisher.$ANALYSIS.R
