-- N-body simulation (benchmarks-game style): five solar-system bodies, double
-- precision, one fixed time step per iteration. The measured value is the
-- total energy printed as the checksum; it is deterministic for a fixed scale.
local n = tonumber(arg[1])
assert(n and n > 0, "scale must be a positive integer")

local sqrt = math.sqrt
local PI = math.pi
local SOLAR_MASS = 4 * PI * PI
local DAYS_PER_YEAR = 365.24

local bodies = {
  -- sun
  {0.0, 0.0, 0.0, 0.0, 0.0, 0.0, SOLAR_MASS},
  -- jupiter
  {4.84143144246472090e+00, -1.16032004402742839e+00, -1.03622044471123109e-01,
   1.66007664274403694e-03 * DAYS_PER_YEAR, 7.69901118419740425e-03 * DAYS_PER_YEAR,
   -6.90460016972063023e-05 * DAYS_PER_YEAR, 9.54791938424326609e-04 * SOLAR_MASS},
  -- saturn
  {8.34336671824457987e+00, 4.12479856412430479e+00, -4.03523417114321381e-01,
   -2.76742510726862411e-03 * DAYS_PER_YEAR, 4.99852801234917238e-03 * DAYS_PER_YEAR,
   2.30417297573763929e-05 * DAYS_PER_YEAR, 2.85885980666130812e-04 * SOLAR_MASS},
  -- uranus
  {1.28943695621391310e+01, -1.51111514016986312e+01, -2.23307578892655734e-01,
   2.96460137564761618e-03 * DAYS_PER_YEAR, 2.37847173959480950e-03 * DAYS_PER_YEAR,
   -2.96589568540237556e-05 * DAYS_PER_YEAR, 4.36624404335156298e-05 * SOLAR_MASS},
  -- neptune
  {1.53796971148509165e+01, -2.59193146099879641e+01, 1.79258772950371181e-01,
   2.68067772490389322e-03 * DAYS_PER_YEAR, 1.62824170038242295e-03 * DAYS_PER_YEAR,
   -9.51592254519715870e-05 * DAYS_PER_YEAR, 5.15138902046611451e-05 * SOLAR_MASS},
}

local nbody = #bodies

local function advance(dt)
  for i = 1, nbody do
    local bi = bodies[i]
    for j = i + 1, nbody do
      local bj = bodies[j]
      local dx = bi[1] - bj[1]
      local dy = bi[2] - bj[2]
      local dz = bi[3] - bj[3]
      local d2 = dx * dx + dy * dy + dz * dz
      local mag = dt / (d2 * sqrt(d2))
      bi[4] = bi[4] - dx * mag * bj[7]
      bi[5] = bi[5] - dy * mag * bj[7]
      bi[6] = bi[6] - dz * mag * bj[7]
      bj[4] = bj[4] + dx * mag * bi[7]
      bj[5] = bj[5] + dy * mag * bi[7]
      bj[6] = bj[6] + dz * mag * bi[7]
    end
  end
  for i = 1, nbody do
    local b = bodies[i]
    b[1] = b[1] + dt * b[4]
    b[2] = b[2] + dt * b[5]
    b[3] = b[3] + dt * b[6]
  end
end

local function energy()
  local e = 0.0
  for i = 1, nbody do
    local bi = bodies[i]
    e = e + 0.5 * bi[7] * (bi[4] * bi[4] + bi[5] * bi[5] + bi[6] * bi[6])
    for j = i + 1, nbody do
      local bj = bodies[j]
      local dx = bi[1] - bj[1]
      local dy = bi[2] - bj[2]
      local dz = bi[3] - bj[3]
      e = e - (bi[7] * bj[7]) / sqrt(dx * dx + dy * dy + dz * dz)
    end
  end
  return e
end

local function offset_momentum()
  local px, py, pz = 0.0, 0.0, 0.0
  for i = 1, nbody do
    local b = bodies[i]
    px = px + b[4] * b[7]
    py = py + b[5] * b[7]
    pz = pz + b[6] * b[7]
  end
  local sun = bodies[1]
  sun[4] = -px / SOLAR_MASS
  sun[5] = -py / SOLAR_MASS
  sun[6] = -pz / SOLAR_MASS
end

offset_momentum()
for _ = 1, n do
  advance(0.01)
end
local value = energy()
assert(value == value and value ~= 0, "energy must be a finite non-zero value")
print(string.format("RESULT scenario=nbody_%d n=%d checksum=%.15e", n, n, value))
