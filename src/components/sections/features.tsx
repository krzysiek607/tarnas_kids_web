"use client"

import { motion } from "framer-motion"
import {
  Gamepad2,
  PenTool,
  Heart,
  Palette,
  Shield,
  BookOpen,
} from "lucide-react"
import { FEATURES } from "@/lib/constants"

const iconMap = {
  Gamepad2,
  PenTool,
  Heart,
  Palette,
  Shield,
  BookOpen,
} as const

const colorMap = {
  pink: {
    bg: "bg-pink-50",
    icon: "bg-gradient-to-br from-pink-500 to-pink-400",
    border: "border-pink-200 hover:border-pink-400",
    glow: "group-hover:shadow-pink-500/20",
  },
  teal: {
    bg: "bg-teal-50",
    icon: "bg-gradient-to-br from-teal-500 to-teal-400",
    border: "border-teal-200 hover:border-teal-400",
    glow: "group-hover:shadow-teal-500/20",
  },
  purple: {
    bg: "bg-purple-50",
    icon: "bg-gradient-to-br from-purple-500 to-purple-400",
    border: "border-purple-200 hover:border-purple-400",
    glow: "group-hover:shadow-purple-500/20",
  },
  yellow: {
    bg: "bg-yellow-50",
    icon: "bg-gradient-to-br from-yellow-500 to-yellow-400",
    border: "border-yellow-200 hover:border-yellow-400",
    glow: "group-hover:shadow-yellow-500/20",
  },
  green: {
    bg: "bg-green-50",
    icon: "bg-gradient-to-br from-green-500 to-green-400",
    border: "border-green-200 hover:border-green-400",
    glow: "group-hover:shadow-green-500/20",
  },
  orange: {
    bg: "bg-orange-50",
    icon: "bg-gradient-to-br from-orange-500 to-orange-400",
    border: "border-orange-200 hover:border-orange-400",
    glow: "group-hover:shadow-orange-500/20",
  },
} as const

export function Features() {
  return (
    <section id="funkcje" className="relative py-24 sm:py-32">
      <div className="absolute inset-0 bg-gradient-to-b from-transparent via-teal-50/20 to-transparent pointer-events-none" />

      <div className="relative mx-auto max-w-7xl px-6">
        <motion.div
          initial={{ opacity: 0, y: 30 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true, margin: "-100px" }}
          transition={{ duration: 0.6 }}
          className="text-center mb-16"
        >
          <span
            className="inline-block rounded-full bg-gradient-to-r from-teal-500 to-green-400 px-5 py-2 text-sm font-bold text-white uppercase tracking-wider shadow-lg shadow-teal-500/20 mb-6"
            style={{ fontFamily: "var(--font-baloo)" }}
          >
            Co oferujemy
          </span>
          <h2
            className="text-4xl font-bold sm:text-5xl bg-gradient-to-r from-teal-500 to-purple-500 bg-clip-text text-transparent mb-4"
            style={{ fontFamily: "var(--font-fredoka)" }}
          >
            Świat pełen przygód i nauki
          </h2>
          <p className="mx-auto max-w-2xl text-lg text-text-muted">
            Każdy dzień z TaLu Kids to nowa przygoda. 7 gier edukacyjnych,
            nauka całego polskiego alfabetu i wirtualny przyjaciel.
          </p>
        </motion.div>

        <div className="grid gap-6 sm:grid-cols-2 lg:grid-cols-3">
          {FEATURES.map((feature, i) => {
            const Icon = iconMap[feature.icon]
            const colors = colorMap[feature.color]

            return (
              <motion.article
                key={feature.title}
                initial={{ opacity: 0, y: 30 }}
                whileInView={{ opacity: 1, y: 0 }}
                viewport={{ once: true, margin: "-50px" }}
                transition={{ duration: 0.5, delay: i * 0.1 }}
                className={`group relative rounded-3xl border-2 ${colors.border} bg-white p-8 transition-all duration-300 hover:-translate-y-2 hover:shadow-2xl ${colors.glow} cursor-default`}
              >
                <div
                  className={`mb-5 flex h-14 w-14 items-center justify-center rounded-2xl ${colors.icon} shadow-lg transition-transform duration-300 group-hover:scale-110 group-hover:rotate-6`}
                >
                  <Icon className="h-7 w-7 text-white" strokeWidth={2} />
                </div>

                <h3
                  className="mb-2 text-xl font-bold text-text"
                  style={{ fontFamily: "var(--font-fredoka)" }}
                >
                  {feature.title}
                </h3>
                <p className="text-sm text-text-light leading-relaxed">
                  {feature.description}
                </p>
              </motion.article>
            )
          })}
        </div>
      </div>
    </section>
  )
}
