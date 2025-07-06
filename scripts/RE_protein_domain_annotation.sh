#!/bin/bash

# read arguments from command line
RE_SUBFAMILY=$1
GENOME_FASTA=$2
BED_FILE=$3
NTHREADS=$4
OUTPUT_DIR=$5
TEMP_DIR=$6

echo "[ $(date) ]: $RE_SUBFAMILY: Extracting loci from BED file [ AWK ]..."
awk -v RE_SUBFAMILY=$RE_SUBFAMILY 'BEGIN{FS = "\t";OFS="\t"} $4 == RE_SUBFAMILY {print $1,$2,$3,$10,0,$6}' $BED_FILE > $OUTPUT_DIR/${RE_SUBFAMILY}.bed
awk 'BEGIN{FS = "\t";OFS="\t"} {split($4, a, "\""); print $1,$2,$3,a[4]":"a[2]":"a[6]":"a[8],$5,$6}' $OUTPUT_DIR/${RE_SUBFAMILY}.bed > $OUTPUT_DIR/${RE_SUBFAMILY}.tmp && mv ${RE_SUBFAMILY}.tmp $OUTPUT_DIR/${RE_SUBFAMILY}.bed

echo "[ $(date) ]: $RE_SUBFAMILY: Extracting nucleotide sequences from the genome FASTA [ bedtools getfasta ]..."
bedtools getfasta \
    -name \
    -fi $GENOME_FASTA \
    -bed $OUTPUT_DIR/${RE_SUBFAMILY}.bed \
    | fold -w 140 > $OUTPUT_DIR/${RE_SUBFAMILY}.fa

echo "[ $(date) ]: $RE_SUBFAMILY: Multiple sequence alignment of nucleotide sequences [ MAFFT ]..."
mafft \
    --reorder \
    --thread $NTHREADS \
    $OUTPUT_DIR/${RE_SUBFAMILY}.fa \
    > $OUTPUT_DIR/${RE_SUBFAMILY}.mafft.fa \
    2> $OUTPUT_DIR/${RE_SUBFAMILY}.mafft.log

echo "[ $(date) ]: $RE_SUBFAMILY: Removing gaps 80% gaps from the multiple sequence alignment [ T-COFFEE ]..."
t_coffee \
    -other_pg seq_reformat \
    -in $OUTPUT_DIR/${RE_SUBFAMILY}.mafft.fa \
    -action +rm_gap 80 \
    > $OUTPUT_DIR/${RE_SUBFAMILY}.t_coffee.fa \
    2> $OUTPUT_DIR/${RE_SUBFAMILY}.t_coffee.log

echo "[ $(date) ]: $RE_SUBFAMILY: Generating consensus sequence [ EMBOSS cons ]..."
cons \
    -sequence $OUTPUT_DIR/${RE_SUBFAMILY}.t_coffee.fa \
    -plurality 1 \
    -n ${RE_SUBFAMILY} \
    -outseq $OUTPUT_DIR/${RE_SUBFAMILY}.cons.fa \
    2> $OUTPUT_DIR/${RE_SUBFAMILY}.cons.log

# remove any empty .log
find $OUTPUT_DIR -name "*.log" -size 0 -delete