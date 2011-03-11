package Dancer::Logger::Log4perl;

# ABSTRACT: Dancer adapter for Log::Log4perl

use strict;
use Dancer::Config       ();
use Dancer::ModuleLoader ();

my $default_config = <<'END_OF_CONFIG';
log4perl.logger = INFO, Screen
log4perl.appender.Screen = Log::Log4perl::Appender::Screen
log4perl.appender.Screen.stderr = 1
log4perl.appender.Screen.stdout = 0
log4perl.appender.Screen.layout = Log::Log4perl::Layout::PatternLayout
log4perl.appender.Screen.layout.ConversionPattern = [%d] [%-5p] %m%n
END_OF_CONFIG

sub new {
   my $package = shift;
   my $conf    = Dancer::Config::setting('log4perl');
   my $class   = $conf->{tiny} ? 'Log::Log4perl::Tiny' : 'Log::Log4perl';
   Dancer::ModuleLoader->require($class) or return;
   if (!$conf->{no_init}) {
      if ($conf->{tiny}) {
         my $logger = $class->get_logger();
         for my $accessor (qw( fh level layout format )) {
            $logger->$accessor($conf->{$accessor})
              if exists $conf->{$accessor};
         }
      } ## end if ($conf->{tiny})
      else {
         my $l4p_conf =
             exists $conf->{config_file} ? $conf->{config_file}
           : exists $conf->{config}      ? \$conf->{config}
           :                               \$default_config;
         Log::Log4perl::init($l4p_conf);
      } ## end else [ if ($conf->{tiny})
   } ## end if (!$conf->{no_init})
   my $logger = $class->get_logger();
   return bless \$logger, $package;
} ## end sub new

sub core    { ${$_[0]}->info($_[1]) }
sub debug   { ${$_[0]}->debug($_[1]) }
sub warning { ${$_[0]}->warn($_[1]) }
sub error   { ${$_[0]}->error($_[1]) }

1;
__END__

=head1 SYNOPSIS

   # In your config.yml
   logger: log4perl
   log4perl:
      config_file: log4perl.conf


   # In your log4perl.conf
   log4perl.rootLogger              = DEBUG, LOG1
   log4perl.appender.LOG1           = Log::Log4perl::Appender::File
   log4perl.appender.LOG1.filename  = /var/log/mylog.log
   log4perl.appender.LOG1.mode      = append
   log4perl.appender.LOG1.layout    = Log::Log4perl::Layout::PatternLayout
   log4perl.appender.LOG1.layout.ConversionPattern = %d %p %m %n


=head1 DESCRIPTION

This class is an interface between L<Dancer>'s logging engine abstraction
layer and the L<Log::Log4perl> library. In order to use it, you have to
set the C<logger> engine to C<log4perl>.

You can use either L<Log::Log4perl> or L<Log::Log4perl::Tiny>. If you want
to use the latter, just specify the C<tiny> option in the specific
configuration.

You can decide to let the module perform the initialisation of the logging
system, or you can do it by yourself. In the latter case, you can pass
the C<no_init> parameter, which instructs the module not to perform
the initialisation.

After initialisation, you can decide to use L<Dancer>'s functions or
the ones provided by either L<Log::Log4perl> or L<Log::Log4perl::Tiny>,
e.g. the stealth loggers in case of a simplified interface.

=head1 CONFIGURATION

The configuration capabilities vary depending on the underlying library
you have.

=head2 Log::Log4perl

If you're using standard L<Log::Log4perl>, then you have two alternatives
to pass a configuration:

=over

=item *

via a configuration file, using the C<config_file> option:

   logger: log4perl
   log4perl:
      config_file: log4perl.conf

=item *

via a straight configuration text, using the C<config> option:

   logger: log4perl
   log4perl:
      config: |
         log4perl.rootLogger              = DEBUG, LOG1
         log4perl.appender.LOG1           = Log::Log4perl::Appender::File
         log4perl.appender.LOG1.filename  = /var/log/mylog.log
         log4perl.appender.LOG1.mode      = append
         log4perl.appender.LOG1.layout    = Log::Log4perl::Layout::PatternLayout
         log4perl.appender.LOG1.layout.ConversionPattern = %d %p %m %n


=back

You can also decide to perform the configuration phase by yourself, directly
inside the program. In this case, the C<no_init> option should come handy.

=head2 Log::Log4perl::Tiny

If all you have is L<Log::Log4perl::Tiny>, you can set some parameters:

=over

=item *

the log C<level>

=item *

the log C<format> (aliased to C<layout> as well)

=back

Again, you can decide to perform your own initialisation, in which case it
is adviseable to use the C<no_init> option.


=head1 INTERFACE

=head2 Logging Facilities

=over

=item B<< new >>

the object constructor.

=item B<< debug >>

=item B<< core >>

=item B<< warning >>

=item B<< error >>

The four methods that a L<Dancer> logger must have.



=back
