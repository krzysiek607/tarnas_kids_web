"use client"

import { motion } from "framer-motion"
import { Shield, BarChart3, Clock, Lock, Eye, Bell } from "lucide-react"

const parentFeatures = [
  {
    icon: Shield,
    title: "Pełna zgodność z RODO i COPPA",
    description: "Dane dziecka są szyfrowane i bezpieczne. Minimalizujemy zbieranie danych.",
  },
  {
    icon: BarChart3,
    title: "Raporty postępów",
    description: "Zobacz które litery Twoje dziecko opanowało i ile czasu spędza w aplikacji.",
  },
  {
    icon: Clock,
    title: "Kontrola czasu",
    description: "Ustaw limity czasu korzystania z aplikacji. Sesje dzieci z krótszym timeout.",
  },
  {
    icon: Lock,
    title: "Bramka rodzicielska",
    description: "4-sekundowe przytrzymanie chroni ustawienia przed przypadkowym dostępem dziecka.",
  },
  {
    icon: Eye,
    title: "Zero reklam",
    description: "Żadnych reklam, targetowania ani linków zewnętrznych. Czysty, bezpieczny interfejs.",
  },
  {
    icon: Bell,
    title: "Powiadomienia o postępach",
    description: "Otrzymuj informacje gdy dziecko osiągnie kamień milowy w nauce.",
  },
]

