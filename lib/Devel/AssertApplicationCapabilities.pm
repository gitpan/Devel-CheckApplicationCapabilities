package Devel::AssertApplicationCapabilities;

use Devel::ApplicationCapabilities;

use strict;

use vars qw($VERSION);

$VERSION = '1.0';

# localising prevents the warningness leaking out of this module
local $^W = 1;    # use warnings is a 5.6-ism

=head1 NAME

Devel::AssertApplicationCapabilities - require that an application has
certain capabilities

=head1 DESCRIPTION

Devel::AssertApplicationCapabilities is a utility module for
Devel::CheckApplicationCapabilities and
Devel::AssertApplicationCapabilities::*.  It is nothing but a magic
C<import()> that lets you do this:

    use Devel::AssertApplicationCapabilities 'make' => qw(GNU);

which will die unless the 'make' utility is GNU make.
or Cygwin.

=cut

sub import {
    shift;
    die("Devel::AssertApplicationCapabilities needs at least two parameters\n")
      unless($#_ >= 1);
    Devel::CheckApplicationCapabilities::die_if_app_isnt(@_);
}

=head1 BUGS and FEEDBACK

I welcome feedback about my code, including constructive criticism.
Bug reports should be made using L<http://rt.cpan.org/> or by email.

If you are feeling particularly generous you can encourage me in my
open source endeavours by buying me something from my wishlist:
  L<http://www.cantrell.org.uk/david/wishlist/>

=head1 SEE ALSO

L<Devel::CheckOS>

L<Devel::CheckLib>

=head1 AUTHOR

David Cantrell E<lt>F<david@cantrell.org.uk>E<gt>

=head1 COPYRIGHT and LICENCE

Copyright 2010 David Cantrell

This software is free-as-in-speech software, and may be used, distributed, and modified under the terms of either the GNU General Public Licence version 2 or the Artistic Licence. It's up to you which one you use. The full text of the licences can be found in the files GPL2.txt and ARTISTIC.txt, respectively.

=head1 CONSPIRACY

This module is also free-as-in-mason software.

=cut

1;
