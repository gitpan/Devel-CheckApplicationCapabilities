package Devel::AssertApplicationCapabilities::GNU;

use strict;
use vars qw($VERSION);
local $^W = 1;
$VERSION = '1.0';
use base qw(Devel::AssertApplicationCapabilities::_Base);

sub app_is {
  my $app = shift;

  Devel::CheckApplicationCapabilities::_with_STDERR_closed(sub {
    qx{$app --version} =~ /\b(gnu|free software foundation)\b/i ? 1 : 0;
  });
}

=head1 COPYRIGHT and LICENCE

Copyright 2010 David Cantrell

This software is free-as-in-speech software, and may be used, distributed, and modified under the terms of either the GNU General Public Licence version 2 or the Artistic Licence. It's up to you which one you use. The full text of the licences can be found in the files GPL2.txt and ARTISTIC.txt, respectively.

=cut

1;
