<?php
// Deterministic include/compile workload: include $count generated modules,
// call the first function of every module and fold in the size of the first
// module's array literal.  The module tree is prepared by the build stage
// (scripts/generate_modules.py) and passed through PHP_MODULES_DIR.
$name = $argv[1] ?? 'include_modules';
$count = (int) ($argv[2] ?? 1000);
$directory = getenv('PHP_MODULES_DIR');
if ($directory === false || $directory === '') {
    fwrite(STDERR, "PHP_MODULES_DIR is not set\n");
    exit(1);
}

for ($i = 1; $i <= $count; $i++) {
    include $directory . sprintf('/module_%04d.php', $i);
}

$sum = 0;
for ($i = 1; $i <= $count; $i++) {
    $function = sprintf('rich_%04d_000', $i);
    $sum += $function(7);
}
$firstArray = 'rich_' . sprintf('%04d', 1);
$sum += count($GLOBALS[$firstArray]);
printf("RESULT scenario=%s checksum=%d\n", $name, $sum);
