#!/bin/bash

# read arguments from command line
SAMPLE_PATH=$1
INDEX_PATH=$2
NTHREADS=$3
RAM_LIMIT=$4
OUTPUT_DIR=$5

SAMPLE_NAME=$(basename $SAMPLE_PATH .fastq.gz)
SAMPLE_1_PATH=$SAMPLE_PATH\_R1.fastq.gz
SAMPLE_2_PATH=$SAMPLE_PATH\_R2.fastq.gz

#------------------------------------------------------#
# Settings suitable for TETranscripts:
# https://github.com/mhammell-laboratory/TEtranscripts/issues/16#issuecomment-364149595)
# https://github.com/nixonlab/DLBCL_HERV_atlas_GDC/issues/1#issuecomment-948028530
#------------------------------------------------------#

echo "[ $(date) ]: $SAMPLE_NAME: Mapping sample to the genome [ STAR ]..."
STAR \
  --genomeLoad LoadAndKeep \
  --limitBAMsortRAM $RAM_LIMIT \
  --genomeDir $INDEX_PATH \
  --runThreadN $NTHREADS \
  --readFilesIn $SAMPLE_1_PATH $SAMPLE_2_PATH \
  --readFilesCommand 'zcat -fc' \
  --outSAMattributes NH HI AS nM NM MD jM jI MC ch \
  --outSAMtype BAM SortedByCoordinate \
  --outSAMunmapped None \
  --outReadsUnmapped Fastxm \
  --outFilterMultimapNmax 200 \
  --winAnchorMultimapNmax 400 \
  --outFilterMismatchNoverLmax 0.04 \
  --outFilterType BySJout \
  --quantMode GeneCounts \
  --outMultimapperOrder Random \
  --outFileNamePrefix $OUTPUT_DIR/$SAMPLE_NAME. \
  > $OUTPUT_DIR/$SAMPLE_NAME.star_align.out.log \
  2> $OUTPUT_DIR/$SAMPLE_NAME.star_align.error.log

echo "[ $(date) ]: $SAMPLE_NAME: Indexing BAM file (.bai) [ sambamba ]..."
sambamba index \
    --nthreads $NTHREADS \
    --show-progress \
    $OUTPUT_DIR/$SAMPLE_NAME.Aligned.sortedByCoord.out.bam \
    2> $OUTPUT_DIR/$SAMPLE_NAME.sambamba_index.error.log

echo "[ $(date) ]: $SAMPLE_NAME: Sorting BAM file by name (natural sort) [ sambamba ]..."
sambamba sort \
    --nthreads $NTHREADS \
    --memory-limit $RAM_LIMIT \
    --natural-sort \
    --show-progress \
    -o $OUTPUT_DIR/$SAMPLE_NAME.nsort.tmp.bam \
    $OUTPUT_DIR/$SAMPLE_NAME.Aligned.sortedByCoord.out.bam \
    > $OUTPUT_DIR/$SAMPLE_NAME.sambamba_nsort.out.log \
    2> $OUTPUT_DIR/$SAMPLE_NAME.sambamba_nsort.error.log

echo "[ $(date) ]: $SAMPLE_NAME: Cleaning BAM header [ samtools reheader ]..."
samtools reheader \
    -c 'grep -v -e ^@CO -e ^@PG' \
    $OUTPUT_DIR/$SAMPLE_NAME.nsort.tmp.bam \
    > $OUTPUT_DIR/$SAMPLE_NAME.nsort.bam \
    2> $OUTPUT_DIR/$SAMPLE_NAME.samtools_reheader.error.log

rm $OUTPUT_DIR/$SAMPLE_NAME.nsort.tmp.bam

# remove logs if empty
for log in $OUTPUT_DIR/$SAMPLE_NAME.*.log; do
  if [ ! -s $log ]; then
    rm $log
  fi
done