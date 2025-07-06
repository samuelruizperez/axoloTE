#!/bin/bash

fam=$1

echo "extracting loci of interest for ${fam}"
awk -v rep=${fam} '$4 == rep' /home/jgrandvallet/sruizperez/projects/axolotl/ext_data/axolotl_genome/AmexG_v6.0-DD_Repeats/ambMex60DD_ucsc_hub.ALL.mod.bed > /home/jgrandvallet/sruizperez/projects/axolotl/rnaseq/DEA_consensus/DEREsxDEGs/tmp/${fam}.bed
