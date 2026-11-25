#!/usr/bin/env node
'use strict';

/*
 * Execute one bcrypt scenario in a fresh Node.js process.
 *
 * The salt (and the reference hash for the compare scenarios) is created before
 * the timed window, exactly like the release manual describes.  Every operation
 * is timed individually with process.hrtime.bigint(), so the per-operation cost
 * excludes process start-up and salt generation.  The correctness gate requires
 * every compare to return true and, for the hash scenarios, verifies the last
 * produced hash once more outside the timed window.
 */

const fs = require('fs');
const path = require('path');

const ENVIRONMENT_PREFIX = '[bcrypt-env] ';
const EVIDENCE_PREFIX = '[bcrypt-bench] ';

function parseArguments(argv) {
  const options = { scenarios: null, scenario: null, mode: null, moduleDir: null };
  for (let index = 0; index < argv.length; index += 1) {
    const name = argv[index];
    const value = argv[index + 1];
    if (name === '--scenarios') {
      options.scenarios = value;
      index += 1;
    } else if (name === '--scenario') {
      options.scenario = value;
      index += 1;
    } else if (name === '--mode') {
      options.mode = value;
      index += 1;
    } else if (name === '--module-dir') {
      options.moduleDir = value;
      index += 1;
    } else {
      throw new Error(`unsupported argument: ${name}`);
    }
  }
  if (!options.scenarios || !options.scenario || !options.mode || !options.moduleDir) {
    throw new Error(
      'usage: bcrypt_runner.js --scenarios <file> --scenario <id> --mode <prefetch|measure> --module-dir <dir>',
    );
  }
  if (!['prefetch', 'measure'].includes(options.mode)) {
    throw new Error(`invalid mode: ${options.mode}`);
  }
  return options;
}

function loadScenario(scenariosPath, scenarioId) {
  const payload = JSON.parse(fs.readFileSync(scenariosPath, 'utf8'));
  const scenario = payload.scenarios.find((item) => item.id === scenarioId);
  if (!scenario) {
    throw new Error(`unknown scenario: ${scenarioId}`);
  }
  return { payload, scenario };
}

function peakRssMib() {
  try {
    const status = fs.readFileSync('/proc/self/status', 'utf8');
    const match = status.match(/^VmHWM:\s+(\d+)\s+kB$/m);
    if (match) {
      return Number(match[1]) / 1024.0;
    }
  } catch (error) {
    /* fall through */
  }
  return process.memoryUsage.rss() / (1024.0 * 1024.0);
}

function elapsedSeconds(started) {
  return Number(process.hrtime.bigint() - started) / 1e9;
}

async function timedOperation(bcrypt, scenario, password, salt, referenceHash) {
  if (scenario.op === 'hash') {
    if (scenario.api === 'sync') {
      return bcrypt.hashSync(password, salt);
    }
    return bcrypt.hash(password, salt);
  }
  if (scenario.api === 'sync') {
    return bcrypt.compareSync(password, referenceHash);
  }
  return bcrypt.compare(password, referenceHash);
}

async function main() {
  const options = parseArguments(process.argv.slice(2));
  const { payload, scenario } = loadScenario(options.scenarios, options.scenario);
  const bcrypt = require(path.join(options.moduleDir, 'bcrypt'));
  const password = payload.password;
  const operations = Number(scenario.ops);

  const environment = {
    node: process.versions.node,
    bcrypt: require(path.join(options.moduleDir, 'bcrypt', 'package.json')).version,
    napi: process.versions.napi || null,
    mode: options.mode,
  };

  const saltStarted = process.hrtime.bigint();
  const salt = bcrypt.genSaltSync(Number(scenario.cost));
  const saltSeconds = elapsedSeconds(saltStarted);
  let referenceHash = null;
  let referenceSeconds = 0;
  if (scenario.op === 'compare') {
    const referenceStarted = process.hrtime.bigint();
    referenceHash = bcrypt.hashSync(password, salt);
    referenceSeconds = elapsedSeconds(referenceStarted);
  }

  const warmupStarted = process.hrtime.bigint();
  await timedOperation(bcrypt, scenario, password, salt, referenceHash);
  const warmupSeconds = elapsedSeconds(warmupStarted);

  const perOperation = [];
  let lastHash = null;
  const batchStarted = process.hrtime.bigint();
  for (let index = 0; index < operations; index += 1) {
    const started = process.hrtime.bigint();
    const result = await timedOperation(bcrypt, scenario, password, salt, referenceHash);
    const seconds = elapsedSeconds(started);
    perOperation.push(seconds);
    if (scenario.op === 'hash') {
      lastHash = result;
    }
    if (scenario.op === 'compare' && result !== true) {
      throw new Error(`compare returned ${result} instead of true`);
    }
  }
  const batchSeconds = elapsedSeconds(batchStarted);

  let correctnessDetail;
  if (scenario.op === 'hash') {
    const verified = lastHash !== null && bcrypt.compareSync(password, lastHash);
    correctnessDetail = verified
      ? 'every hash comparison against the produced hash returned true'
      : 'produced hash did not verify';
    if (!verified) {
      throw new Error(correctnessDetail);
    }
  } else {
    correctnessDetail = `all ${operations} comparisons returned true`;
  }

  const totalSeconds = perOperation.reduce((total, value) => total + value, 0);
  const evidence = {
    scenario: scenario.id,
    op: scenario.op,
    api: scenario.api,
    cost: Number(scenario.cost),
    ops: operations,
    mode: options.mode,
    salt_seconds: Number(saltSeconds.toFixed(9)),
    reference_hash_seconds: Number(referenceSeconds.toFixed(9)),
    warmup_seconds: Number(warmupSeconds.toFixed(9)),
    batch_seconds: Number(batchSeconds.toFixed(9)),
    per_operation_seconds: perOperation.map((value) => Number(value.toFixed(9))),
    total_seconds: Number(totalSeconds.toFixed(9)),
    ms_per_op: Number(((totalSeconds / operations) * 1000).toFixed(6)),
    ops_per_second: Number((operations / totalSeconds).toFixed(6)),
    max_rss_mib: Number(peakRssMib().toFixed(3)),
    correctness: { ok: true, detail: correctnessDetail },
  };
  process.stdout.write(`${ENVIRONMENT_PREFIX}${JSON.stringify(environment)}\n`);
  process.stdout.write(`${EVIDENCE_PREFIX}${JSON.stringify(evidence)}\n`);
}

main().catch((error) => {
  process.stderr.write(`[bcrypt-bench] ERROR: ${error.message}\n`);
  process.exit(1);
});
