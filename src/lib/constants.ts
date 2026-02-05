export const SITE_CONFIG = {
  name: "Tarnas Kids",
  tagline: "Partner Twojego Dziecka",
  description:
    "Aplikacja edukacyjna dla dzieci 4-8 lat. Gry, zabawy, bajki i rozwoj przez zabaw\u0119 z wirtualnym zwierzakiem.",
  url: "https://tarnaskids.pl",
  email: "kontakt@tarnaskids.pl",
  ageRange: "4-8 lat",
  copyright: `\u00A9 ${new Date().getFullYear()} Tarnas Kids. Wszelkie prawa zastrze\u017Cone.`,
} as const

export const NAV_LINKS = [
  { label: "Funkcje", href: "#funkcje" },
  { label: "Jak to dzia\u0142a", href: "#jak-to-dziala" },
  { label: "Przewodnicy", href: "#przewodnicy" },
  { label: "Dla rodzic\u00F3w", href: "#dla-rodzicow" },
  { label: "FAQ", href: "#faq" },
] as const

export const FEATURES = [
  {
    title: "Gry edukacyjne",
    description:
      "Interaktywne gry rozwijaj\u0105ce logiczne my\u015Blenie, pami\u0119\u0107 i zdolno\u015Bci manualne. 7 r\u00F3\u017Cnych gier dostosowanych do wieku dziecka.",
    icon: "Gamepad2" as const,
    color: "pink" as const,
  },
  {
    title: "Nauka pisania",
    description:
      "Ca\u0142y polski alfabet od A do \u017B z systemem waypoint\u00F3w. Dziecko \u015Bledzi literki palcem i zdobywa nagrody za ka\u017Cd\u0105 opanowan\u0105.",
    icon: "PenTool" as const,
    color: "teal" as const,
  },
  {
    title: "Wirtualny zwierzak",
    description:
      "Magiczne jajko, kt\u00F3re ro\u015Bnie razem z wiedz\u0105 dziecka. Karm, baw si\u0119 i obserwuj jak Tw\u00F3j pupil ewoluuje przez 4 fazy!",
    icon: "Heart" as const,
    color: "purple" as const,
  },
  {
    title: "Rozw\u00F3j kreatywno\u015Bci",
    description:
      "Rysowanie, szlaczki, kolorowanki i zadania tworcze. Wspieramy artystyczne talenty ka\u017Cdego dziecka.",
    icon: "Palette" as const,
    color: "yellow" as const,
  },
  {
    title: "Bezpieczna przestrze\u0144",
    description:
      "Zero reklam, zero ukrytych p\u0142atno\u015Bci. Kontrola rodzicielska z bramk\u0105 4-sekundow\u0105. Pe\u0142na zgodno\u015B\u0107 z RODO i COPPA.",
    icon: "Shield" as const,
    color: "green" as const,
  },
  {
    title: "Bajki i opowiadania",
    description:
      "Interaktywne historie z Lumi i Taro, kt\u00F3re rozwijaj\u0105 wyobra\u017Ani\u0119 i ucz\u0105 warto\u015Bci. Idealne na dobranoc.",
    icon: "BookOpen" as const,
    color: "orange" as const,
  },
] as const

export const EVOLUTION_STEPS = [
  {
    emoji: "\uD83E\uDD5A",
    title: "Opiekuj si\u0119",
    description:
      "Karm, myj i baw si\u0119 ze swoim jajkiem. Ono potrzebuje mi\u0142o\u015Bci, \u017Ceby rosn\u0105\u0107!",
    color: "yellow" as const,
  },
  {
    emoji: "\u26A1",
    title: "Ucz si\u0119",
    description:
      "Rozwi\u0105zuj zadania edukacyjne, aby zdobywa\u0107 magiczn\u0105 energi\u0119 potrzebn\u0105 do wyklucia.",
    color: "teal" as const,
  },
  {
    emoji: "\uD83D\uDC23",
    title: "Wykluwaj!",
    description:
      "Zobacz moment p\u0119kni\u0119cia skorupki i poznaj swojego unikalnego zwierzaka!",
    color: "purple" as const,
  },
] as const

