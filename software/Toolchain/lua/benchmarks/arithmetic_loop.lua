-- Deterministic integer arithmetic loop, the representative load of the legacy
-- 43-software delivery (2,000,000 modulo operations accumulated into a checksum).
-- Every result is derived from closed-form integer arithmetic, so the printed
-- checksum can be recomputed independently and must match on every repetition.
local n = tonumber(arg[1])
assert(n and n > 0, "scale must be a positive integer")

local MOD = 1000000007
local MULT = 2654435761
local sum = 0
for i = 1, n do
  sum = (sum + ((i * MULT) % MOD)) % MOD
end
print(string.format("RESULT scenario=arithmetic_loop_%d n=%d checksum=%d", n, n, sum))
