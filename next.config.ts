import type { NextConfig } from "next"

const nextConfig: NextConfig = {
  output: "export",
  basePath: "/tarnas_kids_web",
  images: {
    unoptimized: true,
  },
}

export default nextConfig
