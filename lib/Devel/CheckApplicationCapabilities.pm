package Devel::CheckApplicationCapabilities;

use strict;
use Exporter;
use Config;
use File::Spec;
use Cwd;

use vars qw($VERSION @ISA @EXPORT_OK %EXPORT_TAGS);

$VERSION = '1.0';

# localising prevents the warningness leaking out of this module
local $^W = 1;    # use warnings is a 5.6-ism

@ISA = qw(Exporter);
@EXPORT_OK = qw(
  app_is app_isnt
  die_if_app_is die_if_app_isnt
  die_unsupported
  list_app_checks
);
%EXPORT_TAGS = (
    all      => \@EXPORT_OK,
    booleans => [qw(app_is app_isnt die_unsupported)],
    fatal    => [qw(die_if_app_is die_if_app_isnt)]
);

=head1 NAME

Devel::CheckApplicationCapabilities - check what an external application
is capable of.

=head1 DESCRIPTION

Devel::CheckApplicationCapabilities provides a nice user-friendly interface
to back-end modules for doing things like checking whether tar(1) supports
the -z argument and so can be expected to support .tar.gz files.

=head1 SYNOPSIS

    use Devel::CheckApplicationCapabilities qw(app_is);
    print "Yay, I can gzip!\n"
      if(app_is('tar' => qw(TarMinusZ)));
    print "Yay, I can bzip too!\n"
      if(app_is('tar' => qw(TarMinusJ TarMinusZ)));

=head1 USING IT IN Makefile.PL or Build.PL

If you want to use this from Makefile.PL or Build.PL, do
not simply copy the module into your distribution as this may cause
problems when PAUSE and search.cpan.org index the distro.  Instead, use
the use-devel-assertos script.

=head1 FUNCTIONS

Devel::CheckApplicationCapabilities implements the following functions, which load subsidiary
modules on demand to do the real work.  They can be exported
by listing their names after C<use Devel::CheckApplicationCapabilities>.  You can also export
groups of functions thus:

    use Devel::CheckApplicationCapabilities qw(:booleans); # export the boolean functions
                                      # and 'die_unsupported'
    
    use Devel::CheckApplicationCapabilities qw(:fatal);    # export those that die on no match

    use Devel::CheckApplicationCapabilities qw(:all);      # export everything

=head2 Boolean functions

=head3 app_is

Takes an application name and a list of capabilities and returns true
if the application has all the capabilities, false otherwise.  The
application can be
specified as a relative path, a full path, or with no path at all in
which case C<$ENV{PATH}> will be searched.

Each capability corresponds to a
Devel::AssertApplicationCapabilities::whatever module.

=cut

# look in $PATH for $app
sub _find_app {
  my $app = shift;
  return $app if(-f $app);

  foreach my $path (split(/$Config{path_sep}/, $ENV{PATH})) {
    return File::Spec->catfile($path, $app) if(-f File::Spec->catfile($path, $app))
  }
  return $app;
}

sub app_is {
  my $app = shift;
  $app = _find_app($app);
  die("Devel::CheckApplicationCapabilities: $app doesn't exist\n")
    unless(-f $app);

  my @targets = @_;
  my $rval = 1;
  foreach my $target (@targets) {
    die("Devel::CheckApplicationCapabilities: $target isn't a legal capability name\n")
      unless($target =~ /^\w+(::\w+)*$/);
    eval "use Devel::AssertApplicationCapabilities::$target '$app'";
    $rval = 0 if($@);
  }
  return $rval;
}

=head3 app_isnt

Exactly the same as C<app_is>, except that it returns true if the
app does not have all the capabilities, otherwise it returns false.

=cut

sub app_isnt {
    my $app = shift;
    my @targets = @_;
    app_is($app, @targets) ? 0 : 1;
}

=head2 Fatal functions

=head3 die_if_app_isnt

As C<app_is()>, except that it dies instead of returning false.  The die()
message matches what the CPAN-testers look for to determine if a module
doesn't support a particular platform.

=cut

sub die_if_app_isnt {
    app_is(@_) ? 1 : die_unsupported();
}

=head3 die_if_app_is

As C<app_isnt()>, except that it dies instead of returning false.

=cut

sub die_if_app_is {
    app_isnt(@_) ? 1 : die_unsupported();
}

=head2 And some utility functions ...

=head3 die_unsupported

This function simply dies with the message "OS unsupported", which is what
the CPAN testers look for to figure out whether a platform is supported or
not.  Yes, it says "OS", not "application".  Sorry, that's just the way
things are.

=cut

