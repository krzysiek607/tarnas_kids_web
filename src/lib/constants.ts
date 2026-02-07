export const SITE_CONFIG = {
  name: "TaLu Kids",
  tagline: "Partner Twojego Dziecka",
  description:
    "Aplikacja edukacyjna dla dzieci 4-8 lat. Gry, zabawy, bajki i rozwoj przez zabawę z wirtualnym zwierzakiem.",
  url: "https://talukids.pl",
  email: "kontakt@talukids.pl",
  ageRange: "4-8 lat",
  copyright: `© ${new Date().getFullYear()} TaLu Kids. Wszelkie prawa zastrzeżone.`,
} as const

export const NAV_LINKS = [
  { label: "Funkcje", href: "#funkcje" },
  { label: "Jak to działa", href: "#jak-to-dziala" },
  { label: "Przewodnicy", href: "#przewodnicy" },
  { label: "Dla rodziców", href: "#dla-rodzicow" },
  { label: "FAQ", href: "#faq" },
] as const

export const FEATURES = [
  {
    title: "Gry edukacyjne",
    description:
      "Interaktywne gry rozwijające logiczne myślenie, pamięć i zdolności manualne. 7 różnych gier dostosowanych do wieku dziecka.",
    icon: "Gamepad2" as const,
    color: "pink" as const,
  },
  {
    title: "Nauka pisania",
    description:
      "Cały polski alfabet od A do Ż z systemem waypointów. Dziecko śledzi literki palcem i zdobywa nagrody za każdą opanowaną.",
    icon: "PenTool" as const,
    color: "teal" as const,
  },
  {
    title: "Wirtualny zwierzak",
    description:
      "Magiczne jajko, które rośnie razem z wiedzą dziecka. Karm, baw się i obserwuj jak Twój pupil ewoluuje przez 4 fazy!",
    icon: "Heart" as const,
    color: "purple" as const,
  },
  {
    title: "Rozwój kreatywności",
    description:
      "Rysowanie, szlaczki, kolorowanki i zadania tworcze. Wspieramy artystyczne talenty każdego dziecka.",
    icon: "Palette" as const,
    color: "yellow" as const,
  },
  {
    title: "Bezpieczna przestrzeń",
    description:
      "Zero reklam, zero ukrytych płatności. Kontrola rodzicielska z bramką 4-sekundową. Pełna zgodność z RODO i COPPA.",
    icon: "Shield" as const,
    color: "green" as const,
  },
  {
    title: "Bajki i opowiadania",
    description:
      "Interaktywne historie z Lumi i Taro, które rozwijają wyobraźnię i uczą wartości. Idealne na dobranoc.",
    icon: "BookOpen" as const,
    color: "orange" as const,
  },
] as const

export const EVOLUTION_STEPS = [
  {
    emoji: "\uD83E\uDD5A",
    title: "Opiekuj się",
    description:
      "Karm, myj i baw się ze swoim jajkiem. Ono potrzebuje miłości, żeby rosnąć!",
    color: "yellow" as const,
  },
  {
    emoji: "\u26A1",
    title: "Ucz się",
    description:
      "Rozwiązuj zadania edukacyjne, aby zdobywać magiczną energię potrzebną do wyklucia.",
    color: "teal" as const,
  },
  {
    emoji: "\uD83D\uDC23",
    title: "Wykluwaj!",
    description:
      "Zobacz moment pęknięcia skorupki i poznaj swojego unikalnego zwierzaka!",
    color: "purple" as const,
  },
] as const

export const TESTIMONIALS = [
  {
    name: "Anna K.",
    role: "Mama 5-latka",
    text: "Maks sam prosi o \u201Ete gry z jajkiem\u201D. Nie wierzyłam, że nauka liter może być tak wciągająca. Po 2 tygodniach zna już cały alfabet!",
    avatar: "AK",
    rating: 5,
  },
  {
    name: "Tomek W.",
    role: "Tata 6-latki",
    text: "Wreszcie aplikacja bez reklam i irytujących powiadomień. Zuzia uwielbia rysowanie szlaczków, a ja mam spokój, że jest bezpieczna.",
    avatar: "TW",
    rating: 5,
  },
  {
    name: "Marta D.",
    role: "Mama 4-latka i 7-latki",
    text: "Obie córki uwielbiają TaLu Kids, mimo różnicy wieku. Starsza pomaga młodszej opiewać się nad zwierzakiem. Cudowne!",
    avatar: "MD",
    rating: 5,
  },
] as const

export const FAQ_ITEMS = [
  {
    question: "Dla jakiego wieku jest TaLu Kids?",
    answer:
      "TaLu Kids jest zaprojektowane dla dzieci w wieku 4-8 lat. Zadania są dostosowane do poziomu rozwoju dziecka i stopniowo się utrudniają.",
  },
  {
    question: "Czy aplikacja jest bezpieczna dla mojego dziecka?",
    answer:
      "Absolutnie! Nie ma żadnych reklam, ukrytych płatności ani linków zewnętrznych. Aplikacja jest w pełni zgodna z RODO i COPPA. Panel rodzica jest chroniony 4-sekundową bramką bezpieczeństwa.",
  },
  {
    question: "Jak działa system zwierzaka?",
    answer:
      "Dziecko otrzymuje magiczne jajko, które ewoluuje w miarę nauki. Karmienie, mycie i zabawa z jajkiem to codzienne aktywności, a rozwiązywanie zadań edukacyjnych daje energię do wyklucia. Zwierzak przechodzi przez 4 fazy ewolucji!",
  },
  {
    question: "Na jakich urządzeniach działa aplikacja?",
    answer:
      "TaLu Kids działa na telefonach i tabletach z Androidem oraz iOS. Aplikacja jest zoptymalizowana pod tablety – idealne do nauki pisania palcem po ekranie.",
  },
  {
    question: "Czy mogę śledzić postępy mojego dziecka?",
    answer:
      "Tak! Panel rodzica pozwala zobaczyć, które litery dziecko opanowało, ile czasu spędza w aplikacji i jakie nagrody zdobyło. Raporty są przejrzyste i łatwe do zrozumienia.",
  },
  {
    question: "Ile kosztuje TaLu Kids?",
    answer:
      "Podstawowa wersja aplikacji jest darmowa i zawiera pełen zestaw gier edukacyjnych. W przyszłości planujemy wersję premium z dodatkowymi treściami i zwierzakami.",
  },
] as const
