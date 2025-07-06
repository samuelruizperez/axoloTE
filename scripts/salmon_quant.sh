#!/bin/bash

echo ""; echo "Activating mamba environment through shell script..."; echo ""
eval "$(command conda 'shell.bash' 'hook' 2> /dev/null)"
source /home/jgrandvallet/projects/axolotl/software/mambaforge/etc/profile.d/conda.sh
source /home/jgrandvallet/projects/axolotl/software/mambaforge/etc/profile.d/mamba.sh
mamba init bash

mamba activate /home/jgrandvallet/projects/axolotl/software/mambaforge/envs/srp_salmon

SALMON_OUT_DIR=/home/jgrandvallet/projects/axolotl/rnaseq/quantification/salmon/
RAW_DIR=/home/jgrandvallet/projects/axolotl/raw_fastq

# Create new list with sample names 
list_files=$(ls $RAW_DIR | egrep '\.fastq.gz$' | awk '$1 ~ /_R/' | awk -F'_R' '{print $1}' | sort -u)
#printf '%s\n' "${list_files[@]}" | wc -w

cd $SALMON_OUT_DIR/quant

for i in $list_files
do
  echo "Initiating quantification for sample $i"
  read1=$RAW_DIR/$i\_R1.fastq.gz; echo "Read 1: $read1"
  read2=$RAW_DIR/$i\_R2.fastq.gz; echo "Read 2: $read2"
  salmon quant \
    --index $SALMON_OUT_DIR/index/axolotl_index \
    --libType A \
    --gcBias \
    --mates1 $read1 \
    --mates2 $read2 \
    --threads 20 \
    --output $SALMON_OUT_DIR/quant/$i/
done

echo ""; echo "-------------------------------------------------------------------------"
echo "Generating MultiQC report of mapped files..."
echo "-------------------------------------------------------------------------"; echo ""

mkdir -p $SALMON_OUT_DIR/multiqc/

/scratch/home/jgrandvallet/projects/axolotl/software/mambaforge/envs/srp_salmon/bin/multiqc $SALMON_OUT_DIR/quant/ --filename salmon_quant_multiqc --outdir $SALMON_OUT_DIR/multiqc/ --interactive

