-- Hash-table construction and traversal: inserts n integer keys and n string
-- keys, then sums the array part, the hash part and the entry count. Stresses
-- table rehash, array/hash part behavior and iteration.
local n = tonumber(arg[1])
assert(n and n > 0, "scale must be a positive integer")

local MOD = 1000000007
local MULT = 2654435761
local t = {}
for i = 1, n do
  t[i] = (i * MULT) % MOD
end
for i = 1, n do
  t["k" .. i] = i
end

local array_sum = 0
local string_sum = 0
for i = 1, n do
  array_sum = (array_sum + t[i]) % MOD
  string_sum = (string_sum + t["k" .. i]) % MOD
end

local count = 0
for _ in pairs(t) do
  count = count + 1
end

local checksum = (array_sum + string_sum) % MOD + count * 1000000000
print(string.format("RESULT scenario=table_build_%d n=%d checksum=%d", n, n, checksum))
