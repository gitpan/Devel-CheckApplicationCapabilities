package Devel::AssertApplicationCapabilities::_Base;

use strict;
use vars qw($VERSION);
local $^W = 1;
use Devel::CheckApplicationCapabilities;
$VERSION = '1.0';

sub import {
  my $class = shift;
  my $app = shift;

  # can't just $class->app_is(...) later because $class isn't really a class.
  my $app_is = $class->can('app_is') ||
    die("$class doesn't implement app_is. YOU FAIL\n");

  Devel::CheckApplicationCapabilities::die_unsupported()
    unless($app_is->($app));
}

=head1 COPYRIGHT and LICENCE

Copyright 2010 David Cantrell

This software is free-as-in-speech software, and may be used, distributed, and modified under the terms of either the GNU General Public Licence version 2 or the Artistic Licence. It's up to you which one you use. The full text of the licences can be found in the files GPL2.txt and ARTISTIC.txt, respectively.

=cut

1;
