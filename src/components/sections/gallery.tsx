"use client"

import { motion } from "framer-motion"
import { useRef, useState, useEffect } from "react"
import { Smartphone, ChevronLeft, ChevronRight } from "lucide-react"

const screens = [
  {
    title: "Ekran g\u0142\u00F3wny",
    description: "4 magiczne \u015Bwiaty do odkrycia",
    gradient: "from-pink-400 to-purple-500",
    icon: "\uD83C\uDFE0",
  },
  {
    title: "Nauka liter",
    description: "Polski alfabet A-\u017B z waypoints",
    gradient: "from-teal-400 to-teal-600",
    icon: "\u270F\uFE0F",
  },
  {
    title: "Zwierzak",
    description: "Opiekuj si\u0119 magicznym jajkiem",
    gradient: "from-purple-400 to-pink-500",
    icon: "\uD83E\uDD5A",
  },
  {
    title: "Szlaczki",
    description: "10 wzor\u00F3w do \u015Bledzenia",
    gradient: "from-yellow-400 to-orange-500",
    icon: "\u3030\uFE0F",
  },
  {
    title: "Gry",
    description: "Labirynty, puzzle i wi\u0119cej",
    gradient: "from-green-400 to-teal-500",
    icon: "\uD83C\uDFAE",
  },
]

export function Gallery() {
  const scrollRef = useRef<HTMLDivElement>(null)
  const [canScrollLeft, setCanScrollLeft] = useState(false)
  const [canScrollRight, setCanScrollRight] = useState(true)

  const checkScroll = () => {
    const el = scrollRef.current
    if (!el) return
    setCanScrollLeft(el.scrollLeft > 10)
    setCanScrollRight(el.scrollLeft < el.scrollWidth - el.clientWidth - 10)
  }

  useEffect(() => {
    const el = scrollRef.current
    if (!el) return
    checkScroll()
    el.addEventListener("scroll", checkScroll, { passive: true })
    window.addEventListener("resize", checkScroll)
    return () => {
      el.removeEventListener("scroll", checkScroll)
      window.removeEventListener("resize", checkScroll)
    }
  }, [])

  const scroll = (direction: "left" | "right") => {
    const el = scrollRef.current
    if (!el) return
    const amount = direction === "left" ? -300 : 300
    el.scrollBy({ left: amount, behavior: "smooth" })
  }

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
            Podgl\u0105d aplikacji
          </span>
          <h2
            className="text-4xl font-bold sm:text-5xl bg-gradient-to-r from-pink-500 via-purple-500 to-teal-500 bg-clip-text text-transparent mb-4"
            style={{ fontFamily: "var(--font-fredoka)" }}
          >
            Zobacz Tarnas Kids w akcji
          </h2>
          <p className="mx-auto max-w-2xl text-lg text-text-muted">
            Pi\u0119knie zaprojektowane ekrany, kt\u00F3re dzieci uwielbiaj\u0105
          </p>
        </motion.div>
      </div>

      {/* Scrollable carousel */}
      <div className="relative">
        {/* Arrow buttons - desktop only */}
        {canScrollLeft && (
          <button
            onClick={() => scroll("left")}
            className="absolute left-2 top-1/2 z-10 -translate-y-1/2 hidden sm:flex h-12 w-12 items-center justify-center rounded-full bg-white/90 shadow-lg border border-pink-100 text-pink-500 backdrop-blur-sm transition-all hover:bg-pink-500 hover:text-white hover:shadow-xl"
            aria-label="Przewi\u0144 w lewo"
          >
            <ChevronLeft className="h-6 w-6" />
          </button>
        )}
        {canScrollRight && (
          <button
            onClick={() => scroll("right")}
            className="absolute right-2 top-1/2 z-10 -translate-y-1/2 hidden sm:flex h-12 w-12 items-center justify-center rounded-full bg-white/90 shadow-lg border border-pink-100 text-pink-500 backdrop-blur-sm transition-all hover:bg-pink-500 hover:text-white hover:shadow-xl"
            aria-label="Przewi\u0144 w prawo"
          >
            <ChevronRight className="h-6 w-6" />
          </button>
        )}

        {/* Fade edges */}
        <div className="pointer-events-none absolute left-0 top-0 bottom-0 z-[5] w-8 bg-gradient-to-r from-background to-transparent sm:w-16" />
        <div className="pointer-events-none absolute right-0 top-0 bottom-0 z-[5] w-8 bg-gradient-to-l from-background to-transparent sm:w-16" />

        <div
          ref={scrollRef}
          className="flex gap-5 overflow-x-auto px-8 pb-4 sm:gap-6 sm:px-16 snap-x snap-mandatory scroll-smooth"
          style={{
            scrollbarWidth: "none",
            msOverflowStyle: "none",
            WebkitOverflowScrolling: "touch",
          }}
        >
          {screens.map((screen, i) => (
            <motion.div
              key={screen.title}
              initial={{ opacity: 0, y: 40 }}
              whileInView={{ opacity: 1, y: 0 }}
              viewport={{ once: true, margin: "-50px" }}
              transition={{ duration: 0.5, delay: i * 0.1 }}
              className="shrink-0 snap-center"
            >
              <div className="relative w-56 sm:w-64 md:w-72">
                <div className="rounded-[2.5rem] border-4 border-gray-800 bg-gray-900 p-2 shadow-2xl">
                  {/* Notch */}
                  <div className="absolute top-0 left-1/2 z-10 h-6 w-28 -translate-x-1/2 rounded-b-2xl bg-gray-800" />

                  {/* Screen */}
                  <div
                    className={`relative aspect-[9/19] overflow-hidden rounded-[2rem] bg-gradient-to-br ${screen.gradient}`}
                  >
                    <div className="flex h-full flex-col items-center justify-center p-6 text-center text-white">
                      <span className="mb-4 text-5xl sm:text-6xl">{screen.icon}</span>
                      <h3
                        className="mb-1 text-lg font-bold sm:text-xl"
                        style={{ fontFamily: "var(--font-fredoka)" }}
                      >
                        {screen.title}
                      </h3>
                      <p className="text-xs opacity-80 sm:text-sm">{screen.description}</p>
                    </div>
                  </div>
                </div>
              </div>
            </motion.div>
          ))}
        </div>

        <div className="mt-6 flex items-center justify-center gap-2 text-sm text-text-muted">
          <Smartphone className="h-4 w-4" />
          <span>Przesu\u0144 aby zobaczy\u0107 wi\u0119cej</span>
        </div>
      </div>

      {/* Hide scrollbar via CSS */}
      <style jsx>{`
        div::-webkit-scrollbar {
          display: none;
        }
      `}</style>
    </section>
  )
}
