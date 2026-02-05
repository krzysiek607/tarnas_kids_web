"use client"

import { useState, type FormEvent } from "react"
import { motion } from "framer-motion"
import { Mail, Send, CheckCircle, MessageSquare } from "lucide-react"
import { SITE_CONFIG } from "@/lib/constants"

export default function ContactPage() {
  const [isSubmitted, setIsSubmitted] = useState(false)
  const [isLoading, setIsLoading] = useState(false)

  const handleSubmit = (e: FormEvent) => {
    e.preventDefault()
    setIsLoading(true)
    setTimeout(() => {
      setIsSubmitted(true)
      setIsLoading(false)
    }, 1000)
  }

  return (
    <main className="min-h-screen pt-28 pb-20">
      <div className="mx-auto max-w-2xl px-6">
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.5 }}
          className="text-center mb-12"
        >
          <div className="mb-4 inline-flex h-16 w-16 items-center justify-center rounded-2xl bg-gradient-to-br from-pink-500 to-purple-500">
            <MessageSquare className="h-8 w-8 text-white" />
          </div>
          <h1
            className="text-4xl font-bold bg-gradient-to-r from-pink-500 to-purple-500 bg-clip-text text-transparent mb-3"
            style={{ fontFamily: "var(--font-fredoka)" }}
          >
            Skontaktuj si\u0119 z nami
          </h1>
          <p className="text-text-muted">
            Masz pytanie lub sugesti\u0119? Ch\u0119tnie pomo\u017Cemy!
          </p>
        </motion.div>

        {isSubmitted ? (
          <motion.div
            initial={{ scale: 0.8, opacity: 0 }}
            animate={{ scale: 1, opacity: 1 }}
            className="rounded-3xl border-2 border-green-200 bg-green-50 p-12 text-center"
          >
            <CheckCircle className="mx-auto mb-4 h-16 w-16 text-green-500" />
            <h2
              className="text-2xl font-bold text-text mb-2"
              style={{ fontFamily: "var(--font-fredoka)" }}
            >
              Wiadomo\u015B\u0107 wys\u0142ana!
            </h2>
            <p className="text-text-muted">
              Odpowiemy najszybciej jak to mo\u017Cliwe. Dzi\u0119kujemy za kontakt!
            </p>
          </motion.div>
        ) : (
          <motion.form
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.5, delay: 0.2 }}
            onSubmit={handleSubmit}
            className="rounded-3xl border-2 border-pink-100 bg-white p-8 shadow-xl shadow-pink-500/5"
          >
            <div className="space-y-5">
              <div>
                <label
                  htmlFor="name"
                  className="mb-1.5 block text-sm font-bold text-text"
                >
                  Imi\u0119
                </label>
                <input
                  id="name"
                  type="text"
                  required
                  placeholder="Twoje imi\u0119"
                  className="w-full rounded-xl border-2 border-gray-100 bg-gray-50 px-4 py-3 text-text transition-all focus:border-pink-300 focus:bg-white focus:outline-none"
                />
              </div>

              <div>
                <label
                  htmlFor="email"
                  className="mb-1.5 block text-sm font-bold text-text"
                >
                  Email
                </label>
                <input
                  id="email"
                  type="email"
                  required
                  placeholder="twoj@email.pl"
                  className="w-full rounded-xl border-2 border-gray-100 bg-gray-50 px-4 py-3 text-text transition-all focus:border-pink-300 focus:bg-white focus:outline-none"
                />
              </div>

              <div>
                <label
                  htmlFor="message"
                  className="mb-1.5 block text-sm font-bold text-text"
                >
                  Wiadomo\u015B\u0107
                </label>
                <textarea
                  id="message"
                  required
                  rows={5}
                  placeholder="Napisz do nas..."
                  className="w-full rounded-xl border-2 border-gray-100 bg-gray-50 px-4 py-3 text-text transition-all focus:border-pink-300 focus:bg-white focus:outline-none resize-none"
                />
              </div>

              <button
                type="submit"
                disabled={isLoading}
                className="inline-flex w-full items-center justify-center gap-2 rounded-full bg-gradient-to-r from-pink-500 to-purple-500 px-8 py-4 font-bold text-white shadow-lg shadow-pink-500/25 transition-all hover:shadow-xl hover:-translate-y-0.5 disabled:opacity-70"
                style={{ fontFamily: "var(--font-baloo)" }}
              >
                {isLoading ? (
                  <div className="h-5 w-5 animate-spin rounded-full border-2 border-white/30 border-t-white" />
                ) : (
                  <>
                    Wy\u015Blij wiadomo\u015B\u0107
                    <Send className="h-4 w-4" />
                  </>
                )}
              </button>
            </div>
          </motion.form>
        )}

        <div className="mt-8 text-center">
          <p className="text-sm text-text-muted">
            Mo\u017Cesz te\u017C napisa\u0107 bezpo\u015Brednio na{" "}
            <a
              href={`mailto:${SITE_CONFIG.email}`}
              className="inline-flex items-center gap-1 text-pink-500 hover:underline font-semibold"
            >
              <Mail className="h-3.5 w-3.5" />
              {SITE_CONFIG.email}
            </a>
          </p>
        </div>
      </div>
    </main>
  )
}
