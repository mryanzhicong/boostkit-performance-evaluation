/** @type {import('next').NextConfig} */
const nextConfig = {
  experimental: { cpus: 2 },
  poweredByHeader: false,
  turbopack: { root: process.env.NEXT_TURBOPACK_ROOT || __dirname },
};

module.exports = nextConfig;
