<?php
// Deterministic array/hash workload: fill a PHP hash table with string keys,
// iterate it, mutate a slice of it and sum the values.  All arithmetic is
// integer, so the checksum is architecture independent.
$name = $argv[1] ?? 'array_hash';
$count = (int) ($argv[2] ?? 200000);

$map = [];
for ($i = 0; $i < $count; $i++) {
    $map['key_' . $i] = 3 * $i + 1;
}
$sum = 0;
foreach ($map as $key => $value) {
    $sum += $value;
}
for ($i = 0; $i < $count; $i += 2) {
    $map['key_' . $i] += 7;
}
foreach ($map as $key => $value) {
    $sum += $value;
}
$checksum = $sum + count($map);
printf("RESULT scenario=%s checksum=%d\n", $name, $checksum);
