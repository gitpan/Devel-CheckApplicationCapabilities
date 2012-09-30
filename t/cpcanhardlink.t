use strict;
use warnings;

use Test::More;
use Config;

use File::Temp qw(tempdir);

use Devel::CheckApplicationCapabilities qw(app_is);

my @binaries = grep { -x $_ } map { "$_/cp" } split(/$Config{path_sep}/, $ENV{PATH});
if(@binaries) {
  push @binaries, 'cp';
  plan tests => $#binaries + 1;
} else {
  plan skip_all => "Couldn't find any cp binaries to test";
  exit(0);
}

my $dir = tempdir();
open(my $fh, '>', "$dir/foo") ||
  die("Can't create $dir/foo to test whether -l is supported\n");
close($fh);

foreach(@binaries) {
  my $module_result = app_is($_, 'cpCanHardLink');
  my $test_result   = test_app_is($_);
  ok((
      ( $module_result && $test_result) ||
      (!$module_result && !$test_result)
  ), "test and moduleheuristics agree about $_ (it is ".($module_result ? '' : 'not')." GNU cp)");
  unlink("$dir/bar");
}

sub test_app_is {
  my $app = shift;
  Devel::CheckApplicationCapabilities::_with_STDERR_closed(sub {
    system($app, '-l', "$dir/foo", "$dir/bar");
    my $r = (stat("$dir/foo"))[1] eq (stat("$dir/bar"))[1] ? 1 : 0;
    unlink("$dir/bar");
    return $r;
  });
}
