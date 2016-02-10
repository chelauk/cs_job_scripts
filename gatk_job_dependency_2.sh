#!/bin/bash
sample=$1
refname=$2
dir=$3
########################
# generate inputs      #
########################
read1="$sample"_R1.fq.gz
read2="$sample"_R2.fq.gz
bamfile="$sample"_R1.fq.gz.bwa.sorted.bam
#######################
interval=$4
user=$5

log=$dir/log

# check arguments are given
if  [ -z "$1" ]
  then
    echo "Please give a job name, the reads with be supplied as sample_R1.fq.gz and sample_R2.fq.gz the aligned file wi
ll be sample_R1.fq.gz.bwa.sorted.bam"
    exit
fi

if  [ -z "$2" ]
 then echo "please supply reference name.  Currently human_g1k_v37"
 exit
fi

if  [ -z "$3" ]
 then echo "please supply current working directly.  Remember to create a log directory within this directory"
 exit
fi

if  [ -z "$4" ]
 then echo "Interval .bed file is optional if none is necessary please insert 0 or for a particular chromosome enter ch
romosome name"
 exit
fi

if  [ -z "$5" ]
 then echo "please enter username"
 exit
fi


# no jobs complete
if ! [ -f "$dir"/bwa_complete ] && ! [ -f "$dir"/interval_complete ]  && ! [ -f "$dir"/realign_complete ] && ! [ -f "$dir"/recal_tab_complete ] && ! [ -f "$dir"/recal_complete ] && ! [ -f "$dir"/var_call_complete ] 

then first && second && third && fourth && fifth && sixth
fi 
    
function first { 
  qsub -wd $log -N "bwa-$sample" \
  /home/sejjctj/job_scripts/sge_bwa_mem_sambamba_samblaster_4_core.job \
  "$refname" \
  "$read1" \
  "$read2" \
  "$dir" \
  "$user" 
  }

function second { 
  qsub -wd $log -N "intCr-$sample" -hold_jid "bwa-$sample" \
  /home/sejjctj/job_scripts/sge_gatk_interval_creater.job \
  "$refname" \
  "$dir" \
  "$bamfile" \
  "$interval" \
  "$user"
  }

function third  { 
  qsub -wd $log -N "realn-$sample" -hold_jid "intCr-$sample" \
  /home/sejjctj/job_scripts/sge_gatk_interval_realigner.job \
  "$refname" \
  "$dir" \
  "${bamfile:0:${#bamfile}-3}"intervals \
  "$bamfile" \
  "$interval" \
  "$user" 
  }

function fourth { 
  qsub -wd $log -N "reTab-$sample" -hold_jid "realn-$sample" \
  /home/sejjctj/job_scripts/sge_gatk_base_recal_table_creator.job \
  "$refname" \
  "$dir" \
  "${bamfile:0:${#bamfile}-3}"realigned.bam \
  "$interval" \
  "$user"
  }

function fifth { 
  qsub -wd $log -N "recal-$sample" -hold_jid "reTab-$sample" \
  /home/sejjctj/job_scripts/sge_gatk_print_reads.job \
  "$refname" \
  "$dir" \
  "${bamfile:0:${#bamfile}-3}"realigned.bam \
  "${bamfile:0:${#bamfile}-3}"realigned.bam.recal_data.table \
  "$interval" \
  "$user"
  }

function sixth  { 
  qsub -wd $log -N "hapl-$sample" -hold_jid "recal-$sample" \
  /home/sejjctj/job_scripts/sge_gatk_haplotype_caller.job \
  "$refname" \
  "$dir" \
  "${bamfile:0:${#bamfile}-3}"realigned.recal.bam \
  "$interval" \
  "$user"
  }
