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
              1. Postanowienia ogólne
            </h2>
            <p>
              Niniejszy regulamin określa zasady korzystania z aplikacji Tarnas
              Kids. Korzystając z aplikacji, akceptujesz poniższe warunki.
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
              za założenie konta i nadzór nad korzystaniem z aplikacji.
            </p>
          </section>

          <section>
            <h2
              className="text-xl font-bold text-text mb-3"
              style={{ fontFamily: "var(--font-fredoka)" }}
            >
              3. Treści
            </h2>
            <p>
              Wszystkie treści w aplikacji są odpowiednie dla dzieci i zostały
              zweryfikowane przez zespół pedagogów. Aplikacja nie zawiera reklam,
              linków zewnętrznych ani treści nieodpowiednich dla grupy wiekowej.
            </p>
          </section>

          <section>
            <h2
              className="text-xl font-bold text-text mb-3"
              style={{ fontFamily: "var(--font-fredoka)" }}
            >
              4. Własność intelektualna
            </h2>
            <p>
              Wszelkie treści, grafiki, dźwięki i kod źródłowy aplikacji Tarnas
              Kids są chronione prawem autorskim i stanowią własność twórców
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
              Pytania dotyczące regulaminu prosimy kierować na:{" "}
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
