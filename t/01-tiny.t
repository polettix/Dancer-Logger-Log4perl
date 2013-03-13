# vim: filetype=perl :
use strict;
use warnings;

#use Test::More tests => 1; # last test to print
use Test::More import => ['!pass'];
eval 'use Log::Log4perl::Tiny';
plan skip_all => 'Log::Log4perl::Tiny required for basic testing' if $@;
# plan 'no_plan';
plan tests => 21;

use Dancer ':syntax';
use Dancer::Test;

ok(open(my $fh, '>', \my $collector), "open()");

setting log4perl => {
   tiny   => 1,
   fh     => $fh,
   layout => '[%p] %m%n',
   level => 'TRACE',
};
setting logger => 'log4perl';

ok(get('/debug' => sub { debug 'debug-whatever'; return 'whatever' }),
   'route addition');
ok(
   get(
      '/core' =>
        sub { Dancer::Logger::core 'core-whatever'; return 'whatever' }
   ),
   'route addition'
);
ok(
   get(
      '/warning' => sub { warning 'warning-whatever'; return 'whatever' }
   ),
   'route addition'
);
ok(get('/error' => sub { error 'error-whatever'; return 'whatever' }),
   'route addition');
ok(get('/info' => sub { info 'info-whatever'; return 'whatever' }),
   'route addition');

for my $level (qw( debug core warning error info )) {
   my $route = "/$level";
   route_exists [GET => $route];
   response_content_is([GET => $route], 'whatever');
   like($collector, qr{$level-whatever}, 'log line is correct');
} ## end for my $level (qw( debug core warning error ))
