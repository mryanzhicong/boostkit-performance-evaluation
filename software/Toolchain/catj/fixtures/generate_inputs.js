#!/usr/bin/env node
'use strict';

/*
 * Generate the deterministic JSON fixtures used by the catj benchmark scenarios.
 *
 * The generator is intentionally free of randomness: every value is a pure
 * function of the object index, so x86_64 and aarch64 produce byte-identical
 * files.  The build stage re-computes the SHA-256 of every generated file and
 * refuses to continue when it differs from fixtures/scenarios.json.
 */

const crypto = require('crypto');
const fs = require('fs');
const path = require('path');

function parseArguments(argv) {
  const options = { scenarios: null, out: null };
  for (let index = 0; index < argv.length; index += 1) {
    const name = argv[index];
    const value = argv[index + 1];
    if (name === '--scenarios') {
      options.scenarios = value;
      index += 1;
    } else if (name === '--out') {
      options.out = value;
      index += 1;
    } else {
      throw new Error(`unsupported argument: ${name}`);
    }
  }
  if (!options.scenarios || !options.out) {
    throw new Error('usage: generate_inputs.js --scenarios <scenarios.json> --out <dir>');
  }
  return options;
}

function buildObjects(count) {
  const objects = [];
  for (let index = 0; index < count; index += 1) {
    objects.push({
      id: index,
      name: `item-${index}`,
      value: Number((((index % 17) - 8) / 4.0).toFixed(6)),
      ok: index % 2 === 0,
      tags: ['alpha', 'beta', 'gamma'],
      nested: { level: index % 7, ratio: Number((index / 7.0).toFixed(6)) },
    });
  }
  return objects;
}

function main() {
  const options = parseArguments(process.argv.slice(2));
  const spec = JSON.parse(fs.readFileSync(options.scenarios, 'utf8'));
  fs.mkdirSync(options.out, { recursive: true });
  for (const input of spec.inputs) {
    const payload = JSON.stringify(buildObjects(input.objects));
    const target = path.join(options.out, input.name);
    fs.writeFileSync(target, payload);
    const sha256 = crypto.createHash('sha256').update(payload).digest('hex');
    const bytes = Buffer.byteLength(payload);
    if (sha256 !== input.sha256 || bytes !== input.bytes) {
      throw new Error(
        `${input.name}: generated ${bytes} bytes / sha256 ${sha256}, ` +
          `expected ${input.bytes} bytes / sha256 ${input.sha256}`,
      );
    }
    process.stdout.write(
      `[catj-input] ${JSON.stringify({ name: input.name, bytes, sha256, objects: input.objects })}\n`,
    );
  }
}

try {
  main();
} catch (error) {
  process.stderr.write(`[catj-input] ERROR: ${error.message}\n`);
  process.exit(1);
}
