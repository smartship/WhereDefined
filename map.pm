use strict;
use warnings;
use File::Find;  
use File::Copy;
use Cwd;
use File::Basename;

sub BuildMapMember2Object # in: ObjName->Object hash, out: MemberName->Object hash
{
    if(@_ < 1)
    {
        return;
    }
    my $HashRef = $_[0];
    my $TargetHash = {};
    my @ObjNames = keys%{$HashRef};
    foreach $Name (@ObjNames)
    {
        $Members = GetMembers($HashRef);
        foreach $MemberName (@{$Members})
        {
            AddHashItem($TargetHash, $MemberName, $$HashRef{$Name});
        }
    }
    return $TargetHash;
}

sub BuildMapFile2Object # in: ObjName->Object hash, out: FileName->Object hash
{
    if(@_ < 1)
    {
        return;
    }
    my $HashRef = $_[0];
    my $TargetHash = {};
    my @ObjNames = keys%{$HashRef};
    foreach $Name (@ObjNames)
    {
        $File = GetFile($HashRef);
        AddHashItem($TargetHash, $File, $$HashRef{$Name});
    }
    return $TargetHash;
}

sub GenerateChildrenList # in: Object hash with children array. out: full children array
{
}

sub AddHashElement
{
    if(@_ < 3)
    {
        return undef;
    }
    my $HashRef = $_[0];
    my $HashKey = $_[1];
    my $HashValue = $_[2];
    
    if(!exist($$HashRef{$HashKey})
    {
        $$HashRef{$HashKey} = [];
    }
    push @{$HashRef->{$HashKey}}, $HashValue};
    
    return $HashRef;
}

"map.pm";