use strict;
use warnings;

use Test::More tests => 28;
use lib 't/lib';

use Devel::CheckApplicationCapabilities ':all';

ok(app_is('t/bin/pass', qw(TestCanPass)),
  "app_is works when an app matches one test (TestCanPass)");
ok(!app_is('t/bin/dothefandango', qw(TestCanPass)),
  "app_is works when an app doesn't match its one test (TestCanPass)");
ok(app_is('t/bin/dothefandango', qw(TestCanDoTheFandango)),
  "app_is works when an app matches one test (TestCanDoTheFandango)");
ok(!app_is('t/bin/pass', qw(TestCanDoTheFandango)),
  "app_is works when an app doesn't match its one test (TestCanDoTheFandango)");

ok(app_is('t/bin/pass', qw(Hlagh::TestCanPass)),
  "multi-level namespaces work (Hlagh::TestCanPass)");

# we now know that both the capability checks and the binaries are OK,
# so can move on to more complicated things

ok(!app_isnt('t/bin/pass', qw(TestCanPass)),
  "app_isnt works when an app matches one test (TestCanPass)");
ok(app_isnt('t/bin/dothefandango', qw(TestCanPass)),
  "app_isnt works when an app doesn't match its one test (TestCanPass)");
ok(!app_isnt('t/bin/dothefandango', qw(TestCanDoTheFandango)),
  "app_isnt works when an app matches one test (TestCanDoTheFandango)");
ok(app_isnt('t/bin/pass', qw(TestCanDoTheFandango)),
  "app_isnt works when an app doesn't match its one test (TestCanDoTheFandango)");

# we now know that app_isnt works for single capabilities

ok(!app_is('t/bin/pass', qw(TestCanPass TestCanDoTheFandango)),
  "app_is works when an app matches only one of multiple tests");
ok(!app_is('t/bin/pass', qw(TestCanDoTheFandango TestCanPass)),
  "... independent of order");
ok(!app_is('t/bin/neither', qw(TestCanPass TestCanDoTheFandango)),
  "app_is works when an app matches none of multiple tests");
ok(app_is('t/bin/both', qw(TestCanPass TestCanDoTheFandango)),
  "app_is works when an app matches multiple tests");

ok(app_isnt('t/bin/pass', qw(TestCanPass TestCanDoTheFandango)),
  "app_isnt works when an app matches only one of multiple tests");
ok(app_isnt('t/bin/pass', qw(TestCanDoTheFandango TestCanPass)),
  "... independent of order");
ok(app_isnt('t/bin/neither', qw(TestCanPass TestCanDoTheFandango)),
  "app_isnt works when an app matches none of multiple tests");
ok(!app_isnt('t/bin/both', qw(TestCanPass TestCanDoTheFandango)),
  "app_isnt works when an app matches multiple tests");

# now check the fatal versions ...

ok(die_if_app_isnt('t/bin/pass', qw(TestCanPass)),
  "die_if_app_isnt works when an app matches");
ok(!eval { die_if_app_isnt('t/bin/pass', qw(TestCanDoTheFandango)); 1;  },
  "die_if_app_isnt dies when an app doesn't match");
ok($@ eq "OS unsupported\n", "... with the correct message");

ok(die_if_app_is('t/bin/pass', qw(TestCanDoTheFandango)),
  "die_if_app_is works when an app doesn't match");
ok(!eval { die_if_app_is('t/bin/pass', qw(TestCanPass)); 1;  },
  "die_if_app_is dies when an app matches");
ok($@ eq "OS unsupported\n", "... with the correct message");

# and finally, list_app_checks
ok((grep { /^TestCanPass/ } list_app_checks()), "list_app_checks picks up our test modules");
ok((grep { /^Hlagh::TestCanPass/ } list_app_checks()), "list_app_checks picks up multi-level test modules");
ok(!(grep { /^_Base/ } list_app_checks()), "list_app_checks ignores _Base");

my $app_checks = list_app_checks();
ok((stat('t/lib/Devel/AssertApplicationCapabilities/Hlagh/TestCanPass.pm'))[1] == (stat($app_checks->{'Hlagh::TestCanPass'}))[1] &&
   (stat('t/lib/Devel/AssertApplicationCapabilities/Hlagh/TestCanPass.pm'))[0] == (stat($app_checks->{'Hlagh::TestCanPass'}))[0],
   "list_app_checks returns the right filenames");

sleep(3); # cos DOS has granularity of 2 seconds. This guarantees that the
          # new file will be newer than the ones we've already used
mkdir 't/morelib';
mkdir 't/morelib/Devel';
mkdir 't/morelib/Devel/AssertApplicationCapabilities';
open(my $fakemodule, '>t/morelib/Devel/AssertApplicationCapabilities/TestCanPass.pm') ||
  die("Can't create a shiny new module\n");
print $fakemodule "
  package Devel::AssertApplicationCapabilities::TestCanPass;
  use base qw(Devel::AssertApplicationCapabilities::_Base);
  sub app_is { 1 }
  1;
";
close($fakemodule);
eval 'use lib "t/morelib"';

ok(list_app_checks()->{TestCanPass} eq 't/morelib/Devel/AssertApplicationCapabilities/TestCanPass.pm',
  "list_app_checks returns the newest version of any module that it can find");
