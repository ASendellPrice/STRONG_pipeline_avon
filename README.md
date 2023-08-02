# Running STRONG on avon

This repository outlines how to run the metagenome assembler STRONG (Strain Resolution ON Graphs, https://github.com/chrisquince/STRONG) on Warwick's HTC avon. The bulk of the pipeline runs within a singularity image prepared by Warwick's Scientific Computing RTP. Taxonomic classification via gtdbtk is conducted outside of the container using a conda environment. 


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
A new directory 'input_reads' containing merged reads for each sample can be generated like so:
```
mkdir input_reads
for SAMPLE in M_P0 M_P1
do
    mkdir input_reads/${SAMPLE}
    files=( raw_data/${SAMPLE}/*_1.fq.gz )
    if [[ ${#files[@]} -gt 1 ]]
    then
        zcat raw_data/${SAMPLE}/*_1.fq.gz | gzip > input_reads/${SAMPLE}/${SAMPLE}_R1.fq.gz
        #zcat raw_data/${SAMPLE}/*_2.fq.gz | gzip > input_reads/${SAMPLE}/${SAMPLE}_R2.fq.gz
    else
        cp raw_data/${SAMPLE}/*_1.fq.gz input_reads/{$SAMPLE}/${SAMPLE}_R1.fq.gz
        cp raw_data/${SAMPLE}/*_2.fq.gz input_reads/{$SAMPLE}/${SAMPLE}_R2.fq.gz
    fi
done
```

This 'input_reads' directory will have the following structure:
```
input_reads/
|-- M_P0
|   |-- M_P0_R1.fq.gz
|   `-- M_P0_R2.fq.gz
`-- M_P1
    |-- M_P1_R1.fq.gz
    `-- M_P1_R2.fq.gz
```


## Step 2: Running STRONG
Now that input files have been created, we can now run STRONG. To run the programme the following are needed:
1. A local copy of the cog database, which can be downloaded like so:
```
wget https://microbial-metag-strong.s3.climb.ac.uk/rpsblast_cog_db.tar.gz
tar -xvzf rpsblast_cog_db.tar.gz
rm rpsblast_cog_db.tar.gz
```
2. config.yaml file defining the run settings. This will need to be updated according to the specifications of your desired run. See example below:
```
# ------ Samples ------
samples: ['M_P0','M_P1'] # specify a list samples to use or '*' to use all samples

# ------ Resources ------
threads : 20 # single task nb threads

# ------ Assembly parameters ------ 
data: /path/to/input_reads # path to data folder

# ----- Annotation database -----
cog_database: /path/to/rpsblast_cog_db/Cog  # COG database

# ----- Binner ------
binner: "concoct"

# ----- Binning parameters ------
concoct:
    contig_size: 1000

read_length: 150
assembly: 
    assembler: spades
    k: [77]
    mem: 2000
    threads: 24

# ----- BayesPaths parameters ------
bayespaths:
    nb_strains: 5
    nmf_runs: 1
    max_giter: 1
    min_orf_number_to_merge_bins: 18
    min_orf_number_to_run_a_bin: 10
    percent_unitigs_shared: 0.1

# ----- DESMAN parameters ------
desman:
    execution: 1
    nb_haplotypes: 10
    nb_repeat: 5
    min_cov: 1
```

4. Submission script 'run_STRONG.sh' included in this github repository.
 


```
# Create directory for STRONG run and move into it:
mkdir run1; cd run1
```

