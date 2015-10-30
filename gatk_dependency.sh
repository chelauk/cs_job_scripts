#!/bin/bash
name=$1
refname=$2
dir=$3
sample=$4
########################
# generate inputs      #
########################
read1="$sample"_R1.fq.gz
read2="$sample"_R2.fq.gz
bamfile="$sample"_R1.fq.gz.bwa.sorted.bam
#######################
interval=$5
user=$6

# no jobs complete
if ! [ -f "$dir"/bwa-complete ] && ! [ -f "$dir"/interval_complete ]  && ! [ -f "$dir"/realign_complete ] && ! [ -f "$dir"/recal_tab_complete ] && ! [ -f "$dir"/recal_complete ] && ! [ -f "$dir"/var_call_complete ] # if none of the jobs have completed 
then
  FIRST=$(qsub -wd "$dir"/log -N "bwa-$name" \
  /home/sejjctj/job_scripts/sge_bwa_mem_sambamba_samblaster_4_core.job \
  "$refname" \
  "$read1" \
  "$read2" \
  "$dir" \
  "$user")
  echo "$FIRST"

  SECOND=$(qsub -wd "$dir"/log -N "intCr-$name" -hold_jid "bwa-$name" \
  /home/sejjctj/job_scripts/sge_gatk_interval_creater.job \
  "$refname" \
  "$dir" \
  "$bamfile" \
  "$interval" \
  "$user")
  echo "$SECOND"

  THIRD=$(qsub -wd "$dir"/log -N "realn-$name" -hold_jid "intCr-$name" \
  /home/sejjctj/job_scripts/sge_gatk_interval_realigner.job \
  "$refname" \
  "$dir" \
  "${bamfile:0:${#bamfile}-3}"intervals \
  "$bamfile" \
  "$interval" \
  "$user" )
  echo "$THIRD"

  FOURTH=$(qsub -wd "$dir"/log -N "reTab-$name" -hold_jid "realn-$name" \
  /home/sejjctj/job_scripts/sge_gatk_base_recal_table_creator.job \
  "$refname" \
  "$dir" \
  "${bamfile:0:${#bamfile}-3}"realigned.bam \
  "$interval" \
  "$user")
  echo "$FOURTH"

  FIFTH=$(qsub -wd "$dir"/log -N "recal-$name" -hold_jid "reTab-$name" \
  /home/sejjctj/job_scripts/sge_gatk_print_reads.job \
  "$refname" \
  "$dir" \
  "${bamfile:0:${#bamfile}-3}"realigned.bam \
  "${bamfile:0:${#bamfile}-3}"realigned.bam.recal_data.table \
  "$interval" \
  "$user")
  echo "$FIFTH"

  SIXTH=$(qsub -wd "$dir"/log -N "hapl-$name" -hold_jid "recal-$name" \
  /home/sejjctj/job_scripts/sge_gatk_haplotype_caller.job \
  "$refname" \
  "$dir" \
  "${bamfile:0:${#bamfile}-3}"realigned.recal.bam \
  "$interval" \
  "$user")
  echo "$SIXTH"
 
  echo "six jobs"
  exit 0

elif ! [ -f "$dir"/interval_complete ]  && ! [ -f "$dir"/realign_complete ] && ! [ -f "$dir"/recal_tab_complete ] && ! [ -f "$dir"/recal_complete ] && ! [ -f "$dir"/var_call_complete ] # if bwa completed 
then 
  
  SECOND=$(qsub -wd "$dir"/log -N "intCr-$name" -hold_jid "bwa-$name" \
  /home/sejjctj/job_scripts/sge_gatk_interval_creater.job \
  "$refname" \
  "$dir" \
  "$bamfile" \
  "$interval" \
  "$user")
  echo "$SECOND"
  
  THIRD=$(qsub -wd "$dir"/log -N "realn-$name" \
  /home/sejjctj/job_scripts/sge_gatk_interval_realigner.job \
  "$refname" \
  "$dir" \
  "${bamfile:0:${#bamfile}-3}"intervals \
  "$bamfile" \
  "$interval" \
  "$user" )
  echo "$SECOND"

  FOURTH=$(qsub -wd "$dir"/log -N "reTab-$name" -hold_jid "realn-$name" \
  /home/sejjctj/job_scripts/sge_gatk_base_recal_table_creator.job \
  "$refname" \
  "$dir" \
  "${bamfile:0:${#bamfile}-3}"realigned.bam \
  "$interval" \
  "$user")
  echo "$THIRD"

  FIFTH=$(qsub -wd "$dir"/log -N "recal-$name" -hold_jid "reTab-$name" \
  /home/sejjctj/job_scripts/sge_gatk_print_reads.job \
  "$refname" \
  "$dir" \
  "${bamfile:0:${#bamfile}-3}"realigned.bam \
  "${bamfile:0:${#bamfile}-3}"realigned.bam.recal_data.table \
  "$interval" \
  "$user")
  echo "$FOURTH"

  SIXTH=$(qsub -wd "$dir"/log -N "hapl-$name" -hold_jid "recal-$name" \
  /home/sejjctj/job_scripts/sge_gatk_haplotype_caller.job \
  "$refname" \
  "$dir" \
  "${bamfile:0:${#bamfile}-3}"realigned.recal.bam \
  "$interval" \
  "$user")
  echo "$FIFTH"

  echo "five jobs"
  exit 0

