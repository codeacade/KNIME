#!/bin/env perl

use warnings; 
use strict;

## run ls but only diplay file of non zero size.
## eg for checking error file that actually have error in it (from sge qsub)
## wget https://raw.githubusercontent.com/tin6150/inet-dev-class/master/eg-code/ls-0.pl

## in reality a one-liner cli could be setup as alias in .bashrc 
## alias ls-0="ls -l | perl -lane 'if ($F[4] != 0 )  { print \$_ };' "   
## when issuing in bash prompt, $_ suffice.  but when script is sourced, need to escape as \$_



## tech tags: 
## - foreach 
## - qx to run system command
## regular expression, with () numbering desired portion


			# what the reg exp parse from ls -l output:
			#
			# -rw-r--r-- 1 hoti1 wheel     2153 Apr 13 09:11 sge-qsub-problem.txt
			# drwxrwxr-x 2 hoti1 wheel  2078776 Apr 13 01:56 sge_output
			# drwxr-xr-x 3 hoti1 wheel      100 Apr 12 17:39 sift_run_uniref90
			# (\S+)     \S+  \S+ \S+ \s+    \d+
			# 1                             5
			# /\S+\s+\S+\s+\S+\s+\S+\s+(\S+)\s+/
			# \s = space
			# \S = non space


sub main {

	#my $fileList = qx !ls -1 /tmp! ;
	#my $fileList = qx "ls -1 | xargs" ;
	my @lsOut = qx "ls -l" ;
	foreach my $line ( @lsOut ) {
        if( $line =~ /^(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\d+)\s+/ ) {
			my $filesize = $5;
			if( $filesize != 0 ) {
				#print "$5 ... $line \n";
				print $line;
			}
		}
	}
} # end sub main


&main();


