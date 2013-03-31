use strict;
use warnings;
use File::Find;  
use File::Copy;
use Cwd;
use File::Basename;
use constant TOP_LEVEL      =>0;
use constant COMMENTATION   =>1;
use constant UNDER_DEFINE   =>2;
use constant UNDER_INHERIT  =>4;
use constant UNDER_MEMBER   =>8;
sub InitState
{
    my $State;
    my $TempState;
    if(@_ >= 1)
    {
        $State = $_[0];
    }
    else
    {
        $State = \$TempState;
    }
    $$State = TOP_LEVEL;
    return $State;
}
sub CleanState
{
    return InitState(@_);
}
sub SetState
{
    my $State = $_[0];
    $$State = $$State | $_[1];
    return $State;
}
sub RemoveState
{
    my $State = $_[0];
    $$State = $$State & (~$_[1]);
    return $State;
}
sub IsState
{
    my $State = $_[0];
    return ($$State == $$State | $_[1]);
}
sub SetStateCommentation    { return SetState($_[0], COMMENTATION); }
sub RemoveStateCommentation { return RemoveState($_[0], COMMENTATION); }
sub IsStateCommentation     { return IsState($_[0], COMMENTATION); }
sub SetStateUnderMember     { return SetState($_[0], UNDER_MEMBER); }
sub RemoveStateUnderMember  { return RemoveState($_[0], UNDER_MEMBER); }
sub IsStateUnderMember      { return IsState($_[0], UNDER_MEMBER); }    
sub SetStateUnderDefine     { return SetState($_[0], UNDER_DEFINE); }   
sub RemoveStateUnderDefine  { return RemoveState($_[0], UNDER_DEFINE); }
sub IsStateUnderDefine      { return IsState($_[0], UNDER_DEFINE); }    
sub SetStateUnderInherit    { return SetState($_[0], UNDER_INHERIT); }   
sub RemoveStateUnderInherit { return RemoveState($_[0], UNDER_INHERIT); }
sub IsStateUnderInherit     { return IsState($_[0], UNDER_INHERIT); }
"parsesxstate.pm";