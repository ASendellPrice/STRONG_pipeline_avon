# Running STRONG on avon

This repository outlines how to run the metagenome assembler STRONG (Strain Resolution ON Graphs, https://github.com/chrisquince/STRONG) on Warwick's HTC avon. The bulk of the pipeline runs within a singularity image prepared by Warwick's Scientific Computing RTP. Taxonomic classification via gtdbtk is conducted outside of the container. 


## Step 1: Generate input
For each sample STRONG expects a single forward read file, and a single reverse read file. If a sample has been sequenced across multiple Illumina lanes you will need to merge multiple forward files and multiple reverse files. For example, presuming sequencing reads are stored in a directory called raw_data with the structure below:

```
raw_data/
|-- M_P0
|   |-- A16_FDSW210123054-1r_H32W7DSX2_L1_1.fq.gz
|   |-- A16_FDSW210123054-1r_H32W7DSX2_L1_2.fq.gz
|   |-- A16_FDSW210123054-1r_H3535DSX2_L2_1.fq.gz
|   |-- A16_FDSW210123054-1r_H3535DSX2_L2_2.fq.gz
|   `-- MD5.txt
`-- M_P1
    |-- A17_FDSW210123055-1r_H32W7DSX2_L1_1.fq.gz
    |-- A17_FDSW210123055-1r_H32W7DSX2_L1_2.fq.gz
    |-- A17_FDSW210123055-1r_H3535DSX2_L3_1.fq.gz
    |-- A17_FDSW210123055-1r_H3535DSX2_L3_2.fq.gz
    `-- MD5.txt
```
A new directory 'input_data' containing merged reads for each sample can be generated like so:
```
mkdir input_reads
for SAMPLE in M_P0 M_P1
do
    mkdir input_reads/{$SAMPLE}
    files=( raw_reads/${SAMPLE}/*_1.fq.gz )
    if [[ ${#files[@]} -gt 1 ]]
    then
        zcat raw_reads/${SAMPLE}/*_1.fq.gz | gzip > input_reads/{$SAMPLE}${SAMPLE}_R1.fq.gz
        zcat raw_reads/${SAMPLE}/*_2.fq.gz | gzip > input_reads/{$SAMPLE}/${SAMPLE}_R2.fq.gz
    else
        cp raw_reads/${SAMPLE}/*_1.fq.gz input_reads/{$SAMPLE}/${SAMPLE}_R1.fq.gz
        cp raw_reads/${SAMPLE}/*_2.fq.gz input_reads/{$SAMPLE}/${SAMPLE}_R2.fq.gz
    fi
done
```
