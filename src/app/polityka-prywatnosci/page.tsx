import type { Metadata } from "next"
import { Shield } from "lucide-react"

export const metadata: Metadata = {
  title: "Polityka prywatności",
  description:
    "Polityka prywatności Tarnas Kids. Dowiedz się, jak chronimy dane Twojego dziecka.",
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
              Polityka prywatności
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
                1. Informacje ogólne
              </h2>
              <p>
                Tarnas Kids (&ldquo;my&rdquo;, &ldquo;nas&rdquo;, &ldquo;nasz&rdquo;) szanuje prywatność użytkowników,
                a w szczególności dzieci korzystających z naszej aplikacji. Niniejsza
                Polityka Prywatności opisuje, w jaki sposób zbieramy, wykorzystujemy i
                chronimy dane osobowe.
              </p>
            </section>

            <section>
              <h2
                className="text-xl font-bold text-text mb-3"
                style={{ fontFamily: "var(--font-fredoka)" }}
              >
                2. Zgodność z RODO i COPPA
              </h2>
              <p>
                Nasza aplikacja jest w pełni zgodna z Rozporządzeniem o Ochronie
                Danych Osobowych (RODO) oraz amerykańską ustawą COPPA (Children&apos;s
                Online Privacy Protection Act). Nie zbieramy danych osobowych
                dzieci bez wyraźnej zgody rodzica lub opiekuna prawnego.
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
                <li>Adres e-mail rodzica (do założenia konta i komunikacji)</li>
                <li>Postępy dziecka w nauce (lokalnie i w chmurze po synchronizacji)</li>
                <li>Anonimowe dane analityczne (czas użytkowania, popularne funkcje)</li>
              </ul>
              <p className="mt-3">
                <strong>NIE zbieramy:</strong> imion dzieci, zdjęć, lokalizacji,
                numerów telefonów ani żadnych danych umożliwiających identyfikację
                dziecka.
              </p>
            </section>

            <section>
              <h2
                className="text-xl font-bold text-text mb-3"
                style={{ fontFamily: "var(--font-fredoka)" }}
              >
                4. Bezpieczeństwo danych
              </h2>
              <p>
                Wszystkie dane są szyfrowane zarówno podczas przesyłania (TLS 1.3),
                jak i podczas przechowywania (AES-256). Korzystamy z Supabase
                jako bezpiecznego backendu z pełną zgodnością SOC 2 Type II.
              </p>
            </section>

            <section>
              <h2
                className="text-xl font-bold text-text mb-3"
                style={{ fontFamily: "var(--font-fredoka)" }}
              >
                5. Prawa użytkownika
              </h2>
              <p>Zgodnie z RODO, masz prawo do:</p>
              <ul className="list-disc pl-6 space-y-2">
                <li>Dostępu do swoich danych</li>
                <li>Sprostowania nieprawidłowych danych</li>
                <li>Usunięcia danych (&ldquo;prawo do bycia zapomnianym&rdquo;)</li>
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
                W sprawach dotyczących prywatności prosimy o kontakt na adres:{" "}
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
