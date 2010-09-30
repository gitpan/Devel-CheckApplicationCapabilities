package Devel::AssertApplicationCapabilities::GNUcp;

use strict;
use vars qw($VERSION);
local $^W = 1;
$VERSION = '1.0';
use base qw(Devel::AssertApplicationCapabilities::_Base);

use Devel::CheckApplicationCapabilities;
use File::Temp qw(tempdir);

sub app_is {
  my $app = shift;

  my $dir = tempdir();
  open(TEMPFILE, '>', "$dir/foo") ||
      die("Can't create $dir/foo to test whether $app supports -al\n");
  print TEMPFILE "Testing";
  close(TEMPFILE);

  Devel::CheckApplicationCapabilities::_with_STDERR_closed(sub {
    system($app, '-al', "$dir/foo", "$dir/bar");
  });

  my $rval = 0;
  if(-e "$dir/bar" && ((stat("$dir/foo"))[1] == (stat("$dir/bar"))[1])) { # same inode
      $rval = 1;
  }
  unlink "$dir/foo", "$dir/bar";
  rmdir $dir;
  return $rval;
}

=head1 NAME

Devel::AssertApplicationCapabilities::GNUcp - check that a binary is GNU cp

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

L<http://www.cantrell.org.uk/cgit/cgit.cgi/perlmodules/>

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
