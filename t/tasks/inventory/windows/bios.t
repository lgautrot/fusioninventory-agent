#!/usr/bin/perl

use strict;
use warnings;
use utf8;
use lib 't/lib';

use English qw(-no_match_vars);
use Test::More;
use Test::MockModule;
use Test::NoWarnings;

use FusionInventory::Test::Utils;

BEGIN {
    # use mock modules for non-available ones
    push @INC, 't/lib/fake/windows' if $OSNAME ne 'MSWin32';
}

use FusionInventory::Agent::Task::Inventory::Win32::Bios;

my %tests = (
    "20050927******.******+***" => "09/27/2005",
    "foobar" => "foobar"
);
plan tests => (scalar keys %tests) + 1;

foreach my $input (keys %tests) {
    my $result = $tests{$input};

    ok(FusionInventory::Agent::Task::Inventory::Win32::Bios::_dateFromIntString($input) eq $result, "_dateFromIntString($input)");
}
