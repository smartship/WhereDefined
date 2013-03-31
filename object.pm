use strict;
use warnings;
use File::Find;  
use File::Copy;
use Cwd;
use File::Basename;

use constant $OBJECT_TYPE_UNKNOWN       => 0; 
use constant $OBJECT_TYPE_MEMBERS       => 1;
use constant $OBJECT_TYPE_INHERIT       => 2;
use constant $OBJECT_TYPE_OBJECT        => 3;

sub CreateNewObject
{
    my $ObjectRef = undef;
    
    if(@_>= 1)
    {
        $ObjectRef = $_[0]; 
    }
    else
    {
        $ObjectRef = {};
    }
    $$ObjectRef{name} = "";
    $$Object{type}    = $OBJECT_TYPE_UNKNOWN;
    #$$ObjectRef{parameters} = [];
    $$ObjectRef{members} = []; # objects array
    $$ObjectRef{file} = -1; #index of the filename array
    $$ObjectRef{line} = -1;
    $$ObjectRef{permission} = 0; # 1:public 2:private 3:protected, 
    $$ObjectRef{parents} = []; # name of his parent
    $$ObjectRef{children} = []; # ref to all his inheritors
    
    return $ObjectRef;
}
sub AddChildren
{
    return AddHashElement("children", @_);
}
sub CleanChildren
{
    return CleanHashElement("children", @_);
}
sub GetChildren
{
    GetHashElement($_[0], "children");
}
sub AddParents
{
    return AddHashElement("parents", @_);
}
sub CleanParents
{
    return CleanHashElement("parents", @_);
}
sub GetParents
{
    GetHashElement($_[0], "parents");
}
sub SetName
{
    return AddHashElement("name", @_);
}
sub CleanName
{
    return CleanHashElement("name", @_);
}
sub GetName
{
    GetHashElement($_[0], "name");
}
sub SetPermission
{
    return AddHashElement("permission", @_);
}
sub CleanPermission
{
    return CleanHashElement("permission", @_);
}
sub GetPermission
{
    GetHashElement($_[0], "permission");
}
sub AddMembers
{
    return AddHashElement("members", @_);
}
sub CleanMembers
{
    return CleanHashElement("members", @_);
}
sub GetMembers
{
    GetHashElement($_[0], "members");
}
sub SetFile
{
    return AddHashElement("file", @_);
}
sub CleanFile
{
    return CleanHashElement("file", @_);
}
sub GetFile
{
    GetHashElement($_[0], "file");
}
sub SetLine
{
    return AddHashElement("line", @_);
}
sub CleanLine
{
    return CleanHashElement("line", @_);
}
sub GetLine
{
    GetHashElement($_[0], "line");
}
sub AddParameters
{
    return AddHashElement("parameters", @_);
}
sub CleanParameters
{
    return CleanHashElement("parameters", @_);
}
sub GetParameters
{
    GetHashElement($_[0], "parameters");
}
sub GetHashElement
{
    if(@_ < 2)
    {
        return undef;
    }
    return $$_[0]->{$$_[1]};
    
}
sub CleanHashElement
{
    if(@_ < 2)
    {
        return undef;
    }
    my $HashElement = $_[0];
    my $HashRef = $_[1];
    
    if(ref($HashRef->{$HashElement}) eq "SCALAR")
    {
        $$HashRef->{$HashElement} = "";
    }
    else if(ref($HashRef->{$HashElement}) eq "ARRAY")
    {
        $$HashRef->{$HashElement} = [];
    }
    else
    {
        return undef;
    }
    
    return $HashRef;
}

sub AddHashElement
{
    if(@_ < 3)
    {
        return undef;
    }
    my $HashElement = $_[0];
    my $HashRef = $_[1];
    my $ParamType = ref($_[2]);
    
    if(ref($HashRef->{$HashElement}) eq "SCALAR")
    {
        $$HashRef->{$HashElement} = $_[2];
    }
    else if(ref($HashRef->{$HashElement}) eq "ARRAY")
    {
        if($ParamType eq "SCALAR")
        {
            ${$HashRef->{$HashElement}}[@{$HashRef->{$HashElement}}] = $_[2];
        }
        else if($ParamType eq "ARRAY")
        {
            push @{$HashRef->{$HashElement}}, @{$_[2]};
        }
    }
    else
    {
        return undef;
    }
    
    return $HashRef;
}
"object.pm";