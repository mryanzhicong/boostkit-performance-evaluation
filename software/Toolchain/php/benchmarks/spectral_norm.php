<?php
// Deterministic spectral-norm solver (classic Zend/benchmarks-game style load).
// Uses only +,-,*,/,sqrt, so the checksum is reproducible within a tiny
// relative tolerance across glibc architectures.
$name = $argv[1] ?? 'compute_spectral_norm';
$n = (int) ($argv[2] ?? 100);

function a(int $i, int $j): float
{
    return 1.0 / ((($i + $j) * ($i + $j + 1) >> 1) + $i + 1);
}

function multiplyAv(array $v, int $n): array
{
    $out = array_fill(0, $n, 0.0);
    for ($i = 0; $i < $n; $i++) {
        $sum = 0.0;
        for ($j = 0; $j < $n; $j++) {
            $sum += a($i, $j) * $v[$j];
        }
        $out[$i] = $sum;
    }
    return $out;
}

function multiplyAtv(array $v, int $n): array
{
    $out = array_fill(0, $n, 0.0);
    for ($i = 0; $i < $n; $i++) {
        $sum = 0.0;
        for ($j = 0; $j < $n; $j++) {
            $sum += a($j, $i) * $v[$j];
        }
        $out[$i] = $sum;
    }
    return $out;
}

function multiplyAtAv(array $v, int $n): array
{
    return multiplyAtv(multiplyAv($v, $n), $n);
}

$u = array_fill(0, $n, 1.0);
for ($i = 0; $i < 10; $i++) {
    $v = multiplyAtAv($u, $n);
    $u = multiplyAtAv($v, $n);
}
$vBv = 0.0;
$vv = 0.0;
for ($i = 0; $i < $n; $i++) {
    $vBv += $u[$i] * $v[$i];
    $vv += $v[$i] * $v[$i];
}
$checksum = sqrt($vBv / $vv);
printf("RESULT scenario=%s checksum=%.12f\n", $name, $checksum);
