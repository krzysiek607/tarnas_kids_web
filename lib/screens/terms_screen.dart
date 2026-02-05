import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';
import '../services/sound_effects_service.dart';

/// Ekran regulaminu (Terms of Service)
/// Dostepny z poziomu strefy rodzica w ustawieniach
class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Regulamin'),
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
              _buildSectionTitle('1. Postanowienia ogolne'),
              _buildBody(
                'Niniejszy Regulamin okresla zasady korzystania z aplikacji '
                'mobilnej Tarnas Kids ("Aplikacja").\n\n'
                'Aplikacja jest edukacyjna gra mobilna przeznaczona dla dzieci '
                'w wieku 5-8 lat, oferujaca gry edukacyjne, gry rozrywkowe, '
                'wirtualnego zwierzaka oraz system nagrod.\n\n'
                'Korzystanie z Aplikacji oznacza akceptacje niniejszego Regulaminu.\n\n'
                'Aplikacja jest przeznaczona do uzytkowania przez dzieci pod '
                'nadzorem rodzica lub opiekuna prawnego.',
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildCard(
            children: [
              _buildSectionTitle('2. Zasady korzystania'),
              _buildBody(
                'Aplikacja jest przeznaczona dla dzieci w wieku 5-8 lat.\n\n'
                'Korzystanie z Aplikacji przez dziecko powinno odbywac sie '
                'pod nadzorem rodzica lub opiekuna prawnego.\n\n'
                'Uzytkownik zobowiazuje sie do korzystania z Aplikacji zgodnie '
                'z jej przeznaczeniem.\n\n'
                'Zabrania sie:\n'
                '  \u2022 Kopiowania, modyfikowania lub rozpowszechniania tresci Aplikacji\n'
                '  \u2022 Prob uzyskania nieautoryzowanego dostepu do systemow Aplikacji\n'
                '  \u2022 Wykorzystywania Aplikacji w sposob niezgodny z prawem',
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildCard(
            children: [
              _buildSectionTitle('3. Subskrypcja i platnosci'),
              _buildBody(
                'Aplikacja oferuje zarowno darmowe, jak i platne funkcjonalnosci.\n\n'
                'Dostep do pelnej wersji Aplikacji wymaga aktywnej subskrypcji.\n\n'
                'Subskrypcja jest obslugiwana przez platforme platnosci sklepu '
                '(Google Play / App Store) i podlega regulaminom tych platform.\n\n'
                'Subskrypcja odnawia sie automatycznie na koniec kazdego okresu '
                'rozliczeniowego, chyba ze zostanie anulowana przed uplywem '
                'biezacego okresu.\n\n'
                'Anulowanie subskrypcji:\n'
                '  \u2022 Android: Google Play > Subskrypcje > Tarnas Kids > Anuluj\n'
                '  \u2022 iOS: Ustawienia > Apple ID > Subskrypcje > Tarnas Kids > Anuluj\n\n'
                'Po anulowaniu subskrypcji dostep do platnych funkcji pozostaje '
                'aktywny do konca oplaconego okresu.\n\n'
                'Zwroty sa obslugiwane zgodnie z politykami Google Play i App Store.',
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildCard(
            children: [
              _buildSectionTitle('4. Wlasnosc intelektualna'),
              _buildBody(
                'Wszelkie prawa autorskie, znaki towarowe i inne prawa wlasnosci '
                'intelektualnej zwiazane z Aplikacja naleza do tworcow Tarnas Kids.\n\n'
                'Uzytkownik otrzymuje ograniczona, niewylaczna, nieprzenoszalna '
                'licencje na korzystanie z Aplikacji na urzadzeniu mobilnym.\n\n'
                'Rysunki i prace stworzone przez dziecko w Aplikacji sa wlasnoscia '
                'uzytkownika.',
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildCard(
            children: [
              _buildSectionTitle('5. Dostepnosc i odpowiedzialnosc'),
              _buildBody(
                'Dokladamy staran, aby Aplikacja byla dostepna nieprzerwanie, '
                'jednak nie gwarantujemy jej ciaglej dostepnosci.\n\n'
                'Aplikacja moze byc chwilowo niedostepna z powodu konserwacji, '
                'aktualizacji lub awarii technicznych.\n\n'
                'Wiele funkcji Aplikacji dziala w trybie offline.\n\n'
                'Aplikacja jest dostarczana w stanie "takim, jaki jest". '
                'Tworcy Aplikacji nie ponosza odpowiedzialnosci za przerwy '
                'w dzialaniu, utrate danych spowodowana usterkami urzadzenia '
                'ani szkody wynikajace z nieprawidlowego korzystania z Aplikacji.',
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildCard(
            children: [
              _buildSectionTitle('6. Ochrona danych'),
              _buildBody(
                'Zasady zbierania i przetwarzania danych osobowych okreslone sa '
                'w Polityce Prywatnosci dostepnej w Aplikacji.\n\n'
                'Aplikacja nie zbiera danych osobowych dzieci. '
                'Szczegoly znajduja sie w Polityce Prywatnosci.',
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildCard(
            children: [
              _buildSectionTitle('7. Zmiany Regulaminu'),
              _buildBody(
                'Zastrzegamy sobie prawo do zmiany niniejszego Regulaminu.\n\n'
                'O istotnych zmianach uzytkownik zostanie poinformowany '
                'poprzez aktualizacje Aplikacji.\n\n'
                'Kontynuowanie korzystania z Aplikacji po zmianie Regulaminu '
                'oznacza akceptacje nowych warunkow.',
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildCard(
            children: [
              _buildSectionTitle('8. Postanowienia koncowe'),
              _buildBody(
                'Regulamin podlega prawu polskiemu.\n\n'
                'W sprawach nieuregulowanych niniejszym Regulaminem zastosowanie '
                'maja odpowiednie przepisy prawa polskiego.\n\n'
                'Wszelkie spory beda rozstrzygane przez sad wlasciwy dla siedziby '
                'tworcow Aplikacji.\n\n'
                'Jesli jakiekolwiek postanowienie Regulaminu zostanie uznane za '
                'niewazne, pozostale postanowienia pozostaja w mocy.',
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
