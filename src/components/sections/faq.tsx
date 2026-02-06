"use client"

import { useState } from "react"
import { motion, AnimatePresence } from "framer-motion"
import { ChevronDown, HelpCircle } from "lucide-react"
import { FAQ_ITEMS } from "@/lib/constants"
import { cn } from "@/lib/utils"

function FaqItem({
  item,
  isOpen,
  onToggle,
}: {
  item: (typeof FAQ_ITEMS)[number]
  isOpen: boolean
  onToggle: () => void
}) {
  return (
    <div
      className={cn(
        "rounded-2xl border-2 transition-all duration-300",
        isOpen
          ? "border-pink-300 bg-pink-50/50 shadow-lg shadow-pink-500/5"
          : "border-gray-100 bg-white hover:border-pink-200"
      )}
    >
      <button
        onClick={onToggle}
        className="flex w-full items-center justify-between gap-4 p-6 text-left"
        aria-expanded={isOpen}
      >
        <span
          className={cn(
            "text-base font-bold transition-colors",
            isOpen ? "text-pink-600" : "text-text"
          )}
          style={{ fontFamily: "var(--font-fredoka)" }}
        >
          {item.question}
        </span>
        <motion.div
          animate={{ rotate: isOpen ? 180 : 0 }}
          transition={{ duration: 0.3 }}
          className={cn(
            "flex h-8 w-8 shrink-0 items-center justify-center rounded-full transition-colors",
            isOpen ? "bg-pink-500 text-white" : "bg-gray-100 text-text-muted"
          )}
        >
          <ChevronDown className="h-4 w-4" />
        </motion.div>
      </button>

      <AnimatePresence initial={false}>
        {isOpen && (
          <motion.div
            initial={{ height: 0, opacity: 0 }}
            animate={{ height: "auto", opacity: 1 }}
            exit={{ height: 0, opacity: 0 }}
            transition={{ duration: 0.3, ease: [0.4, 0, 0.2, 1] }}
            className="overflow-hidden"
          >
            <div className="px-6 pb-6">
              <p className="text-sm text-text-light leading-relaxed">
                {item.answer}
              </p>
            </div>
          </motion.div>
        )}
      </AnimatePresence>
    </div>
  )
}

export function Faq() {
  const [openIndex, setOpenIndex] = useState<number | null>(0)

  return (
    <section id="faq" className="relative py-24 sm:py-32 bg-white">
      <div className="relative mx-auto max-w-3xl px-6">
        <motion.div
          initial={{ opacity: 0, y: 30 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true, margin: "-100px" }}
          transition={{ duration: 0.6 }}
          className="text-center mb-16"
        >
          <span
            className="inline-block rounded-full bg-gradient-to-r from-teal-500 to-teal-400 px-5 py-2 text-sm font-bold text-white uppercase tracking-wider shadow-lg shadow-teal-500/20 mb-6"
            style={{ fontFamily: "var(--font-baloo)" }}
          >
            <HelpCircle className="inline h-4 w-4 mr-1 -mt-0.5" />
            FAQ
          </span>
          <h2
            className="text-4xl font-bold sm:text-5xl bg-gradient-to-r from-teal-500 to-purple-500 bg-clip-text text-transparent mb-4"
            style={{ fontFamily: "var(--font-fredoka)" }}
          >
            Najczęstsze pytania
          </h2>
          <p className="mx-auto max-w-xl text-lg text-text-muted">
            Odpowiedzi na pytania, które najczęściej słyszymy od rodziców
          </p>
        </motion.div>

        <div className="space-y-3">
          {FAQ_ITEMS.map((item, i) => (
            <motion.div
              key={i}
              initial={{ opacity: 0, y: 20 }}
              whileInView={{ opacity: 1, y: 0 }}
              viewport={{ once: true }}
              transition={{ duration: 0.4, delay: i * 0.08 }}
            >
              <FaqItem
                item={item}
                isOpen={openIndex === i}
                onToggle={() => setOpenIndex(openIndex === i ? null : i)}
              />
            </motion.div>
          ))}
        </div>
      </div>
    </section>
  )
}
