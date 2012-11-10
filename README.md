NAME
====

Dancer::Logger::Log4perl - Dancer adapter for Log::Log4perl

SYNOPSIS
========

In your `config.yml`

    logger: log4perl
    log4perl:
       config_file: log4perl.conf

In your `log4perl.conf`

    log4perl.rootLogger              = DEBUG, LOG1
    log4perl.appender.LOG1           = Log::Log4perl::Appender::File
    log4perl.appender.LOG1.filename  = /var/log/mylog.log
    log4perl.appender.LOG1.mode      = append
    log4perl.appender.LOG1.layout    = Log::Log4perl::Layout::PatternLayout
    log4perl.appender.LOG1.layout.ConversionPattern = %d %p %m %n


ALL THE REST
============

Want to know more? [See the module's documentation](http://search.cpan.org/perldoc?Dancer::Logger::Log4perl) to figure out
all the bells and whistles of this module!

Want to install the latest release? [Go fetch it on CPAN](http://search.cpan.org/dist/Dancer-Logger-Log4perl/).

Want to contribute? [Fork it on GitHub](https://github.com/polettix/Dancer-Logger-Log4perl).

That's all folks!

