package PluginsDirs;

use strict;
use warnings;
use feature 'state';

use File::Find;

my @list;

sub list {
    return @list if @list;

    find sub {
        my $name = $_;
        my $path = $File::Find::name;
        my $type =
            -l $path ? 'l'
          : -f $path ? 'f'
          :            'd';
        push @list, { name => $name, path => $path, type => $type };
    }, '/app/src/plugins';

    return @list;
}

sub libs {
    state @libs;

    return @libs if @libs;

    foreach my $item (list) {
        next if $item->{type} ne 'd' || $item->{name} ne 'lib';
        next if $item->{path} !~ m/src\/lib/;
        push @libs, $item->{path};
    }
    return @libs;

}

my @cli_bins;

sub cli_bins {
    return @cli_bins if @cli_bins;

    foreach my $item(list) {
        next if $item->{type} ne 'd' || $item->{name} ne 'bin';
        next if $item->{path} =~ m/src\/bin/;
        push @cli_bins, $item->{path};
    }

    return @cli_bins;
}

my @app_bins;

sub app_bins {
    return @app_bins if @app_bins;

    foreach my $item(list) {
        next if $item->{type} ne 'd' || $item->{name} ne 'bin';
        next if $item->{path} !~ m/src\/bin/;
        push @app_bins, $item->{path};
    }

    return @app_bins;
}

sub autoload_files {
    state @autoload_files;

    return @autoload_files if @autoload_files;

    foreach my $item(list) {
        next if $item->{type} ne 'f' || $item->{name} ne 'autoload.pl';
        push @autoload_files, $item->{path};
    }

    my $first = $ENV{AUTOLOAD_FIRST} // '';
    $first =~ s/[\s\t]//g if $first;
    $first = $first ? [ map {qr/$_/} split /,/, $first ] : [qr/-website\//];

    my $last = $ENV{AUTOLOAD_LAST} // '';
    $last =~ s/[\s\t]//g if $last;
    $last = $last ? [ map {qr/$_/} split /,/, $last ] : [qr/\/theme-/];

    my @before;
    my @others;

    foreach my $check (@$first) {
        foreach my $lib (@autoload_files) {
            if ( $lib =~ m/$check/ ) {
                push @before, $lib;
            }
            else {
                push @others, $lib;
            }
        }
    }

    @autoload_files = @others;

    @others = ();

    my @after;

    foreach my $check (@$last) {
        foreach my $lib (@autoload_files) {
            if ( $lib =~ m/$check/ ) {
                push @after, $lib;
            }
            else {
                push @others, $lib;
            }
        }
    }

    @others = sort @others;

    return @autoload_files = ( @before, @others, @after );
}

push @INC, libs if $0 !~ m/^^t\//;

1;
