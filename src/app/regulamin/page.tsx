import type { Metadata } from "next"
import { FileText } from "lucide-react"

export const metadata: Metadata = {
  title: "Regulamin",
  description: "Regulamin korzystania z aplikacji Tarnas Kids.",
}

export default function TermsPage() {
  return (
    <main className="min-h-screen pt-28 pb-20">
      <div className="mx-auto max-w-3xl px-6">
        <div className="mb-8 flex items-center gap-3">
          <div className="flex h-12 w-12 items-center justify-center rounded-2xl bg-gradient-to-br from-teal-500 to-green-400">
            <FileText className="h-6 w-6 text-white" />
          </div>
          <div>
            <h1
              className="text-3xl font-bold text-text"
              style={{ fontFamily: "var(--font-fredoka)" }}
            >
              Regulamin
            </h1>
            <p className="text-sm text-text-muted">
              Ostatnia aktualizacja: 1 lutego 2026
            </p>
          </div>
        </div>

        <div className="space-y-8 text-text-light leading-relaxed">
          <section>
            <h2
              className="text-xl font-bold text-text mb-3"
              style={{ fontFamily: "var(--font-fredoka)" }}
            >
              1. Postanowienia og\u00F3lne
            </h2>
            <p>
              Niniejszy regulamin okre\u015Bla zasady korzystania z aplikacji Tarnas
              Kids. Korzystaj\u0105c z aplikacji, akceptujesz poni\u017Csze warunki.
            </p>
          </section>

          <section>
            <h2
              className="text-xl font-bold text-text mb-3"
              style={{ fontFamily: "var(--font-fredoka)" }}
            >
              2. Korzystanie z aplikacji
            </h2>
            <p>
              Tarnas Kids jest przeznaczony dla dzieci w wieku 4-8 lat pod
              nadzorem rodzica lub opiekuna. Rodzic/opiekun jest odpowiedzialny
              za za\u0142o\u017Cenie konta i nadz\u00F3r nad korzystaniem z aplikacji.
            </p>
          </section>

          <section>
            <h2
              className="text-xl font-bold text-text mb-3"
              style={{ fontFamily: "var(--font-fredoka)" }}
            >
              3. Tre\u015Bci
            </h2>
            <p>
              Wszystkie tre\u015Bci w aplikacji s\u0105 odpowiednie dla dzieci i zosta\u0142y
              zweryfikowane przez zesp\u00F3\u0142 pedagog\u00F3w. Aplikacja nie zawiera reklam,
              link\u00F3w zewn\u0119trznych ani tre\u015Bci nieodpowiednich dla grupy wiekowej.
            </p>
          </section>

          <section>
            <h2
              className="text-xl font-bold text-text mb-3"
              style={{ fontFamily: "var(--font-fredoka)" }}
            >
              4. W\u0142asno\u015B\u0107 intelektualna
            </h2>
            <p>
              Wszelkie tre\u015Bci, grafiki, d\u017Awi\u0119ki i kod \u017Ar\u00F3d\u0142owy aplikacji Tarnas
              Kids s\u0105 chronione prawem autorskim i stanowi\u0105 w\u0142asno\u015B\u0107 tw\u00F3rc\u00F3w
              aplikacji.
            </p>
          </section>

          <section>
            <h2
              className="text-xl font-bold text-text mb-3"
              style={{ fontFamily: "var(--font-fredoka)" }}
            >
              5. Kontakt
            </h2>
            <p>
              Pytania dotycz\u0105ce regulaminu prosimy kierowa\u0107 na:{" "}
              <a
                href="mailto:kontakt@tarnaskids.pl"
                className="text-pink-500 hover:underline font-semibold"
              >
                kontakt@tarnaskids.pl
              </a>
            </p>
          </section>
        </div>
      </div>
    </main>
  )
}
