# albopictus_pop_gen
Repository with analysis pipeline of Ae. albopictus ddRAD sequencing data

001_demultiplexing.sh: Paired-end ddRADseq reads are demultiplexed using ‘process_radtags’ from Stacks. Reads with mapping quality < Q10 are discarded (-q).

002_fastqc_demu.sh and 003_multiqc_demu.sh: Run ‘FastQC’ quality control on demultiplexed FASTQ files and  create a summary report with all FastQC reports using ‘MultiQC’.

004_alignment.sh: Align paired-end ddRADseq reads to the *Aedes albopictus* reference genome using ‘bwa-mem’, allowing up to 3 mismatches (‘NM:<4’)

