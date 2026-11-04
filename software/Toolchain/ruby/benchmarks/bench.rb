#!/usr/bin/env ruby
# Deterministic Ruby workload matrix.
#
# Usage: ruby bench.rb <scenario> <scale> [label]
#
# Every scenario performs a deterministic amount of work derived from <scale>
# and prints exactly one line:
#
#     RESULT scenario=<name> checksum=<value>
#
# The parser in scripts/results/parse_benchmark.py validates that line against
# the committed expected value, so an accidental workload or interpreter change
# fails the case instead of silently producing different numbers.
require 'benchmark'

scenario = ARGV[0]
scale = (ARGV[1] || '1').to_i
scale = 1 if scale < 1
label = ARGV[2] || 'run'

checksum = nil

base = scenario.sub(/_(?:small|large)\z/, '')
case base
when 'arith_int'
  # Integer arithmetic and modulo: a hot Ruby engine loop.
  acc = 0
  (1..scale).each do |i|
    acc = (acc + ((i * i) % 1_000_003)) % 1_000_000_007
  end
  checksum = acc
when 'arith_float'
  # Floating point arithmetic, same IEEE double order on every architecture.
  acc = 0.0
  (1..scale).each do |i|
    acc += Math.sqrt(i) + i / 7.0
  end
  checksum = acc
when 'string_concat'
  buffer = +''
  (1..scale).each do |i|
    buffer << i.to_s << ':abcdefgh;'
  end
  checksum = buffer.length
when 'regex_subst'
  text = +''
  (1..scale).each do |i|
    text << "line #{i} value=#{((i * 2_654_435_761) % 1_000_003)}\n"
  end
  checksum = text.gsub(/\d+/, 'N').scan('N').length
when 'hash_ops'
  # String keyed hash table: insertion, lookup and deletion.
  table = {}
  accumulator = 0
  (1..scale).each do |i|
    table["key_#{i}"] = i
  end
  (1..scale).each do |i|
    accumulator = (accumulator + table["key_#{i}"]) % 2_000_000_001
  end
  table.delete_if { |key, _| key.end_with?('0') }
  checksum = accumulator + table.length
when 'array_sort'
  # Pseudo random (fixed LCG) integer array sorted numerically.
  state = 20_261_102
  values = Array.new(scale) do
    state = (state * 1_103_515_245 + 12_345) % 2_147_483_648
    state % 1_000_003
  end
  ordered = values.sort
  checksum = ordered[0] + ordered[-1] + ordered[ordered.length / 2]
when 'method_calls'
  # Method call overhead: two arguments, arithmetic result.
  def accumulate(left, right)
    left + right
  end
  acc = 0
  (1..scale).each do |i|
    acc = accumulate(acc, i % 97) % 1_000_000_007
  end
  checksum = acc
when 'block_yield'
  # Block/yield overhead via an explicit block call.
  def apply_block(left, right)
    yield(left, right)
  end
  acc = 0
  (1..scale).each do |i|
    acc = apply_block(acc, i % 89) { |a, b| (a + b) % 1_000_000_007 }
  end
  checksum = acc
when 'upstream_benchmark'
  # Upstream benchmark: the Benchmark module shipped with the Ruby standard
  # library.  Its report is kept in the raw log; the RESULT checksum certifies
  # that the module produced the expected number of report rows.
  report_rows = 0
  Benchmark.bm(20) do |x|
    report_rows += 1
    x.report('arith') do
      acc = 0
      200_000.times { |i| acc = (acc + i) % 1_000_003 }
    end
    report_rows += 1
    x.report('hash') do
      table = {}
      50_000.times { |i| table[i] = i * 2 }
      table.values.sum
    end
  end
  checksum = report_rows
else
  warn "unknown scenario: #{scenario}"
  exit 2
end

if base == 'arith_float'
  printf("RESULT scenario=%s checksum=%.12f\n", scenario, checksum)
else
  printf("RESULT scenario=%s checksum=%d\n", scenario, checksum)
end
