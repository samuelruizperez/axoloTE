#!/bin/bash

# read arguments from command line
SAMPLE_PATH=$1
GENE_INDEX=$2
TE_INDEX=$3
STRAND=$4
MODE=$5
OUTPUT_DIR=$6

SAMPLE_NAME=$(basename $SAMPLE_PATH .nsort.bam)

echo "[ $(date) ]: $SAMPLE_NAME: Quantifying TE subfamily expression [ TEcount ]..."
TEcount \
  --BAM $SAMPLE_PATH \
  --GTF $GENE_INDEX \
  --TE $TE_INDEX \
  --stranded $STRAND \
  --mode $MODE \
  --project $SAMPLE_NAME \
  --outdir $OUTPUT_DIR \
  --verbose 3 \
  > $OUTPUT_DIR/$SAMPLE_NAME.tecount.log 2>&1

# remove logs if empty
for log in $OUTPUT_DIR/$SAMPLE_NAME.*.log; do
  if [ ! -s $log ]; then
    rm $log
  fi
done