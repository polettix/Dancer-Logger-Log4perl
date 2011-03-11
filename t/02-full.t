# vim: filetype=perl :
use strict;
use warnings;

#use Test::More tests => 1; # last test to print
use Test::More import => ['!pass'];
eval 'use Log::Log4perl';
plan skip_all => 'Log::Log4perl required for full testing' if $@;
#plan 'no_plan';
plan tests => 17;

use Dancer ':syntax';
use Dancer::Test;

my $logfile = __FILE__ . '.log';

setting log4perl => {
   tiny   => 0,
   config => "
log4perl.rootLogger              = DEBUG, LOG1
log4perl.appender.LOG1           = Log::Log4perl::Appender::File
log4perl.appender.LOG1.filename  = $logfile
log4perl.appender.LOG1.mode      = append
log4perl.appender.LOG1.layout    = Log::Log4perl::Layout::PatternLayout
log4perl.appender.LOG1.layout.ConversionPattern = %d %p %m %n
   ",
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

for my $level (qw( debug core warning error )) {
   my $route = "/$level";
   route_exists [GET => $route];
   response_content_is([GET => $route], 'whatever');
} ## end for my $level (qw( debug core warning error ))

my $collector = do {
   local (@ARGV, $/) = ($logfile);
   <>;
};

for my $level (qw( debug core warning error )) {
   like($collector, qr{$level-whatever}, 'log line is correct');
}

ok(unlink($logfile), 'unlinking log file');
