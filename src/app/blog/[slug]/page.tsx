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
    title: "Jak skutecznie nauczy\u0107 dziecko liter?",
    date: "2026-01-28",
    readTime: "5 min",
    category: "Edukacja",
    content: `
Nauka liter to jeden z najwa\u017Cniejszych etap\u00F3w w rozwoju dziecka. Oto 5 sprawdzonych metod:

**1. Multisensoryczne podej\u015Bcie**
Dzieci ucz\u0105 si\u0119 najlepiej, gdy angażuj\u0105 wiele zmys\u0142\u00F3w jednocze\u015Bnie. W Tarnas Kids dziecko \u015Bledzi liter\u0119 palcem po ekranie, s\u0142yszy jej brzmienie i widzi animacj\u0119 nagrody.

**2. Powtarzanie w kontekście zabawy**
Zamiast nudnych powt\u00F3rek, ka\u017Cda litera to mini-przygoda. Dziecko nie czuje, \u017Ce si\u0119 uczy \u2013 po prostu si\u0119 bawi.

**3. System nagr\u00F3d**
Gwiazdki, odznaki i post\u0119p ewolucji zwierzaka \u2013 pozytywne wzmocnienia motywuj\u0105 do dalszej nauki.

**4. W\u0142asne tempo**
Ka\u017Cde dziecko uczy si\u0119 inaczej. Tarnas Kids nie wymusza tempa \u2013 dziecko mo\u017Ce powtarza\u0107 literki tyle razy, ile potrzebuje.

**5. Zaangażowanie rodzica**
Panel rodzica pozwala \u015Bledzi\u0107 post\u0119py i wsp\u00F3lnie cieszy\u0107 si\u0119 z osi\u0105gni\u0119\u0107 dziecka.
    `,
  },
  "bezpieczenstwo-dzieci-w-sieci": {
    title: "Bezpiecze\u0144stwo dzieci w sieci - poradnik dla rodzic\u00F3w",
    date: "2026-01-20",
    readTime: "7 min",
    category: "Bezpiecze\u0144stwo",
    content: `
Bezpiecze\u0144stwo cyfrowe dzieci to priorytet ka\u017Cdego rodzica. Oto na co zwr\u00F3ci\u0107 uwag\u0119:

**Polityka prywatno\u015Bci**
Zawsze czytaj polityk\u0119 prywatno\u015Bci aplikacji dla dzieci. Szukaj zgodno\u015Bci z RODO i COPPA.

**Reklamy i zakupy**
Unikaj aplikacji z reklamami targetowanymi i ukrytymi mikrop\u0142atno\u015Bciami. W Tarnas Kids nie ma \u017Cadnych reklam.

**Kontrola rodzicielska**
Dobra aplikacja oferuje panel rodzica z mo\u017Cliwo\u015Bci\u0105 ustawiania limit\u00F3w czasu i \u015Bledzenia post\u0119p\u00F3w.

**Szyfrowanie danych**
Dane dziecka musz\u0105 by\u0107 szyfrowane zar\u00F3wno podczas przesy\u0142ania, jak i przechowywania.
    `,
  },
  "gamifikacja-w-edukacji": {
    title: "Gamifikacja w edukacji - dlaczego dzia\u0142a?",
    date: "2026-01-12",
    readTime: "6 min",
    category: "Nauka",
    content: `
Badania naukowe potwierdzaj\u0105, \u017Ce gamifikacja znacz\u0105co poprawia efekty nauki u dzieci.

**Co m\u00F3wi\u0105 badania?**
Uniwersytet Stanford wykaza\u0142, \u017Ce dzieci ucz\u0105ce si\u0119 przez gry zapamiętuj\u0105 o 40% wi\u0119cej materia\u0142u.

**Dopamina i motywacja**
System nagr\u00F3d w grach aktywuje uk\u0142ad dopaminowy, tworz\u0105c pozytywne skojarzenia z nauk\u0105.

**Ewolucja zwierzaka w Tarnas Kids**
Nasz system ewolucji to przyk\u0142ad gamifikacji \u2013 dziecko uczy si\u0119 liter, bo chce zobaczy\u0107 jak jego zwierzak ewoluuje.

**Flow state**
Dobre gry edukacyjne utrzymuj\u0105 dziecko w stanie flow \u2013 zadania nie s\u0105 ani za \u0142atwe, ani za trudne.
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
