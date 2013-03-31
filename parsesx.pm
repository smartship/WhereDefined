use strict;
use warnings;
use File::Find;  
use File::Copy;
use Cwd;
use File::Basename;

sub ParseSX
    my $HashRef = $_[0];
    my $File = $[1];
    my $FileHandle;
    my $WithInCommentation = 0;
    my $SyntacticAnalyzer = CreateSyntacticAnalyzer();
    my $LexicalAnalyzer = CreateLexicalAnalyzer($HashRef);
    my $WordList;
    my $SyntacticResult;
    
    my $CurrLineNum = 0;
    open $FileHandle,$File;
	while(<$FileHandle>)
	{
        $CurrLineNum ++;
		$LineTextRef = \$_;
        if(FocusText($LineTextRef))
        {
    		LexicalAnalyzerPushLine($LexicalAnalyzer, $LineTextRef, $CurrLineNum); # simple lexical analyzer
	    }
	}
	
	SyntacticAnalyzerPushWordStream($SyntacticAnalyzer, GetWordStream($LexicalAnalyzer));
	$SyntacticResult = GetSyntacticAnalyzerResult($SyntacticAnalyzer);
	MergeObjects($HashRef, $SyntacticResult);
}

sub FocusText
{
    my $StringRef = $_[0];
    $$StringRef = chomp($$StringRef);
    if($$StringRef =~/^\s*(.*?)\s*$/)
	{
		$$StringRef = $1;
	}
	return (!($$StringRef eq ""));
    
}

"parsesx.pm";