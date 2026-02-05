"use client"

import { motion, useScroll, useTransform } from "framer-motion"
import { useRef } from "react"
import { Smartphone } from "lucide-react"

const screens = [
  {
    title: "Ekran główny",
    description: "4 magiczne światy do odkrycia",
    gradient: "from-pink-400 to-purple-500",
    icon: "🏠",
  },
  {
    title: "Nauka liter",
    description: "Polski alfabet A-Ż z waypoints",
    gradient: "from-teal-400 to-teal-600",
    icon: "✏️",
  },
  {
    title: "Zwierzak",
    description: "Opiekuj się magicznym jajkiem",
    gradient: "from-purple-400 to-pink-500",
    icon: "🥚",
  },
  {
    title: "Szlaczki",
    description: "10 wzorów do śledzenia",
    gradient: "from-yellow-400 to-orange-500",
    icon: "〰️",
  },
  {
    title: "Gry",
    description: "Labirynty, puzzle i więcej",
    gradient: "from-green-400 to-teal-500",
    icon: "🎮",
  },
]

export function Gallery() {
  const containerRef = useRef<HTMLDivElement>(null)
  const { scrollYProgress } = useScroll({
    target: containerRef,
    offset: ["start end", "end start"],
  })
  const x = useTransform(scrollYProgress, [0, 1], ["5%", "-15%"])

  return (
    <section className="relative py-24 sm:py-32 overflow-hidden">
      <div className="absolute inset-0 bg-gradient-to-b from-white via-purple-50/20 to-white pointer-events-none" />

      <div className="relative mx-auto max-w-7xl px-6">
        <motion.div
          initial={{ opacity: 0, y: 30 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true, margin: "-100px" }}
          transition={{ duration: 0.6 }}
          className="text-center mb-16"
        >
          <span
            className="inline-block rounded-full bg-gradient-to-r from-pink-500 to-orange-400 px-5 py-2 text-sm font-bold text-white uppercase tracking-wider shadow-lg shadow-pink-500/20 mb-6"
            style={{ fontFamily: "var(--font-baloo)" }}
          >
            Podgląd aplikacji
          </span>
          <h2
            className="text-4xl font-bold sm:text-5xl bg-gradient-to-r from-pink-500 via-purple-500 to-teal-500 bg-clip-text text-transparent mb-4"
            style={{ fontFamily: "var(--font-fredoka)" }}
          >
            Zobacz Tarnas Kids w akcji
          </h2>
          <p className="mx-auto max-w-2xl text-lg text-text-muted">
            Pięknie zaprojektowane ekrany, które dzieci uwielbiają
          </p>
        </motion.div>
      </div>

      {/* Scrolling mockups */}
      <div ref={containerRef} className="relative">
        <motion.div style={{ x }} className="flex gap-6 pl-8">
          {screens.map((screen, i) => (
            <motion.div
              key={screen.title}
              initial={{ opacity: 0, y: 40 }}
              whileInView={{ opacity: 1, y: 0 }}
              viewport={{ once: true, margin: "-50px" }}
              transition={{ duration: 0.5, delay: i * 0.1 }}
              className="shrink-0"
            >
              {/* Phone mockup */}
              <div className="relative w-64 sm:w-72">
                <div className="rounded-[2.5rem] border-4 border-gray-800 bg-gray-900 p-2 shadow-2xl">
                  {/* Notch */}
                  <div className="absolute top-0 left-1/2 z-10 h-6 w-28 -translate-x-1/2 rounded-b-2xl bg-gray-800" />

                  {/* Screen */}
                  <div
                    className={`relative aspect-[9/19] overflow-hidden rounded-[2rem] bg-gradient-to-br ${screen.gradient}`}
                  >
                    <div className="flex h-full flex-col items-center justify-center p-6 text-center text-white">
                      <span className="mb-4 text-6xl">{screen.icon}</span>
                      <h3
                        className="mb-1 text-xl font-bold"
                        style={{ fontFamily: "var(--font-fredoka)" }}
                      >
                        {screen.title}
                      </h3>
                      <p className="text-sm opacity-80">{screen.description}</p>
                    </div>
                  </div>
                </div>
              </div>
            </motion.div>
          ))}
        </motion.div>

        <div className="mt-8 flex items-center justify-center gap-2 text-sm text-text-muted">
          <Smartphone className="h-4 w-4" />
          <span>Dostępne na telefony i tablety</span>
        </div>
      </div>
    </section>
  )
}
