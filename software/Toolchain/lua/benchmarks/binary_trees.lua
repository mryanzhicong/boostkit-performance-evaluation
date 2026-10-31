-- Binary-trees benchmark (benchmarks-game style): allocates and traverses a
-- large number of short-lived trees. Stresses allocation and garbage
-- collection. Node counts are integers, so the checksum is exact.
local n = tonumber(arg[1])
assert(n and n > 0, "scale must be a positive integer")

local function bottom_up_tree(depth)
  if depth > 0 then
    return {bottom_up_tree(depth - 1), bottom_up_tree(depth - 1)}
  end
  return {}
end

local function item_check(tree)
  if tree[1] then
    return 1 + item_check(tree[1]) + item_check(tree[2])
  end
  return 1
end

local max_depth = n
local stretch_depth = max_depth + 1
local stretch_check = item_check(bottom_up_tree(stretch_depth))
local long_lived = bottom_up_tree(max_depth)
local long_lived_check = item_check(long_lived)

local total = stretch_check
for depth = 4, max_depth, 2 do
  local iterations = 1 << (max_depth - depth + 4)
  local sum = 0
  for _ = 1, iterations do
    sum = sum + item_check(bottom_up_tree(depth))
  end
  total = total + sum
end
total = total + long_lived_check

-- release the long-lived tree before reporting so the process exit path does
-- not include a full-collection of an otherwise unreachable structure
long_lived = nil
print(string.format("RESULT scenario=binary_trees_%d n=%d checksum=%d", n, n, total))