elif ! [ -f "$dir"/realign_complete ] && ! [ -f "$dir"/recal_tab_complete ] && ! [ -f "$dir"/recal_complete ] && ! [ -f "$dir"/var_call_complete ] # if interval creation has completed
then 
  
  THIRD=$(qsub -wd "$dir"/log -N "realn-$name" \
  /home/sejjctj/job_scripts/sge_gatk_interval_realigner.job \
  "$refname" \
  "$dir" \
  "${bamfile:0:${#bamfile}-3}"intervals \
  "$bamfile" \
  "$interval" \
  "$user" )
  
  FOURTH=$(qsub -wd "$dir"/log -N "reTab-$name"  \
  /home/sejjctj/job_scripts/sge_gatk_base_recal_table_creator.job \
  "$refname" \
  "$dir" \
  "${bamfile:0:${#bamfile}-3}"realigned.bam \
  "$interval" \
  "$user")
  echo "$THIRD"

  FIFTH=$(qsub -wd "$dir"/log -N "recal-$name" -hold_jid "reTab-$name" \
  /home/sejjctj/job_scripts/sge_gatk_print_reads.job \
  "$refname" \
  "$dir" \
  "${bamfile:0:${#bamfile}-3}"realigned.bam \
  "${bamfile:0:${#bamfile}-3}"realigned.bam.recal_data.table \
  "$interval" \
  "$user")
  echo "$FOURTH"
  
  SIXTH=$(qsub -wd "$dir"/log -N "hapl-$name" -hold_jid "recal-$name" \
  /home/sejjctj/job_scripts/sge_gatk_haplotype_caller.job \
  "$refname" \
  "$dir" \
  "${bamfile:0:${#bamfile}-3}"realigned.recal.bam \
  "$interval" \
  "$user")
  echo "$FIFTH"

  echo "three jobs"
  exit 0

elif ! [ -f "$dir"/recal_tab_complete ] && ! [ -f "$dir"/recal_complete ] &&  ! [ -f "$dir"/var_call_complete ] # if realign has completed
  then

  FOURTH=$(qsub -wd "$dir"/log -N "reTab-$name"  \
  /home/sejjctj/job_scripts/sge_gatk_base_recal_table_creator.job \
  "$refname" \
  "$dir" \
  "${bamfile:0:${#bamfile}-3}"realigned.bam \
  "$interval" \
  "$user")
  echo "$THIRD"

  FIFTH=$(qsub -wd "$dir"/log -N "recal-$name"  \
  /home/sejjctj/job_scripts/sge_gatk_print_reads.job \
  "$refname" \
  "$dir" \
  "${bamfile:0:${#bamfile}-3}"realigned.bam \
  "${bamfile:0:${#bamfile}-3}"realigned.bam.recal_data.table \
  "$interval" \
  "$user")
  echo "$FOURTH"
  
  SIXTH=$(qsub -wd "$dir"/log -N "hapl-$name" -hold_jid "recal-$name" \
  /home/sejjctj/job_scripts/sge_gatk_haplotype_caller.job \
  "$refname" \
  "$dir" \
  "${bamfile:0:${#bamfile}-3}"realigned.recal.bam \
  "$interval" \
  "$user")
  echo "$FIFTH"
  
  echo "three jobs"
  
elif ! [ -f "$dir"/recal_complete ] && ! [ -f "$dir"/var_call_complete ] # if recal table has been created 
  then

  FIFTH=$(qsub -wd "$dir"/log -N "recal-$name"  \
  /home/sejjctj/job_scripts/sge_gatk_print_reads.job \
  "$refname" \
  "$dir" \
  "${bamfile:0:${#bamfile}-3}"realigned.bam \
  "${bamfile:0:${#bamfile}-3}"realigned.bam.recal_data.table \
  "$interval" \
  "$user")

  SIXTH=$(qsub -wd "$dir"/log -N "hapl-$name" -hold_jid "recal-$name" \
  /home/sejjctj/job_scripts/sge_gatk_haplotype_caller.job \
  "$refname" \
  "$dir" \
  "${bamfile:0:${#bamfile}-3}"realigned.recal.bam \
  "$interval" \
  "$user")
  echo "$SIXTH"

elif ! [ -f "$dir"/var_call_complete ] # if recalibration is complete
  then
  SIXTH=$(qsub -wd "$dir"/log -N "hapl-$name" -hold_jid "recal-$name" \
  /home/sejjctj/job_scripts/sge_gatk_haplotype_caller.job \
  "$refname" \
  "$dir" \
  "${bamfile:0:${#bamfile}-3}"realigned.recal.bam \
  "$interval" \
  "$user")
  echo "$SIXTH"
  exit 0

else
  echo "all done!"
  exit 0
fi
