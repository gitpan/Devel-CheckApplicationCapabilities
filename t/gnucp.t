use strict;
use warnings;

use Test::More;
use Config;

my @binaries = grep { -x $_ } map { "$_/cp" } split(/$Config{path_sep}/, $ENV{PATH});
if(@binaries) {
  push @binaries, 'cp';
  plan tests => $#binaries + 1;
} else {
  plan skip_all => "Couldn't find any cp binaries to test";
  exit(0);
}

use Devel::CheckApplicationCapabilities qw(app_is);
foreach(@binaries) {
  my $isgnucp = app_is($_, 'GNUcp');
  my $isgnu   = app_is($_, 'GNU');
  ok((
      ( $isgnucp &&  $isgnu) ||
      (!$isgnucp && !$isgnu)
  ), "GNUcp and GNU heuristics agree about $_ (it is ".($isgnucp ? '' : 'not')." GNU cp)");
}
