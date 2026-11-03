-- Fannkuch-redux permutation benchmark (benchmarks-game style): iterates every
-- permutation of n elements and sums the flip counts with alternating signs.
-- Deterministic integer workload that stresses table indexing and loops.
local n = tonumber(arg[1])
assert(n and n > 0, "scale must be a positive integer")

local p, q, s = {}, {}, {}
for i = 1, n do
  p[i] = i
  q[i] = i
  s[i] = i
end

local sign = 1
local maxflips = 0
local sum = 0

repeat
  -- copy and flip
  local q1 = p[1]
  if q1 ~= 1 then
    for i = 2, n do
      q[i] = p[i]
    end
    local flips = 1
    repeat
      local qq = q[q1]
      if qq == 1 then
        sum = sum + sign * flips
        if flips > maxflips then
          maxflips = flips
        end
        break
      end
      q[q1] = q1
      if q1 >= 4 then
        local i, j = 2, q1 - 1
        repeat
          q[i], q[j] = q[j], q[i]
          i = i + 1
          j = j - 1
        until i >= j
      end
      q1 = qq
      flips = flips + 1
    until false
  end
  -- permute
  if sign == 1 then
    p[2], p[1] = p[1], p[2]
    sign = -1
  else
    p[2], p[3] = p[3], p[2]
    sign = 1
    for i = 3, n do
      local sx = s[i]
      if sx ~= 1 then
        s[i] = sx - 1
        break
      end
      if i == n then
        local checksum = maxflips * 10000000 + sum
        print(string.format("RESULT scenario=fannkuch_%d n=%d checksum=%d", n, n, checksum))
        return
      end
      s[i] = i
      local t = p[1]
      for j = 1, i do
        p[j] = p[j + 1]
      end
      p[i + 1] = t
    end
  end
until false
