#!/bin/bash

#
# Generated at: 2016-11-16T14:09:32
# This file was generated with the following options
#	--workflow	conf/fastqc.yml
#

#
# Samples: Sample_5
#
#
# Starting Workflow
#
#
# Global Variables:
#	resample: 0
#	wait: 0
#	auto_input: 1
#	coerce_paths: 1
#	auto_name: 1
#	indir: data/raw
#	outdir: data/processed
#	min: 0
#	override_process: 0
#	rule_based: 1
#	verbose: 1
#	create_outdir: 1
#	file_rule: (Sample.*)$
#	by_sample_outdir: 1
#	find_by_dir: 1
#	trimmomatic_dir: data/processed/{$sample}/trimmomatic
#	trimmomatic: data/processed/{$sample}/trimmomatic
#	raw_fastqc_dir: data/processed/{$sample}
#	raw_fastqc: data/processed/{$sample}
#	analysis_dir: data/processed/analysis
#	READ1: {$self->raw_fastqc_dir}/{$sample}_read1.fastq.gz
#	READ2: {$self->raw_fastqc_dir}/{$sample}_read2.fastq.gz
#	TR1: {$self->trimmomatic_dir}/{$sample}_read1_trimmomatic
#	TR2: {$self->trimmomatic_dir}/{$sample}_read2_trimmomatic
#

#
#

# Starting raw_fastqc
#



#
# Variables 
# Indir: /scratch/gencore/templates_git/data/raw
# Outdir: /scratch/gencore/templates_git/data/processed/raw_fastqc
# Local Variables:
#	CAT1: {$self->indir}/*_R1*.fastq.gz
#	CAT2: {$self->indir}/*_R1*.fastq.gz
#	before_meta: HPC Directives

#
#HPC jobname=raw_fastqc
#HPC module=gencore/1 gencore_dev gencore_qc
#HPC ntasks=1
#HPC procs=1
#HPC commands_per_node=1
#HPC mem=12GB
#HPC walltime=01:00:00
#HPC cpus_per_task=3
#HPC partition=serial

#	outdir: /scratch/gencore/templates_git/data/processed/raw_fastqc
#	indir: /scratch/gencore/templates_git/data/raw
#

