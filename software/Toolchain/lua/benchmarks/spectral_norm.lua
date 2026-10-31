-- Spectral-norm benchmark (benchmarks-game style): ten power iterations of
-- A^T A on an n x n matrix defined by a closed-form formula. Floating point
-- heavy, no I/O, fully deterministic for a fixed scale.
local n = tonumber(arg[1])
assert(n and n > 0, "scale must be a positive integer")

local sqrt = math.sqrt
local u, v, w = {}, {}, {}
for i = 1, n do
  u[i] = 1.0
end

local function eval_a(i, j)
  local ij = i + j - 1
  return 1.0 / (ij * (ij - 1) / 2 + i)
end

-- v = A * u
local function multiply_av(u, v)
  for i = 1, n do
    local t = 0.0
    for j = 1, n do
      t = t + eval_a(i, j) * u[j]
    end
    v[i] = t
  end
end

-- v = A^T * u
local function multiply_atv(u, v)
  for i = 1, n do
    local t = 0.0
    for j = 1, n do
      t = t + eval_a(j, i) * u[j]
    end
    v[i] = t
  end
end

-- v = A^T * A * u
local function multiply_atav(u, v)
  multiply_av(u, w)
  multiply_atv(w, v)
end

for _ = 1, 10 do
  multiply_atav(u, v)
  multiply_atav(v, u)
end

local vbv, vv = 0.0, 0.0
for i = 1, n do
  vbv = vbv + u[i] * v[i]
  vv = vv + v[i] * v[i]
end
local value = sqrt(vbv / vv)
assert(value == value and value ~= 0, "spectral norm must be finite and non-zero")
print(string.format("RESULT scenario=spectral_norm_%d n=%d checksum=%.15e", n, n, value))
