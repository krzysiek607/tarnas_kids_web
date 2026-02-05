import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';
import '../services/sound_effects_service.dart';

/// Ekran polityki prywatnosci
/// Dostepny z poziomu strefy rodzica w ustawieniach
class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Polityka Prywatnosci'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () {
            SoundEffectsService.instance.playClick();
            context.pop();
          },
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildCard(
            children: [
              _buildSectionTitle('1. Administrator danych'),
              _buildBody(
                'Administratorem danych osobowych jest tworca aplikacji '
                'Tarnas Kids.\n\n'
                'Kontakt: [UZUPELNIJ_EMAIL]',
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildCard(
            children: [
              _buildSectionTitle('2. Jakie dane zbieramy'),
              _buildBody(
                'Dane zbierane automatycznie:\n\n'
                '  \u2022 Anonimowy identyfikator uzytkownika (UUID) - '
                'niepowiazany z imieniem, nazwiskiem ani zadnymi danymi osobowymi\n'
                '  \u2022 Zdarzenia uzytkowania - informacje o odwiedzanych '
                'ekranach, uruchamianych grach i zdobywanych nagrodach\n'
                '  \u2022 Dane techniczne - typ urzadzenia, wersja systemu '
                'operacyjnego, wersja aplikacji\n'
                '  \u2022 Anonimowe nagrania sesji - sposob nawigacji po '
                'aplikacji (klikniecia, przejscia miedzy ekranami). '
                'Wszystkie teksty sa automatycznie maskowane\n\n'
                'Dane przechowywane lokalnie na urzadzeniu:\n\n'
                '  \u2022 Stan gry (postepy zwierzaka, zebrane nagrody)\n'
                '  \u2022 Preferencje uzytkownika (glosnosc muzyki, efekty dzwiekowe)\n\n'
                'Te dane nie sa wysylane na nasze serwery i pozostaja '
                'wylacznie na urzadzeniu.',
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildCard(
            children: [
              _buildSectionTitle('3. Dane, ktorych NIE zbieramy'),
              _buildBody(
                '  \u2022 Imion, nazwisk ani pseudonimow dzieci\n'
                '  \u2022 Adresow e-mail\n'
                '  \u2022 Numerow telefonow\n'
                '  \u2022 Lokalizacji (GPS)\n'
                '  \u2022 Zdjec ani nagran audio/wideo z kamery/mikrofonu\n'
                '  \u2022 Danych kontaktowych\n'
                '  \u2022 Danych innych aplikacji na urzadzeniu',
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildCard(
            children: [
              _buildSectionTitle('4. Cel zbierania danych'),
              _buildBody(
                'Zebrane dane wykorzystujemy wylacznie w celu:\n\n'
                '  \u2022 Poprawy jakosci i funkcjonalnosci aplikacji\n'
                '  \u2022 Analizy, ktore gry sa najpopularniejsze\n'
                '  \u2022 Wykrywania i naprawiania bledow technicznych\n'
                '  \u2022 Ulepszania doswiadczenia uzytkownika\n\n'
                'Nie wykorzystujemy danych do:\n\n'
                '  \u2022 Reklam targetowanych\n'
                '  \u2022 Profilowania dzieci\n'
                '  \u2022 Sprzedazy danych podmiotom trzecim\n'
                '  \u2022 Kontaktowania sie z uzytkownikami',
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildCard(
            children: [
              _buildSectionTitle('5. Uslugi zewnetrzne'),
              _buildBody(
                'Aplikacja korzysta z nastepujacych uslug zewnetrznych:\n\n'
                '  \u2022 Firebase Analytics (Google) - analityka uzytkowania, '
                'anonimowe zdarzenia\n'
                '  \u2022 Firebase Crashlytics (Google) - raportowanie bledow, '
                'dane o awariach\n'
                '  \u2022 PostHog (UE) - analityka i nagrania sesji, '
                'anonimowe zdarzenia, zamaskowane nagrania\n'
                '  \u2022 Supabase (UE) - przechowywanie postepu gry, '
                'anonimowy identyfikator + stan gry\n\n'
                'Dane przetwarzane przez PostHog i Supabase sa przechowywane '
                'na serwerach w Unii Europejskiej.\n\n'
                'Firebase (Google) przetwarza dane zgodnie z politykami '
                'prywatnosci Google.',
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildCard(
            children: [
              _buildSectionTitle('6. Ochrona danych dzieci (RODO / COPPA)'),
              _buildBody(
                'RODO (Rozporzadzenie UE 2016/679):\n\n'
                '  \u2022 Aplikacja nie zbiera danych osobowych dzieci '
                'w rozumieniu RODO\n'
                '  \u2022 Wszystkie identyfikatory sa anonimowe i losowo generowane\n'
                '  \u2022 Uzytkownik (rodzic/opiekun) ma prawo do usuniecia '
                'wszystkich danych poprzez opcje "Usun wszystkie dane" '
                'w ustawieniach aplikacji\n\n'
                'COPPA (Children\'s Online Privacy Protection Act):\n\n'
                '  \u2022 Aplikacja nie zbiera danych osobowych dzieci '
                'ponizej 13 roku zycia\n'
                '  \u2022 Nie wymagamy rejestracji ani podawania jakichkolwiek '
                'danych osobowych\n'
                '  \u2022 Nie wyswietlamy reklam targetowanych\n'
                '  \u2022 Nie udostepniamy danych podmiotom trzecim '
                'w celach komercyjnych',
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildCard(
            children: [
              _buildSectionTitle('7. Prawa uzytkownika'),
              _buildBody(
                'Jako rodzic lub opiekun prawny dziecka korzystajacego '
                'z aplikacji, przysluguja Ci nastepujace prawa:\n\n'
                '  \u2022 Prawo dostepu - mozesz sprawdzic, jakie dane sa '
                'przechowywane, kontaktujac sie z nami\n'
                '  \u2022 Prawo do usuniecia - mozesz usunac wszystkie dane '
                'z poziomu aplikacji (Ustawienia > Strefa Rodzica > '
                'Usun wszystkie dane) lub kontaktujac sie z nami\n'
                '  \u2022 Prawo do sprzeciwu - mozesz wylaczyc analityke '
                'odinstalowujac aplikacje',
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildCard(
            children: [
              _buildSectionTitle('8. Bezpieczenstwo danych'),
              _buildBody(
                '  \u2022 Komunikacja miedzy aplikacja a serwerami jest '
                'szyfrowana (HTTPS/TLS)\n'
                '  \u2022 Dostep do bazy danych jest chroniony uwierzytelnianiem '
                'i polityka Row Level Security\n'
                '  \u2022 Nie przechowujemy hasel ani danych uwierzytelniajacych\n'
                '  \u2022 Nagrania sesji sa automatycznie maskowane - '
                'teksty nie sa widoczne',
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildCard(
            children: [
              _buildSectionTitle('9. Przechowywanie danych'),
              _buildBody(
                '  \u2022 Dane analityczne sa przechowywane przez okres '
                '12 miesiecy, a nastepnie automatycznie usuwane\n'
                '  \u2022 Dane o postepie gry sa przechowywane do momentu '
                'usuniecia przez uzytkownika\n'
                '  \u2022 Nagrania sesji sa przechowywane przez 30 dni',
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildCard(
            children: [
              _buildSectionTitle('10. Zmiany w Polityce Prywatnosci'),
              _buildBody(
                'O wszelkich zmianach w Polityce Prywatnosci bedziesz '
                'informowany poprzez aktualizacje aplikacji.\n\n'
                'Aktualna wersja Polityki Prywatnosci jest zawsze dostepna '
                'pod adresem: [UZUPELNIJ_URL]',
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildCard(
            children: [
              _buildSectionTitle('11. Kontakt'),
              _buildBody(
                'Jesli masz pytania dotyczace Polityki Prywatnosci lub '
                'chcesz skorzystac z przyslugujacych Ci praw, '
                'skontaktuj sie z nami:\n\n'
                'E-mail: [UZUPELNIJ_EMAIL]',
              ),
            ],
          ),
          const SizedBox(height: 16),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                'Ostatnia aktualizacja: 4 lutego 2026',
                style: TextStyle(
                  fontSize: 13,
                  color: AppTheme.textLightColor,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildCard({required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.bold,
          color: AppTheme.textColor,
        ),
      ),
    );
  }

  Widget _buildBody(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 14,
        height: 1.6,
        color: AppTheme.textLightColor,
      ),
    );
  }
}