#TASK tags=Sample_5_R1
mkdir -p /scratch/gencore/templates_git/data/processed/Sample_5/raw_fastqc/Sample_5_R1_FASTQC && \
    cat /scratch/gencore/templates_git/data/raw/Sample_5/*_R1*.fastq.gz >  /scratch/gencore/templates_git/data/processed/Sample_5/Sample_5_read1.fastq.gz && \
    fastqc --extract \
    /scratch/gencore/templates_git/data/processed/Sample_5/Sample_5_read1.fastq.gz \
    -o /scratch/gencore/templates_git/data/processed/Sample_5/raw_fastqc/Sample_5_R1_FASTQC/ -t 3

#TASK tags=Sample_5_R2
mkdir -p /scratch/gencore/templates_git/data/processed/Sample_5/raw_fastqc/Sample_5_R2_FASTQC && \
    cat /scratch/gencore/templates_git/data/raw/Sample_5/*_R1*.fastq.gz >  /scratch/gencore/templates_git/data/processed/Sample_5/Sample_5_read2.fastq.gz && \
    fastqc --extract \
    /scratch/gencore/templates_git/data/processed/Sample_5/Sample_5_read2.fastq.gz \
    -o /scratch/gencore/templates_git/data/processed/Sample_5/raw_fastqc/Sample_5_R2_FASTQC/ -t 3



#
# Ending raw_fastqc
#


#
#

# Starting trimmomatic
#



#
# Variables 
# Indir: /scratch/gencore/templates_git/data/processed/raw_fastqc
# Outdir: /scratch/gencore/templates_git/data/processed/trimmomatic
# Local Variables:
#	before_meta: HPC Directives

#
#HPC jobname=trimmomatic
#HPC module=gencore/1 gencore_dev gencore_qc
#HPC mem=12GB
#HPC walltime=02:00:00
#HPC cpus_per_task=12
#HPC ntasks=1
#HPC procs=1
#HPC commands_per_node=1
#HPC partition=serial
#

#	outdir: /scratch/gencore/templates_git/data/processed/trimmomatic
#	indir: /scratch/gencore/templates_git/data/processed/raw_fastqc
#

#TASK tags=Sample_5
trimmomatic \
   PE -threads 12 \
   -trimlog /scratch/gencore/templates_git/data/processed/Sample_5/trimmomatic/Sample_5_trimmomatic.log \
   /scratch/gencore/templates_git/data/processed/Sample_5/Sample_5_read1.fastq.gz \
   /scratch/gencore/templates_git/data/processed/Sample_5/Sample_5_read2.fastq.gz \
   /scratch/gencore/templates_git/data/processed/Sample_5/trimmomatic/Sample_5_read1_trimmomatic_1PE \
   /scratch/gencore/templates_git/data/processed/Sample_5/trimmomatic/Sample_5_read1_trimmomatic_1SE \
   /scratch/gencore/templates_git/data/processed/Sample_5/trimmomatic/Sample_5_read2_trimmomatic_2PE \
   /scratch/gencore/templates_git/data/processed/Sample_5/trimmomatic/Sample_5_read2_trimmomatic_2SE \
   ILLUMINACLIP:/scratch/nd48/Tools/bin/trimmomatic_adapter.fa:2:30:10 TRAILING:3 LEADING:3 SLIDINGWINDOW:4:15 MINLEN:36



#
# Ending trimmomatic
#


#
#

# Starting trimmomatic_fastqc
#



#
# Variables 
# Indir: /scratch/gencore/templates_git/data/processed/trimmomatic
# Outdir: /scratch/gencore/templates_git/data/processed/trimmomatic_fastqc
# Local Variables:
#	OUTPUT: {$self->outdir}/{$sample}
#	before_meta: HPC Directives

#
#HPC jobname=trimmomatic_fastqc
#HPC deps=trimmomatic
#HPC module=gencore/1 gencore_dev gencore_qc
#HPC mem=12GB
#HPC ntasks=1
#HPC procs=1
#HPC commands_per_node=1
#HPC walltime=02:00:00
#HPC cpus_per_task=4
#HPC partition=serial
#

#	outdir: /scratch/gencore/templates_git/data/processed/trimmomatic_fastqc
#	indir: /scratch/gencore/templates_git/data/processed/trimmomatic
#

#TASK tags=Sample_5
mkdir -p /scratch/gencore/templates_git/data/processed/Sample_5/trimmomatic_fastqc/Sample_5_FASTQC_read1_TRIMMED && \
    fastqc --extract \
    /scratch/gencore/templates_git/data/processed/Sample_5/trimmomatic/Sample_5_read1_trimmomatic_1PE \
    -o /scratch/gencore/templates_git/data/processed/Sample_5/trimmomatic_fastqc/Sample_5_FASTQC_read1_TRIMMED/ -t 4

#TASK tags=Sample_5
mkdir -p /scratch/gencore/templates_git/data/processed/Sample_5/trimmomatic_fastqc/Sample_5_FASTQC_read2_TRIMMED && \
      fastqc --extract \
      /scratch/gencore/templates_git/data/processed/Sample_5/trimmomatic/Sample_5_read2_trimmomatic_2PE \
      -o /scratch/gencore/templates_git/data/processed/Sample_5/trimmomatic_fastqc/Sample_5_FASTQC_read2_TRIMMED/ -t 4



#
# Ending trimmomatic_fastqc
#


#
#

# Starting trimmomatic_gzip
#



#
# Variables 
# Indir: /scratch/gencore/templates_git/{$self->trimmomatic}
# Outdir: /scratch/gencore/templates_git/data/processed/trimmomatic_gzip
# Local Variables:
#	indir: {$self->trimmomatic}
#	INPUT: {$self->indir}/{$sample}
#	before_meta: HPC Directives

#
#HPC jobname=trimmomatic_gzip
#HPC deps=trimmomatic
#HPC mem=10GB
#HPC module=gencore/1 gencore_dev gencore_qc
#HPC walltime=00:20:00
#HPC cpus_per_task=1
#HPC commands_per_node=1
#HPC partition=serial
#

#	outdir: /scratch/gencore/templates_git/data/processed/trimmomatic_gzip
#	OUTPUT: {$self->outdir}/{$sample}
#

#TASK tags=Sample_5
gzip -f /scratch/gencore/templates_git/data/processed/Sample_5/trimmomatic/Sample_5_read1_trimmomatic_1PE

#TASK tags=Sample_5
gzip -f /scratch/gencore/templates_git/data/processed/Sample_5/trimmomatic/Sample_5_read2_trimmomatic_2PE



#
# Ending trimmomatic_gzip
#


#
#

# Starting remove_trimmomatic_logs
#



#
# Variables 
# Indir: /scratch/gencore/templates_git/data/processed/trimmomatic_gzip
# Outdir: /scratch/gencore/templates_git/data/processed/remove_trimmomatic_logs
# Local Variables:
#	create_outdir: 0
#	before_meta: HPC Directives

#
#HPC jobname=remove_trimmomatic_logs
#HPC deps=trimmomatic
#HPC module=gencore/1 gencore_dev gencore_qc
#HPC mem=4GB
#HPC walltime=00:20:00
#HPC cpus_per_task=1
#HPC commands_per_node=1
#HPC partition=serial
#

#	outdir: /scratch/gencore/templates_git/data/processed/remove_trimmomatic_logs
#	indir: /scratch/gencore/templates_git/data/processed/trimmomatic_gzip
#	OUTPUT: {$self->outdir}/{$sample}
#	INPUT: {$self->indir}/{$sample}
#

#TASK tags=Sample_5
find /scratch/gencore/templates_git/data/processed/Sample_5/trimmomatic -name "*_trimmomatic.log" -type f -delete



#
# Ending remove_trimmomatic_logs
#

#
# Ending Workflow
#
