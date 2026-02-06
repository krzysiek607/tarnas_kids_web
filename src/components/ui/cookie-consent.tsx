"use client"

import { useState, useEffect } from "react"
import { motion, AnimatePresence } from "framer-motion"
import { Cookie, X } from "lucide-react"
import { href } from "@/lib/utils"

export function CookieConsent() {
  const [isVisible, setIsVisible] = useState(false)

  useEffect(() => {
    const consent = localStorage.getItem("cookie-consent")
    if (!consent) {
      const timer = setTimeout(() => setIsVisible(true), 2000)
      return () => clearTimeout(timer)
    }
  }, [])

  const handleAccept = () => {
    localStorage.setItem("cookie-consent", "accepted")
    setIsVisible(false)
  }

  const handleDecline = () => {
    localStorage.setItem("cookie-consent", "declined")
    setIsVisible(false)
  }

  return (
    <AnimatePresence>
      {isVisible && (
        <motion.div
          initial={{ y: 100, opacity: 0 }}
          animate={{ y: 0, opacity: 1 }}
          exit={{ y: 100, opacity: 0 }}
          transition={{ type: "spring", damping: 25 }}
          className="fixed bottom-4 left-4 right-4 z-50 mx-auto max-w-lg rounded-2xl border border-pink-100 bg-white p-5 shadow-2xl shadow-pink-500/10 sm:bottom-6 sm:left-6 sm:right-auto"
        >
          <button
            onClick={handleDecline}
            className="absolute top-3 right-3 text-text-muted hover:text-text transition-colors"
            aria-label="Zamknij"
          >
            <X className="h-4 w-4" />
          </button>

          <div className="flex items-start gap-3">
            <div className="flex h-10 w-10 shrink-0 items-center justify-center rounded-xl bg-yellow-50">
              <Cookie className="h-5 w-5 text-yellow-500" />
            </div>
            <div className="space-y-3">
              <p className="text-sm text-text-light leading-relaxed pr-4">
                Używamy ciasteczek, aby zapewnić najlepsze doświadczenie na
                naszej stronie.{" "}
                <a
                  href={href("/polityka-prywatnosci")}
                  className="text-pink-500 hover:underline font-medium"
                >
                  Dowiedz się więcej
                </a>
              </p>
              <div className="flex gap-2">
                <button
                  onClick={handleAccept}
                  className="rounded-full bg-gradient-to-r from-pink-500 to-purple-500 px-4 py-1.5 text-xs font-bold text-white transition-all hover:shadow-lg hover:shadow-pink-500/25"
                  style={{ fontFamily: "var(--font-baloo)" }}
                >
                  Akceptuję
                </button>
                <button
                  onClick={handleDecline}
                  className="rounded-full border border-pink-200 px-4 py-1.5 text-xs font-semibold text-text-light transition-colors hover:bg-pink-50"
                  style={{ fontFamily: "var(--font-baloo)" }}
                >
                  Tylko niezbędne
                </button>
              </div>
            </div>
          </div>
        </motion.div>
      )}
    </AnimatePresence>
  )
}
