<?php
// Deterministic n-body simulation (classic Zend/benchmarks-game style load).
// Only +,-,*,/ and sqrt are used, so the result is reproducible on every
// supported glibc architecture within a tiny relative tolerance.
$name = $argv[1] ?? 'compute_nbody';
$steps = (int) ($argv[2] ?? 10000);

$pi = 3.141592653589793;
$solarMass = 4.0 * $pi * $pi;
$daysPerYear = 365.24;

$bodies = [
    [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, $solarMass],
    [
        4.84143144246472090e+00,
        -1.16032004402742839e+00,
        -1.03622044471123109e-01,
        1.66007664274403694e-03 * $daysPerYear,
        7.69901118419740425e-03 * $daysPerYear,
        -6.90460016972063023e-05 * $daysPerYear,
        9.54791938424326609e-04 * $solarMass,
    ],
    [
        8.34336671824457987e+00,
        4.12479856412430479e+00,
        -4.03523417114321381e-01,
        -2.76742510726862411e-03 * $daysPerYear,
        4.99852801234917238e-03 * $daysPerYear,
        2.30417297573763929e-05 * $daysPerYear,
        2.85885980666130812e-04 * $solarMass,
    ],
    [
        1.28943695621391310e+01,
        -1.51111514016986312e+01,
        -2.23307578892655734e-01,
        2.96460137564761618e-03 * $daysPerYear,
        2.37847173959480950e-03 * $daysPerYear,
        -2.96589568540237556e-05 * $daysPerYear,
        4.36624404335156298e-05 * $solarMass,
    ],
    [
        1.53796971148509165e+01,
        -2.59193146099879641e+01,
        1.79258772950371181e-01,
        2.68067772490389322e-03 * $daysPerYear,
        1.62824170038242295e-03 * $daysPerYear,
        -9.51592254519715870e-05 * $daysPerYear,
        5.15138902046611451e-05 * $solarMass,
    ],
];

function advance(array &$bodies, int $steps): void
{
    $n = count($bodies);
    for ($step = 0; $step < $steps; $step++) {
        for ($i = 0; $i < $n; $i++) {
            $bi = &$bodies[$i];
            for ($j = $i + 1; $j < $n; $j++) {
                $bj = &$bodies[$j];
                $dx = $bi[0] - $bj[0];
                $dy = $bi[1] - $bj[1];
                $dz = $bi[2] - $bj[2];
                $distanceSquared = $dx * $dx + $dy * $dy + $dz * $dz;
                $distance = sqrt($distanceSquared);
                $magnitude = 0.01 / ($distanceSquared * $distance);
                $dx *= $magnitude;
                $dy *= $magnitude;
                $dz *= $magnitude;
                $bi[3] -= $dx * $bj[6];
                $bi[4] -= $dy * $bj[6];
                $bi[5] -= $dz * $bj[6];
                $bj[3] += $dx * $bi[6];
                $bj[4] += $dy * $bi[6];
                $bj[5] += $dz * $bi[6];
                unset($bj);
            }
            unset($bi);
            $bodies[$i][0] += 0.01 * $bodies[$i][3];
            $bodies[$i][1] += 0.01 * $bodies[$i][4];
            $bodies[$i][2] += 0.01 * $bodies[$i][5];
        }
    }
}

function energy(array $bodies): float
{
    $e = 0.0;
    $n = count($bodies);
    for ($i = 0; $i < $n; $i++) {
        $bi = $bodies[$i];
        $e += 0.5 * $bi[6] * ($bi[3] * $bi[3] + $bi[4] * $bi[4] + $bi[5] * $bi[5]);
        for ($j = $i + 1; $j < $n; $j++) {
            $bj = $bodies[$j];
            $dx = $bi[0] - $bj[0];
            $dy = $bi[1] - $bj[1];
            $dz = $bi[2] - $bj[2];
            $e -= ($bi[6] * $bj[6]) / sqrt($dx * $dx + $dy * $dy + $dz * $dz);
        }
    }
    return $e;
}

advance($bodies, $steps);
$checksum = energy($bodies);
printf("RESULT scenario=%s checksum=%.12f\n", $name, $checksum);