sub die_unsupported { die("OS unsupported\n"); }

# takes a subref as its argument.  It temporarily closes
# STDERR, runs the subref, then restores STDERR.
sub _with_STDERR_closed {
  open(my $REALSTDERR, ">&STDERR") || die("Can't dup STDERR\n");
  close(STDERR);

  my $rval = shift->();

  open(STDERR, '>&', $REALSTDERR) || die("Can't dup saved STDERR\n");
  return $rval;
}

=head3 list_app_checks

When called in list context,
return a list of all the capabilities that can be checked, or
Devel::AssertApplicationCapabilities::* modules that are available.
That includes both those bundled with this module and any third-party
add-ons you have installed.

In scalar context, returns a hashref keyed by capability with the filename
of the most recent version of the supporting module that is available to you.

Unfortunately, on some platforms this list may have file case
broken.  eg, some platforms might return 'gnu' instead of 'GNU'.
This is because they have case-insensitive filesystems so things
should Just Work anyway.

=cut

my ($re_Devel, $re_AssertApplicationCapabilities);
sub list_app_checks {
    eval " # only load these if needed
        use File::Find::Rule;
        use File::Spec;
    ";
    
    die($@) if($@);
    if (!$re_Devel) {
        my $case_flag = File::Spec->case_tolerant ? '(?i)' : '';
        $re_Devel    = qr/$case_flag ^Devel$/x;
        $re_AssertApplicationCapabilities = qr/$case_flag ^AssertApplicationCapabilities$/x;
    }

    # sort by mtime, so oldest last
    my @modules = sort {
        (stat($a->{file}))[9] <=> (stat($b->{file}))[9]
    } map {
        my (undef, $dir_part, $file_part) = File::Spec->splitpath($_);
        $file_part =~ s/\.pm$//;
        my (@dirs) = grep {+length} File::Spec->splitdir($dir_part);
        foreach my $i (reverse 1..$#dirs) {
            next unless $dirs[$i] =~ $re_AssertApplicationCapabilities
                && $dirs[$i - 1] =~ $re_Devel;
            splice @dirs, 0, $i + 1;
            last;
        }
        {
            module => join('::', @dirs, $file_part),
            file   => File::Spec->canonpath($_)
        }
    } File::Find::Rule->file()->not(File::Find::Rule->name('_*'))->name('*.pm')->in(
        grep { -d }
        map { File::Spec->catdir($_, qw(Devel AssertApplicationCapabilities)) }
        @INC
    );

    my %modules = map {
        $_->{module} => $_->{file}
    } @modules;

    if(wantarray()) {
        return sort keys %modules;
    } else {
        return \%modules;
    }
}

=head1 CAPABILITIES SUPPORTED

To see the list of capabilities for which information is available, run this:

    perl -MDevel::CheckApplicationCapabilities=:all -le 'print join(", ", list_app_checks())'

Note that capitalisation is important.  These are the names of the
underlying Devel::AssertApplicationCapabilities::* modules
which do the actual platform detection, so they have to
be 'legal' filenames and module names, which unfortunately precludes
funny characters, so we check for 'tar -z' with 'TarMinusZ'.
Sorry.

If you want to add your own OSes or families, see L<Devel::AssertApplicationCapabilities::Extending>
and please feel free to upload the results to the CPAN.

=head1 BUGS and FEEDBACK

I welcome feedback about my code, including constructive criticism.
Bug reports should be made using L<http://rt.cpan.org/> or by email.

If you are feeling particularly generous you can encourage me in my
open source endeavours by buying me something from my wishlist:
  L<http://www.cantrell.org.uk/david/wishlist/>

=head1 SEE ALSO

L<Devel::AssertApplicationCapabilities::Extending>

L<Devel::CheckOS>

L<Devel::CheckLib>

=head1 AUTHOR

David Cantrell E<lt>F<david@cantrell.org.uk>E<gt>

=head1 SOURCE CODE REPOSITORY

L<http://www.cantrell.org.uk/cgit/cgit.cgi/perlmodules/>

=head1 COPYRIGHT and LICENCE

Copyright 2010 David Cantrell

This software is free-as-in-speech software, and may be used, distributed, and modified under the terms of either the GNU General Public Licence version 2 or the Artistic Licence. It's up to you which one you use. The full text of the licences can be found in the files GPL2.txt and ARTISTIC.txt, respectively.

=head1 TWEED

I recommend buying splendiferous cloth from <http://www.dashingtweeds.co.uk/>, especially from their "lumatwill" range.

=head1 CONSPIRACY

This module is also free-as-in-mason software.

=cut

1;
