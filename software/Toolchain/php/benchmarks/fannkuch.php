<?php
// Deterministic fannkuch benchmark: enumerate every permutation with Heap's
// algorithm, count pancake flips for each and keep the maximum plus the sum of
// all flip counts.  All arithmetic is integer, so the checksum is architecture
// independent.  Heap's algorithm is used instead of the Knuth countdown so the
// enumeration is obviously complete and duplicate free.
$name = $argv[1] ?? 'compute_fannkuch';
$n = (int) ($argv[2] ?? 9);

function ip_flips(array $perm): int
{
    $flips = 0;
    while ($perm[0] !== 0) {
        $first = $perm[0];
        for ($i = 0, $j = $first; $i < $j; $i++, $j--) {
            $tmp = $perm[$i];
            $perm[$i] = $perm[$j];
            $perm[$j] = $tmp;
        }
        $flips++;
    }
    return $flips;
}

function ip_fannkuch(int $n): int
{
    $values = range(0, $n - 1);
    $counters = array_fill(0, $n, 0);
    $maxFlips = 0;
    $sumFlips = 0;

    $flips = ip_flips($values);
    $maxFlips = $flips;
    $sumFlips = $flips;

    $index = 0;
    while ($index < $n) {
        if ($counters[$index] < $index) {
            if ($index % 2 === 0) {
                $tmp = $values[0];
                $values[0] = $values[$index];
                $values[$index] = $tmp;
            } else {
                $pivot = $counters[$index];
                $tmp = $values[$pivot];
                $values[$pivot] = $values[$index];
                $values[$index] = $tmp;
            }
            $flips = ip_flips($values);
            if ($flips > $maxFlips) {
                $maxFlips = $flips;
            }
            $sumFlips += $flips;
            $counters[$index]++;
            $index = 0;
        } else {
            $counters[$index] = 0;
            $index++;
        }
    }
    // Keep both the maximum and the per-permutation sum visible.
    return $maxFlips * 1000000 + ($sumFlips % 1000000);
}

$checksum = ip_fannkuch($n);
printf("RESULT scenario=%s checksum=%d\n", $name, $checksum);
