# albopictus_pop_gen
This repository contains a ddRAD-seq analysis pipeline for <i>Aedes albopictus</i>. The workflow was developed to process paired-end ddRAD-seq data generated from libraries prepared with the NlaIII and MluCl restriction enzymes.

## Read Processing and Variant Calling
<b>001_demultiplexing.sh</b>: Demultiplexing of raw ddRAD reads using `process_radtags` from Stacks. Reads with low quality < Q10 were discarded (`q`). This script was run separately for each sequencing library.

<b>002_fastqc_demu.sh</b>: `FastQC` quality assessment of demultiplexed reads and combining all FastQC reports using `MultiQC` (<b>003_multiqc_demu.sh</b>).

<b>004_alignment.sh</b>: Alignment of paired-end reads to the <i>Ae. albopictus</i> reference genome (GenBank accession: GCA_006516635.1) using `bwa-mem`, retaining only alignments with an alignment score ≥ 30 (`-T 30`) and allowing up to three mismatches (`NM:<4`).

<b>005_gstacks_albo.sh</b>: Assembly of RAD-loci, SNP identification and genotype calling of each individual at each identified SNP using `gstacks` from Stacks. 

<b>006_populations_albo.sh</b>: Filtering of loci using `populations` from Stacks by retaining loci that are present in at least 25% (`-r 0.25`) of individuals within a population and export of dataset in VCF format (`populations.snps.vcf`) for downstream analyses.

## SNP Filtering
<b>010_first_pass_filter.sh</b>: Initial filtering of the SNP dataset (<code>populations.snps.vcf</code>) using `VCFtools` by removing indels, excluding SNPs located within repetitive regions of the <i>Ae. albopictus</i> genome and retaining only SNPs genotyped in at least 50% of individuals. Repeat regions were identified with RepeatMasker (<b>repeatmasker_albopictus.sh</b>). The filtered dataset was exported as <code>populations.snps.filtered1.vcf</code> and site-level and individual-level quality metrics were calculated (<b>011_compute_metrics.sh</b>).

<b>020_preliminary_filters.ipynb</b>: Site- and individual-level metrics were inspected in a Jupyter notebook () to assess data quality and support filtering decisions. SNPs were subsequently filtered based on minimum allele count (MAC = 3), maximum read depth (≤ 30) and allele balance (between 0.25 and 0.75 or below 0.01 for keeping fixed alleles) and exported as <code>populations.snps.filtered2.vcf</code>. Site- and individual-level quality metrics were calculated (<b>021_compute_metrics.sh</b>)

<b>030_test_thresholds.sh</b>: Different combinations of SNP missingness and minimum depth thresholds were applied, and the resulting VCF files were inspected in a Jupyter notebook (<b>031_inspect_thresholds.ipynb</b>) to identify an optimal balance between data quality and SNP retention. 

<b>040_FMi_and_LD_filter.sh</b>: Final SNP filtering based on the most promising combinations of SNP missingness, minimum depth and missing data per individual thresholds. Furthermore, SNPs were pruned for linkage disequilibrium using `PLINK`.

<b>041_SNP_filtering_reduced_vcf.sh</b>: Separate filtering of reduced dataset containing the samples from Europe, the USA and Israel using the same filtering thresholds as in the global dataset. 
