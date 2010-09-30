use strict;
use warnings;

use Test::More;
use Config;

my @binaries = grep { -x $_ } map { "$_/tar" } split(/$Config{path_sep}/, $ENV{PATH});
if(@binaries) {
  push @binaries, 'tar';
  plan tests => ($#binaries + 1) * 2;
} else {
  plan skip_all => "Couldn't find any tar binaries to test";
  exit(0);
}

use Devel::CheckApplicationCapabilities qw(app_is);

foreach(@binaries) {
  my $j = app_is($_, 'TarMinusJ');
  ok($j || 1,
    "$_ ".($j ? 'supports' : 'does not support')." -j");
  my $z = app_is($_, 'TarMinusZ');
  ok($z || 1,
    "$_ ".($z ? 'supports' : 'does not support')." -z");
}
