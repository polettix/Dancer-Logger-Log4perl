package Dancer::Logger::Log4perl;

# ABSTRACT: Dancer adapter for Log::Log4perl

use strict;
use Dancer::Config       ();
use Dancer::ModuleLoader ();

my $default_config = <<'END_OF_CONFIG';
log4perl.logger = TRACE, Screen
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

sub core    { ${$_[0]}->trace($_[1]) }
sub info    { ${$_[0]}->info($_[1]) }
sub debug   { ${$_[0]}->debug($_[1]) }
sub warning { ${$_[0]}->warn($_[1]) }
sub error   { ${$_[0]}->error($_[1]) }

1;
__END__

=head1 SYNOPSIS

In your config.yml

   logger: log4perl
   log4perl:
      config_file: log4perl.conf

In your log4perl.conf

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
you have, even though the following configurations are common:

=over

=item B<< no_init >>

skip the initialisation phase of the logging module, assuming that it
is performed elsewhere.

=item B<< tiny >>

allows you to decide whether L<Log::Log4perl> (when set to a false value) or
L<Log::Log4perl::Tiny> (when set to a true value) should be used.

=back

=head2 Log::Log4perl

If you're using standard L<Log::Log4perl>, then you have two alternatives
to pass a configuration:

=over

=item B<< config_file >>

via a configuration file, using the C<config_file> option:

   logger: log4perl
   log4perl:
      config_file: log4perl.conf

=item B<< config >>

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


=head2 Log::Log4perl::Tiny

If all you have is L<Log::Log4perl::Tiny>, you can set some parameters:

=over

=item B<< level >>

the log C<level>

   logger: log4perl
   log4perl:
      tiny: 1
      level: INFO

=item B<< format >>

the log C<format> (aliased to C<layout> as well)

   logger: log4perl
   log4perl:
      tiny: 1
      format: [%p] %m%n

=back

=begin hideme

=over

=item B<< new >>

=item B<< debug >>

=item B<< core >>

=item B<< warning >>

=item B<< error >>

=back

=end hideme

=head1 EXAMPLES

All examples below assume that you have your L<Log::Log4perl> initialisation
stuff inside a file called F<log4perl.conf>, e.g. something along the
following lines:

   log4perl.logger = INFO, Screen
   log4perl.appender.Screen = Log::Log4perl::Appender::Screen
   log4perl.appender.Screen.stderr = 1
   log4perl.appender.Screen.stdout = 0
   log4perl.appender.Screen.layout = Log::Log4perl::Layout::PatternLayout
   log4perl.appender.Screen.layout.ConversionPattern = [%d] [%-5p] %m%n

The above initialisation text is actually what you get by default.

=head2 Log::Log4perl, Automatic Initialisation, Dancer Logging Interface

In this case you'll probably want to let the module handle the initialisation
and forget about L<Log::Log4perl> in your code. In the L<Dancer> configuration
file:

   # config.yml
   logger: log4perl
   log4perl:
      config_file: log4perl.conf

In your code:

   # somewhere...
   get '/please/warn' => sub {
      warning "ouch!"; # good ol' Dancer warning
      return ':-)';
   };


=head2 Log::Log4perl, Manual Initialisation, Log::Log4perl Stealth Interface

If you want to use L<Log::Log4perl>'s stealth interface, chances are you
also want to avoid a full configuration file and rely upon C<easy_init()>.
In this case, you will probably want to perform the initialisation by your
own, so your configuration file will be bare bones:

   # config.yml
   logger: log4perl
   log4perl:
      no_init: 1

and your code will contain all the meat:

   use Log::Log4perl qw( :easy );
   Log::Log4perl->easy_init($INFO);
   get '/please/warn' => sub {
      WARN 'ouch!'; # Log::Log4perl way of warning
      return ';-)';
   };


=head2 Log::Log4perl, Whatever Initialisation, Whatever Interface

Whatever the method you use to initialise the logger (but take care to
initialise it once and only once, see L<Log::Log4perl>), you can always
use both L<Dancer> and L<Log::Log4perl> functions:

   use Log::Log4perl qw( :easy );
   get '/please/warn/2/times' => sub {
      warning 'ouch!'; # Dancer style
      WARN    'OUCH!'; # Log::Log4perl style
      return ':-D';
   };

If you don't like either functional interface, and prefer to stick to
L<Log::Log4perl>'s object-oriented interface to avoid collisions in
function names:

   use Log::Log4perl ();
   get '/please/warn/2/times' => sub {
      get_logger()->warn('ouch!'); # Log::Log4perl, OO way
      return 'B-)';
   };

Well, you get the idea... just peruse L<Log::Log4perl> documentation for
more!

=head2 Log::Log4perl::Tiny, Automatic Initialisation, Any Interface

If you prefer to use L<Log::Log4perl::Tiny> you can put the relevant
options directly inside the configuration file:

   # config.yml
   logger: log4perl
   log4perl:
      tiny: 1
      level: DEBUG
      format:  [%p] %m%n

At this point, you can import the relevant methods in your code and use
them as you would with L<Log::Log4perl>:

   use Log::Log4perl::Tiny qw( :easy );
   get '/please/warn' => sub {
      WARN 'ouch!'; # Log::Log4perl(::Tiny) way of warning
      # you can also use Dancer's warning here...
      warning 'OUCH!';
      return ';-)';
   };

=head2 Log::Log4perl::Tiny, Any Initialisation, Any Interface

As an alternative to the previous example, you can also limit the
configuration file to a minimum:

   # config.yml
   logger: log4perl
   log4perl:
      tiny: 1

and initialise the logging library inside the code:

   use Log::Log4perl::Tiny qw( :easy );
   Log::Log4perl->easy_init($INFO);
   get '/please/warn' => sub {
      WARN 'ouch!'; # Log::Log4perl(::Tiny) way of warning
      # you can also use Dancer's warning here...
      warning 'OUCH!';
      return ';-)';
   };


=head1 SUPPORT

If you find a bug, have a comment or (constructive) criticism you have
different options:

=over

=item -

just write to the L</AUTHOR>

=item -

open a bug request on the relevant RT queue at
https://rt.cpan.org/Public/Dist/Display.html?Name=Dancer-Logger-Log4perl

=item -

open an issue or propose a patch on GitHub at
https://github.com/polettix/Dancer-Logger-Log4perl

=back
