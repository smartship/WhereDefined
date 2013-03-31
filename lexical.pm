use strict;
use warnings;
use File::Find;  
use File::Copy;
use Cwd;
use File::Basename;

use constant $COMMENT_STATE => "1";
use constant $NORMAL_STATE  => "0";
use constant $QUOTE_STATE   => "2";

# very simple lexical analyzer, only handle limited keyword.

use constant $SX_NUM_OF_LINE            => "__LE__";

sub CreateLexicalAnalyzer
{
    my $LexicalInfo = {wordlist => (), state => 0};
    return $LexicalInfo;     
}

sub SplitBeginWord
{
    my $SplitOut;
    my $Word = $_[0];
    my $Keyword;
    foreach $Keyword (@KEYWORD_BEGIN_OF_WORD)
    {
        if($Word ~= /^$Keyword(.+)/)
        {
            $SplitOut[@$SplitOut] = $Keyword;
            $Word = $&;
            exit;
        }
    }
    return $SplitOut;
}

sub LexicalAnalyzerPushLine
{
    my $LexicalInfo = $_[0];
    my $LineTextRef = $_[1];
    my $LineNum = $_[2];
    my $LineNumAdded = 0;
    #PushNewElement($LexicalInfo{wordlist}, ConvertLineNum($LineNum));
    $$LineTextRef ~= s/(\t)/ /;
    foreach $Word (split(/+/,$$LineTextRef))
    {
        while(1)
        {
            switch($LexicalInfo{state})
            {
                case($NORMAL_STATE)
                {
                    my $Occurrence = GetFirstOccurence($Word, $SX_DELIMITION_SYMBOL);
                    if($Occurrence eq -1) # cannot find matched char. 
                    {
                        if(!LineNumAdded)
                        {
                            PushNewElement($LexicalInfo{wordlist}, ConvertLineNum($LineNum));
                            LineNumAdded = 1;
                        }
                        PushNewElement($LexicalInfo{wordlist}, $Word);
                        last;
                    }
                    else
                    {
                        if($Occurrence!=0) # push the first part of word
                        {
                            if(!LineNumAdded)
                            {
                                PushNewElement($LexicalInfo{wordlist}, ConvertLineNum($LineNum));
                                LineNumAdded = 1;
                            }
                            PushNewElement($LexicalInfo{wordlist}, substr($Word, 0, $Occurrence));
                        }

                        # check middle part
                        my ($Keyword, $Length) = MatchWithDelimitions(substr($Word, $Occurrence), \$SX_LEXICAL_DELIMITIONS{delimitions});

                        switch($Keyword)
                        {
                            case($SX_LEXICAL_DELIMITIONS{inline_comment})
                            {
                                last; # no meaningful content in this line
                            }
                            case($SX_LEXICAL_DELIMITIONS{section_comment_start})
                            {
                                $LexicalInfo{state} = $COMMENT_STATE;
                            }
                            case($SX_LEXICAL_DELIMITIONS{quote})
                            {
                                if(!LineNumAdded)
                                {
                                    PushNewElement($LexicalInfo{wordlist}, ConvertLineNum($LineNum));
                                    LineNumAdded = 1;
                                }
                                PushNewElement($LexicalInfo{wordlist}, "\"");
                                $LexicalInfo{state} = $QUOTE_STATE;
                            }
                            else
                            {
                                PushNewElement($LexicalInfo{wordlist}, $Keyword);
                            }
                        }

                        # get the latter part
                        $Word = substr($Word, $Occurrence + $Length);
                    }
                }
                case($COMMENT_STATE)
                {
                    my $Occurrence = GetFirstOccurence($Word, $SX_DELIMITION_SYMBOL_COMMENT);
                    if($Occurrence eq -1) # cannot find matched char. 
                    {
                        last;
                    }
                    else
                    {
                        # check middle part
                        my ($Keyword, $Length) = MatchWithDelimitions(substr($Word, $Occurrence), \$SX_LEXICAL_DELIMITIONS{delimitions});
                        switch($Keyword)
                        {
                            case($SX_LEXICAL_DELIMITIONS{section_comment_end})
                            {
                                $LexicalInfo{state} = $NORMAL_STATE;
                            }
                            else
                            {
                                last;
                            }
                        }
                        # get the latter part
                        $Word = substr($Word, $Occurrence + $Length);
                    }
                }
                case($QUOTE_STATE)
                {
                    my $Occurrence = GetFirstOccurence($Word, $SX_DELIMITION_SYMBOL_QUOTE);
                    if($Occurrence eq -1) # cannot find matched char. 
                    {
                        MergeNewElementToLast($LexicalInfo{wordlist}, $Word,"\xFD")
                        last;
                    }
                    else
                    {
                        # check middle part
                        my ($Keyword, $Length) = MatchWithDelimitions(substr($Word, $Occurrence), \$SX_LEXICAL_DELIMITIONS{delimitions});
                        # get the latter part
                        switch($Keyword)
                        {
                            case($SX_LEXICAL_DELIMITIONS{quote})
                            {
                                MergeNewElementToLast($LexicalInfo{wordlist}, "\"");
                                $LexicalInfo{state} = $NORMAL_STATE;
                            }
                            else
                            {
                                MergeNewElementToLast($LexicalInfo{wordlist}, $Word,"\xFD");
                                last;
                            }
                        }
                        # get the latter part
                        $Word = substr($Word, $Occurrence + $Length);
                    }
                }
            }

            if($Word eq "")
            {
                last;
            }
        }
    }
}

sub GetWordStream
{
    my $LexicalInfo = $_[0];
    return $$LexicalInfo{wordlist};
}

sub GetFirstOccurence($Word, $SX_DELIMITION_SYMBOL)
{
    my @Chars = split //, $_[0];
    my $MatchChars = $_[1];
    for (my $Index = 0; $index < @Chars; $index++)
    {
        if(index($MatchChars, $Chars[Index])
        {
            return $Index;
        }
    }
    return -1;
}

sub MatchWithDelimitions(substr($Word, $Occurrence), \%SX_LEXICAL_DELIMITIONS)
{
    my $Word = $_[0];
    my $DelimitionRef = $_[1];
    foreach $Delimitions (@$DelimitionRef)
    {
        foreach $SingleDelimit (@Delimitions)
        {
            if(index($Word, $SingleDelimit) == 0)
            {
                #delimition found at the beginning of word
                return @($SingleDelimit, length($SingleDelimit));
            }
        }
    }

    # why runs here??? one of the delimitions should be found in the word...

    return @(undef, undef);
}



sub PushNewElement
{
    my $ArrayRef = $_[0];
    my $ElementRef = $_[1];
    $$ArrayRef[@$ArrayRef] = $$ElementRef;
}

sub MergeNewElementToLast
{
    my $ArrayRef = $_[0];
    my $ElementRef = $_[1];
    my $Delimition = $_[2];
    $$ArrayRef[@$ArrayRef -1 ] = $$ArrayRef[@$ArrayRef -1 ].$Delimition.$$ElementRef;    
}
sub ConvertLineNum($LineNum)
{
    return $SX_NUM_OF_LINE.$LineNum;
}
"lexical.pm"