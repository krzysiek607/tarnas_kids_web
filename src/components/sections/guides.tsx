"use client"

import { motion } from "framer-motion"
import Image from "next/image"

const guides = [
  {
    name: "Lumi",
    role: "Wesoła Odkrywczyni",
    description:
      "Lumi uwielbia eksplorować i odkrywać nowe rzeczy. Pomaga dzieciom poznawać świat liter i liczb z uśmiechem na twarzy.",
    image: "/images/Lumi.png",
    borderColor: "border-pink-400",
    bgGradient: "from-pink-100 to-pink-50",
    textColor: "text-pink-600",
  },
  {
    name: "Taro",
    role: "Pomysłowy Wynalazca",
    description:
      "Taro jest pełen pomysłów i kreatywności. Inspiruje dzieci do tworzenia, rysowania i rozwiązywania zagadek logicznych.",
    image: "/images/Taro.png",
    borderColor: "border-teal-400",
    bgGradient: "from-teal-100 to-teal-50",
    textColor: "text-teal-600",
  },
]

export function Guides() {
  return (
    <section id="przewodnicy" className="relative py-24 sm:py-32 bg-white">
      <div className="relative mx-auto max-w-5xl px-6">
        <motion.div
          initial={{ opacity: 0, y: 30 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true, margin: "-100px" }}
          transition={{ duration: 0.6 }}
          className="text-center mb-16"
        >
          <span
            className="inline-block rounded-full bg-gradient-to-r from-purple-500 to-pink-400 px-5 py-2 text-sm font-bold text-white uppercase tracking-wider shadow-lg shadow-purple-500/20 mb-6"
            style={{ fontFamily: "var(--font-baloo)" }}
          >
            Przewodnicy
          </span>
          <h2
            className="text-4xl font-bold sm:text-5xl bg-gradient-to-r from-purple-500 to-pink-500 bg-clip-text text-transparent mb-4"
            style={{ fontFamily: "var(--font-fredoka)" }}
          >
            Poznaj swoich przyjaciół
          </h2>
          <p className="mx-auto max-w-2xl text-lg text-text-muted">
            Lumi i Taro to wierni towarzysze, którzy zawsze służą pomocą i
            dobrym słowem w każdej przygodzie.
          </p>
        </motion.div>

        <div className="grid gap-8 md:grid-cols-2">
          {guides.map((guide, i) => (
            <motion.div
              key={guide.name}
              initial={{ opacity: 0, x: i === 0 ? -40 : 40 }}
              whileInView={{ opacity: 1, x: 0 }}
              viewport={{ once: true, margin: "-50px" }}
              transition={{ duration: 0.6, delay: i * 0.15 }}
              className={`group relative overflow-hidden rounded-3xl border-2 ${guide.borderColor} bg-gradient-to-br ${guide.bgGradient} p-8 transition-all duration-300 hover:-translate-y-2 hover:shadow-2xl`}
            >
              <div className="flex flex-col items-center text-center sm:flex-row sm:text-left sm:items-start gap-6">
                <motion.div
                  className={`shrink-0 h-28 w-28 overflow-hidden rounded-full border-4 ${guide.borderColor} bg-white shadow-xl`}
                  whileHover={{ scale: 1.1, rotate: 5 }}
                  transition={{ type: "spring", stiffness: 300 }}
                >
                  <Image
                    src={guide.image}
                    alt={guide.name}
                    width={112}
                    height={112}
                    className="h-full w-full object-cover"
                  />
                </motion.div>

                <div>
                  <h3
                    className={`text-2xl font-bold ${guide.textColor} mb-1`}
                    style={{ fontFamily: "var(--font-fredoka)" }}
                  >
                    {guide.name}
                  </h3>
                  <p
                    className="text-sm font-bold text-text-light mb-3"
                    style={{ fontFamily: "var(--font-baloo)" }}
                  >
                    {guide.role}
                  </p>
                  <p className="text-sm text-text-light leading-relaxed">
                    {guide.description}
                  </p>
                </div>
              </div>
            </motion.div>
          ))}
        </div>
      </div>
    </section>
  )
}
