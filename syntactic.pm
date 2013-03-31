use strict;
use warnings;
use File::Find;  
use File::Copy;
use Cwd;
use File::Basename;

use constant $STATE_TOP             => 0;
use constant $STATE_UNDER_DEFINE    => 1;
use constant $STATE_UNDER_OBJECT    => 2;
use constant $STATE_UNDER_INHERIT   => 3;
use constant $STATE_UNDER_MEMBER    => 4;

sub CreateSyntacticAnalyzer
{
    my $SyntacticInfo= {};
    my $$SyntacticInfo{objects} = $_[0];
    return $SyntacticInfo;
}

sub SyntacticAnalyzerPushWordStream
{
    my $SyntacticInfo = $_[0];
    my $WordList = $_[1];
    my $Pos = 0;
    my $State = $STATE_TOP;
    my $CurrObejct;
    
    while($Pos < @$WordList)
    {
        if($$WordList[$Pos] eq $SX_LEFT_BRAKET)
        {
            my $Keyword;
            $Keyword = KeywordAnalyzer($State, $WordList, $Pos+1);
            SetFile($Keyword);
            switch($$Keyword{type})
            {
                case $OBJECT_TYPE_UNKNOWN
                {
                    $Pos = FinishCurrentBracket($WordList, $Pos);
                }
                case $OBJECT_TYPE_DEFINE
                {
                    $CurrObject = CreateNewObject($Keyword);
                    $Pos =FinishCurrentBracket($WordList, $Pos+1);
                    $State = STATE_UNDER_DEFINE;
                }
                case $OBJECT_TYPE_OBJECT
                {
                    SetObjectType($CurrObject, $OBJECT_TYPE_OBJECT);
                }
                case $OBJECT_TYPE_MEMBERS
                {
                    AddMember($CurrObject, $Keyword);
                    FinishCurrentBracket($WordList, $Pos);
                }
                case $OBJECT_TYPE_INHERIT
                {
                    AddParent($CurrObject, $Keyword);
                    $Pos =FinishCurrentBracket($WordList, $Pos+1);
                    $State = STATE_UNDER_INHERIT;
                }                
                case $OBJECT_TYPE_INHERIT_DONE
                {
                    $Pos++;
                    $State = STATE_UNDER_DEFINE;
                }
                
                case $OBJECT_TYPE_OBJECT_DONE
                {
                    $Pos++;
                    $State = STATE_UNDER_DEFINE;
                }
                
                case $OBJECT_TYPE_DEFINE_DONE
                {
                    AddObjectToHash($CurrObject, $$SyntacticInfo{objects});
                    $Pos++;
                    $State = STATE_TOP;
                }
            }
        }
        else
        {
            $Pos++;
        }
    }
}

sub GetSyntacticAnalyzerResult
{
    my $SyntacticInfo = $_[0];
    return $SyntacticInfo{objects};
}

sub FinishCurrentBracket
{
    my $WordList = $_[0];
    my $Pos = $_[1];
    my $StartWithLeftBracket = !($$WordList[$Pos]eq $SX_LEFT_BRAKET);
    my $BracketCount = 0;
    $Pos++;
    
    while(($BracketCount == -1) || ($Pos == @$WordList))
    {
        if($$WordList[$Pos] eq $SX_LEFT_BRAKET)
        {
            $BracketCount ++;
        }
        else if($$WordList[$Pos] eq $SX_RIGHT_BRAKET)
        {
            $BracketCount --;
        }
        $Pos ++;
    }
    
    if($Pos == @$WordList)
    {
        return $Pos - 1; 
    }
    
    if(!$StartWithLeftBracket)
    {
        $Pos -- ;
    }
}

sub KeywordAnalyzer($State, $WordList, $Pos+1)
{
    $State = $_[0];
    $WordList = $_[1];
    $Pos = $_[2];
    
}

"syntactic.pm"