export function Parents() {
  return (
    <section id="dla-rodzicow" className="relative py-24 sm:py-32 bg-white">
      <div className="relative mx-auto max-w-7xl px-6">
        <div className="grid gap-16 lg:grid-cols-2 lg:items-center">
          {/* Text content */}
          <motion.div
            initial={{ opacity: 0, x: -40 }}
            whileInView={{ opacity: 1, x: 0 }}
            viewport={{ once: true, margin: "-100px" }}
            transition={{ duration: 0.6 }}
          >
            <span
              className="inline-block rounded-full bg-gradient-to-r from-purple-500 to-pink-400 px-5 py-2 text-sm font-bold text-white uppercase tracking-wider shadow-lg shadow-purple-500/20 mb-6"
              style={{ fontFamily: "var(--font-baloo)" }}
            >
              Dla rodziców
            </span>
            <h2
              className="text-4xl font-bold sm:text-5xl bg-gradient-to-r from-purple-500 to-pink-500 bg-clip-text text-transparent mb-4"
              style={{ fontFamily: "var(--font-fredoka)" }}
            >
              Pełna kontrola, zero stresu
            </h2>
            <p className="text-lg text-text-muted mb-8 leading-relaxed">
              Wiemy, jak ważne jest bezpieczeństwo Twojego dziecka w sieci.
              Dlatego Tarnas Kids zostało zaprojektowane z myślą o spokoju
              rodziców. Żadnych niespodzianek.
            </p>

            <div className="grid gap-4 sm:grid-cols-2">
              {parentFeatures.slice(0, 4).map((feature, i) => (
                <motion.div
                  key={feature.title}
                  initial={{ opacity: 0, y: 20 }}
                  whileInView={{ opacity: 1, y: 0 }}
                  viewport={{ once: true }}
                  transition={{ duration: 0.4, delay: i * 0.1 }}
                  className="flex gap-3"
                >
                  <div className="flex h-10 w-10 shrink-0 items-center justify-center rounded-xl bg-purple-50">
                    <feature.icon className="h-5 w-5 text-purple-500" />
                  </div>
                  <div>
                    <h4 className="text-sm font-bold text-text">{feature.title}</h4>
                    <p className="text-xs text-text-muted leading-relaxed">
                      {feature.description}
                    </p>
                  </div>
                </motion.div>
              ))}
            </div>
          </motion.div>

          {/* Dashboard preview card */}
          <motion.div
            initial={{ opacity: 0, x: 40 }}
            whileInView={{ opacity: 1, x: 0 }}
            viewport={{ once: true, margin: "-100px" }}
            transition={{ duration: 0.6, delay: 0.2 }}
            className="relative"
          >
            <div className="rounded-3xl border-2 border-purple-200 bg-gradient-to-br from-purple-50 to-pink-50 p-8 shadow-xl">
              <div className="mb-6 flex items-center gap-3">
                <div className="flex h-12 w-12 items-center justify-center rounded-full bg-gradient-to-br from-purple-500 to-pink-500 text-2xl shadow-lg">
                  👨‍👩‍👧‍👦
                </div>
                <div>
                  <h3
                    className="text-xl font-bold text-text"
                    style={{ fontFamily: "var(--font-fredoka)" }}
                  >
                    Panel Rodzica
                  </h3>
                  <p className="text-xs text-text-muted">Śledź postępy i zarządzaj ustawieniami</p>
                </div>
              </div>

              {/* Progress bars mock */}
              <div className="space-y-4 mb-6">
                <div>
                  <div className="mb-1 flex justify-between text-xs">
                    <span className="font-semibold text-text-light">Alfabet</span>
                    <span className="font-bold text-teal-500">78%</span>
                  </div>
                  <div className="h-2.5 rounded-full bg-gray-100 overflow-hidden">
                    <motion.div
                      initial={{ width: 0 }}
                      whileInView={{ width: "78%" }}
                      viewport={{ once: true }}
                      transition={{ duration: 1, delay: 0.5 }}
                      className="h-full rounded-full bg-gradient-to-r from-teal-400 to-teal-500"
                    />
                  </div>
                </div>
                <div>
                  <div className="mb-1 flex justify-between text-xs">
                    <span className="font-semibold text-text-light">Szlaczki</span>
                    <span className="font-bold text-pink-500">54%</span>
                  </div>
                  <div className="h-2.5 rounded-full bg-gray-100 overflow-hidden">
                    <motion.div
                      initial={{ width: 0 }}
                      whileInView={{ width: "54%" }}
                      viewport={{ once: true }}
                      transition={{ duration: 1, delay: 0.7 }}
                      className="h-full rounded-full bg-gradient-to-r from-pink-400 to-pink-500"
                    />
                  </div>
                </div>
                <div>
                  <div className="mb-1 flex justify-between text-xs">
                    <span className="font-semibold text-text-light">Liczenie</span>
                    <span className="font-bold text-purple-500">91%</span>
                  </div>
                  <div className="h-2.5 rounded-full bg-gray-100 overflow-hidden">
                    <motion.div
                      initial={{ width: 0 }}
                      whileInView={{ width: "91%" }}
                      viewport={{ once: true }}
                      transition={{ duration: 1, delay: 0.9 }}
                      className="h-full rounded-full bg-gradient-to-r from-purple-400 to-purple-500"
                    />
                  </div>
                </div>
              </div>

              {/* Stats row */}
              <div className="grid grid-cols-3 gap-3">
                {[
                  { label: "Dni aktywności", value: "23", color: "text-teal-500" },
                  { label: "Nagrody", value: "47", color: "text-yellow-500" },
                  { label: "Ewolucja", value: "Faza 3", color: "text-purple-500" },
                ].map((stat) => (
                  <div
                    key={stat.label}
                    className="rounded-xl bg-white p-3 text-center shadow-sm"
                  >
                    <p className={`text-lg font-bold ${stat.color}`}>{stat.value}</p>
                    <p className="text-[10px] text-text-muted">{stat.label}</p>
                  </div>
                ))}
              </div>
            </div>

            {/* Decorative elements */}
            <div className="absolute -top-4 -right-4 h-16 w-16 rounded-2xl bg-gradient-to-br from-yellow-400 to-yellow-500 opacity-20 blur-xl" />
            <div className="absolute -bottom-4 -left-4 h-20 w-20 rounded-2xl bg-gradient-to-br from-teal-400 to-teal-500 opacity-20 blur-xl" />
          </motion.div>
        </div>
      </div>
    </section>
  )
}
