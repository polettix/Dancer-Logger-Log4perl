# vim: filetype=perl :
use strict;
use warnings;

#use Test::More tests => 1; # last test to print
use Test::More import => ['!pass'];
BEGIN {
   eval 'use Log::Log4perl::Tiny qw( :subs )';
   plan skip_all => 'Log::Log4perl::Tiny required for basic testing' if $@;
}
#plan 'no_plan';
plan tests => 17;

use Dancer ':syntax';
use Dancer::Test;

my $logger = get_logger();
$logger->layout('[%p] %m%n');
$logger->level('DEBUG');

ok(open(my $fh, '>', \my $collector), "open()");
$logger->fh($fh);

setting log4perl => {
   tiny   => 1,
   no_init => 1,
};
setting logger => 'log4perl';

ok(get('/debug' => sub { DEBUG 'debug-whatever'; return 'whatever' }),
   'route addition');
ok(
   get(
      '/core' =>
        sub { INFO 'core-whatever'; return 'whatever' }
   ),
   'route addition'
);
ok(
   get(
      '/warning' => sub { WARN 'warning-whatever'; return 'whatever' }
   ),
   'route addition'
);
ok(get('/error' => sub { ERROR 'error-whatever'; return 'whatever' }),
   'route addition');

for my $level (qw( debug core warning error )) {
   my $route = "/$level";
   route_exists [GET => $route];
   response_content_is([GET => $route], 'whatever');
   like($collector, qr{$level-whatever}, 'log line is correct');
} ## end for my $level (qw( debug core warning error ))
