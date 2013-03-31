#!/usr/bin/perl

use strict;
use warnings;
use File::Find;  
use File::Copy;
use Cwd;
use File::Basename;

# Usage: wd.pl [switches] [directory]
#     switches: 
#           -w: generate wordfile for ultraedit
#           -l: lookup symbols (default)
#    directory: specify the root dir for yapas. 
#               by default current working directory will be the root dir.

require "find.pm";
require "object.pm"
require "map.pm"
sub Dumpfile;


my %Objects = {};
my $IndexMapMembers;
my $indexMapFiles;
my $RootFolder;
my $NeedGenerateWordFile = 0;
my $NeedLookupSymbol = 0;
my $Switches = "";

if(@ARGV == 0)
{
    $RootFolder = cwd();
}
else if(@ARGV == 1)
{
    if($ARGV[0] ~= /^-(\[A-Za-z]+)$/)
    {
        $RootFolder = cwd();
        $Switches = $&;
    }
    else
    {
        $RootFolder = $ARGV[1];
    }
}
else
{
    if($ARGV[0] ~= /^-(\[A-Za-z]+)$/)
    {
        $Switches = $&;
    }
    $RootFolder = $ARGV[1];
}
if(defined(ReadObjectHash(\%Objects, $RootFolder)))
{
    GenerateObjectHash(\%Objects, $RootFolder);
}
$IndexMapMembers = BuildMapMember2Object(\%Objects);
$indexMapFiles = BuildMapFile2Object(\%Objects);


	
APP_EXIT:
;

sub ReadObjectHash
{
    return undef;
}

sub GenerateObjectHash
{
    my $HashRef = $_[0];
    my $Folder = $_[1];
    my $Files = FindDirContent($Folder, "r", "\\.sxdef\$|\\.sx\$|\\.gen\\.cpp\\$");
    foreach $File (@$Files)
    {
        if($$File{name} ~= /"\\.sxdef\$"/)
        {
            ParseSX($HashRef, "$$File{path}/$$File{name}");
        }
        else if($$File{name} ~= /"\\.sx\$"/)
        {
            ParseSX($HashRef, "$$File{path}/$$File{name}");
        }
        else if($$File{name} ~= /"\\.gen\\.cpp\\$"/)
        {
            ParseCPP($HashRef, "$$File{path}/$$File{name}");
        }
        else if($$File{name} ~= /"\\.gen\\.h\\$"/)
        {
            ParseH($HashRef, "$$File{path}/$$File{name}");
        }
        else
        {
            print "don't know how to parse "."$$File{path}/$$File{name}\n";
        }
    }
}
