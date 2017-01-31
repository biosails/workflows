#!/bin/bash
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=72
#SBATCH --time=96:00:00
#SBATCH --mem 1700G

#Load gencore modules
module load gencore/1
module load gencore_de_novo_genomic/1.0
module load gencore_rnaseq

#Export Trinity PATH
export PATH=/scratch/gencore/software/trinity/2.2.0/bin:/scratch/gencore/software/resequencing/bin:$PATH

#Export RSEM path
export PATH=/scratch/gencore/software/rsem/1.2.29/bin:$PATH

#Run Trinity assembly
Trinity --bypass_java_version_check \
--seqType fq \
--max_memory 1700G \
--CPU 72 \
--left \
../data/NCS-49-RNA-15_83/Sample_RNA-B1_read1_trimmomatic_1PE.fastq.gz,\
../data/NCS-49-RNA-15_83/Sample_RNA-B2_read1_trimmomatic_1PE.fastq.gz,\
../data/NCS-49-RNA-15_83/Sample_RNA-B3_read1_trimmomatic_1PE.fastq.gz,\
../data/NCS-49-RNA-15_83/Sample_RNA-B4_read1_trimmomatic_1PE.fastq.gz,\
../data/NCS-49-RNA-15_83/Sample_RNA-B6_read1_trimmomatic_1PE.fastq.gz \
--right \
../data/NCS-49-RNA-15_83/Sample_RNA-B1_read2_trimmomatic_2PE.fastq.gz,\
../data/NCS-49-RNA-15_83/Sample_RNA-B2_read2_trimmomatic_2PE.fastq.gz,\
../data/NCS-49-RNA-15_83/Sample_RNA-B3_read2_trimmomatic_2PE.fastq.gz,\
../data/NCS-49-RNA-15_83/Sample_RNA-B4_read2_trimmomatic_2PE.fastq.gz,\
../data/NCS-49-RNA-15_83/Sample_RNA-B6_read2_trimmomatic_2PE.fastq.gz \
--single \
../data/NCS-49-RNA-15_83/Sample_RNA-B1_read1_trimmomatic_1SE.fastq.gz,\
../data/NCS-49-RNA-15_83/Sample_RNA-B1_read2_trimmomatic_2SE.fastq.gz,\
../data/NCS-49-RNA-15_83/Sample_RNA-B2_read1_trimmomatic_1SE.fastq.gz,\
../data/NCS-49-RNA-15_83/Sample_RNA-B2_read2_trimmomatic_2SE.fastq.gz,\
../data/NCS-49-RNA-15_83/Sample_RNA-B3_read1_trimmomatic_1SE.fastq.gz,\
../data/NCS-49-RNA-15_83/Sample_RNA-B3_read2_trimmomatic_2SE.fastq.gz,\
../data/NCS-49-RNA-15_83/Sample_RNA-B4_read1_trimmomatic_1SE.fastq.gz,\
../data/NCS-49-RNA-15_83/Sample_RNA-B4_read2_trimmomatic_2SE.fastq.gz,\
../data/NCS-49-RNA-15_83/Sample_RNA-B6_read1_trimmomatic_1SE.fastq.gz,\
../data/NCS-49-RNA-15_83/Sample_RNA-B6_read2_trimmomatic_2SE.fastq.gz
--output Trinity_frog

#Gather assembly stats
/scratch/gencore/software/trinity/2.2.0/share/trinity-2.2.0/util/TrinityStats.pl \
Trinity_frog/Trinity.fasta > Trinity_frog/TrinityStats-frog-15-83.txt

#Change into assembly output directory
cd Trinity_frog

#Build a Bowtie2 small index of the assembly (PLEASE NOTE: No need if using the --prep-reference parameter of RSEM below)
bowtie2-build-s Trinity.fasta Trinity

