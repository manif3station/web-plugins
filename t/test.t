use strict;
use Test::More;
use lib 'src/lib';
use PluginsDirs;

local *PluginsDirs::list = sub {
    (
        { path => 'src/plugins/a/lib', name => 'lib', type => 'd' },
        {
            path => 'src/plugins/a/lib/ABC.pm',
            name => 'ABC.pm',
            type => 'f'
        },
        { path => 'src/plugins/a/src/lib', name => 'lib', type => 'd' },
        {
            path => 'src/plugins/a/src/lib/DEF.pm',
            name => 'DEF.pm',
            type => 'f'
        },
        { path => 'src/plugins/b/bin',     name => 'bin', type => 'd' },
        { path => 'src/plugins/b/src/lib', name => 'lib', type => 'd' },
        { path => 'src/plugins/c/src/bin', name => 'bin', type => 'd' },
        { path => 'src/plugins/c/bin',     name => 'bin', type => 'd' },
        {
            path => 'src/plugins/c/bin/autoload.pl',
            name => 'autoload.pl',
            type => 'f'
        },
    )
};

subtest libs => sub {
    my @got = PluginsDirs->libs;

    is_deeply \@got, [
        qw(
          src/plugins/a/src/lib
          src/plugins/b/src/lib
        )
    ];
};

subtest cli_bins => sub {
    my @got = PluginsDirs->cli_bins;

    is_deeply \@got, [
        qw(
          src/plugins/b/bin
          src/plugins/c/bin
        )
    ];
};

subtest app_bins => sub {
    my @got = PluginsDirs->app_bins;

    is_deeply \@got, [
        qw(
          src/plugins/c/src/bin
        )
    ];
};

subtest autoload_files => sub {
    my @got = PluginsDirs->autoload_files;

    is_deeply \@got, [
        qw(
          src/plugins/c/bin/autoload.pl
        )
    ];
};

done_testing;
