

`/scicore/home/muellepi/GROUP/202407_Aalbopictus_SNPs_analysis_by_wandrille`


methodo from https://onlinelibrary.wiley.com/doi/10.1002/ece3.9138

(also use https://journals.plos.org/plosntds/article?id=10.1371/journal.pntd.0008463 )

"""
 - BWA allowing up to four mismatches. 
 - SNP calling : ref_map.pl wrapper in STACKS. 
 - The VCF file output was used to filter the data for sequencing and SNP call quality. 
 - VCFtools v1.9 and R : we excluded loci that 
 	- mapped to repetitive regions of the genome, 
 	- had more than 50% missing data, 
 	- or did not exhibit allele balance. 
 	- We included only bi-allelic variants, with a maximum mean depth value of 30 and with a minimum allele count of three.

 - plink to include only individuals with 
	- less than 20% missing genotypes 
	- a genotyping rate greater than 80% in iterative steps for the 
		1.native_invasive and 
		2.europe datasets, independently. 
	- We excluded tags with more than 10 SNPs and used the populations function in STACKS to obtain output files in VCF format. 

Since most of the downstream analyses require that SNPs are unlinked, we removed linked sites by excluding SNPs located within a window of 400bp (i.e., option --thin 400) with VCFtools. 
The window size corresponded to our maximum fragment size, thus each SNP belongs to a single DNA fragment. 
After conducting a relatedness analysis, we excluded one individual per sibling pair from the analyses (see section below). 
The reduced dataset was split into two cleaned datasets: 
  1.native_invasive_cleaned, including 153 samples and 4714 loci and SNPs, and 
  2.europe_cleaned, including 93 samples and 6308 loci and SNPs (Table 3).


"""


```
Demultiplexing
/scicore/home/muellepi/GROUP/scripts/scripts_demultiplexing
Alignment
/scicore/home/muellepi/GROUP/scripts/scripts_alignment
However, there we did the alignment for individual library plus fq files send by collaborators.
I don’t remember if we did the alignment for all samples at once. I suspect so, but I couldn’t find the “original” script. I think it was exactly like this one:
 
/scicore/home/muellepi/GROUP/albopictus/alignments/AlboAlign/NewGenome/RE_Alignemnt_newgenome.sh but exchanging the samplesheet with this one: samplelist_albo570.txt
Variant Calling
 
Catalogue building with gstacks:
/scicore/home/muellepi/GROUP/albopictus/stacks.ref/Albo_570/gstacks-291029.sh --> does not exists
 
First stacks populations run:
/scicore/home/muellepi/GROUP/albopictus/stacks.ref/Albo_570/populations_311019/populations311019.sh
```


# Steps


## raw data

`/scicore/home/muellepi/GROUP/albopictus/raw`

## Demultiplexed with STACKS 

`/scicore/home/muellepi/GROUP/albopictus/cleaned/combined_fq_albo/`

```
This directory contains all .fq.gz files combined from all libraries (1-5) sequenced at DBSSE/SwissTPH. 
In addtion the samples from the populations DE and GEB (Germany and Georgia, respectively) have been demultiplexed against the reads of 2 sequencing runs
(specpops, to be interpreted as re-sequencing).
The first set of demultiplexed files are kept elsewhere.
The second additon of files to this directory is a library sequencied in Melbourne containing samples from Hong Kong and Turkey (MelbLib). This is a total of 42 sequences.

In total this directory contains information for 278 + 42 individuals, including sample.lists and folders containing the .rem.fq files output by stacks.

On the 9.10.19 I added 500 unzipped .fq files (R1 and R2) from Tom Schmidt (University of Melbourne) that have been missing from the data set.
```

## aligned with BWA

genome : `/scicore/home/muellepi/GROUP/albopictus/genome/albogenome/nuclear/Yale_genome`


`/scicore/home/muellepi/GROUP/albopictus/alignments/AlboAlign/NewGenome`

--> RM all *.sam files and the non sorted files 

## Variant calling with STACKS

/scicore/home/muellepi/GROUP/albopictus/stacks.ref/Albo_570/populations_311019

  -P,--in-path: path to a directory containing Stacks ouput files.
  -O,--out-path: path to a directory where to write the output files. (Required by -V; otherwise defaults to value of -P.)
  
  -p 1 ,--min-populations [int]: minimum number of populations a locus must be present in to process a locus.
  -r 0.25 ,--min-samples-per-pop [float]: minimum percentage of individuals in a population required to process a locus for that population.

  --ordered-export: if data is reference aligned, exports will be ordered; only a single representative of each overlapping site.
  --vcf: output SNPs and haplotypes in Variant Call Format (VCF).
  --plink: output genotypes in PLINK format.

 GT:DP:AD:GQ:GL : genotype / read depth / allele depth / genotype quality / genotype likelihood

 


# filtering

## initial data


`/scicore/home/muellepi/GROUP/albopictus/stacks.ref/Albo_570/populations_311019/populations.snps.vcf`

6 758 948 SNPs

## 010 first pass : filter > 50% missing data

this first pass will just quickly limit the number of SNPs by throwing away the ones we are certain we don't want to keep.

  - > 50% missing data
010_first_pass_filter.sh

After filtering, kept 694'878 out of a possible 6'758'948 Sites



## 020 second pass : filter repeated regions


repetitive regions of the genome, obtained with RepeatMasker/4.0.7:

`/scicore/home/muellepi/GROUP/albopictus/albo_repeats/ae_albopictus_scaffolds.fa.bed`

After filtering, kept 634'524 out of a possible 694'878 Sites

## 030 computing metrics and filtering allele balance, MAC, and meand depth

sites:
 - allele balance. 
 - allele frequency (NB: this is for the whole data and not by pop)
 - mean depth per site
 - site quality
 - missing data per site

individuals:
 - mean depth per individual
 - missing data per individual
 - heterozygosity and inbreeding coefficient . 
      NB: not so appropriate because we have multiple pop
      but it could be useful to flag outlier individuals


population info: `/scicore/home/muellepi/GROUP/albopictus/info/albo_global_pops_UNSD.txt`


strategy:

  apply filter :
   - mac >= 3
   - mean_depth <=30
   - (balance > 0.25 & balance < 0.75) | balance <0.01

   `036_apply_combined_filter/populations.snps.filter3.vcf`
   remaining: 274'781

## 040 exploring filters on min depth, max depth, minimum fraction missing (snps and ind)

041_compute_metrics.sh : computing various metrics on what we have 

### 042 test different threshold of min depth and fraction missing for SNPs

fix max depth at 30

then we play with 
   - minimum min depth (0,4,5,10)
   - minimum fraction missing (SNPs) (10 to 45%)

and report 
    - f_missing ( SNPs & individuals )
    - number of remaining SNPs
    - number of remaining individuals per population


### 043 analysis of the different thresholds and test of different fraction missing for individuals

### 044 trying different ways to account for linkgae desiquilibrium

  Linkage
        plink --indep-pairwise
          OR 
        vcftools --thin 400 ? 

    minimum non-missing for sites 0.75 , for individuals 0.8 : 
      - --thin 400 :    384 indv,  2'550 snps
      - LD-based thin : 384 indv, 14'768 snps
    minimum non-missing for sites 0.70 , for individuals 0.8 : 
      - --thin 400 :    333 indv,  4'860 snps
      - LD-based thin : 333 indv, 27'748 snps

    minimum non-missing for sites 0.65 , for individuals 0.7 , min depth of 3 : 
      - --thin 400 :    347 indv,  1'813 snps
      - LD-based thin : 347 indv, 11'566 snps


From Ann-Christin 26/07:
 - LD-based thin seems more appropriate
 - Filter configuration : try to go for more individuals if possible
 - better for now: sites 0.65 , for individuals 0.7 , min depth of 3
    - try increasing % missing for individuals to retain more 
    - FM_0.65 mD_2 FMi_0.35 ?


### 045 applying linkage desiquilibrium filtering


045_FMi_filter_and_LD_thinning.sh

trying the following thresholds:

FM    mD  FMi   #SNPs pre-thin  #SNPs post thin   #indv
0.65  2   0.35  44'200          24'555            414
0.65  2   0.30  44'200          23'869            373
0.70  2   0.35  20'392          12'118            433
0.70  2   0.30  20'392          11'936            406
0.65  3   0.35  21'102          11'867            383
0.65  3   0.30  21'102          11'567            348
0.75  2   0.35   5'288           3'423            451
0.70  3   0.35   5'482           3'396            414
0.75  2   0.30   5'288           3'388            437
0.70  3   0.30   5'482           3'353            387


best candidates :

0.65  2   0.35  44'200          24'555            413
0.70  2   0.35  20'392          12'118            432
0.70  2   0.30  20'392          11'936            405
0.65  3   0.35  21'102          11'867            382


From their 3D PCA projection ,all 4 exhibit similar patterns (at least, for me). 



From Ann-Christin:

  I agree the best candidates for the analysis are:
  FM    mD  FMi   #SNPs pre-thin  #SNPs post thin   #indv
  0.65  2   0.35  44'200          24'555            414
  0.70  2   0.35  20'392          12'118            433 


prefered or the moment: `FM_0.70_mD_2_MD_30_FMi_0.35/`


### 046 FMi filtering WITHOUT LD filtering


FM_0.70_mD_2_MD_30_FMi_0.35



## 050 genetic relatedness analysis

Relatedness analysis

* SPAGeDi (Hardy & Vekemans, 2002) for the datasets 1.native_invasive and 2.europe. We identified putative full siblings based on pairwise k values of >0.1875, and putative half-siblings with values ranging from 0.1875 > k > 0.0938, following Iacchei et al. (2013). 

* --relatedness2 flag of VCFtools (Danecek et al., 2011) based on the KING inference (Manichaikul et al., 2010)

* selected only pairs of siblings identified by both SPAGeDI and VCFtools. 

* ML-Relate (Kalinowski et al., 2006) to confirm putative relationships as described in Schmidt et al. (2018). 

We run two specific hypotheses of putative relationships: we ran a first “standard” test assuming that the kinship category assigned using Loiselle's k was more likely than the next most likely kinship category. Second, we run a “conservative” test that assumed that the kinship category assigned using Loiselle's k was less likely to be correct. Thus, for pairs with k > 0.1875, statistical tests run with ML-Relate would determine whether the identified pair was full siblings or half-siblings, while for pairs with 0.1875 > k > 0.09375, tests would help determine whether the identified pair was full siblings, half-siblings, or unrelated. Conservative and standard tests were run using 10,000 simulations of random genotype pairs.


SPAGeDi and ML-relate are intended for Windows. --> ask Ann-Christin to perform these.





051_relatedness_computation_with_vcftools_and_plink.sh
 * VCFtools --relatedness2
     thresholds of [0.0442,0.0884,0.177,0.354] from https://www.kingrelatedness.com/manual.shtml
 * plink -make-grm-gz


--- Ann-christin e-mail from 30/08 ---

I managed to run SpaGeDi with a subset of 500 random snps.
I attached the outcome sorted by kinship value. To me the results don't make sense at all. The Loiselle's k is often rather high, i.e. most of the pairwise comparisons would be defined to be close kin (like so close they could be clones). However, the comparisons with self result in a range of values for k from <0.1 to > 1.1, as far as I have seen.

 had these difficulties before.  When a single panmictic population is assumed the relationship is overestimated. Creating groups based on location does not help. 
 The problem seems to be that SPaGeDi needs spatial information. 
 So, as you suggested I ran Spagedi on the potential kinship groups that you created based on the --relatedness2 outcome. 
 I did not have time to look at the results in detail, but they seem more reasonable. However, forming the groups is quite interesting because it turns out individuals from a range of locations form one group, meaning roughly a third of individual from the invaded range share I high number of similar snps, i.e. are less divers than the native range. This is the expected outcome.

I attach the results as an excel worksheet (sorry for the old fashioned way). the 
 * first sheet is the data you send me, I added columns for the stuff I tested in ml-relate with some info. 
 * Sheet 2 is the spagedi results based on a subset of 500 snps. 
 * Sheet 3 is the Spagedi results from the run with the kinship groups. The relatedness values from Spagedi are on the very bottom. 

I attached the original output of Spagedi for pkg's as well (p_out_pkg.txt).

In your kinship group I noticed that some putative siblings have been collected from far (>300 km) to very far (>1000km) apart locations. If it was only one pair, one could consider carryover of individuals, But > three times? I han't finished all the tests with ml-Relate, but I added a rough estimate of the distance between sampling locations, so you get an idea what I mean. Some Individuals stand out, and I am wondering if this is due to missing data.

So my suggestion would be to remove 1 Individual from each full sibling pair, unless the pair was sampled from far apart locations. For the 2nd degree relationships I am not sure what to do.

I will be on holiday for the coming weeks, so I can only sporadically check my e-mail. I will give some more thoughts on which individuals to exclude and provide a list and my rationale for the selection.

---

 * relatedness2 KING
 * SpgeDi Loiselle k ( full-sibling : k values of >0.1875,  half-siblings  0.1875>k>0.0938 from Iacchei 2013)

--> test pair of siblings infered by both

 * ML-relate test decision --> some p-values are missing ? Is there a correction for multiple testing? if not, can we get the exact p-value to do it ourselves ? 
Why are cells B472 tot C475 colored?

--> a priori both full and half siblings are removed


052_relatedness_metric_analysis

 X compare `FM_0.70_mD_2_MD_30_FMi_0.35/` and `FM_0.65_mD_2_MD_30_FMi_0.35/`
 X document the "potential  kinship group"
 X integrate Spagedi 
 X and ml-relate results
 X make decision


==== update by Ann christin 01/11 ====

 - filtering proposition:
    - different level of conservativeness for filtering out sibling pairs
      - 1 of each pair is removed. The exception is, if a single individuals is found in multiple pairs. Then I tried to remove the non-unique individual of the comparisons.
      - The second list excludes only full (1st degree ) individuals.
      - The third list excludes 1st and second degree siblings, unless they have been sampled far apart (> 100km).


      -> going the medium way: remove all individuals that are related to the 1st degree ("full siblings"). 

    - exclude the X-degree siblings that came up by either program AND have been confirmed by mlRelate (which actually tested two hypothesis).
    - First "filter" used: In some cases a certain individuals comes up as potential sibling in more than one pairwise comparisons. If so, remove this particular individual.
    - 2nd "filter": out of a pair of sibling remove individual that has more missing data (potentially lower quality data).

    this removes:

        - invaded@FRMA11
        - invaded@FRST10
        - invaded@IUD3
        - invaded@IPA5
        - invaded@SRB17
        - invaded@ESPV2
        - invaded@MAB2
        - invaded@CHBE121
        - invaded@CHBE129
        - invaded@CHCAS3
        - invaded@CHNE1
        - invaded@CHPR1
        - invaded@TH1
        - invaded@TH8
        - invaded@TH6




`053_removing_siblings.sh`


--> downstream with final filters and sibling removed



  X fineRADstructure -> plot the results from Ann-Christin
    data export ->
      X matrix
      X dendrogram


  O PCA --> clustering on the PCA coordinates

`061_PCA.sh`





## 07xxx DAPC 

  tentative work with DAPC, nothing very conclusive 

## 08xxx Admixture

### 081 admixture all
### 082 admixture native
### 083 admixture invaded

### 084 plotting admixture

  -> plots in 082 and 083 folders

In all analysis the Indonesian samples forms their own which muddies a bit the clarity of the rest of the analysis.

## 09xxx  --> remove indonesian samples and PCA + ADMIXTURE
### 091 remove indonesian samples
### 092 PCA 
### 093 prep admixture
### 094 admixture all
### 095 admixture native
### 096 PCA plots 
  -> plots in 092 folder
### 097 admixture plots 
  -> plots in 094 and 095 folders

## 10xx Fst computation

### 1O1 Fst computation
### 102 plotting Fst



============ various plans and notes ================

 DAPC plan:
  * all
    * with indonesian samples removed
    * with indonesian and Vanuatu samples removed ?
  * invaded/native
    * with indonesian samples removed


 FsT 
  - invaded/native
  - countries
  - DAPC clusters
  - others?




 O Fst-based on the clustering
  plink https://www.cog-genomics.org/plink/1.9/basic_stats#fst
      --fst ['case-control'] 
  python https://biopython.org/wiki/PopGen_Genepop
            https://scikit-allel.readthedocs.io/en/stable/index.html
  Rpackage https://cran.r-project.org/web/packages/genepop/index.html



 O FineRad -> coancestry by country 


  O BADmixture -> ?


Downstream analyses:
 X PCA
 O DPCA
   The DAPC analysis maximizes the between group while minimizing the within-group variance and computes a PCA, followed by a discriminant analysis to identify the number of genetic clusters (Jombart et al., 2010). We used the function find.clusters to estimate the number of clusters K and xvalDapc option to perform cross-validation and to assess the most likely number of principal components to retain in the DAPC analysis. 
 X admixture https://dalexander.github.io/admixture/
    X input file: .bed .fam .bim made with plink --make-bed
        -> will need to fiddle with the sample names to make them adhere to what's expected by plink
        https://bioinformatics.stackexchange.com/questions/3667/converting-vcf-file-to-plink-bed-bim-fam-files

    X ancestry analysis and to estimate the most likely number of evolutionary clusters K 
    X choose the most likely value for K using the ADMIXTURE's cross-validation procedure

    -> check out badmixture

 X FineRADstructure 
      https://evomics.org/learning/population-and-speciation-genomics/2020-population-and-speciation-genomics/fineradstructure-activity/
      https://github.com/millanek/fineRADstructure
      
    O make a version without the LD-based thinning
 O Fst , Fis ... 







===
links:
https://miro.com/app/board/uXjVKzOrlvM=/

https://www.ddocent.com/filtering/
https://speciationgenomics.github.io/filtering_vcfs/




plink and PCA https://www.cog-genomics.org/plink/1.9/ld#indep

clusters and DAPC https://www.rdocumentation.org/packages/adegenet/versions/1.2-7/topics/find.clusters

package install:
```
ml R

install.packages("adegenet")
install.packages("pegas")
install.packages("hierfstat")

```

```
library(adegenet)
library(pegas)


setwd('/scicore/home/muellepi/GROUP/202407_Aalbopictus_SNPs_analysis_by_wandrille/')

vcfFile = '051_relatedness_computation_with_vcftools_and_plink/FM_0.70_mD_2_MD_30_FMi_0.35/FM_0.70_mD_2_MD_30_FMi_0.35_LD_thin.renamed.vcf.gz'

# reading files in adegenet format: https://cran.r-project.org/web/packages/pegas/vignettes/ReadingFiles.pdf
loci_data = read.vcf( vcfFile , to=20000 )
genind_data = loci2genind(loci_data)
genind_data


# adegenet DAPC tutorial https://raw.githubusercontent.com/thibautjombart/adegenet/master/tutorials/tutorial-dapc.pdf

#grp <- find.clusters(genind_data, max.n.clust=50)
# keep 432 PCs (all)
# keep 3 clusters (min BIC)
grp <- find.clusters(genind_data, max.n.clust=50, n.pca = 432, n.clust = 2)

dapc1 <- dapc( genind_data , grp$grp , n.pca = 432 , n.da = 2)
scatter(dapc1)

scatter(dapc1, scree.da=FALSE, bg="white", pch=20, cell=0, cstar=0, col=myCol, solid=.4
        cex=3,clab=0, leg=TRUE, txt.leg=paste("Cluster",1:6))


```


FineRADstructure https://evomics.org/learning/population-and-speciation-genomics/2020-population-and-speciation-genomics/fineradstructure-activity/
 
