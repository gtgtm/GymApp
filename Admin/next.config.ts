import type { NextConfig } from "next";

// Production is a static export served from a sub-folder of shared hosting
// (gautamgupta.in/gymbrain); see .env.production. Local dev leaves it unset.
const basePath = process.env.NEXT_PUBLIC_BASE_PATH ?? "";

const nextConfig: NextConfig = {
  output: "export",
  basePath,
  // Emit /members/index.html instead of /members.html so Apache serves
  // every route as a plain directory index without rewrite rules.
  trailingSlash: true,
};

export default nextConfig;
