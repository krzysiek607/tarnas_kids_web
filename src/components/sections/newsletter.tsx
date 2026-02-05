"use client"

import { useState, type FormEvent } from "react"
import { motion } from "framer-motion"
import { Send, CheckCircle, Sparkles } from "lucide-react"

export function Newsletter() {
  const [email, setEmail] = useState("")
  const [isSubmitted, setIsSubmitted] = useState(false)
  const [isLoading, setIsLoading] = useState(false)

  const handleSubmit = (e: FormEvent) => {
    e.preventDefault()
    if (!email) return

    setIsLoading(true)
    // Simulate API call
    setTimeout(() => {
      setIsSubmitted(true)
      setIsLoading(false)
    }, 1000)
  }

  return (
    <section
      id="newsletter"
      className="relative py-24 sm:py-32 overflow-hidden"
    >
      {/* Decorative background */}
      <div className="absolute inset-0 bg-gradient-to-br from-pink-500 via-purple-500 to-teal-500" />
      <div className="absolute inset-0 bg-[radial-gradient(ellipse_at_top_right,rgba(255,255,255,0.15),transparent_50%)]" />
      <div className="absolute inset-0 bg-[radial-gradient(ellipse_at_bottom_left,rgba(255,255,255,0.1),transparent_50%)]" />

      {/* Floating shapes */}
      <motion.div
        className="absolute top-10 left-10 h-20 w-20 rounded-full bg-white/10"
        animate={{ y: [0, -20, 0], scale: [1, 1.1, 1] }}
        transition={{ duration: 8, repeat: Infinity }}
      />
      <motion.div
        className="absolute bottom-10 right-10 h-32 w-32 rounded-3xl bg-white/5 rotate-12"
        animate={{ y: [0, 15, 0], rotate: [12, 20, 12] }}
        transition={{ duration: 10, repeat: Infinity }}
      />

      <div className="relative mx-auto max-w-2xl px-6 text-center">
        <motion.div
          initial={{ opacity: 0, y: 30 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true, margin: "-100px" }}
          transition={{ duration: 0.6 }}
        >
          <div className="mb-6 inline-flex items-center gap-2 rounded-full bg-white/20 px-4 py-2 text-white backdrop-blur-sm">
            <Sparkles className="h-4 w-4" />
            <span
              className="text-sm font-bold"
              style={{ fontFamily: "var(--font-baloo)" }}
            >
              Dołącz do beta testerów
            </span>
          </div>

          <h2
            className="mb-4 text-4xl font-bold text-white sm:text-5xl"
            style={{ fontFamily: "var(--font-fredoka)" }}
          >
            Bądź na bieżąco!
          </h2>
          <p className="mb-10 text-lg text-white/80">
            Zostaw email, a powiadomimy Cię o premierze aplikacji. Jako jedni z
            pierwszych otrzymasz dostęp do wersji beta!
          </p>

          {isSubmitted ? (
            <motion.div
              initial={{ scale: 0.8, opacity: 0 }}
              animate={{ scale: 1, opacity: 1 }}
              className="flex flex-col items-center gap-3"
            >
              <div className="flex h-16 w-16 items-center justify-center rounded-full bg-white/20 backdrop-blur-sm">
                <CheckCircle className="h-8 w-8 text-green-300" />
              </div>
              <p className="text-xl font-bold text-white" style={{ fontFamily: "var(--font-fredoka)" }}>
                Dziękujemy!
              </p>
              <p className="text-white/80">
                Powiadomimy Cię o premierze na adres{" "}
                <span className="font-bold text-white">{email}</span>
              </p>
            </motion.div>
          ) : (
            <form onSubmit={handleSubmit} className="mx-auto max-w-md">
              <div className="flex flex-col gap-3 sm:flex-row">
                <input
                  type="email"
                  value={email}
                  onChange={(e) => setEmail(e.target.value)}
                  placeholder="twoj@email.pl"
                  required
                  className="flex-1 rounded-full border-2 border-white/20 bg-white/10 px-6 py-4 text-white placeholder:text-white/50 backdrop-blur-sm transition-all focus:border-white/50 focus:bg-white/15 focus:outline-none"
                  style={{ fontFamily: "var(--font-body)" }}
                />
                <button
                  type="submit"
                  disabled={isLoading}
                  className="inline-flex items-center justify-center gap-2 rounded-full bg-white px-8 py-4 font-bold text-purple-600 shadow-xl transition-all hover:shadow-2xl hover:-translate-y-0.5 active:translate-y-0 disabled:opacity-70"
                  style={{ fontFamily: "var(--font-baloo)" }}
                >
                  {isLoading ? (
                    <div className="h-5 w-5 animate-spin rounded-full border-2 border-purple-200 border-t-purple-600" />
                  ) : (
                    <>
                      Powiadom mnie
                      <Send className="h-4 w-4" />
                    </>
                  )}
                </button>
              </div>
              <p className="mt-4 text-xs text-white/60">
                Żadnego spamu. Możesz się wypisać w każdej chwili.
              </p>
            </form>
          )}
        </motion.div>
      </div>
    </section>
  )
}
