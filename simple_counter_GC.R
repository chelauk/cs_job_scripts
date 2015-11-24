
#### load the exomeDepth package
library(ExomeDepth)
#### load the list of bamfiles
SureLoc <- read.table('sureselect_ext200.bed', header = TRUE)
source("bam1.files")

#### do the read counts

myCount <- getBamCounts(bed.frame = SureLoc, bam.files = my.bam, include.chr = FALSE, referenceFasta = '../human_g1k_v37.fasta')

#### create data frame

myCount.dafr <- as(myCount[, colnames(myCount)], 'data.frame')

#### export data frame

write.csv(myCount.dafr, "data1_GC.csv")

