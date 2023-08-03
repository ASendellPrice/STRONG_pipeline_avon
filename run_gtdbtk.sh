#!/bin/bash
#SBATCH --nodes=1
#SBATCH --cpus-per-task=10

# Load mamba module, initiate shell, and load environment
module load Mamba/4.14.0-0
conda activate gtdbtk-2.3.0

# Create input directory and copy fastas
mkdir gtdbtk
mkdir gtdbtk/input
cp desman/Bin_*/*.fasta gtdbtk/input

# Run gtdbtk
gtdbtk classify_wf --cpus 10 --genome_dir gtdbtk/input --extension fasta \
--out_dir gtdbtk --skip_ani_screen 
