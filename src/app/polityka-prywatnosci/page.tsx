import type { Metadata } from "next"
import { Shield } from "lucide-react"

export const metadata: Metadata = {
  title: "Polityka prywatno\u015Bci",
  description:
    "Polityka prywatno\u015Bci Tarnas Kids. Dowiedz si\u0119, jak chronimy dane Twojego dziecka.",
}

export default function PrivacyPolicyPage() {
  return (
    <main className="min-h-screen pt-28 pb-20">
      <div className="mx-auto max-w-3xl px-6">
        <div className="mb-8 flex items-center gap-3">
          <div className="flex h-12 w-12 items-center justify-center rounded-2xl bg-gradient-to-br from-purple-500 to-pink-500">
            <Shield className="h-6 w-6 text-white" />
          </div>
          <div>
            <h1
              className="text-3xl font-bold text-text"
              style={{ fontFamily: "var(--font-fredoka)" }}
            >
              Polityka prywatno\u015Bci
            </h1>
            <p className="text-sm text-text-muted">
              Ostatnia aktualizacja: 1 lutego 2026
            </p>
          </div>
        </div>

        <div className="prose prose-lg max-w-none">
          <div className="space-y-8 text-text-light leading-relaxed">
            <section>
              <h2
                className="text-xl font-bold text-text mb-3"
                style={{ fontFamily: "var(--font-fredoka)" }}
              >
                1. Informacje og\u00F3lne
              </h2>
              <p>
                Tarnas Kids (&ldquo;my&rdquo;, &ldquo;nas&rdquo;, &ldquo;nasz&rdquo;) szanuje prywatno\u015B\u0107 u\u017Cytkownik\u00F3w,
                a w szczeg\u00F3lno\u015Bci dzieci korzystaj\u0105cych z naszej aplikacji. Niniejsza
                Polityka Prywatno\u015Bci opisuje, w jaki spos\u00F3b zbieramy, wykorzystujemy i
                chronimy dane osobowe.
              </p>
            </section>

            <section>
              <h2
                className="text-xl font-bold text-text mb-3"
                style={{ fontFamily: "var(--font-fredoka)" }}
              >
                2. Zgodno\u015B\u0107 z RODO i COPPA
              </h2>
              <p>
                Nasza aplikacja jest w pe\u0142ni zgodna z Rozporz\u0105dzeniem o Ochronie
                Danych Osobowych (RODO) oraz ameryka\u0144sk\u0105 ustaw\u0105 COPPA (Children&apos;s
                Online Privacy Protection Act). Nie zbieramy danych osobowych
                dzieci bez wyra\u017Anej zgody rodzica lub opiekuna prawnego.
              </p>
            </section>

            <section>
              <h2
                className="text-xl font-bold text-text mb-3"
                style={{ fontFamily: "var(--font-fredoka)" }}
              >
                3. Jakie dane zbieramy
              </h2>
              <ul className="list-disc pl-6 space-y-2">
                <li>Adres e-mail rodzica (do za\u0142o\u017Cenia konta i komunikacji)</li>
                <li>Post\u0119py dziecka w nauce (lokalnie i w chmurze po synchronizacji)</li>
                <li>Anonimowe dane analityczne (czas u\u017Cytkowania, popularne funkcje)</li>
              </ul>
              <p className="mt-3">
                <strong>NIE zbieramy:</strong> imion dzieci, zdj\u0119\u0107, lokalizacji,
                numer\u00F3w telefon\u00F3w ani \u017Cadnych danych umo\u017Cliwiaj\u0105cych identyfikacj\u0119
                dziecka.
              </p>
            </section>

            <section>
              <h2
                className="text-xl font-bold text-text mb-3"
                style={{ fontFamily: "var(--font-fredoka)" }}
              >
                4. Bezpiecze\u0144stwo danych
              </h2>
              <p>
                Wszystkie dane s\u0105 szyfrowane zar\u00F3wno podczas przesy\u0142ania (TLS 1.3),
                jak i podczas przechowywania (AES-256). Korzystamy z Supabase
                jako bezpiecznego backendu z pe\u0142n\u0105 zgodno\u015Bci\u0105 SOC 2 Type II.
              </p>
            </section>

            <section>
              <h2
                className="text-xl font-bold text-text mb-3"
                style={{ fontFamily: "var(--font-fredoka)" }}
              >
                5. Prawa u\u017Cytkownika
              </h2>
              <p>Zgodnie z RODO, masz prawo do:</p>
              <ul className="list-disc pl-6 space-y-2">
                <li>Dost\u0119pu do swoich danych</li>
                <li>Sprostowania nieprawid\u0142owych danych</li>
                <li>Usuni\u0119cia danych (&ldquo;prawo do bycia zapomnianym&rdquo;)</li>
                <li>Przenoszenia danych</li>
                <li>Sprzeciwu wobec przetwarzania</li>
              </ul>
            </section>

            <section>
              <h2
                className="text-xl font-bold text-text mb-3"
                style={{ fontFamily: "var(--font-fredoka)" }}
              >
                6. Kontakt
              </h2>
              <p>
                W sprawach dotycz\u0105cych prywatno\u015Bci prosimy o kontakt na adres:{" "}
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
      </div>
    </main>
  )
}
