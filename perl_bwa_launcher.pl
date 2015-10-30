=head1 CONTACT

  Please email comments or questions to authors

=cut

=head1 NAME

bwa-launcher - A script to launch the novoalign alignment with PE reads settings

=head1 SYNOPSIS

        perl bwa-laucher.pl -workplacelist listofdirectories.txt -reference referencename -reads the common extension of the reads
       
=head1 DESCRIPTION

This script will launch the BWA job script on a series of samples.
This script will also sort and run picard rmdup
Each sample should be in a different folder, and the list of folders should be provided
in the workplacelist text file, one directory per line, absolute path.

The file with reads name should be located in each sample folder, one read file per line (i.e. in case of PE reads it has to contain 2 lines)

=head1 SEE ALSO

=head1 FEEDBACK

Chela James chela.james@ucl.ac.uk

=head1 AUTHORS
Chela James - Email E<lt>chela.james@ucl.ac.ukE<gt>
Francesco Lescai - Email E<lt>f.lescai@ucl.ac.ukE<gt>
Elia Stupka - Email E<lt>e.stupka@ucl.ac.ukE<gt>

=cut

use strict;
use warnings;
use Getopt::Long;
use Cwd;

#Pick up script name automatically for usage message
my $script=substr($0, 1+rindex($0,'/'));

my $cwd = getcwd();
#Set usage message
my $usage="Usage: $script -workplacelist directory_list_name -ext .fq (or .fastq or .gz) \nIn each directory you should have a file with the file name of the reads on the separate lines\nPlease try again.\n\n\n";

#Declare all variables needed by GetOpt
my ($workplacelist, $extension );

#Get command-line parameters with GetOptions, and check that all needed are there, otherwise die with usage message
die $usage unless
        &GetOptions(    'workplacelist:s' => \$workplacelist,
                                        'ext:s' => \$extension,
                                )
        && $workplacelist && $extension;



#open the directory file

my $directories = open (DIR, $workplacelist);
my $count=1;
while (<DIR>) {

        chomp();
        my $directory = $_;

        print STDERR "checking on the drives for directory ".$directory."\n\n";

        my $list =`ls $directory/*$extension`;
        chomp ($list);
        my @readlist = split (/\n/, $list);

        #take just the file name from the absolute path for read 1
        my @absquery1 = split(/\//,$readlist[0]);
        my $endquery1=scalar(@absquery1);
        $endquery1=$endquery1-1;
        my $query1=$absquery1[$endquery1];

        #take just the file name from the absolute path for read 2
        my @absquery2 = split(/\//,$readlist[1]);
        my $endquery2=scalar(@absquery2);
        $endquery2=$endquery2-1;
        my $query2=$absquery2[$endquery2];

        my $bwacommand = "bash /home/sejjctj/job_scripts/align_bash_pipe.sh $count $directory $query1 $query2 $cwd";

        print  "$bwacommand\n";
        system ($bwacommand);
	sleep(3);
	$count++;
}