#Estimate transcript level abundances using RSEM B1
align_and_estimate_abundance.pl \
--thread_count 72 \
--seqType fq \
--left ../data/NCS-49-RNA-15_83/Sample_RNA-B1_read1_trimmomatic_1PE.fastq.gz \
--right ../data/NCS-49-RNA-15_83/Sample_RNA-B1_read2_trimmomatic_2PE.fastq.gz \
--single \
../data/NCS-49-RNA-15_83/Sample_RNA-B1_read1_trimmomatic_1SE.fastq.gz,\
../data/NCS-49-RNA-15_83/Sample_RNA-B1_read2_trimmomatic_2SE.fastq.gz \
--transcripts Trinity.fasta --output_prefix frog-15-83-B1 \
--est_method RSEM --aln_method bowtie2 \
--trinity_mode --output_dir RSEM-B1

#Estimate transcript level abundances using RSEM B2
align_and_estimate_abundance.pl --thread_count 72 --seqType fq --left ../data/NCS-49-RNA-15_83/Sample_RNA-B2_read1_trimmomatic_1PE.fastq.gz --right ../data/NCS-49-RNA-15_83/Sample_RNA-B2_read2_trimmomatic_2PE.fastq.gz --single ../
data/NCS-49-RNA-15_83/Sample_RNA-B2_read1_trimmomatic_1SE.fastq.gz,../data/NCS-49-RNA-15_83/Sample_RNA-B2_read2_trimmomatic_2SE.fastq.gz --transcripts Trinity.fasta --output_prefix frog-15-83-B2 --est_method RSEM --aln_method bowt
ie2 --trinity_mode --output_dir RSEM-B2

#Estimate transcript level abundances using RSEM B3
align_and_estimate_abundance.pl --thread_count 72 --seqType fq --left ../data/NCS-49-RNA-15_83/Sample_RNA-B3_read1_trimmomatic_1PE.fastq.gz --right ../data/NCS-49-RNA-15_83/Sample_RNA-B3_read2_trimmomatic_2PE.fastq.gz --single ../
data/NCS-49-RNA-15_83/Sample_RNA-B3_read1_trimmomatic_1SE.fastq.gz,../data/NCS-49-RNA-15_83/Sample_RNA-B3_read2_trimmomatic_2SE.fastq.gz --transcripts Trinity.fasta --output_prefix frog-15-83-B3 --est_method RSEM --aln_method bowt
ie2 --trinity_mode --output_dir RSEM-B3

#Estimate transcript level abundances using RSEM B4
align_and_estimate_abundance.pl --thread_count 72 --seqType fq --left ../data/NCS-49-RNA-15_83/Sample_RNA-B4_read1_trimmomatic_1PE.fastq.gz --right ../data/NCS-49-RNA-15_83/Sample_RNA-B4_read2_trimmomatic_2PE.fastq.gz --single ../
data/NCS-49-RNA-15_83/Sample_RNA-B4_read1_trimmomatic_1SE.fastq.gz,../data/NCS-49-RNA-15_83/Sample_RNA-B4_read2_trimmomatic_2SE.fastq.gz --transcripts Trinity.fasta --output_prefix frog-15-83-B4 --est_method RSEM --aln_method bowt
ie2 --trinity_mode --output_dir RSEM-B4

#Estimate transcript level abundances using RSEM B6
align_and_estimate_abundance.pl --thread_count 72 --seqType fq --left ../data/NCS-49-RNA-15_83/Sample_RNA-B6_read1_trimmomatic_1PE.fastq.gz --right ../data/NCS-49-RNA-15_83/Sample_RNA-B6_read2_trimmomatic_2PE.fastq.gz --single ../
data/NCS-49-RNA-15_83/Sample_RNA-B5_read1_trimmomatic_1SE.fastq.gz,../data/NCS-49-RNA-15_83/Sample_RNA-B6_read2_trimmomatic_2SE.fastq.gz --transcripts Trinity.fasta --output_prefix frog-15-83-B6 --est_method RSEM --aln_method bowt
ie2 --trinity_mode --output_dir RSEM-B6
