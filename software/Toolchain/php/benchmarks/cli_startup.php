<?php
// Minimal single-process start-up workload: compiling and running this tiny
// script is the whole measured work, so the sample is dominated by CLI
// bootstrap plus one file compilation.
$name = $argv[1] ?? 'cli_startup';
echo "RESULT scenario={$name} checksum=1\n";
