#!/bin/bash
#SBATCH --nodes=1
#SBATCH --cpus-per-task=48
#SBATCH --mem-per-cpu=31418
#SBATCH --time=48:00:00
#SBATCH --partition=hmem

# this value should be less or equal to --cpus-per-task 
# larger --cpus-per-task, the more memory is allocated (useful).
# however, many threads can cause slow downs, so less threads sometimes is desireble
export OMP_NUM_THREADS=48

# specify the container to launch
container=/home/shared/STRONG/containers/STRONG-b25b173.sif 

# Set output directory
outputdir=$(pwd)

# run the container 
singularity run ${container} "/STRONG/bin/STRONG ${outputdir} --threads 48"
