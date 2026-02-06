import type { Metadata } from "next"
import { ArrowLeft, Calendar, Clock } from "lucide-react"
import { notFound } from "next/navigation"
import { href } from "@/lib/utils"

const posts: Record<
  string,
  {
    title: string
    date: string
    readTime: string
    category: string
    content: string
  }
> = {
  "jak-nauczyc-dziecko-liter": {
    title: "Jak skutecznie nauczyć dziecko liter?",
    date: "2026-01-28",
    readTime: "5 min",
    category: "Edukacja",
    content: `
Nauka liter to jeden z najważniejszych etapów w rozwoju dziecka. Oto 5 sprawdzonych metod:

**1. Multisensoryczne podejście**
Dzieci uczą się najlepiej, gdy angażują wiele zmysłów jednocześnie. W Tarnas Kids dziecko śledzi literę palcem po ekranie, słyszy jej brzmienie i widzi animację nagrody.

**2. Powtarzanie w kontekście zabawy**
Zamiast nudnych powtórek, każda litera to mini-przygoda. Dziecko nie czuje, że się uczy – po prostu się bawi.

**3. System nagród**
Gwiazdki, odznaki i postęp ewolucji zwierzaka – pozytywne wzmocnienia motywują do dalszej nauki.

**4. Własne tempo**
Każde dziecko uczy się inaczej. Tarnas Kids nie wymusza tempa – dziecko może powtarzać literki tyle razy, ile potrzebuje.

**5. Zaangażowanie rodzica**
Panel rodzica pozwala śledzić postępy i wspólnie cieszyć się z osiągnięć dziecka.
    `,
  },
  "bezpieczenstwo-dzieci-w-sieci": {
    title: "Bezpieczeństwo dzieci w sieci - poradnik dla rodziców",
    date: "2026-01-20",
    readTime: "7 min",
    category: "Bezpieczeństwo",
    content: `
Bezpieczeństwo cyfrowe dzieci to priorytet każdego rodzica. Oto na co zwrócić uwagę:

**Polityka prywatności**
Zawsze czytaj politykę prywatności aplikacji dla dzieci. Szukaj zgodności z RODO i COPPA.

**Reklamy i zakupy**
Unikaj aplikacji z reklamami targetowanymi i ukrytymi mikropłatnościami. W Tarnas Kids nie ma żadnych reklam.

**Kontrola rodzicielska**
Dobra aplikacja oferuje panel rodzica z możliwością ustawiania limitów czasu i śledzenia postępów.

**Szyfrowanie danych**
Dane dziecka muszą być szyfrowane zarówno podczas przesyłania, jak i przechowywania.
    `,
  },
  "gamifikacja-w-edukacji": {
    title: "Gamifikacja w edukacji - dlaczego działa?",
    date: "2026-01-12",
    readTime: "6 min",
    category: "Nauka",
    content: `
Badania naukowe potwierdzają, że gamifikacja znacząco poprawia efekty nauki u dzieci.

**Co mówią badania?**
Uniwersytet Stanford wykazał, że dzieci uczące się przez gry zapamiętują o 40% więcej materiału.

**Dopamina i motywacja**
System nagród w grach aktywuje układ dopaminowy, tworząc pozytywne skojarzenia z nauką.

**Ewolucja zwierzaka w Tarnas Kids**
Nasz system ewolucji to przykład gamifikacji – dziecko uczy się liter, bo chce zobaczyć jak jego zwierzak ewoluuje.

**Flow state**
Dobre gry edukacyjne utrzymują dziecko w stanie flow – zadania nie są ani za łatwe, ani za trudne.
    `,
  },
}

export async function generateStaticParams() {
  return Object.keys(posts).map((slug) => ({ slug }))
}

export async function generateMetadata({
  params,
}: {
  params: Promise<{ slug: string }>
}): Promise<Metadata> {
  const { slug } = await params
  const post = posts[slug]
  if (!post) return { title: "Nie znaleziono" }

  return {
    title: post.title,
    description: post.content.slice(0, 160).trim(),
  }
}

export default async function BlogPostPage({
  params,
}: {
  params: Promise<{ slug: string }>
}) {
  const { slug } = await params
  const post = posts[slug]

  if (!post) {
    notFound()
  }

  return (
    <main className="min-h-screen pt-28 pb-20">
      <article className="mx-auto max-w-3xl px-6">
        <a
          href={href("/blog")}
          className="mb-8 inline-flex items-center gap-2 text-sm font-semibold text-pink-500 hover:text-pink-600 transition-colors"
        >
          <ArrowLeft className="h-4 w-4" />
          Wróć do bloga
        </a>

        <span className="inline-block rounded-full bg-pink-100 px-3 py-1 text-xs font-bold text-pink-600 mb-4">
          {post.category}
        </span>

        <h1
          className="text-3xl font-bold text-text mb-4 sm:text-4xl"
          style={{ fontFamily: "var(--font-fredoka)" }}
        >
          {post.title}
        </h1>

        <div className="mb-8 flex items-center gap-4 text-sm text-text-muted">
          <span className="flex items-center gap-1">
            <Calendar className="h-4 w-4" />
            {new Date(post.date).toLocaleDateString("pl-PL", {
              day: "numeric",
              month: "long",
              year: "numeric",
            })}
          </span>
          <span className="flex items-center gap-1">
            <Clock className="h-4 w-4" />
            {post.readTime}
          </span>
        </div>

        <div className="prose prose-lg max-w-none">
          {post.content.split("\n\n").map((paragraph, i) => {
            if (paragraph.startsWith("**") && paragraph.endsWith("**")) {
              const text = paragraph.replace(/\*\*/g, "")
              return (
                <h2
                  key={i}
                  className="text-xl font-bold text-text mt-8 mb-3"
                  style={{ fontFamily: "var(--font-fredoka)" }}
                >
                  {text}
                </h2>
              )
            }

            const parts = paragraph.split(/(\*\*[^*]+\*\*)/)
            return (
              <p key={i} className="text-text-light leading-relaxed mb-4">
                {parts.map((part, j) =>
                  part.startsWith("**") && part.endsWith("**") ? (
                    <strong key={j} className="font-bold text-text">
                      {part.replace(/\*\*/g, "")}
                    </strong>
                  ) : (
                    <span key={j}>{part}</span>
                  )
                )}
              </p>
            )
          })}
        </div>
      </article>
    </main>
  )
}