export const TESTIMONIALS = [
  {
    name: "Anna K.",
    role: "Mama 5-latka",
    text: "Maks sam prosi o \u201Ete gry z jajkiem\u201D. Nie wierzy\u0142am, \u017Ce nauka liter mo\u017Ce by\u0107 tak wci\u0105gaj\u0105ca. Po 2 tygodniach zna ju\u017C ca\u0142y alfabet!",
    avatar: "AK",
    rating: 5,
  },
  {
    name: "Tomek W.",
    role: "Tata 6-latki",
    text: "Wreszcie aplikacja bez reklam i irytuj\u0105cych powiadomie\u0144. Zuzia uwielbia rysowanie szlaczk\u00F3w, a ja mam spok\u00F3j, \u017Ce jest bezpieczna.",
    avatar: "TW",
    rating: 5,
  },
  {
    name: "Marta D.",
    role: "Mama 4-latka i 7-latki",
    text: "Obie c\u00F3rki uwielbiaj\u0105 Tarnas Kids, mimo r\u00F3\u017Cnicy wieku. Starsza pomaga m\u0142odszej opiewa\u0107 si\u0119 nad zwierzakiem. Cudowne!",
    avatar: "MD",
    rating: 5,
  },
] as const

export const FAQ_ITEMS = [
  {
    question: "Dla jakiego wieku jest Tarnas Kids?",
    answer:
      "Tarnas Kids jest zaprojektowane dla dzieci w wieku 4-8 lat. Zadania s\u0105 dostosowane do poziomu rozwoju dziecka i stopniowo si\u0119 utrudniaj\u0105.",
  },
  {
    question: "Czy aplikacja jest bezpieczna dla mojego dziecka?",
    answer:
      "Absolutnie! Nie ma \u017Cadnych reklam, ukrytych p\u0142atno\u015Bci ani link\u00F3w zewn\u0119trznych. Aplikacja jest w pe\u0142ni zgodna z RODO i COPPA. Panel rodzica jest chroniony 4-sekundow\u0105 bramk\u0105 bezpiecze\u0144stwa.",
  },
  {
    question: "Jak dzia\u0142a system zwierzaka?",
    answer:
      "Dziecko otrzymuje magiczne jajko, kt\u00F3re ewoluuje w miar\u0119 nauki. Karmienie, mycie i zabawa z jajkiem to codzienne aktywno\u015Bci, a rozwi\u0105zywanie zada\u0144 edukacyjnych daje energi\u0119 do wyklucia. Zwierzak przechodzi przez 4 fazy ewolucji!",
  },
  {
    question: "Na jakich urz\u0105dzeniach dzia\u0142a aplikacja?",
    answer:
      "Tarnas Kids dzia\u0142a na telefonach i tabletach z Androidem oraz iOS. Aplikacja jest zoptymalizowana pod tablety \u2013 idealne do nauki pisania palcem po ekranie.",
  },
  {
    question: "Czy mog\u0119 \u015Bledzi\u0107 post\u0119py mojego dziecka?",
    answer:
      "Tak! Panel rodzica pozwala zobaczy\u0107, kt\u00F3re litery dziecko opanowa\u0142o, ile czasu sp\u0119dza w aplikacji i jakie nagrody zdoby\u0142o. Raporty s\u0105 przejrzyste i \u0142atwe do zrozumienia.",
  },
  {
    question: "Ile kosztuje Tarnas Kids?",
    answer:
      "Podstawowa wersja aplikacji jest darmowa i zawiera pe\u0142en zestaw gier edukacyjnych. W przysz\u0142o\u015Bci planujemy wersj\u0119 premium z dodatkowymi tre\u015Bciami i zwierzakami.",
  },
] as const
