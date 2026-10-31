<?php
// Deterministic string churn: build a large array of small formatted strings,
// join them and hash the result.  crc32() is pure integer table lookup, so the
// checksum is identical on every architecture.
$name = $argv[1] ?? 'string_churn';
$count = (int) ($argv[2] ?? 200000);

$parts = [];
for ($i = 0; $i < $count; $i++) {
    $parts[] = sprintf('%08d:%d:%s', $i, ($i * 7) % 1000, ($i % 2 === 0) ? 'even' : 'odd');
}
$joined = implode('|', $parts);
$checksum = crc32($joined) + strlen($joined);
printf("RESULT scenario=%s checksum=%d\n", $name, $checksum);
