use strict;
use warnings;
use File::Find;  
use File::Copy;
use Cwd;
use File::Basename;

sub TraverseDirectory # %result, level, path
{

    my $ResultRef = $_[0];
    my $ConfigRef = $ResultRef->{Config};
    my $CurrLevel = $_[1]; # increase the directory level once enter the function
    my $Path = $_[2];
    
	if(defined($$ConfigRef{"DirLevel"}))
	{
	    if($CurrLevel > $$ConfigRef{"DirLevel"})
	    {
	        return;
	    }
	}
	
	#print "try to search dir: " . $Path . "\n";
	my $DIRHANDLE;
	my @FileList;
	
	opendir $DIRHANDLE, $Path;
	@FileList = readdir $DIRHANDLE;
	closedir $DIRHANDLE;
	
	foreach (@FileList) 
	{
		if($_ eq "." || $_ eq "..")
		{
			next;
		}
		
		if(-d $Path."/".$_)
		{
		    TraverseDirectory($ResultRef,$CurrLevel+1,$Path."/".$_);
		    next;
		}
		
	    if(($$ConfigRef{MatchRegularExpression}) && (!/$$ConfigRef{MatchRegularExpression}/))
	    {
            #printf "Match failed\n";
            next;
	    }
	    
        # add files to search result list
        $$ResultRef{"Files"}[@{$ResultRef->{"Files"}}]{name} = $_;
        $$ResultRef{"Files"}[@{$ResultRef->{"Files"}}]{path} = $Path;
        
        # callback here
        #&{$ConfigRef->{"CallbackFunc"}}($_,$Path,$Path."\\".$_);
	}

}

sub FindDirContent # startpath, callback, searchmode, matchexpression
{
    my %Result;
    my @Files;
    my %Config;
    $Result{Files} = \@Files;
    $Result{Config} = \%Config;
    $Config{RootPath} = $_[0];
	$Config{MatchRegularExpression} = undef; #Rr
    $Config{DirLevel} = undef; # number

	
	if(@_ >= 3)
	{
		my $SearchMode = $_[1];
		
		# handle directoty level
		if($SearchMode =~ /([0-9]+)/)
		{
		    $Config{DirLevel} = $&;
		}

		# handle regular expression matching
		if(($SearchMode =~ /r/i) && (@_>=4))
		{
	        $Config{MatchRegularExpression} = $_[2];
		}
	}
	
    TraverseDirectory(\%Result, 0, $Config{RootPath});
    return \@Files;
}



"find.pm";