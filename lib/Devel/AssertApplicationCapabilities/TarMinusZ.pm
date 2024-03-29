package Devel::AssertApplicationCapabilities::TarMinusZ;

use strict;
use vars qw($VERSION);
local $^W = 1;
$VERSION = '1.0';
use base qw(Devel::AssertApplicationCapabilities::_Base);

use Devel::CheckApplicationCapabilities;
use File::Temp qw(tempdir);
use Cwd qw(getcwd);

local $/ = undef;
my $data = <DATA>;

sub app_is {
  my $app = shift;
  my $original_dir = getcwd();

  my $dir = tempdir();  chdir($dir);
  open(my $tempfh, '>', "foo.tgz") ||
      die("Can't create $dir/foo.tgz to test whether $app supports -z\n");
  print $tempfh $data;
  close($tempfh);

  Devel::CheckApplicationCapabilities::_with_STDERR_closed(sub {
    system($app, '-xzf', 'foo.tgz');
  }); 

  my $rval = 0;
  if(-e 'foo' && do { if(open(my $tempfh, 'foo')) { <$tempfh> } } eq 'bar') {
    $rval = 1;
  }
  unlink "$dir/foo", "$dir/foo.tbz";
  chdir($original_dir);
  rmdir $dir;
  return $rval;
}

=head1 NAME

Devel::AssertApplicationCapabilities::TarMinusZ - check that a tar binary
supports the GNU-ish -j argument, to handle bzip2'ed tarballs

=cut

=head1 BUGS/WARNINGS/LIMITATIONS

This is a heuristic.  That means that it can be wrong.  Bug reports are
most welcome, and should include the output from 'cp --version' as well
as, of course, telling me what the bug is.

The check is actually whether 'cp -al blah/foo blah/bar' results in two
files with the same inode number, as well as whether cp looks GNU-ish.

=head1 SEE ALSO

L<Devel::AssertApplicationCapabilities::GNU>

=head1 SOURCE CODE REPOSITORY

L<git://github.com/DrHyde/perl-modules-Devel-CheckApplicationCapabilities.git>

=head1 AUTHOR, COPYRIGHT and LICENCE

Copyright 2010 David Cantrell <david@cantrell.org.uk>

This software is free-as-in-speech software, and may be used,
distributed, and modified under the terms of either the GNU
General Public Licence version 2 or the Artistic Licence.  It's
up to you which one you use.  The full text of the licences can
be found in the files GPL2.txt and ARTISTIC.txt, respectively.

=head1 CONSPIRACY

This module is also free-as-in-mason software.

=cut

1;
__DATA__
� �O�L ��;� �a��]�<Bbe����-L�����f�����7)�j�)��2���s�~�)��w�U���ˊs?�f�I�Z�C��r�bз��=             ����f^ (  
