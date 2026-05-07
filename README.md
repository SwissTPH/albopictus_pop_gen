# albopictus_pop_gen
Repository with analysis pipeline of Ae. albopictus ddRAD sequencing data

##read_processing
### 001_demultiplexing.sh
Paired-end ddRADseq reads are demultiplexed using `process_radtags` from Stacks. Reads with mapping quality < Q10 are discarded (`-q`).

### 002_fastqc_demu.sh and 003_multiqc_demu.sh
Run `FastQC` quality control on demultiplexed FASTQ files and  create a summary report with all FastQC reports using `MultiQC`.

### 004_alignment.sh
Align paired-end ddRADseq reads to the *Aedes albopictus* reference genome using `bwa-mem`, allowing up to 3 mismatches (`NM:<4`)

### 005_gstacks_albo.sh and 006_populations_albo.sh
Build RAD-loci and call genotypes and identify SNPs using `gstacks` from Stacks.`gstacks`first identifies SNPs withing the meta-population for each locus and then genotypes each individual at each identified SNP.
Loci are filtered with `populations`from Stacks: Loci are kept if present in at least one population (`-p 1`) nad in at least 25% of individuals within a population (`-r 0.25`). Filtered datasets are exported in both VCF and PLINK formats for downstream analyses.
