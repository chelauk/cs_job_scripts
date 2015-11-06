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
name=$5
user=$6

# check arguments are given
if  [ -z "$1" ]
  then
    echo "Please give a job name, the reads with be supplied as sample_R1.fq.gz and sample_R2.fq.gz the aligned file will be sample_R1.fq.gz.bwa.sorted.bam"
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
 then echo "Interval .bed file is optional if none is necessary please insert 0 or for a particular chromosome enter chromosome name"
 exit
fi

if  [ -z "$5" ]
 then echo "please enter jobname"
 exit
fi

if  [ -z "$6" ]
 then echo "please enter username"
 exit
fi

# no jobs complete
if ! [ -f "$dir"/bwa_complete ] && ! [ -f "$dir"/interval_complete ]  && ! [ -f "$dir"/realign_complete ] && ! [ -f "$dir"/recal_tab_complete ] && ! [ -f "$dir"/recal_complete ] && ! [ -f "$dir"/var_call_complete ] # if none of the jobs have completed 
  then
    first
    second
    third
    fourth
    fifth
    sixth
    echo "Six jobs"
    exit 0

elif ! [ -f "$dir"/interval_complete ]  && ! [ -f "$dir"/realign_complete ] && ! [ -f "$dir"/recal_tab_complete ] && ! [ -f "$dir"/recal_complete ] && ! [ -f "$dir"/var_call_complete ] # if bwa completed 
  then 
    second
    third
    fourth
    fifth
    sixth
    echo "Five jobs"
    exit 0

elif  ! [ -f "$dir"/realign_complete ] && ! [ -f "$dir"/recal_tab_complete ] && ! [ -f "$dir"/recal_complete ] && ! [ -f "$dir"/var_call_complete ] # if bwa completed 
  then 
    third
    fourth
    fifth
    sixth
    echo "Four jobs"
    exit 0

elif ! [ -f "$dir"/recal_tab_complete ] && ! [ -f "$dir"/recal_complete ] && ! [ -f "$dir"/var_call_complete ] # if interval creation has completed
  then
    fourth
    fifth
    sixth
    echo "Three jobs"
    exit 0

elif  ! [ -f "$dir"/recal_complete ] && ! [ -f "$dir"/var_call_complete ] # if interval creation has completed
  then
    fifth
    sixth
    echo "Two jobs"
    exit 0

elif ! [ -f "$dir"/var_call_complete ]
  then
  	sixth
  	echo "One job"
  	exit 0
  	
else
  echo "all done!"
  exit 0
fi
    
  function first { qsub -wd "$dir"/log -N "bwa-$name" \
  /home/sejjctj/job_scripts/sge_bwa_mem_sambamba_samblaster_4_core.job \
  "$refname" \
  "$read1" \
  "$read2" \
  "$dir" \
  "$user" 
  }

  function second { qsub -wd "$dir"/log -N "intCr-$name" -hold_jid "bwa-$name" \
  /home/sejjctj/job_scripts/sge_gatk_interval_creater.job \
  "$refname" \
  "$dir" \
  "$bamfile" \
  "$interval" \
  "$user" 
  }

  function third { qsub -wd "$dir"/log -N "realn-$name" -hold_jid "intCr-$name" \
  /home/sejjctj/job_scripts/sge_gatk_interval_realigner.job \
  "$refname" \
  "$dir" \
  "${bamfile:0:${#bamfile}-3}"intervals \
  "$bamfile" \
  "$interval" \
  "$user" 
  }

  function fourth { qsub -wd "$dir"/log -N "reTab-$name" -hold_jid "realn-$name" \
  /home/sejjctj/job_scripts/sge_gatk_base_recal_table_creator.job \
  "$refname" \
  "$dir" \
  "${bamfile:0:${#bamfile}-3}"realigned.bam \
  "$interval" \
  "$user"
  }

  function fifth { qsub -wd "$dir"/log -N "recal-$name" -hold_jid "reTab-$name" \
  /home/sejjctj/job_scripts/sge_gatk_print_reads.job \
  "$refname" \
  "$dir" \
  "${bamfile:0:${#bamfile}-3}"realigned.bam \
  "${bamfile:0:${#bamfile}-3}"realigned.bam.recal_data.table \
  "$interval" \
  "$user"
  }

  function sixth { qsub -wd "$dir"/log -N "hapl-$name" -hold_jid "recal-$name" \
  /home/sejjctj/job_scripts/sge_gatk_haplotype_caller.job \
  "$refname" \
  "$dir" \
  "${bamfile:0:${#bamfile}-3}"realigned.recal.bam \
  "$interval" \
  "$user"
  }
