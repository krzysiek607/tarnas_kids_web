import type { Metadata } from "next"
import { Parents } from "@/components/sections/parents"
import { Faq } from "@/components/sections/faq"
import { Newsletter } from "@/components/sections/newsletter"

export const metadata: Metadata = {
  title: "Dla rodzic\u00F3w",
  description:
    "Bezpiecze\u0144stwo, kontrola rodzicielska i raporty post\u0119p\u00F3w. Dowiedz si\u0119, jak Tarnas Kids chroni Twoje dziecko.",
}

export default function ForParentsPage() {
  return (
    <main className="pt-20">
      <Parents />
      <Faq />
      <Newsletter />
    </main>
  )
}
