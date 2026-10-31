-- String workload: repeated concatenation, table.concat aggregation, the
-- pattern matching engine and string.format. Exercises string interning and
-- the string library without any I/O inside the measured loop.
local n = tonumber(arg[1])
assert(n and n > 0, "scale must be a positive integer")

local sum = 0
for i = 1, n do
  local s = "chunk-" .. i .. "-" .. (i % 97)
  sum = sum + #s
end

local parts = {}
for i = 1, n do
  parts[i] = string.format("%d:%s:%d", i, "payload" .. (i % 1000), #tostring(i))
end
local big = table.concat(parts, ",", 1, n)

local text = string.rep("abc123def", 1000)
local replaced, replacements = text:gsub("%d+", "X")

for i = 1, 10000 do
  sum = sum + #string.format("%08d", i)
end

sum = sum + #big + #replaced + replacements * 1000
print(string.format("RESULT scenario=string_churn_%d n=%d checksum=%d", n, n, sum))
