package Devel::AssertApplicationCapabilities::TestCanPass;

use strict;
use vars qw($VERSION);
local $^W = 1;
$VERSION = '1.0';
use base qw(Devel::AssertApplicationCapabilities::_Base);

use Config;

sub app_is {
  my $app = shift;

  Devel::CheckApplicationCapabilities::_with_STDERR_closed(sub {
    system("$Config{perlpath} $app pass") == 0
  });
}

1;
