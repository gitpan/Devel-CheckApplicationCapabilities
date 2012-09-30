package Devel::AssertApplicationCapabilities::GNUcp;

use strict;
use vars qw($VERSION);
local $^W = 1;
$VERSION = '1.01';
use base qw(Devel::AssertApplicationCapabilities::_Base);

use Devel::AssertApplicationCapabilities::GNU;

sub app_is {
  return 0 unless($_[0] =~ /\bcp(\.(exe|com))$/);
  return Devel::AssertApplicationCapabilities::GNU::app_is(@_);
}

=head1 NAME

Devel::AssertApplicationCapabilities::GNUcp - check that a binary is GNU cp

=cut

=head1 BUGS/WARNINGS/LIMITATIONS

This is a wrapper around Devel::AssertApplicationCapabilities::GNUcp
that also checks that the binary is called 'cp'.  It exists solely
for backward compatibility reasons.  The old check whether it supports
the -al argument is now, correctly, in ...::cpSupportsMinusal.

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
