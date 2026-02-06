"use client"

import { motion, useMotionValue, useTransform, animate } from "framer-motion"
import { useEffect, useRef } from "react"
import { Gamepad2, BookA, Trophy, Users } from "lucide-react"

function AnimatedNumber({ value, suffix = "" }: { value: number; suffix?: string }) {
  const ref = useRef<HTMLSpanElement>(null)
  const motionValue = useMotionValue(0)
  const rounded = useTransform(motionValue, (latest) => Math.round(latest))

  useEffect(() => {
    const controls = animate(motionValue, value, {
      duration: 2,
      ease: [0.25, 0.46, 0.45, 0.94],
    })
    return controls.stop
  }, [motionValue, value])

  useEffect(() => {
    const unsubscribe = rounded.on("change", (latest) => {
      if (ref.current) {
        ref.current.textContent = latest.toString() + suffix
      }
    })
    return unsubscribe
  }, [rounded, suffix])

  return <span ref={ref}>0{suffix}</span>
}

const stats = [
  {
    value: 7,
    suffix: "",
    label: "Gier edukacyjnych",
    icon: Gamepad2,
    color: "text-pink-500",
    bg: "bg-pink-50",
  },
  {
    value: 32,
    suffix: "",
    label: "Liter do nauki",
    icon: BookA,
    color: "text-teal-500",
    bg: "bg-teal-50",
  },
  {
    value: 4,
    suffix: "",
    label: "Fazy ewolucji",
    icon: Trophy,
    color: "text-purple-500",
    bg: "bg-purple-50",
  },
  {
    value: 500,
    suffix: "+",
    label: "Rodzin w beta",
    icon: Users,
    color: "text-yellow-500",
    bg: "bg-yellow-50",
  },
]

export function Stats() {
  return (
    <section className="relative py-16">
      <div className="mx-auto max-w-5xl px-6">
        <motion.div
          initial={{ opacity: 0, y: 30 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true, margin: "-50px" }}
          transition={{ duration: 0.6 }}
          className="grid grid-cols-2 gap-6 sm:grid-cols-4"
        >
          {stats.map((stat, i) => (
            <motion.div
              key={stat.label}
              initial={{ opacity: 0, scale: 0.8 }}
              whileInView={{ opacity: 1, scale: 1 }}
              viewport={{ once: true }}
              transition={{ duration: 0.4, delay: i * 0.1 }}
              className="text-center"
            >
              <div
                className={`mx-auto mb-3 flex h-14 w-14 items-center justify-center rounded-2xl ${stat.bg}`}
              >
                <stat.icon className={`h-7 w-7 ${stat.color}`} />
              </div>
              <p
                className={`text-3xl font-bold ${stat.color} sm:text-4xl`}
                style={{ fontFamily: "var(--font-fredoka)" }}
              >
                <AnimatedNumber value={stat.value} suffix={stat.suffix} />
              </p>
              <p className="text-xs text-text-muted font-medium mt-1">
                {stat.label}
              </p>
            </motion.div>
          ))}
        </motion.div>
      </div>
    </section>
  )
}
