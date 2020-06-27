#!/usr/bin/perl -w
use strict;
use warnings;

my $readColumn=2;             #read count
$readColumn--;

my %hash=();
my @normalSamples=();
my @tumorSamples=();

my @files=glob("*.gene.quantification.txt");

for my $file_name(@files)
{
  my $entity_submitter_id=$file_name;
  $entity_submitter_id=~s/.gene.quantification.txt//g;
  if(-f $file_name)
  {
    my @idArr=split(/\-/,$entity_submitter_id);
    if($idArr[3]=~/^1/)
    {
      push(@normalSamples,$entity_submitter_id);
    }
    else
    {
      push(@tumorSamples,$entity_submitter_id);
    }        	
    open(RF,"$file_name") or die $!;
    while(my $line=<RF>)
    {
      next if($line=~/^\n/);
      next if($line=~/^\_/);
      chomp($line);
      my @arr=split(/\t/,$line);
      ${$hash{$arr[0]}}{$entity_submitter_id}=$arr[$readColumn];
    }
    close(RF);
  }
}

open(WF,">mRNAmatrix.txt") or die $!;
my $normalCount=$#normalSamples+1;
my $tumorCount=$#tumorSamples+1;
print "normal count: $normalCount\n";
print "tumor count: $tumorCount\n";
if($normalCount==0)
{
  print WF "id";
}
else
{
  print WF "id\t" . join("\t",@normalSamples);
}
print WF "\t" . join("\t",@tumorSamples) . "\n";
foreach my $key(keys %hash)
{
  print WF $key;
  foreach my $normal(@normalSamples)
  {
    print WF "\t" . ${$hash{$key}}{$normal};
  }
  foreach my $tumor(@tumorSamples)
  {
    print WF "\t" . ${$hash{$key}}{$tumor};
  }
  print WF "\n";
}
close(WF);

### Perl code provided by third party