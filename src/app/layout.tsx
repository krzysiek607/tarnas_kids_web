import type { Metadata } from "next"
import { Fredoka, Nunito, Baloo_2 } from "next/font/google"
import { Navbar } from "@/components/layout/navbar"
import { Footer } from "@/components/layout/footer"
import { CookieConsent } from "@/components/ui/cookie-consent"
import "./globals.css"

const fredoka = Fredoka({
  subsets: ["latin", "latin-ext"],
  variable: "--font-fredoka",
  display: "swap",
})

const nunito = Nunito({
  subsets: ["latin", "latin-ext"],
  variable: "--font-nunito",
  display: "swap",
})

const baloo = Baloo_2({
  subsets: ["latin", "latin-ext"],
  variable: "--font-baloo",
  display: "swap",
})

export const metadata: Metadata = {
  metadataBase: new URL("https://tarnaskids.pl"),
  title: {
    default: "Tarnas Kids - Partner Twojego Dziecka | Edukacja przez zabaw\u0119",
    template: "%s | Tarnas Kids",
  },
  description:
    "Aplikacja edukacyjna dla dzieci 4-8 lat. Gry, nauka pisania, wirtualny zwierzak i bezpieczna przestrze\u0144 do rozwoju. Bez reklam, zgodna z RODO.",
  keywords: [
    "edukacja dzieci",
    "gry edukacyjne",
    "nauka pisania",
    "aplikacja dla dzieci",
    "nauka liter",
    "gry dla przedszkolak\u00F3w",
    "bezpieczna aplikacja",
    "tarnas kids",
    "wirtualny zwierzak",
    "nauka przez zabaw\u0119",
  ],
  authors: [{ name: "Tarnas Kids" }],
  creator: "Tarnas Kids",
  openGraph: {
    type: "website",
    locale: "pl_PL",
    url: "https://tarnaskids.pl",
    siteName: "Tarnas Kids",
    title: "Tarnas Kids - Partner Twojego Dziecka",
    description:
      "Aplikacja edukacyjna dla dzieci 4-8 lat. Gry, nauka pisania, wirtualny zwierzak i bezpieczna przestrze\u0144 do rozwoju.",
    images: [
      {
        url: "/og-image.png",
        width: 1200,
        height: 630,
        alt: "Tarnas Kids - Edukacja przez zabaw\u0119",
      },
    ],
  },
  twitter: {
    card: "summary_large_image",
    title: "Tarnas Kids - Partner Twojego Dziecka",
    description:
      "Aplikacja edukacyjna dla dzieci 4-8 lat. Gry, nauka pisania i wirtualny zwierzak.",
    images: ["/og-image.png"],
  },
  robots: {
    index: true,
    follow: true,
    googleBot: {
      index: true,
      follow: true,
      "max-video-preview": -1,
      "max-image-preview": "large",
      "max-snippet": -1,
    },
  },
  icons: {
    icon: "/favicon.svg",
    apple: "/apple-touch-icon.png",
  },
}

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode
}>) {
  return (
    <html lang="pl" className={`${fredoka.variable} ${nunito.variable} ${baloo.variable}`}>
      <head>
        <script
          type="application/ld+json"
          dangerouslySetInnerHTML={{
            __html: JSON.stringify({
              "@context": "https://schema.org",
              "@type": "MobileApplication",
              name: "Tarnas Kids",
              operatingSystem: "Android, iOS",
              applicationCategory: "EducationalApplication",
              audience: {
                "@type": "PeopleAudience",
                suggestedMinAge: 4,
                suggestedMaxAge: 8,
              },
              description:
                "Aplikacja edukacyjna dla dzieci 4-8 lat z grami, nauk\u0105 pisania i wirtualnym zwierzakiem.",
              offers: {
                "@type": "Offer",
                price: "0",
                priceCurrency: "PLN",
              },
            }),
          }}
        />
      </head>
      <body className="antialiased">
        <Navbar />
        {children}
        <Footer />
        <CookieConsent />
      </body>
    </html>
  )
}
