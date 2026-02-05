import type { Metadata } from "next"
import { Calendar, Clock, ArrowRight } from "lucide-react"
import { href } from "@/lib/utils"

export const metadata: Metadata = {
  title: "Blog",
  description:
    "Porady dotycz\u0105ce edukacji dzieci, rozw\u00F3j przez zabaw\u0119 i aktualno\u015Bci Tarnas Kids.",
}

const posts = [
  {
    slug: "jak-nauczyc-dziecko-liter",
    title: "Jak skutecznie nauczy\u0107 dziecko liter?",
    excerpt:
      "5 sprawdzonych metod nauki alfabetu, kt\u00F3re sprawiaj\u0105, \u017Ce dzieci ucz\u0105 si\u0119 z rado\u015Bci\u0105. Dowiedz si\u0119, jak Tarnas Kids wspiera ten proces.",
    date: "2026-01-28",
    readTime: "5 min",
    category: "Edukacja",
    categoryColor: "bg-teal-100 text-teal-600",
  },
  {
    slug: "bezpieczenstwo-dzieci-w-sieci",
    title: "Bezpiecze\u0144stwo dzieci w sieci - poradnik dla rodzic\u00F3w",
    excerpt:
      "Jak wybra\u0107 bezpieczn\u0105 aplikacj\u0119 dla dziecka? Na co zwr\u00F3ci\u0107 uwag\u0119 w polityce prywatno\u015Bci? Praktyczny przewodnik.",
    date: "2026-01-20",
    readTime: "7 min",
    category: "Bezpiecze\u0144stwo",
    categoryColor: "bg-purple-100 text-purple-600",
  },
  {
    slug: "gamifikacja-w-edukacji",
    title: "Gamifikacja w edukacji - dlaczego dzia\u0142a?",
    excerpt:
      "Nauka przez zabaw\u0119 to nie tylko has\u0142o. Poznaj badania naukowe, kt\u00F3re potwierdzaj\u0105 skuteczno\u015B\u0107 gamifikacji w edukacji dzieci.",
    date: "2026-01-12",
    readTime: "6 min",
    category: "Nauka",
    categoryColor: "bg-pink-100 text-pink-600",
  },
]

export default function BlogPage() {
  return (
    <main className="min-h-screen pt-28 pb-20">
      <div className="mx-auto max-w-4xl px-6">
        <div className="mb-12 text-center">
          <h1
            className="text-4xl font-bold bg-gradient-to-r from-pink-500 to-purple-500 bg-clip-text text-transparent mb-3 sm:text-5xl"
            style={{ fontFamily: "var(--font-fredoka)" }}
          >
            Blog Tarnas Kids
          </h1>
          <p className="text-lg text-text-muted">
            Porady, inspiracje i aktualno\u015Bci ze \u015Bwiata edukacji dzieci
          </p>
        </div>

        <div className="grid gap-6">
          {posts.map((post) => (
            <a
              key={post.slug}
              href={href(`/blog/${post.slug}`)}
              className="group rounded-3xl border-2 border-gray-100 bg-white p-8 shadow-md transition-all duration-300 hover:-translate-y-1 hover:shadow-xl hover:border-pink-200 block"
            >
              <div className="flex flex-col gap-4 sm:flex-row sm:items-start sm:justify-between">
                <div className="flex-1">
                  <span
                    className={`inline-block rounded-full px-3 py-1 text-xs font-bold ${post.categoryColor} mb-3`}
                  >
                    {post.category}
                  </span>
                  <h2
                    className="text-xl font-bold text-text mb-2 group-hover:text-pink-500 transition-colors"
                    style={{ fontFamily: "var(--font-fredoka)" }}
                  >
                    {post.title}
                  </h2>
                  <p className="text-sm text-text-light leading-relaxed mb-3">
                    {post.excerpt}
                  </p>
                  <div className="flex items-center gap-4 text-xs text-text-muted">
                    <span className="flex items-center gap-1">
                      <Calendar className="h-3.5 w-3.5" />
                      {new Date(post.date).toLocaleDateString("pl-PL", {
                        day: "numeric",
                        month: "long",
                        year: "numeric",
                      })}
                    </span>
                    <span className="flex items-center gap-1">
                      <Clock className="h-3.5 w-3.5" />
                      {post.readTime}
                    </span>
                  </div>
                </div>
                <ArrowRight className="h-5 w-5 shrink-0 text-pink-300 transition-all group-hover:text-pink-500 group-hover:translate-x-1 mt-1" />
              </div>
            </a>
          ))}
        </div>
      </div>
    </main>
  )
}
