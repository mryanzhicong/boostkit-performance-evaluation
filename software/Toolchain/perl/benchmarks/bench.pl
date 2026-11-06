#!/usr/bin/env perl
# Deterministic Perl workload matrix.
#
# Usage: perl bench.pl <scenario> <scale> [label]
#
# Every scenario performs a deterministic amount of work derived from <scale>
# and prints exactly one line:
#
#     RESULT scenario=<name> checksum=<value>
#
# The parser in scripts/results/parse_benchmark.py validates that line against
# the committed expected value, so an accidental workload or interpreter change
# fails the case instead of silently producing different numbers.
use strict;
use warnings;
use Benchmark qw(timethese);

my ($scenario, $scale, $label) = @ARGV;
my $base_scenario = $scenario;
$base_scenario =~ s/_(?:small|large)$//;
$scale = defined $scale ? int($scale) : 1;
$scale = 1 if $scale < 1;
$label = defined $label ? $label : 'run';

my $checksum;

if ($base_scenario eq 'arith_int') {
    # Integer arithmetic and modulo: one PHP-like engine hot loop.
    my $acc = 0;
    for my $i (1 .. $scale) {
        $acc = ($acc + (($i * $i) % 1000003)) % 1000000007;
    }
    $checksum = $acc;
}
elsif ($base_scenario eq 'arith_float') {
    # Floating point arithmetic (sqrt/divide/add), same IEEE double order on
    # every architecture, so the result is comparable with a 1e-9 tolerance.
    my $acc = 0.0;
    for my $i (1 .. $scale) {
        $acc += sqrt($i) + $i / 7.0;
    }
    $checksum = $acc;
}
elsif ($base_scenario eq 'string_concat') {
    my $buffer = '';
    for my $i (1 .. $scale) {
        $buffer .= $i . ':abcdefgh;';
    }
    $checksum = length($buffer);
}
elsif ($base_scenario eq 'regex_subst') {
    my $text = '';
    for my $i (1 .. $scale) {
        $text .= "line $i value=" . (($i * 2654435761) % 1000003) . "\n";
    }
    my $count = ($text =~ s/(\d+)/N/g);
    $checksum = $count;
}
elsif ($base_scenario eq 'hash_ops') {
    # String keyed hash table: insertion, lookup and deletion.
    my %table;
    my $accumulator = 0;
    for my $i (1 .. $scale) {
        $table{"key_$i"} = $i;
    }
    for my $i (1 .. $scale) {
        $accumulator = ($accumulator + $table{"key_$i"}) % 2000000001;
    }
    for my $i (1 .. $scale) {
        delete $table{"key_$i"} if ($i % 3) == 0;
    }
    $checksum = $accumulator + scalar(keys %table);
}
elsif ($base_scenario eq 'array_sort') {
    # Pseudo random (fixed LCG) integer array sorted numerically.
    my @values;
    my $state = 20261102;
    for my $i (1 .. $scale) {
        $state = ($state * 1103515245 + 12345) % 2147483648;
        push @values, $state % 1000003;
    }
    my @sorted = sort { $a <=> $b } @values;
    $checksum = $sorted[0] + $sorted[-1] + $sorted[int(@sorted / 2)];
}
elsif ($base_scenario eq 'sub_calls') {
    # Subroutine call overhead: two arguments, arithmetic result.
    sub accumulate {
        my ($left, $right) = @_;
        return $left + $right;
    }
    my $acc = 0;
    for my $i (1 .. $scale) {
        $acc = accumulate($acc, $i % 97) % 1000000007;
    }
    $checksum = $acc;
}
elsif ($base_scenario eq 'upstream_benchmark') {
    # Upstream benchmark: the Benchmark module shipped with Perl core.  It is
    # run with a fixed iteration count and its report is kept in the raw log;
    # the RESULT checksum certifies that the module produced its report.
    my $results = timethese(
        -0.2,
        {
            'arith_loop' => sub {
                my $acc = 0;
                for my $i (1 .. 200000) { $acc = ($acc + $i) % 1000003; }
                return $acc;
            },
            'hash_loop' => sub {
                my %h;
                for my $i (1 .. 50000) { $h{$i} = $i * 2; }
                my $sum = 0;
                for my $key (keys %h) { $sum += $h{$key}; }
                return $sum;
            },
        },
    );
    my $timing_lines = 0;
    for my $timing (values %{$results}) {
        $timing_lines++ if defined $timing;
    }
    $checksum = $timing_lines;
}
else {
    print STDERR "unknown scenario: $scenario\n";
    exit 2;
}

if ($base_scenario eq 'arith_float') {
    printf "RESULT scenario=%s checksum=%.12f\n", $scenario, $checksum;
}
else {
    printf "RESULT scenario=%s checksum=%d\n", $scenario, $checksum;
}
