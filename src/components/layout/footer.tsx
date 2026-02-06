import { Sparkles, Mail, Heart } from "lucide-react"
import { SITE_CONFIG, NAV_LINKS } from "@/lib/constants"
import { href } from "@/lib/utils"

export function Footer() {
  return (
    <footer className="relative border-t border-pink-100 bg-white">
      <div className="absolute inset-0 bg-gradient-to-b from-transparent to-pink-50/30 pointer-events-none" />

      <div className="relative mx-auto max-w-7xl px-6 py-16">
        <div className="grid gap-12 md:grid-cols-3">
          {/* Brand */}
          <div className="space-y-4">
            <a href={href("/")} className="flex items-center gap-2">
              <div className="flex h-10 w-10 items-center justify-center rounded-xl bg-gradient-to-br from-pink-500 to-purple-500">
                <Sparkles className="h-5 w-5 text-white" />
              </div>
              <span
                className="text-2xl font-bold bg-gradient-to-r from-pink-500 via-purple-500 to-teal-500 bg-clip-text text-transparent"
                style={{ fontFamily: "var(--font-fredoka)" }}
              >
                {SITE_CONFIG.name}
              </span>
            </a>
            <p className="text-sm text-text-muted leading-relaxed max-w-xs">
              {SITE_CONFIG.tagline} w codziennym rozwoju. Bezpieczna edukacja
              przez zabawę dla dzieci {SITE_CONFIG.ageRange}.
            </p>
          </div>

          {/* Links */}
          <div className="space-y-4">
            <h3
              className="text-sm font-bold uppercase tracking-wider text-text-light"
              style={{ fontFamily: "var(--font-baloo)" }}
            >
              Nawigacja
            </h3>
            <ul className="space-y-2">
              {NAV_LINKS.map((link) => (
                <li key={link.href}>
                  <a
                    href={link.href}
                    className="text-sm text-text-muted hover:text-pink-500 transition-colors"
                  >
                    {link.label}
                  </a>
                </li>
              ))}
            </ul>
          </div>

          {/* Legal & Contact */}
          <div className="space-y-4">
            <h3
              className="text-sm font-bold uppercase tracking-wider text-text-light"
              style={{ fontFamily: "var(--font-baloo)" }}
            >
              Informacje
            </h3>
            <ul className="space-y-2">
              <li>
                <a
                  href={href("/polityka-prywatnosci")}
                  className="text-sm text-text-muted hover:text-pink-500 transition-colors"
                >
                  Polityka prywatności
                </a>
              </li>
              <li>
                <a
                  href={href("/regulamin")}
                  className="text-sm text-text-muted hover:text-pink-500 transition-colors"
                >
                  Regulamin
                </a>
              </li>
              <li>
                <a
                  href={`mailto:${SITE_CONFIG.email}`}
                  className="inline-flex items-center gap-1.5 text-sm text-text-muted hover:text-pink-500 transition-colors"
                >
                  <Mail className="h-3.5 w-3.5" />
                  {SITE_CONFIG.email}
                </a>
              </li>
            </ul>
          </div>
        </div>

        <div className="mt-12 flex flex-col items-center justify-between gap-4 border-t border-pink-50 pt-8 sm:flex-row">
          <p className="text-xs text-text-muted">{SITE_CONFIG.copyright}</p>
          <p className="flex items-center gap-1 text-xs text-text-muted">
            Stworzone z <Heart className="h-3 w-3 fill-pink-500 text-pink-500" /> dla
            dzieci
          </p>
        </div>
      </div>
    </footer>
  )
}
