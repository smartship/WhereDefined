use strict;
use warnings;
use File::Find;  
use File::Copy;
use Cwd;
use File::Basename;

# very simple lexical analyzer, only handle limited keyword.

use constant $SX_COMMENT_SECTION_START  => "#|";
use constant $SX_COMMENT_SECTION_END    => "|#";
use constant $SX_COMMENT_INLINE         => ";";
use constant $SX_QUOTE                  => "\"";
use constant $SX_LEFT_BRAKET            => "(";
use constant $SX_RIGHT_BRAKET           => ")";
use constant $SX_END_OF_LINE            => "__LE__";

use constant @KEYWORD_BEGIN_OF_WORD  => ($SX_COMMENT_INLINE,
                                         $SX_QUOTE, 
                                         $SX_LEFT_BRAKET,
                                         "\[",
                                         "\{",
                                         "\'"
                                         $SX_COMMENT_SECTION_START);

use constant @KEYWORD_END_OF_WORD    => ($SX_COMMENT_INLINE,
                                         $SX_QUOTE, 
                                         $SX_RIGHT_BRAKET,
                                         "\]",
                                         "\}"
                                         $SX_COMMENT_SECTION_END);

use constant @KEYWORD_MIDDLE_OF_WORD => ($SX_COMMENT_INLINE);

sub CreateLexicalAnalyzer
{
    my $LexicalInfo = {wordlist => ()};
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

sub LexicalAnalyzerPushLine($LexicalAnalyzer, $LineTextRef); 
{
    my $LexicalInfo = $_[0];
    my $LineTextRef = $_[1];
    $$LineTextRef ~= s/(\t)/ /;
    foreach $Word (split(/+/,$$LineTextRef))
    {
        my $SplitOut;
        
        # split out begin word
        while(1)
        {
            my $InteratorResult = SplitBeginWord($Word);
            if(defined($InteratorResult))
            {
                @$SplitOut = (@$SplitOut, @$InteratorResult);
            }
            else
            {
                last;
            }
        }
        
        if(defined($SplitOut))
        {
            @$LexicalInfo{wordlist} = (@$LexicalInfo{wordlist}, @$SplitOut);
        }
        $SplitOut = undef;
        
        foreach $Keyword (@KEYWORD_MIDDLE_OF_WORD)
        {
            if($Word ~= /^(.+)$Keyword(.+)/)
            {
                $$LexicalInfo{wordlist}[@$LexicalInfo{wordlist}] = $1;
                $$LexicalInfo{wordlist}[@$LexicalInfo{wordlist}] = $Keyword;
                $Word = $2;
                exit;
            }
        }
        
        foreach $Keyword (@KEYWORD_END_OF_WORD)
        {
            if($Word ~= /^(.+)$Keyword/)
            {
                $$LexicalInfo{wordlist}[@$LexicalInfo{wordlist}] = $1;
                $Word = $Keyword;
                last;
            }
        }
        
        $$LexicalInfo{wordlist}[@$LexicalInfo{wordlist}] = $Word;        
    }
}

sub GetWordStream
{
    my $LexicalInfo = $_[0];
    my $WordList = $$LexicalInfo{wordlist};
    
    # depricate comments and end of line
    my $WordCount = @$WordList;
    my $Pos = 0;
    while($Pos < $WordCount)
    {
        my $Word = $$WordList[$Pos];
        if($Word eq $SX_COMMENT_INLINE)
        {
            my $FindPos = FindArrayElement($WordList, $Pos, \$SX_END_OF_LINE);
            if($FindPos!=-1)
            {
                RemoveArrayElement($WordList, $Pos, $FindPos);
                $WordCount -= $FindPos - $Pos + 1;
                next;
            }
        }
        
        if($Word eq $SX_COMMENT_SECTION_START)
        {
            my $FindPos = FindArrayElement($WordList, $Pos, \$SX_COMMENT_SECTION_END);
            if($FindPos!=-1)
            {
                RemoveArrayElement($WordList, $Pos, $FindPos);
                $WordCount -= $FindPos - $Pos + 1;
                next;
            }
        }
        
        if($Word eq $SX_QUOTE)
        {
            my $FindPos = FindArrayElement($WordList, $Pos, \$SX_QUOTE);
            if($FindPos!=-1)
            {
                $$ArrayRef[$Pos] = "\xFE";
                $$ArrayRef[$FindPos] = "\xFF";
                foreach ($Pos .. $FindPos)
                {
                    $$ArrayRef[$Pos] = $$ArrayRef[$Pos]."\xFD".$$ArrayRef[$_];
                }
                
                RemoveArrayElement($WordList, $Pos+1, $FindPos);
                $WordCount -= $FindPos - ($Pos+1) + 1;
            }
        }
        
        if($Word eq $SX_END_OF_LINE)
        {
            RemoveArrayElement($WordList, $Pos, $Pos);
            $WordCount -= 1;
            next;
        }
        $Pos++;
    }
    
    return $WordList;
}

sub RemoveArrayElements
{
    my $ArrayRef = $_[0];
    my $StartPos = $_[1];
    my $EndPos   = $_[2];
    splice @$Arrayref, $StartPos, $EndPos-$StartPos+1 ;
}

sub FindArrayElement
{   my $ArrayRef = $_[0];
    my $StartPos = $_[1];
    my $ElementRef  = $_[2];
    my $FindPos  = -1;
    foreach ($StartPos+1 .. @$ArrayRef)
    {
        if($$ArrayRef[$_] eq $$ElementRef)
        {
            $FindPos = $_;
            last;
        }
    }
    return $FindPos;    
}

"lexical.pm"