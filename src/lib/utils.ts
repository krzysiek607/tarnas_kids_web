import { type ClassValue, clsx } from "clsx"
import { twMerge } from "tailwind-merge"

export function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs))
}

const BASE_PATH = process.env.NEXT_PUBLIC_BASE_PATH || "/talu_kids_web"

export function href(path: string): string {
  if (path.startsWith("#") || path.startsWith("mailto:") || path.startsWith("http")) {
    return path
  }
  return `${BASE_PATH}${path}`
}
