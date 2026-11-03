-- Garbage-collection pressure: each round allocates and drops many tables,
-- short strings and closures. A full collection runs once at start-up and
-- every ten rounds, so the workload mixes incremental and full GC work.
-- All output values are deterministic integers.
local rounds = tonumber(arg[1])
assert(rounds and rounds > 0, "scale must be a positive integer")

collectgarbage("collect")
local sum = 0

local function make_object(id, tag)
  return {
    id = id,
    tag = tag,
    name = "obj-" .. id .. "-" .. tag,
    data = {tag, id % 13, tostring(id)},
  }
end

for r = 1, rounds do
  local batch = {}
  for i = 1, 100 do
    local id = r * 100 + i
    local tag = i % 37
    local obj = make_object(id, tag)
    batch[i] = obj
    sum = sum + obj.id % 7 + #obj.name + #obj.data[3] + obj.data[2]
  end

  local counter = 0
  local function bump()
    counter = counter + 1
    return counter
  end
  for _ = 1, 20 do
    sum = sum + bump()
  end

  local parts = {}
  for i = 1, 20 do
    parts[i] = string.format("%d-%s", r, i)
  end
  sum = sum + #table.concat(parts, ";")

  if r % 10 == 0 then
    collectgarbage("collect")
  end
end

print(string.format("RESULT scenario=gc_stress_%d rounds=%d checksum=%d", rounds, rounds, sum))
