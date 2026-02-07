import type { Metadata } from "next"
import { Parents } from "@/components/sections/parents"
import { Faq } from "@/components/sections/faq"
import { Newsletter } from "@/components/sections/newsletter"

export const metadata: Metadata = {
  title: "Dla rodziców",
  description:
    "Bezpieczeństwo, kontrola rodzicielska i raporty postępów. Dowiedz się, jak TaLu Kids chroni Twoje dziecko.",
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
