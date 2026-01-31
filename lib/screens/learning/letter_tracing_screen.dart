import 'dart:math';
import 'package:flutter/material.dart';
import '../../models/tracing_path.dart';
import '../../widgets/tracing_canvas.dart';
import 'tracing_game_screen.dart';

/// Ekran gry "Literki" - nauka pisania polskiego alfabetu
/// Kazda litera wyswietlana jako para: duza + mala (np. "A a")
class LetterTracingScreen extends StatelessWidget {
  const LetterTracingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width - 64;
    final patterns = _createLetterPatterns(screenWidth);

    // Losowa kolejnosc
    patterns.shuffle(Random());

    return TracingGameScreen(
      title: 'Literki',
      emoji: '✏️',
      patterns: patterns,
      drawColor: const Color(0xFF66BB6A), // Zielony
      useHandwritingFont: true,
      rewardType: 'letters',
      enableRewards: true,
    );
  }

  List<TracingPattern> _createLetterPatterns(double width) {
    // Wymiary dla pary liter (duza + mala)
    final centerX = width / 2;
    const topY = 60.0;

    // Duza litera po lewej
    const bigLetterHeight = 120.0;
    const bigLetterWidth = 70.0;
    final bigLetterCenterX = centerX - 60;

    // Mala litera po prawej
    const smallLetterHeight = 80.0;
    const smallLetterWidth = 50.0;
    final smallLetterCenterX = centerX + 60;
    final smallLetterTopY = topY + (bigLetterHeight - smallLetterHeight); // Wyrownanie do dolu

    // Polski alfabet z duzymi i malymi literami
    // Waypoints są znormalizowane (0.0-1.0) dla całego canvas
    return [
      // A a - z waypointami!
      TracingPattern(
        name: 'A a',
        hint: 'Dwie kreski do góry i poprzeczka',
        path: _combinePaths([
          _createBigA(bigLetterCenterX, topY, bigLetterWidth, bigLetterHeight),
          _createSmallA(smallLetterCenterX, smallLetterTopY, smallLetterWidth, smallLetterHeight),
        ]),
        waypoints: _createWaypointsForA(
          bigLetterCenterX, topY, bigLetterWidth, bigLetterHeight,
          smallLetterCenterX, smallLetterTopY, smallLetterWidth, smallLetterHeight,
          width,
        ),
      ),
      // Ą ą - z waypointami!
      TracingPattern(
        name: 'Ą ą',
        hint: 'Litera A z ogonkiem',
        path: _combinePaths([
          _createBigAOgonek(bigLetterCenterX, topY, bigLetterWidth, bigLetterHeight),
          _createSmallAOgonek(smallLetterCenterX, smallLetterTopY, smallLetterWidth, smallLetterHeight),
        ]),
        waypoints: _createWaypointsForAOgonek(
          bigLetterCenterX, topY, bigLetterWidth, bigLetterHeight,
          smallLetterCenterX, smallLetterTopY, smallLetterWidth, smallLetterHeight,
          width,
        ),
      ),
      // B b - z waypointami!
      TracingPattern(
        name: 'B b',
        hint: 'Kreska pionowa i brzuszki',
        path: _combinePaths([
          _createBigB(bigLetterCenterX - bigLetterWidth / 2, topY, bigLetterWidth, bigLetterHeight),
          _createSmallB(smallLetterCenterX - smallLetterWidth / 2, smallLetterTopY, smallLetterWidth, smallLetterHeight),
        ]),
        waypoints: _createWaypointsForB(
          bigLetterCenterX - bigLetterWidth / 2, topY, bigLetterWidth, bigLetterHeight,
          smallLetterCenterX - smallLetterWidth / 2, smallLetterTopY, smallLetterWidth, smallLetterHeight,
          width,
        ),
      ),
      // C c - z waypointami!
      TracingPattern(
        name: 'C c',
        hint: 'Polkole otwarte w prawo',
        path: _combinePaths([
          _createBigC(bigLetterCenterX, topY + bigLetterHeight / 2, bigLetterHeight / 2.2),
          _createSmallC(smallLetterCenterX, smallLetterTopY + smallLetterHeight / 2, smallLetterHeight / 2.2),
        ]),
        waypoints: _createWaypointsForC(
          bigLetterCenterX, topY + bigLetterHeight / 2, bigLetterHeight / 2.2,
          smallLetterCenterX, smallLetterTopY + smallLetterHeight / 2, smallLetterHeight / 2.2,
          width,
        ),
      ),
      // Ć ć - z waypointami!
      TracingPattern(
        name: 'Ć ć',
        hint: 'Litera C z kreską na górze',
        path: _combinePaths([
          _createBigCKreska(bigLetterCenterX, topY + bigLetterHeight / 2, bigLetterHeight / 2.2, topY),
          _createSmallCKreska(smallLetterCenterX, smallLetterTopY + smallLetterHeight / 2, smallLetterHeight / 2.2, smallLetterTopY),
        ]),
        waypoints: _createWaypointsForCKreska(
          bigLetterCenterX, topY + bigLetterHeight / 2, bigLetterHeight / 2.2, topY,
          smallLetterCenterX, smallLetterTopY + smallLetterHeight / 2, smallLetterHeight / 2.2, smallLetterTopY,
          width,
        ),
      ),
      // D d - z waypointami!
      TracingPattern(
        name: 'D d',
        hint: 'Kreska i duzy brzuszek',
        path: _combinePaths([
          _createBigD(bigLetterCenterX - bigLetterWidth / 2, topY, bigLetterWidth, bigLetterHeight),
          _createSmallD(smallLetterCenterX - smallLetterWidth / 2, smallLetterTopY, smallLetterWidth, smallLetterHeight),
        ]),
        waypoints: _createWaypointsForD(
          bigLetterCenterX - bigLetterWidth / 2, topY, bigLetterWidth, bigLetterHeight,
          smallLetterCenterX - smallLetterWidth / 2, smallLetterTopY, smallLetterWidth, smallLetterHeight,
          width,
        ),
      ),
      // E e - z waypointami!
      TracingPattern(
        name: 'E e',
        hint: 'Kreska i trzy poziome',
        path: _combinePaths([
          _createBigE(bigLetterCenterX - bigLetterWidth / 2, topY, bigLetterWidth, bigLetterHeight),
          _createSmallE(smallLetterCenterX, smallLetterTopY + smallLetterHeight / 2, smallLetterHeight / 2.2),
        ]),
        waypoints: _createWaypointsForE(
          bigLetterCenterX - bigLetterWidth / 2, topY, bigLetterWidth, bigLetterHeight,
          smallLetterCenterX, smallLetterTopY + smallLetterHeight / 2, smallLetterHeight / 2.2,
          width,
        ),
      ),
      // Ę ę - z waypointami!
      TracingPattern(
        name: 'Ę ę',
        hint: 'Litera E z ogonkiem',
        path: _combinePaths([
          _createBigEOgonek(bigLetterCenterX - bigLetterWidth / 2, topY, bigLetterWidth, bigLetterHeight),
          _createSmallEOgonek(smallLetterCenterX, smallLetterTopY + smallLetterHeight / 2, smallLetterHeight / 2.2),
        ]),
        waypoints: _createWaypointsForEOgonek(
          bigLetterCenterX - bigLetterWidth / 2, topY, bigLetterWidth, bigLetterHeight,
          smallLetterCenterX, smallLetterTopY + smallLetterHeight / 2, smallLetterHeight / 2.2,
          width,
        ),
      ),
      // F f - z waypointami!
      TracingPattern(
        name: 'F f',
        hint: 'Kreska i dwie poziome na górze',
        path: _combinePaths([
          _createBigF(bigLetterCenterX - bigLetterWidth / 2, topY, bigLetterWidth, bigLetterHeight),
          _createSmallF(smallLetterCenterX, smallLetterTopY, smallLetterWidth, smallLetterHeight),
        ]),
        waypoints: _createWaypointsForF(
          bigLetterCenterX - bigLetterWidth / 2, topY, bigLetterWidth, bigLetterHeight,
          smallLetterCenterX, smallLetterTopY, smallLetterWidth, smallLetterHeight,
          width,
        ),
      ),
      // G g - z waypointami!
      TracingPattern(
        name: 'G g',
        hint: 'Litera C z kreska do srodka',
        path: _combinePaths([
          _createBigG(bigLetterCenterX, topY + bigLetterHeight / 2, bigLetterHeight / 2.2),
          _createSmallG(smallLetterCenterX, smallLetterTopY, smallLetterWidth, smallLetterHeight),
        ]),
        waypoints: _createWaypointsForG(
          bigLetterCenterX, topY + bigLetterHeight / 2, bigLetterHeight / 2.2,
          smallLetterCenterX, smallLetterTopY, smallLetterWidth, smallLetterHeight,
          width,
        ),
      ),
      // H h - z waypointami!
      TracingPattern(
        name: 'H h',
        hint: 'Dwie pionowe połączone w środku',
        path: _combinePaths([
          _createBigH(bigLetterCenterX - bigLetterWidth / 2, topY, bigLetterWidth, bigLetterHeight),
          _createSmallH(smallLetterCenterX - smallLetterWidth / 2, smallLetterTopY, smallLetterWidth, smallLetterHeight),
        ]),
        waypoints: _createWaypointsForH(
          bigLetterCenterX - bigLetterWidth / 2, topY, bigLetterWidth, bigLetterHeight,
          smallLetterCenterX - smallLetterWidth / 2, smallLetterTopY, smallLetterWidth, smallLetterHeight,
          width,
        ),
      ),
      // I i - z waypointami!
      TracingPattern(
        name: 'I i',
        hint: 'Prosta kreska w dół',
        path: _combinePaths([
          _createBigI(bigLetterCenterX, topY, bigLetterHeight),
          _createSmallI(smallLetterCenterX, smallLetterTopY, smallLetterHeight),
        ]),
        waypoints: _createWaypointsForI(
          bigLetterCenterX, topY, bigLetterHeight,
          smallLetterCenterX, smallLetterTopY, smallLetterHeight,
          width,
        ),
      ),
      // J j - z waypointami!
      TracingPattern(
        name: 'J j',
        hint: 'Kreska zakręcona w lewo na dole',
        path: _combinePaths([
          _createBigJ(bigLetterCenterX, topY, bigLetterHeight),
          _createSmallJ(smallLetterCenterX, smallLetterTopY, smallLetterHeight),
        ]),
        waypoints: _createWaypointsForJ(
          bigLetterCenterX, topY, bigLetterHeight,
          smallLetterCenterX, smallLetterTopY, smallLetterHeight,
          width,
        ),
      ),
      // K k - z waypointami!
      TracingPattern(
        name: 'K k',
        hint: 'Pionowa i dwie skośne',
        path: _combinePaths([
          _createBigK(bigLetterCenterX - bigLetterWidth / 2, topY, bigLetterWidth, bigLetterHeight),
          _createSmallK(smallLetterCenterX - smallLetterWidth / 2, smallLetterTopY, smallLetterWidth, smallLetterHeight),
        ]),
        waypoints: _createWaypointsForK(
          bigLetterCenterX - bigLetterWidth / 2, topY, bigLetterWidth, bigLetterHeight,
          smallLetterCenterX - smallLetterWidth / 2, smallLetterTopY, smallLetterWidth, smallLetterHeight,
          width,
        ),
      ),
      // L l - z waypointami!
      TracingPattern(
        name: 'L l',
        hint: 'Kreska w dół i w prawo',
        path: _combinePaths([
          _createBigL(bigLetterCenterX - bigLetterWidth / 2, topY, bigLetterWidth, bigLetterHeight),
          _createSmallL(smallLetterCenterX, smallLetterTopY, smallLetterHeight),
        ]),
        waypoints: _createWaypointsForL(
          bigLetterCenterX - bigLetterWidth / 2, topY, bigLetterWidth, bigLetterHeight,
          smallLetterCenterX, smallLetterTopY, smallLetterHeight,
          width,
        ),
      ),
      // Ł ł - z waypointami!
      TracingPattern(
        name: 'Ł ł',
        hint: 'Litera L z kreska w poprzek',
        path: _combinePaths([
          _createBigLKreska(bigLetterCenterX - bigLetterWidth / 2, topY, bigLetterWidth, bigLetterHeight),
          _createSmallLKreska(smallLetterCenterX, smallLetterTopY, smallLetterHeight),
        ]),
        waypoints: _createWaypointsForLKreska(
          bigLetterCenterX - bigLetterWidth / 2, topY, bigLetterWidth, bigLetterHeight,
          smallLetterCenterX, smallLetterTopY, smallLetterHeight,
          width,
        ),
      ),
      // M m - z waypointami!
      TracingPattern(
        name: 'M m',
        hint: 'Dwa szczyty jak góry',
        path: _combinePaths([
          _createBigM(bigLetterCenterX - bigLetterWidth / 2, topY, bigLetterWidth, bigLetterHeight),
          _createSmallM(smallLetterCenterX - smallLetterWidth / 2, smallLetterTopY, smallLetterWidth, smallLetterHeight),
        ]),
        waypoints: _createWaypointsForM(
          bigLetterCenterX - bigLetterWidth / 2, topY, bigLetterWidth, bigLetterHeight,
          smallLetterCenterX - smallLetterWidth / 2, smallLetterTopY, smallLetterWidth, smallLetterHeight,
          width,
        ),
      ),
      // N n - z waypointami!
      TracingPattern(
        name: 'N n',
        hint: 'Dwie pionowe z ukosna',
        path: _combinePaths([
          _createBigN(bigLetterCenterX - bigLetterWidth / 2, topY, bigLetterWidth, bigLetterHeight),
          _createSmallN(smallLetterCenterX - smallLetterWidth / 2, smallLetterTopY, smallLetterWidth, smallLetterHeight),
        ]),
        waypoints: _createWaypointsForN(
          bigLetterCenterX - bigLetterWidth / 2, topY, bigLetterWidth, bigLetterHeight,
          smallLetterCenterX - smallLetterWidth / 2, smallLetterTopY, smallLetterWidth, smallLetterHeight,
          width,
        ),
      ),
      // Ń ń - z waypointami!
      TracingPattern(
        name: 'Ń ń',
        hint: 'Litera N z kreską na górze',
        path: _combinePaths([
          _createBigNKreska(bigLetterCenterX - bigLetterWidth / 2, topY, bigLetterWidth, bigLetterHeight),
          _createSmallNKreska(smallLetterCenterX - smallLetterWidth / 2, smallLetterTopY, smallLetterWidth, smallLetterHeight),
        ]),
        waypoints: _createWaypointsForNKreska(
          bigLetterCenterX - bigLetterWidth / 2, topY, bigLetterWidth, bigLetterHeight,
          smallLetterCenterX - smallLetterWidth / 2, smallLetterTopY, smallLetterWidth, smallLetterHeight,
          width,
        ),
      ),
      // O o - z waypointami!
      TracingPattern(
        name: 'O o',
        hint: 'Duże kółko',
        path: _combinePaths([
          _createBigO(bigLetterCenterX, topY + bigLetterHeight / 2, bigLetterHeight / 2.2),
          _createSmallO(smallLetterCenterX, smallLetterTopY + smallLetterHeight / 2, smallLetterHeight / 2.2),
        ]),
        waypoints: _createWaypointsForO(
          bigLetterCenterX, topY + bigLetterHeight / 2, bigLetterHeight / 2.2,
          smallLetterCenterX, smallLetterTopY + smallLetterHeight / 2, smallLetterHeight / 2.2,
          width,
        ),
      ),
      // Ó ó - z waypointami!
      TracingPattern(
        name: 'Ó ó',
        hint: 'Litera O z kreską na górze',
        path: _combinePaths([
          _createBigOKreska(bigLetterCenterX, topY + bigLetterHeight / 2, bigLetterHeight / 2.2, topY),
          _createSmallOKreska(smallLetterCenterX, smallLetterTopY + smallLetterHeight / 2, smallLetterHeight / 2.2, smallLetterTopY),
        ]),
        waypoints: _createWaypointsForOKreska(
          bigLetterCenterX, topY + bigLetterHeight / 2, bigLetterHeight / 2.2, topY,
          smallLetterCenterX, smallLetterTopY + smallLetterHeight / 2, smallLetterHeight / 2.2, smallLetterTopY,
          width,
        ),
      ),
      // P p - z waypointami!
      TracingPattern(
        name: 'P p',
        hint: 'Pionowa i brzuszek na górze',
        path: _combinePaths([
          _createBigP(bigLetterCenterX - bigLetterWidth / 2, topY, bigLetterWidth, bigLetterHeight),
          _createSmallP(smallLetterCenterX - smallLetterWidth / 2, smallLetterTopY, smallLetterWidth, smallLetterHeight),
        ]),
        waypoints: _createWaypointsForP(
          bigLetterCenterX - bigLetterWidth / 2, topY, bigLetterWidth, bigLetterHeight,
          smallLetterCenterX - smallLetterWidth / 2, smallLetterTopY, smallLetterWidth, smallLetterHeight,
          width,
        ),
      ),
      // R r - z waypointami!
      TracingPattern(
        name: 'R r',
        hint: 'Jak P ale z nozka',
        path: _combinePaths([
          _createBigR(bigLetterCenterX - bigLetterWidth / 2, topY, bigLetterWidth, bigLetterHeight),
          _createSmallR(smallLetterCenterX - smallLetterWidth / 2, smallLetterTopY, smallLetterWidth, smallLetterHeight),
        ]),
        waypoints: _createWaypointsForR(
          bigLetterCenterX - bigLetterWidth / 2, topY, bigLetterWidth, bigLetterHeight,
          smallLetterCenterX - smallLetterWidth / 2, smallLetterTopY, smallLetterWidth, smallLetterHeight,
          width,
        ),
      ),
      // S s - z waypointami!
      TracingPattern(
        name: 'S s',
        hint: 'Waz - zakret w jedna i druga strone',
        path: _combinePaths([
          _createBigS(bigLetterCenterX, topY, bigLetterWidth * 0.6, bigLetterHeight),
          _createSmallS(smallLetterCenterX, smallLetterTopY, smallLetterWidth * 0.6, smallLetterHeight),
        ]),
        waypoints: _createWaypointsForS(
          bigLetterCenterX, topY, bigLetterWidth * 0.6, bigLetterHeight,
          smallLetterCenterX, smallLetterTopY, smallLetterWidth * 0.6, smallLetterHeight,
          width,
        ),
      ),
      // Ś ś - z waypointami!
      TracingPattern(
        name: 'Ś ś',
        hint: 'Litera S z kreską na górze',
        path: _combinePaths([
          _createBigSKreska(bigLetterCenterX, topY, bigLetterWidth * 0.6, bigLetterHeight),
          _createSmallSKreska(smallLetterCenterX, smallLetterTopY, smallLetterWidth * 0.6, smallLetterHeight),
        ]),
        waypoints: _createWaypointsForSKreska(
          bigLetterCenterX, topY, bigLetterWidth * 0.6, bigLetterHeight,
          smallLetterCenterX, smallLetterTopY, smallLetterWidth * 0.6, smallLetterHeight,
          width,
        ),
      ),
      // T t - z waypointami!
      TracingPattern(
        name: 'T t',
        hint: 'Kreska pozioma i pionowa w dół',
        path: _combinePaths([
          _createBigT(bigLetterCenterX, topY, bigLetterWidth, bigLetterHeight),
          _createSmallT(smallLetterCenterX, smallLetterTopY, smallLetterWidth, smallLetterHeight),
        ]),
        waypoints: _createWaypointsForT(
          bigLetterCenterX, topY, bigLetterWidth, bigLetterHeight,
          smallLetterCenterX, smallLetterTopY, smallLetterWidth, smallLetterHeight,
          width,
        ),
      ),
      // U u - z waypointami!
      TracingPattern(
        name: 'U u',
        hint: 'Jak miseczka',
        path: _combinePaths([
          _createBigU(bigLetterCenterX - bigLetterWidth / 2, topY, bigLetterWidth, bigLetterHeight),
          _createSmallU(smallLetterCenterX - smallLetterWidth / 2, smallLetterTopY, smallLetterWidth, smallLetterHeight),
        ]),
        waypoints: _createWaypointsForU(
          bigLetterCenterX - bigLetterWidth / 2, topY, bigLetterWidth, bigLetterHeight,
          smallLetterCenterX - smallLetterWidth / 2, smallLetterTopY, smallLetterWidth, smallLetterHeight,
          width,
        ),
      ),
      // W w - z waypointami!
      TracingPattern(
        name: 'W w',
        hint: 'Jak dwa V obok siebie',
        path: _combinePaths([
          _createBigW(bigLetterCenterX - bigLetterWidth / 2, topY, bigLetterWidth, bigLetterHeight),
          _createSmallW(smallLetterCenterX - smallLetterWidth / 2, smallLetterTopY, smallLetterWidth, smallLetterHeight),
        ]),
        waypoints: _createWaypointsForW(
          bigLetterCenterX - bigLetterWidth / 2, topY, bigLetterWidth, bigLetterHeight,
          smallLetterCenterX - smallLetterWidth / 2, smallLetterTopY, smallLetterWidth, smallLetterHeight,
          width,
        ),
      ),
      // Y y - z waypointami!
      TracingPattern(
        name: 'Y y',
        hint: 'Dwie skośne i kreska w dół',
        path: _combinePaths([
          _createBigY(bigLetterCenterX - bigLetterWidth / 2, topY, bigLetterWidth, bigLetterHeight),
          _createSmallY(smallLetterCenterX - smallLetterWidth / 2, smallLetterTopY, smallLetterWidth, smallLetterHeight),
        ]),
        waypoints: _createWaypointsForY(
          bigLetterCenterX - bigLetterWidth / 2, topY, bigLetterWidth, bigLetterHeight,
          smallLetterCenterX - smallLetterWidth / 2, smallLetterTopY, smallLetterWidth, smallLetterHeight,
          width,
        ),
      ),
      // Z z - z waypointami!
      TracingPattern(
        name: 'Z z',
        hint: 'Zygzak - pozioma, skos, pozioma',
        path: _combinePaths([
          _createBigZ(bigLetterCenterX - bigLetterWidth / 2, topY, bigLetterWidth, bigLetterHeight),
          _createSmallZ(smallLetterCenterX - smallLetterWidth / 2, smallLetterTopY, smallLetterWidth, smallLetterHeight),
        ]),
        waypoints: _createWaypointsForZ(
          bigLetterCenterX - bigLetterWidth / 2, topY, bigLetterWidth, bigLetterHeight,
          smallLetterCenterX - smallLetterWidth / 2, smallLetterTopY, smallLetterWidth, smallLetterHeight,
          width,
        ),
      ),
      // Ź ź - z waypointami!
      TracingPattern(
        name: 'Ź ź',
        hint: 'Litera Z z kreską na górze',
        path: _combinePaths([
          _createBigZKreska(bigLetterCenterX - bigLetterWidth / 2, topY, bigLetterWidth, bigLetterHeight),
          _createSmallZKreska(smallLetterCenterX - smallLetterWidth / 2, smallLetterTopY, smallLetterWidth, smallLetterHeight),
        ]),
        waypoints: _createWaypointsForZKreska(
          bigLetterCenterX - bigLetterWidth / 2, topY, bigLetterWidth, bigLetterHeight,
          smallLetterCenterX - smallLetterWidth / 2, smallLetterTopY, smallLetterWidth, smallLetterHeight,
          width,
        ),
      ),
      // Ż ż - z waypointami!
      TracingPattern(
        name: 'Ż ż',
        hint: 'Litera Z z kropką na górze',
        path: _combinePaths([
          _createBigZKropka(bigLetterCenterX - bigLetterWidth / 2, topY, bigLetterWidth, bigLetterHeight),
          _createSmallZKropka(smallLetterCenterX - smallLetterWidth / 2, smallLetterTopY, smallLetterWidth, smallLetterHeight),
        ]),
        waypoints: _createWaypointsForZKropka(
          bigLetterCenterX - bigLetterWidth / 2, topY, bigLetterWidth, bigLetterHeight,
          smallLetterCenterX - smallLetterWidth / 2, smallLetterTopY, smallLetterWidth, smallLetterHeight,
          width,
        ),
      ),
    ];
  }

  /// Laczy wiele sciezek w jedna
  Path _combinePaths(List<Path> paths) {
    final combined = Path();
    for (final path in paths) {
      combined.addPath(path, Offset.zero);
    }
    return combined;
  }

  // ============================================
  // DUZE LITERY (uppercase)
  // ============================================

  Path _createBigA(double cx, double top, double w, double h) {
    final left = cx - w / 2;
    final right = cx + w / 2;
    final bottom = top + h;
    final midY = top + h * 0.65;

    return Path()
      ..moveTo(left, bottom)
      ..lineTo(cx, top)
      ..lineTo(right, bottom)
      ..moveTo(left + w * 0.2, midY)
      ..lineTo(right - w * 0.2, midY);
  }

  Path _createBigAOgonek(double cx, double top, double w, double h) {
    final path = _createBigA(cx, top, w, h);
    final right = cx + w / 2;
    final bottom = top + h;
    path.moveTo(right - 3, bottom);
    path.quadraticBezierTo(right + 8, bottom + 12, right + 4, bottom + 20);
    return path;
  }

  Path _createBigB(double left, double top, double w, double h) {
    final right = left + w * 0.85;
    final mid = top + h / 2;
    final bottom = top + h;

    return Path()
      ..moveTo(left, top)
      ..lineTo(left, bottom)
      ..moveTo(left, top)
      ..lineTo(right - 10, top)
      ..quadraticBezierTo(right, top + h * 0.12, right, top + h * 0.25)
      ..quadraticBezierTo(right, mid - 3, right - 10, mid)
      ..lineTo(left, mid)
      ..lineTo(right - 8, mid)
      ..quadraticBezierTo(right + 3, mid + h * 0.12, right + 3, mid + h * 0.25)
      ..quadraticBezierTo(right + 3, bottom - 3, right - 8, bottom)
      ..lineTo(left, bottom);
  }

  Path _createBigC(double cx, double cy, double r) {
    return Path()
      ..addArc(
        Rect.fromCircle(center: Offset(cx, cy), radius: r),
        -pi * 0.3,
        -pi * 1.4,
      );
  }

  Path _createBigCKreska(double cx, double cy, double r, double top) {
    final path = _createBigC(cx, cy, r);
    path.moveTo(cx - 10, top - 15);
    path.lineTo(cx + 10, top - 28);
    return path;
  }

  Path _createBigD(double left, double top, double w, double h) {
    final right = left + w;
    final bottom = top + h;

    return Path()
      ..moveTo(left, top)
      ..lineTo(left, bottom)
      ..moveTo(left, top)
      ..lineTo(left + w * 0.3, top)
      ..quadraticBezierTo(right, top + h * 0.1, right, top + h / 2)
      ..quadraticBezierTo(right, bottom - h * 0.1, left + w * 0.3, bottom)
      ..lineTo(left, bottom);
  }

  Path _createBigE(double left, double top, double w, double h) {
    final right = left + w;
    final mid = top + h / 2;
    final bottom = top + h;

    return Path()
      ..moveTo(right, top)
      ..lineTo(left, top)
      ..lineTo(left, bottom)
      ..lineTo(right, bottom)
      ..moveTo(left, mid)
      ..lineTo(right - 10, mid);
  }

  Path _createBigEOgonek(double left, double top, double w, double h) {
    final path = _createBigE(left, top, w, h);
    final right = left + w;
    final bottom = top + h;
    path.moveTo(right - 3, bottom);
    path.quadraticBezierTo(right + 8, bottom + 12, right + 4, bottom + 20);
    return path;
  }

  Path _createBigF(double left, double top, double w, double h) {
    final right = left + w;
    final mid = top + h / 2;
    final bottom = top + h;

    return Path()
      ..moveTo(right, top)
      ..lineTo(left, top)
      ..lineTo(left, bottom)
      ..moveTo(left, mid)
      ..lineTo(right - 15, mid);
  }

  Path _createBigG(double cx, double cy, double r) {
    final path = Path()
      ..addArc(
        Rect.fromCircle(center: Offset(cx, cy), radius: r),
        -pi * 0.3,
        -pi * 1.4,
      );
    path.moveTo(cx + r, cy);
    path.lineTo(cx + r * 0.3, cy);
    return path;
  }

  Path _createBigH(double left, double top, double w, double h) {
    final right = left + w;
    final mid = top + h / 2;
    final bottom = top + h;

    return Path()
      ..moveTo(left, top)
      ..lineTo(left, bottom)
      ..moveTo(right, top)
      ..lineTo(right, bottom)
      ..moveTo(left, mid)
      ..lineTo(right, mid);
  }

  Path _createBigI(double cx, double top, double h) {
    return Path()
      ..moveTo(cx, top)
      ..lineTo(cx, top + h);
  }

  Path _createBigJ(double cx, double top, double h) {
    final bottom = top + h;
    return Path()
      ..moveTo(cx, top)
      ..lineTo(cx, bottom - 20)
      ..quadraticBezierTo(cx, bottom, cx - 25, bottom)
      ..quadraticBezierTo(cx - 35, bottom, cx - 35, bottom - 15);
  }

  Path _createBigK(double left, double top, double w, double h) {
    final mid = top + h / 2;
    final bottom = top + h;
    final right = left + w;

    return Path()
      ..moveTo(left, top)
      ..lineTo(left, bottom)
      ..moveTo(right, top)
      ..lineTo(left + 3, mid)
      ..lineTo(right, bottom);
  }

  Path _createBigL(double left, double top, double w, double h) {
    final right = left + w;
    final bottom = top + h;

    return Path()
      ..moveTo(left, top)
      ..lineTo(left, bottom)
      ..lineTo(right, bottom);
  }

  Path _createBigLKreska(double left, double top, double w, double h) {
    final path = _createBigL(left, top, w, h);
    final mid = top + h / 2;
    path.moveTo(left - 10, mid + 8);
    path.lineTo(left + 15, mid - 12);
    return path;
  }

  Path _createBigM(double left, double top, double w, double h) {
    final right = left + w;
    final cx = left + w / 2;
    final bottom = top + h;

    return Path()
      ..moveTo(left, bottom)
      ..lineTo(left, top)
      ..lineTo(cx, top + h * 0.35)
      ..lineTo(right, top)
      ..lineTo(right, bottom);
  }

  Path _createBigN(double left, double top, double w, double h) {
    final right = left + w;
    final bottom = top + h;

    return Path()
      ..moveTo(left, bottom)
      ..lineTo(left, top)
      ..lineTo(right, bottom)
      ..lineTo(right, top);
  }

  Path _createBigNKreska(double left, double top, double w, double h) {
    final path = _createBigN(left, top, w, h);
    final cx = left + w / 2;
    path.moveTo(cx - 10, top - 15);
    path.lineTo(cx + 10, top - 28);
    return path;
  }

  Path _createBigO(double cx, double cy, double r) {
    return Path()..addOval(Rect.fromCircle(center: Offset(cx, cy), radius: r));
  }

  Path _createBigOKreska(double cx, double cy, double r, double top) {
    final path = _createBigO(cx, cy, r);
    path.moveTo(cx - 10, top - 15);
    path.lineTo(cx + 10, top - 28);
    return path;
  }

  Path _createBigP(double left, double top, double w, double h) {
    final right = left + w * 0.9;
    final mid = top + h / 2;
    final bottom = top + h;

    return Path()
      ..moveTo(left, bottom)
      ..lineTo(left, top)
      ..lineTo(right - 15, top)
      ..quadraticBezierTo(right, top + h * 0.12, right, top + h * 0.25)
      ..quadraticBezierTo(right, mid - 3, right - 15, mid)
      ..lineTo(left, mid);
  }

  Path _createBigR(double left, double top, double w, double h) {
    final right = left + w * 0.9;
    final mid = top + h / 2;
    final bottom = top + h;

    return Path()
      ..moveTo(left, bottom)
      ..lineTo(left, top)
      ..lineTo(right - 15, top)
      ..quadraticBezierTo(right, top + h * 0.12, right, top + h * 0.25)
      ..quadraticBezierTo(right, mid - 3, right - 15, mid)
      ..lineTo(left, mid)
      ..moveTo(left + w * 0.35, mid)
      ..lineTo(left + w, bottom);
  }

  Path _createBigS(double cx, double top, double w, double h) {
    final bottom = top + h;
    final mid = top + h / 2;

    return Path()
      ..moveTo(cx + w / 2, top + h * 0.12)
      ..quadraticBezierTo(cx + w / 2, top, cx, top)
      ..quadraticBezierTo(cx - w / 2, top, cx - w / 2, top + h * 0.22)
      ..quadraticBezierTo(cx - w / 2, mid, cx, mid)
      ..quadraticBezierTo(cx + w / 2, mid, cx + w / 2, mid + h * 0.22)
      ..quadraticBezierTo(cx + w / 2, bottom, cx, bottom)
      ..quadraticBezierTo(cx - w / 2, bottom, cx - w / 2, bottom - h * 0.12);
  }

  Path _createBigSKreska(double cx, double top, double w, double h) {
    final path = _createBigS(cx, top, w, h);
    path.moveTo(cx - 10, top - 15);
    path.lineTo(cx + 10, top - 28);
    return path;
  }

  Path _createBigT(double cx, double top, double w, double h) {
    final left = cx - w / 2;
    final right = cx + w / 2;
    final bottom = top + h;

    return Path()
      ..moveTo(left, top)
      ..lineTo(right, top)
      ..moveTo(cx, top)
      ..lineTo(cx, bottom);
  }

  Path _createBigU(double left, double top, double w, double h) {
    final right = left + w;
    final bottom = top + h;
    final cx = left + w / 2;

    return Path()
      ..moveTo(left, top)
      ..lineTo(left, bottom - 25)
      ..quadraticBezierTo(left, bottom, cx, bottom)
      ..quadraticBezierTo(right, bottom, right, bottom - 25)
      ..lineTo(right, top);
  }

  Path _createBigW(double left, double top, double w, double h) {
    final right = left + w;
    final bottom = top + h;
    final q1 = left + w * 0.25;
    final q2 = left + w * 0.5;
    final q3 = left + w * 0.75;

    return Path()
      ..moveTo(left, top)
      ..lineTo(q1, bottom)
      ..lineTo(q2, top + h * 0.45)
      ..lineTo(q3, bottom)
      ..lineTo(right, top);
  }

  Path _createBigY(double left, double top, double w, double h) {
    final right = left + w;
    final cx = left + w / 2;
    final mid = top + h / 2;
    final bottom = top + h;

    return Path()
      ..moveTo(left, top)
      ..lineTo(cx, mid)
      ..lineTo(right, top)
      ..moveTo(cx, mid)
      ..lineTo(cx, bottom);
  }

  Path _createBigZ(double left, double top, double w, double h) {
    final right = left + w;
    final bottom = top + h;

    return Path()
      ..moveTo(left, top)
      ..lineTo(right, top)
      ..lineTo(left, bottom)
      ..lineTo(right, bottom);
  }

  Path _createBigZKreska(double left, double top, double w, double h) {
    final path = _createBigZ(left, top, w, h);
    final cx = left + w / 2;
    path.moveTo(cx - 10, top - 15);
    path.lineTo(cx + 10, top - 28);
    return path;
  }

  Path _createBigZKropka(double left, double top, double w, double h) {
    final path = _createBigZ(left, top, w, h);
    final cx = left + w / 2;
    path.addOval(Rect.fromCircle(center: Offset(cx, top - 20), radius: 5));
    return path;
  }

  // ============================================
  // MALE LITERY (lowercase)
  // ============================================

  Path _createSmallA(double cx, double top, double w, double h) {
    // Mala litera 'a' - kolko z kreska po prawej
    final r = h * 0.35;
    final circleY = top + h - r;
    final right = cx + w * 0.3;

    return Path()
      ..addArc(
        Rect.fromCircle(center: Offset(cx, circleY), radius: r),
        0,
        2 * pi,
      )
      ..moveTo(right, top + h * 0.3)
      ..lineTo(right, top + h);
  }

  Path _createSmallAOgonek(double cx, double top, double w, double h) {
    final path = _createSmallA(cx, top, w, h);
    final right = cx + w * 0.3;
    final bottom = top + h;
    path.moveTo(right - 2, bottom);
    path.quadraticBezierTo(right + 6, bottom + 10, right + 3, bottom + 16);
    return path;
  }

  Path _createSmallB(double left, double top, double w, double h) {
    // Mala litera 'b' - wysoka kreska i kolko na dole
    final r = h * 0.3;
    final circleY = top + h - r;
    final bottom = top + h;

    return Path()
      ..moveTo(left, top)
      ..lineTo(left, bottom)
      ..addArc(
        Rect.fromCircle(center: Offset(left + r, circleY), radius: r),
        pi,
        -2 * pi,
      );
  }

  Path _createSmallC(double cx, double cy, double r) {
    return Path()
      ..addArc(
        Rect.fromCircle(center: Offset(cx, cy), radius: r),
        -pi * 0.3,
        -pi * 1.4,
      );
  }

  Path _createSmallCKreska(double cx, double cy, double r, double top) {
    final path = _createSmallC(cx, cy, r);
    path.moveTo(cx - 8, top - 12);
    path.lineTo(cx + 8, top - 22);
    return path;
  }

  Path _createSmallD(double left, double top, double w, double h) {
    // Mala litera 'd' - kolko po lewej i wysoka kreska
    final r = h * 0.3;
    final circleY = top + h - r;
    final right = left + w;
    final bottom = top + h;

    return Path()
      ..moveTo(right, top)
      ..lineTo(right, bottom)
      ..addArc(
        Rect.fromCircle(center: Offset(right - r, circleY), radius: r),
        0,
        2 * pi,
      );
  }

  Path _createSmallE(double cx, double cy, double r) {
    // Mala litera 'e' - kolko z kreska w srodku
    return Path()
      ..moveTo(cx - r, cy)
      ..lineTo(cx + r, cy)
      ..addArc(
        Rect.fromCircle(center: Offset(cx, cy), radius: r),
        0,
        -pi * 1.5,
      );
  }

  Path _createSmallEOgonek(double cx, double cy, double r) {
    final path = _createSmallE(cx, cy, r);
    final bottom = cy + r;
    path.moveTo(cx - r * 0.7, bottom);
    path.quadraticBezierTo(cx - r * 0.5 + 8, bottom + 10, cx - r * 0.5 + 5, bottom + 16);
    return path;
  }

  Path _createSmallF(double cx, double top, double w, double h) {
    // Mala litera 'f' - zakrzywiona gora i kreska pozioma
    final hookTop = top + h * 0.15;
    final crossY = top + h * 0.4;
    final bottom = top + h;

    return Path()
      ..moveTo(cx + w * 0.3, top)
      ..quadraticBezierTo(cx - w * 0.1, top, cx - w * 0.1, hookTop)
      ..lineTo(cx - w * 0.1, bottom)
      ..moveTo(cx - w * 0.35, crossY)
      ..lineTo(cx + w * 0.25, crossY);
  }

  Path _createSmallG(double cx, double top, double w, double h) {
    // Mala litera 'g' - kolko na gorze, ogonek w dol
    final r = h * 0.25;
    final circleY = top + r + h * 0.1;
    final right = cx + w * 0.3;
    final tailBottom = top + h + h * 0.3;

    return Path()
      ..addArc(
        Rect.fromCircle(center: Offset(cx, circleY), radius: r),
        0,
        2 * pi,
      )
      ..moveTo(right, circleY - r)
      ..lineTo(right, top + h * 0.7)
      ..quadraticBezierTo(right, tailBottom, cx - w * 0.3, tailBottom - h * 0.1);
  }

  Path _createSmallH(double left, double top, double w, double h) {
    // Mala litera 'h' - wysoka kreska i luk
    final right = left + w;
    final bottom = top + h;
    final archTop = top + h * 0.4;

    return Path()
      ..moveTo(left, top)
      ..lineTo(left, bottom)
      ..moveTo(left, archTop + h * 0.15)
      ..quadraticBezierTo(left + w * 0.5, archTop, right, archTop + h * 0.2)
      ..lineTo(right, bottom);
  }

  Path _createSmallI(double cx, double top, double h) {
    // Mala litera 'i' - kreska z kropka
    final bodyTop = top + h * 0.35;
    final bottom = top + h;

    return Path()
      ..addOval(Rect.fromCircle(center: Offset(cx, top + h * 0.15), radius: 4))
      ..moveTo(cx, bodyTop)
      ..lineTo(cx, bottom);
  }

  Path _createSmallJ(double cx, double top, double h) {
    // Mala litera 'j' - kreska z kropka i ogonkiem
    final bodyTop = top + h * 0.35;
    final bottom = top + h;

    return Path()
      ..addOval(Rect.fromCircle(center: Offset(cx, top + h * 0.15), radius: 4))
      ..moveTo(cx, bodyTop)
      ..lineTo(cx, bottom - 10)
      ..quadraticBezierTo(cx, bottom + 5, cx - 15, bottom + 5);
  }

  Path _createSmallK(double left, double top, double w, double h) {
    // Mala litera 'k' - wysoka kreska i dwie skosne
    final right = left + w;
    final mid = top + h * 0.55;
    final bottom = top + h;

    return Path()
      ..moveTo(left, top)
      ..lineTo(left, bottom)
      ..moveTo(right, top + h * 0.35)
      ..lineTo(left + 3, mid)
      ..lineTo(right, bottom);
  }

  Path _createSmallL(double cx, double top, double h) {
    // Mala litera 'l' - prosta kreska
    return Path()
      ..moveTo(cx, top)
      ..lineTo(cx, top + h);
  }

  Path _createSmallLKreska(double cx, double top, double h) {
    final path = _createSmallL(cx, top, h);
    final mid = top + h / 2;
    path.moveTo(cx - 10, mid + 6);
    path.lineTo(cx + 10, mid - 8);
    return path;
  }

  Path _createSmallM(double left, double top, double w, double h) {
    // Mala litera 'm' - dwa luki
    final right = left + w;
    final mid = left + w / 2;
    final bottom = top + h;
    final archTop = top;

    return Path()
      ..moveTo(left, bottom)
      ..lineTo(left, archTop + h * 0.2)
      ..quadraticBezierTo(left + w * 0.25, archTop, mid, archTop + h * 0.25)
      ..lineTo(mid, bottom)
      ..moveTo(mid, archTop + h * 0.2)
      ..quadraticBezierTo(mid + w * 0.25, archTop, right, archTop + h * 0.25)
      ..lineTo(right, bottom);
  }

  Path _createSmallN(double left, double top, double w, double h) {
    // Mala litera 'n' - jeden luk
    final right = left + w;
    final bottom = top + h;
    final archTop = top;

    return Path()
      ..moveTo(left, bottom)
      ..lineTo(left, archTop + h * 0.15)
      ..quadraticBezierTo(left + w * 0.5, archTop, right, archTop + h * 0.25)
      ..lineTo(right, bottom);
  }

  Path _createSmallNKreska(double left, double top, double w, double h) {
    final path = _createSmallN(left, top, w, h);
    final cx = left + w / 2;
    path.moveTo(cx - 8, top - 12);
    path.lineTo(cx + 8, top - 22);
    return path;
  }

  Path _createSmallO(double cx, double cy, double r) {
    return Path()..addOval(Rect.fromCircle(center: Offset(cx, cy), radius: r));
  }

  Path _createSmallOKreska(double cx, double cy, double r, double top) {
    final path = _createSmallO(cx, cy, r);
    path.moveTo(cx - 8, top - 12);
    path.lineTo(cx + 8, top - 22);
    return path;
  }

  Path _createSmallP(double left, double top, double w, double h) {
    // Mala litera 'p' - kreska w dół i kolko na gorze
    final r = h * 0.28;
    final circleY = top + r + h * 0.05;
    final tailBottom = top + h + h * 0.35;

    return Path()
      ..moveTo(left, top + h * 0.1)
      ..lineTo(left, tailBottom)
      ..addArc(
        Rect.fromCircle(center: Offset(left + r, circleY), radius: r),
        pi,
        -2 * pi,
      );
  }

  Path _createSmallR(double left, double top, double w, double h) {
    // Mala litera 'r' - kreska i luk na gorze
    final bottom = top + h;

    return Path()
      ..moveTo(left, bottom)
      ..lineTo(left, top + h * 0.15)
      ..quadraticBezierTo(left + w * 0.5, top, left + w * 0.8, top + h * 0.15);
  }

  Path _createSmallS(double cx, double top, double w, double h) {
    final bottom = top + h;
    final mid = top + h / 2;

    return Path()
      ..moveTo(cx + w / 2, top + h * 0.15)
      ..quadraticBezierTo(cx + w / 2, top, cx, top)
      ..quadraticBezierTo(cx - w / 2, top, cx - w / 2, top + h * 0.22)
      ..quadraticBezierTo(cx - w / 2, mid, cx, mid)
      ..quadraticBezierTo(cx + w / 2, mid, cx + w / 2, mid + h * 0.22)
      ..quadraticBezierTo(cx + w / 2, bottom, cx, bottom)
      ..quadraticBezierTo(cx - w / 2, bottom, cx - w / 2, bottom - h * 0.15);
  }

  Path _createSmallSKreska(double cx, double top, double w, double h) {
    final path = _createSmallS(cx, top, w, h);
    path.moveTo(cx - 8, top - 12);
    path.lineTo(cx + 8, top - 22);
    return path;
  }

  Path _createSmallT(double cx, double top, double w, double h) {
    // Mala litera 't' - kreska z poprzeczka
    final crossY = top + h * 0.25;
    final bottom = top + h;

    return Path()
      ..moveTo(cx, top)
      ..lineTo(cx, bottom - 8)
      ..quadraticBezierTo(cx, bottom, cx + w * 0.3, bottom)
      ..moveTo(cx - w * 0.3, crossY)
      ..lineTo(cx + w * 0.3, crossY);
  }

  Path _createSmallU(double left, double top, double w, double h) {
    // Mala litera 'u' - miseczka z kreska
    final right = left + w;
    final bottom = top + h;
    final cx = left + w / 2;

    return Path()
      ..moveTo(left, top)
      ..lineTo(left, bottom - 15)
      ..quadraticBezierTo(left, bottom, cx, bottom)
      ..quadraticBezierTo(right, bottom, right, bottom - 15)
      ..lineTo(right, top)
      ..lineTo(right, bottom);
  }

  Path _createSmallW(double left, double top, double w, double h) {
    final right = left + w;
    final bottom = top + h;
    final q1 = left + w * 0.25;
    final q2 = left + w * 0.5;
    final q3 = left + w * 0.75;

    return Path()
      ..moveTo(left, top)
      ..lineTo(q1, bottom)
      ..lineTo(q2, top + h * 0.5)
      ..lineTo(q3, bottom)
      ..lineTo(right, top);
  }

  Path _createSmallY(double left, double top, double w, double h) {
    // Mala litera 'y' - dwie skosne z ogonkiem
    final right = left + w;
    final cx = left + w / 2;
    final mid = top + h * 0.6;
    final tailBottom = top + h + h * 0.35;

    return Path()
      ..moveTo(left, top)
      ..lineTo(cx, mid)
      ..lineTo(right, top)
      ..moveTo(cx, mid)
      ..lineTo(cx - w * 0.2, tailBottom)
      ..quadraticBezierTo(cx - w * 0.4, tailBottom + 5, cx - w * 0.5, tailBottom - 5);
  }

  Path _createSmallZ(double left, double top, double w, double h) {
    final right = left + w;
    final bottom = top + h;

    return Path()
      ..moveTo(left, top)
      ..lineTo(right, top)
      ..lineTo(left, bottom)
      ..lineTo(right, bottom);
  }

  Path _createSmallZKreska(double left, double top, double w, double h) {
    final path = _createSmallZ(left, top, w, h);
    final cx = left + w / 2;
    path.moveTo(cx - 8, top - 12);
    path.lineTo(cx + 8, top - 22);
    return path;
  }

  Path _createSmallZKropka(double left, double top, double w, double h) {
    final path = _createSmallZ(left, top, w, h);
    final cx = left + w / 2;
    path.addOval(Rect.fromCircle(center: Offset(cx, top - 15), radius: 4));
    return path;
  }

  // ============================================
  // WAYPOINTS DLA LITER (proof-of-concept: A, B, C)
  // Waypoints w pikselach (absolutne, dopasowane do Path)
  // ============================================

  /// Waypoints dla litery A a
  List<Waypoint> _createWaypointsForA(
    double bigCx, double bigTop, double bigW, double bigH,
    double smallCx, double smallTop, double smallW, double smallH,
    double canvasWidth,
  ) {
    final bigLeft = bigCx - bigW / 2;
    final bigRight = bigCx + bigW / 2;
    final bigBottom = bigTop + bigH;
    final bigMidY = bigTop + bigH * 0.65;

    // Mała litera 'a'
    final smallR = smallH * 0.35;
    final smallCircleY = smallTop + smallH - smallR;
    final smallRight = smallCx + smallW * 0.3;

    return [
      // Duża litera A - lewa noga (od dołu do góry)
      Waypoint.pixels(bigLeft, bigBottom, isStartPoint: true),
      Waypoint.pixels((bigLeft + bigCx) / 2, (bigBottom + bigTop) / 2),
      Waypoint.pixels(bigCx, bigTop),
      // Duża litera A - prawa noga (od góry do dołu)
      Waypoint.pixels((bigCx + bigRight) / 2, (bigTop + bigBottom) / 2),
      Waypoint.pixels(bigRight, bigBottom),
      // Duża litera A - poprzeczka
      Waypoint.pixels(bigLeft + bigW * 0.2, bigMidY),
      Waypoint.pixels(bigRight - bigW * 0.2, bigMidY),
      // Mała litera a - kółko (góra)
      Waypoint.pixels(smallCx, smallCircleY - smallR),
      // Mała litera a - kółko (dół)
      Waypoint.pixels(smallCx, smallCircleY + smallR),
      // Mała litera a - kreska w dół
      Waypoint.pixels(smallRight, smallTop + smallH, isEndPoint: true),
    ];
  }

  /// Waypoints dla litery B b
  List<Waypoint> _createWaypointsForB(
    double bigLeft, double bigTop, double bigW, double bigH,
    double smallLeft, double smallTop, double smallW, double smallH,
    double canvasWidth,
  ) {
    final bigRight = bigLeft + bigW * 0.85;
    final bigMid = bigTop + bigH / 2;
    final bigBottom = bigTop + bigH;

    // Mała litera 'b'
    final smallR = smallH * 0.3;
    final smallCircleY = smallTop + smallH - smallR;
    final smallBottom = smallTop + smallH;

    return [
      // Duża B - kreska pionowa
      Waypoint.pixels(bigLeft, bigTop, isStartPoint: true),
      Waypoint.pixels(bigLeft, bigMid),
      Waypoint.pixels(bigLeft, bigBottom),
      // Duża B - górny brzuszek
      Waypoint.pixels(bigRight - 10, bigTop),
      Waypoint.pixels(bigRight, bigTop + bigH * 0.25),
      Waypoint.pixels(bigRight - 10, bigMid),
      // Duża B - dolny brzuszek
      Waypoint.pixels(bigRight + 3, bigMid + bigH * 0.25),
      Waypoint.pixels(bigRight - 8, bigBottom),
      // Mała b - kreska
      Waypoint.pixels(smallLeft, smallTop),
      Waypoint.pixels(smallLeft, smallBottom),
      // Mała b - kółko
      Waypoint.pixels(smallLeft + smallR, smallCircleY - smallR),
      Waypoint.pixels(smallLeft + smallR * 2, smallCircleY),
      Waypoint.pixels(smallLeft + smallR, smallCircleY + smallR, isEndPoint: true),
    ];
  }

  /// Waypoints dla litery C c
  List<Waypoint> _createWaypointsForC(
    double bigCx, double bigCy, double bigR,
    double smallCx, double smallCy, double smallR,
    double canvasWidth,
  ) {
    return [
      // Duża C - łuk od góra-prawo do dół-prawo
      Waypoint.pixels(bigCx + bigR * 0.8, bigCy - bigR * 0.6, isStartPoint: true),
      Waypoint.pixels(bigCx, bigCy - bigR),        // góra
      Waypoint.pixels(bigCx - bigR, bigCy),         // lewo
      Waypoint.pixels(bigCx, bigCy + bigR),          // dół
      Waypoint.pixels(bigCx + bigR * 0.8, bigCy + bigR * 0.6),
      // Mała c - łuk
      Waypoint.pixels(smallCx + smallR * 0.8, smallCy - smallR * 0.6),
      Waypoint.pixels(smallCx, smallCy - smallR),   // góra
      Waypoint.pixels(smallCx - smallR, smallCy),    // lewo
      Waypoint.pixels(smallCx, smallCy + smallR),     // dół
      Waypoint.pixels(smallCx + smallR * 0.8, smallCy + smallR * 0.6, isEndPoint: true),
    ];
  }

  /// Waypoints dla litery D d
  /// Duże D: kreska pionowa (góra->dół), brzuszek (góra->prawo->dół)
  /// Małe d: kółko (przeciwnie do zegara), kreska (góra->dół)
  List<Waypoint> _createWaypointsForD(
    double bigLeft, double bigTop, double bigW, double bigH,
    double smallLeft, double smallTop, double smallW, double smallH,
    double canvasWidth,
  ) {
    final bigRight = bigLeft + bigW;
    final bigBottom = bigTop + bigH;
    final bigMid = bigTop + bigH / 2;

    // Mała litera 'd'
    final smallR = smallH * 0.3;
    final smallCircleY = smallTop + smallH - smallR;
    final smallRight = smallLeft + smallW;
    final smallBottom = smallTop + smallH;

    return [
      // Duże D - kreska pionowa (góra -> dół)
      Waypoint.pixels(bigLeft, bigTop, isStartPoint: true),
      Waypoint.pixels(bigLeft, bigMid),
      Waypoint.pixels(bigLeft, bigBottom),
      // Duże D - brzuszek (góra -> prawo -> dół)
      Waypoint.pixels(bigLeft + bigW * 0.3, bigTop),
      Waypoint.pixels(bigRight, bigMid),
      Waypoint.pixels(bigLeft + bigW * 0.3, bigBottom),
      // Małe d - kółko (start od prawej, przeciwnie do zegara)
      Waypoint.pixels(smallRight - smallR, smallCircleY + smallR),  // dół kółka
      Waypoint.pixels(smallRight - smallR * 2, smallCircleY),        // lewa strona
      Waypoint.pixels(smallRight - smallR, smallCircleY - smallR),  // góra kółka
      // Małe d - kreska (góra -> dół)
      Waypoint.pixels(smallRight, smallTop),
      Waypoint.pixels(smallRight, smallBottom, isEndPoint: true),
    ];
  }

  /// Waypoints dla litery E e
  /// Duże E: kreska pionowa (góra->dół), 3 poziome (góra, środek, dół)
  /// Małe e: kreska pozioma w środku, łuk (prawo->góra->lewo->dół)
  List<Waypoint> _createWaypointsForE(
    double bigLeft, double bigTop, double bigW, double bigH,
    double smallCx, double smallCy, double smallR,
    double canvasWidth,
  ) {
    final bigRight = bigLeft + bigW;
    final bigMid = bigTop + bigH / 2;
    final bigBottom = bigTop + bigH;

    return [
      // Duże E - kreska pionowa (góra -> dół)
      Waypoint.pixels(bigLeft, bigTop, isStartPoint: true),
      Waypoint.pixels(bigLeft, bigMid),
      Waypoint.pixels(bigLeft, bigBottom),
      // Duże E - górna pozioma (lewo -> prawo)
      Waypoint.pixels(bigRight, bigTop),
      // Duże E - środkowa pozioma (lewo -> prawo)
      Waypoint.pixels(bigLeft, bigMid),  // powrót
      Waypoint.pixels(bigRight - 10, bigMid),
      // Duże E - dolna pozioma (lewo -> prawo)
      Waypoint.pixels(bigLeft, bigBottom),  // powrót
      Waypoint.pixels(bigRight, bigBottom),
      // Małe e - kreska pozioma (lewo -> prawo)
      Waypoint.pixels(smallCx - smallR, smallCy),
      Waypoint.pixels(smallCx + smallR, smallCy),
      // Małe e - łuk (prawo -> góra -> lewo -> dół-lewo)
      Waypoint.pixels(smallCx, smallCy - smallR),   // góra
      Waypoint.pixels(smallCx - smallR, smallCy),    // lewo
      Waypoint.pixels(smallCx - smallR * 0.7, smallCy + smallR, isEndPoint: true),  // dół-lewo
    ];
  }

  /// Waypoints dla litery F f
  /// Duże F: kreska pionowa (góra->dół), 2 poziome (góra, środek)
  /// Małe f: haczyk (góra-prawo->lewo), kreska (góra->dół), poprzeczka
  List<Waypoint> _createWaypointsForF(
    double bigLeft, double bigTop, double bigW, double bigH,
    double smallCx, double smallTop, double smallW, double smallH,
    double canvasWidth,
  ) {
    final bigRight = bigLeft + bigW;
    final bigMid = bigTop + bigH / 2;
    final bigBottom = bigTop + bigH;

    // Małe f
    final smallHookTop = smallTop + smallH * 0.15;
    final smallCrossY = smallTop + smallH * 0.4;
    final smallBottom = smallTop + smallH;
    final smallX = smallCx - smallW * 0.1;

    return [
      // Duże F - kreska pionowa (góra -> dół)
      Waypoint.pixels(bigLeft, bigTop, isStartPoint: true),
      Waypoint.pixels(bigLeft, bigMid),
      Waypoint.pixels(bigLeft, bigBottom),
      // Duże F - górna pozioma (lewo -> prawo)
      Waypoint.pixels(bigLeft, bigTop),  // powrót do góry
      Waypoint.pixels(bigRight, bigTop),
      // Duże F - środkowa pozioma (lewo -> prawo)
      Waypoint.pixels(bigLeft, bigMid),  // powrót
      Waypoint.pixels(bigRight - 15, bigMid),
      // Małe f - haczyk (prawo-góra -> lewo)
      Waypoint.pixels(smallCx + smallW * 0.3, smallTop),
      Waypoint.pixels(smallX, smallHookTop),
      // Małe f - kreska pionowa (góra -> dół)
      Waypoint.pixels(smallX, smallBottom),
      // Małe f - poprzeczka (lewo -> prawo)
      Waypoint.pixels(smallCx - smallW * 0.35, smallCrossY),
      Waypoint.pixels(smallCx + smallW * 0.25, smallCrossY, isEndPoint: true),
    ];
  }

  /// Waypoints dla litery G g
  /// Duże G: łuk C + poprzeczka do środka
  /// Małe g: kółko + ogonek pod linię pisma
  List<Waypoint> _createWaypointsForG(
    double bigCx, double bigCy, double bigR,
    double smallCx, double smallTop, double smallW, double smallH,
    double canvasWidth,
  ) {
    // Małe g
    final smallR = smallH * 0.25;
    final smallCircleY = smallTop + smallR + smallH * 0.1;
    final smallRight = smallCx + smallW * 0.3;
    final smallTailBottom = smallTop + smallH + smallH * 0.3;

    return [
      // Duże G - łuk (jak C) od góra-prawo do dół-prawo
      Waypoint.pixels(bigCx + bigR * 0.8, bigCy - bigR * 0.6, isStartPoint: true),
      Waypoint.pixels(bigCx, bigCy - bigR),        // góra
      Waypoint.pixels(bigCx - bigR, bigCy),         // lewo
      Waypoint.pixels(bigCx, bigCy + bigR),          // dół
      Waypoint.pixels(bigCx + bigR, bigCy + bigR * 0.3),  // prawo-dół
      // Duże G - poprzeczka (prawo -> środek)
      Waypoint.pixels(bigCx + bigR, bigCy),
      Waypoint.pixels(bigCx + bigR * 0.3, bigCy),
      // Małe g - kółko (od prawej, przeciwnie do zegara)
      Waypoint.pixels(smallCx + smallR, smallCircleY),      // prawa strona
      Waypoint.pixels(smallCx, smallCircleY - smallR),       // góra
      Waypoint.pixels(smallCx - smallR, smallCircleY),        // lewa strona
      Waypoint.pixels(smallCx, smallCircleY + smallR),         // dół
      // Małe g - ogonek pod linię
      Waypoint.pixels(smallRight, smallCircleY - smallR),
      Waypoint.pixels(smallRight, smallTop + smallH * 0.7),
      Waypoint.pixels(smallCx - smallW * 0.3, smallTailBottom - smallH * 0.1, isEndPoint: true),
    ];
  }

  /// Waypoints dla litery H h
  /// Duże H: lewa pionowa (góra->dół), prawa pionowa (góra->dół), poprzeczka
  /// Małe h: kreska (góra->dół), mostek (łuk w prawo)
  List<Waypoint> _createWaypointsForH(
    double bigLeft, double bigTop, double bigW, double bigH,
    double smallLeft, double smallTop, double smallW, double smallH,
    double canvasWidth,
  ) {
    final bigRight = bigLeft + bigW;
    final bigMid = bigTop + bigH / 2;
    final bigBottom = bigTop + bigH;

    // Małe h
    final smallRight = smallLeft + smallW;
    final smallBottom = smallTop + smallH;
    final smallArchTop = smallTop + smallH * 0.4;

    return [
      // Duże H - lewa pionowa (góra -> dół)
      Waypoint.pixels(bigLeft, bigTop, isStartPoint: true),
      Waypoint.pixels(bigLeft, bigMid),
      Waypoint.pixels(bigLeft, bigBottom),
      // Duże H - prawa pionowa (góra -> dół)
      Waypoint.pixels(bigRight, bigTop),
      Waypoint.pixels(bigRight, bigMid),
      Waypoint.pixels(bigRight, bigBottom),
      // Duże H - poprzeczka (lewo -> prawo)
      Waypoint.pixels(bigLeft, bigMid),
      Waypoint.pixels(bigRight, bigMid),
      // Małe h - kreska pionowa (góra -> dół)
      Waypoint.pixels(smallLeft, smallTop),
      Waypoint.pixels(smallLeft, smallBottom),
      // Małe h - mostek (łuk: lewo -> góra -> prawo -> dół)
      Waypoint.pixels(smallLeft, smallArchTop + smallH * 0.15),
      Waypoint.pixels(smallLeft + smallW * 0.5, smallArchTop),
      Waypoint.pixels(smallRight, smallArchTop + smallH * 0.2),
      Waypoint.pixels(smallRight, smallBottom, isEndPoint: true),
    ];
  }

  /// Waypoints dla litery I i
  /// Duże I: prosta pionowa (góra->dół)
  /// Małe i: kreska (góra->dół), POTEM kropka (na końcu!)
  List<Waypoint> _createWaypointsForI(
    double bigCx, double bigTop, double bigH,
    double smallCx, double smallTop, double smallH,
    double canvasWidth,
  ) {
    final bigBottom = bigTop + bigH;

    // Małe i
    final smallBodyTop = smallTop + smallH * 0.35;
    final smallBottom = smallTop + smallH;
    final smallDotY = smallTop + smallH * 0.15;

    return [
      // Duże I - prosta pionowa (góra -> dół)
      Waypoint.pixels(bigCx, bigTop, isStartPoint: true),
      Waypoint.pixels(bigCx, bigTop + bigH * 0.5),
      Waypoint.pixels(bigCx, bigBottom),
      // Małe i - kreska (góra -> dół)
      Waypoint.pixels(smallCx, smallBodyTop),
      Waypoint.pixels(smallCx, smallBottom),
      // Małe i - kropka (zawsze na końcu!)
      Waypoint.pixels(smallCx, smallDotY, isEndPoint: true),
    ];
  }

  /// Waypoints dla litery J j
  /// Duże J: pionowa (góra->dół), haczyk w lewo
  /// Małe j: kreska z haczykiem pod linię, POTEM kropka (na końcu!)
  List<Waypoint> _createWaypointsForJ(
    double bigCx, double bigTop, double bigH,
    double smallCx, double smallTop, double smallH,
    double canvasWidth,
  ) {
    final bigBottom = bigTop + bigH;

    // Małe j
    final smallBodyTop = smallTop + smallH * 0.35;
    final smallBottom = smallTop + smallH;
    final smallDotY = smallTop + smallH * 0.15;

    return [
      // Duże J - pionowa (góra -> dół, przed haczykiem)
      Waypoint.pixels(bigCx, bigTop, isStartPoint: true),
      Waypoint.pixels(bigCx, bigTop + bigH * 0.5),
      Waypoint.pixels(bigCx, bigBottom - 20),
      // Duże J - haczyk w lewo
      Waypoint.pixels(bigCx - 25, bigBottom),
      Waypoint.pixels(bigCx - 35, bigBottom - 15),
      // Małe j - kreska (góra -> dół)
      Waypoint.pixels(smallCx, smallBodyTop),
      Waypoint.pixels(smallCx, smallBottom - 10),
      // Małe j - haczyk w lewo pod linię
      Waypoint.pixels(smallCx - 15, smallBottom + 5),
      // Małe j - kropka (zawsze na końcu!)
      Waypoint.pixels(smallCx, smallDotY, isEndPoint: true),
    ];
  }

  /// Waypoints dla litery K k
  /// Duże K: pionowa (góra->dół), skos górny (prawo-góra->środek), skos dolny (środek->prawo-dół)
  /// Małe k: pionowa (góra->dół), skos górny, skos dolny
  List<Waypoint> _createWaypointsForK(
    double bigLeft, double bigTop, double bigW, double bigH,
    double smallLeft, double smallTop, double smallW, double smallH,
    double canvasWidth,
  ) {
    final bigRight = bigLeft + bigW;
    final bigMid = bigTop + bigH / 2;
    final bigBottom = bigTop + bigH;

    // Małe k
    final smallRight = smallLeft + smallW;
    final smallMid = smallTop + smallH * 0.55;
    final smallBottom = smallTop + smallH;

    return [
      // Duże K - pionowa (góra -> dół)
      Waypoint.pixels(bigLeft, bigTop, isStartPoint: true),
      Waypoint.pixels(bigLeft, bigMid),
      Waypoint.pixels(bigLeft, bigBottom),
      // Duże K - skos górny (prawo-góra -> środek-lewo)
      Waypoint.pixels(bigRight, bigTop),
      Waypoint.pixels(bigLeft + 3, bigMid),
      // Duże K - skos dolny (środek -> prawo-dół)
      Waypoint.pixels(bigRight, bigBottom),
      // Małe k - pionowa (góra -> dół)
      Waypoint.pixels(smallLeft, smallTop),
      Waypoint.pixels(smallLeft, smallBottom),
      // Małe k - skos górny (prawo-góra -> środek)
      Waypoint.pixels(smallRight, smallTop + smallH * 0.35),
      Waypoint.pixels(smallLeft + 3, smallMid),
      // Małe k - skos dolny (środek -> prawo-dół)
      Waypoint.pixels(smallRight, smallBottom, isEndPoint: true),
    ];
  }

  /// Waypoints dla litery L l
  /// Duże L: pionowa (góra->dół), pozioma (lewo->prawo na dole)
  /// Małe l: prosta pionowa (góra->dół)
  List<Waypoint> _createWaypointsForL(
    double bigLeft, double bigTop, double bigW, double bigH,
    double smallCx, double smallTop, double smallH,
    double canvasWidth,
  ) {
    final bigRight = bigLeft + bigW;
    final bigBottom = bigTop + bigH;

    // Małe l
    final smallBottom = smallTop + smallH;

    return [
      // Duże L - pionowa (góra -> dół)
      Waypoint.pixels(bigLeft, bigTop, isStartPoint: true),
      Waypoint.pixels(bigLeft, bigTop + bigH * 0.5),
      Waypoint.pixels(bigLeft, bigBottom),
      // Duże L - pozioma (lewo -> prawo na dole)
      Waypoint.pixels(bigRight, bigBottom),
      // Małe l - pionowa (góra -> dół)
      Waypoint.pixels(smallCx, smallTop),
      Waypoint.pixels(smallCx, smallTop + smallH * 0.5),
      Waypoint.pixels(smallCx, smallBottom, isEndPoint: true),
    ];
  }

  /// Waypoints dla litery Ł ł
  /// Duże Ł: jak L + przekreślenie (na końcu!)
  /// Małe ł: jak l + przekreślenie (na końcu!)
  List<Waypoint> _createWaypointsForLKreska(
    double bigLeft, double bigTop, double bigW, double bigH,
    double smallCx, double smallTop, double smallH,
    double canvasWidth,
  ) {
    final bigRight = bigLeft + bigW;
    final bigBottom = bigTop + bigH;
    final bigMid = bigTop + bigH / 2;

    // Małe ł
    final smallBottom = smallTop + smallH;
    final smallMid = smallTop + smallH / 2;

    return [
      // Duże Ł - pionowa (góra -> dół)
      Waypoint.pixels(bigLeft, bigTop, isStartPoint: true),
      Waypoint.pixels(bigLeft, bigMid),
      Waypoint.pixels(bigLeft, bigBottom),
      // Duże Ł - pozioma (lewo -> prawo na dole)
      Waypoint.pixels(bigRight, bigBottom),
      // Duże Ł - przekreślenie (od dołu-lewo do góry-prawo)
      Waypoint.pixels(bigLeft - 10, bigMid + 8),
      Waypoint.pixels(bigLeft + 15, bigMid - 12),
      // Małe ł - pionowa (góra -> dół)
      Waypoint.pixels(smallCx, smallTop),
      Waypoint.pixels(smallCx, smallBottom),
      // Małe ł - przekreślenie (od dołu-lewo do góry-prawo, na końcu!)
      Waypoint.pixels(smallCx - 10, smallMid + 6),
      Waypoint.pixels(smallCx + 10, smallMid - 8, isEndPoint: true),
    ];
  }

  /// Waypoints dla litery M m
  /// Duże M: pion (dół->góra), skos w dół (do środka), skos w górę (do prawej), pion (góra->dół)
  /// Małe m: laseczka (dół->góra), mostek1, pion1, mostek2, pion2
  List<Waypoint> _createWaypointsForM(
    double bigLeft, double bigTop, double bigW, double bigH,
    double smallLeft, double smallTop, double smallW, double smallH,
    double canvasWidth,
  ) {
    final bigRight = bigLeft + bigW;
    final bigCx = bigLeft + bigW / 2;
    final bigBottom = bigTop + bigH;

    // Małe m
    final smallMid = smallLeft + smallW / 2;
    final smallRight = smallLeft + smallW;
    final smallBottom = smallTop + smallH;
    final smallArchTop = smallTop;

    return [
      // Duże M - lewa pionowa (dół -> góra)
      Waypoint.pixels(bigLeft, bigBottom, isStartPoint: true),
      Waypoint.pixels(bigLeft, bigTop + bigH * 0.5),
      Waypoint.pixels(bigLeft, bigTop),
      // Duże M - skos w dół do środka
      Waypoint.pixels(bigCx, bigTop + bigH * 0.35),
      // Duże M - skos w górę do prawej
      Waypoint.pixels(bigRight, bigTop),
      // Duże M - prawa pionowa (góra -> dół)
      Waypoint.pixels(bigRight, bigTop + bigH * 0.5),
      Waypoint.pixels(bigRight, bigBottom),
      // Małe m - laseczka (dół -> góra)
      Waypoint.pixels(smallLeft, smallBottom),
      Waypoint.pixels(smallLeft, smallArchTop + smallH * 0.2),
      // Małe m - mostek 1 (łuk w prawo)
      Waypoint.pixels(smallLeft + smallW * 0.25, smallArchTop),
      Waypoint.pixels(smallMid, smallArchTop + smallH * 0.25),
      // Małe m - pion 1 (środek -> dół)
      Waypoint.pixels(smallMid, smallBottom),
      // Małe m - mostek 2 (łuk w prawo)
      Waypoint.pixels(smallMid + smallW * 0.25, smallArchTop),
      Waypoint.pixels(smallRight, smallArchTop + smallH * 0.25),
      // Małe m - pion 2 (prawo -> dół)
      Waypoint.pixels(smallRight, smallBottom, isEndPoint: true),
    ];
  }

  /// Waypoints dla litery N n
  /// Duże N: pion (dół->góra), skos (góra-lewo->dół-prawo), pion (dół->góra)
  /// Małe n: laseczka (dół->góra), mostek, pion
  List<Waypoint> _createWaypointsForN(
    double bigLeft, double bigTop, double bigW, double bigH,
    double smallLeft, double smallTop, double smallW, double smallH,
    double canvasWidth,
  ) {
    final bigRight = bigLeft + bigW;
    final bigBottom = bigTop + bigH;

    // Małe n
    final smallRight = smallLeft + smallW;
    final smallBottom = smallTop + smallH;
    final smallArchTop = smallTop;

    return [
      // Duże N - lewa pionowa (dół -> góra)
      Waypoint.pixels(bigLeft, bigBottom, isStartPoint: true),
      Waypoint.pixels(bigLeft, bigTop + bigH * 0.5),
      Waypoint.pixels(bigLeft, bigTop),
      // Duże N - skos (góra-lewo -> dół-prawo)
      Waypoint.pixels(bigLeft + bigW * 0.5, bigTop + bigH * 0.5),
      Waypoint.pixels(bigRight, bigBottom),
      // Duże N - prawa pionowa (dół -> góra)
      Waypoint.pixels(bigRight, bigTop + bigH * 0.5),
      Waypoint.pixels(bigRight, bigTop),
      // Małe n - laseczka (dół -> góra)
      Waypoint.pixels(smallLeft, smallBottom),
      Waypoint.pixels(smallLeft, smallArchTop + smallH * 0.15),
      // Małe n - mostek (łuk w prawo)
      Waypoint.pixels(smallLeft + smallW * 0.5, smallArchTop),
      Waypoint.pixels(smallRight, smallArchTop + smallH * 0.25),
      // Małe n - pion (prawo -> dół)
      Waypoint.pixels(smallRight, smallBottom, isEndPoint: true),
    ];
  }

  /// Waypoints dla litery Ń ń
  /// Jak N/n + kreska ukośna nad literą (na końcu!)
  List<Waypoint> _createWaypointsForNKreska(
    double bigLeft, double bigTop, double bigW, double bigH,
    double smallLeft, double smallTop, double smallW, double smallH,
    double canvasWidth,
  ) {
    final bigRight = bigLeft + bigW;
    final bigBottom = bigTop + bigH;
    final bigCx = bigLeft + bigW / 2;

    // Małe ń
    final smallRight = smallLeft + smallW;
    final smallBottom = smallTop + smallH;
    final smallArchTop = smallTop;
    final smallCx = smallLeft + smallW / 2;

    return [
      // Duże Ń - lewa pionowa (dół -> góra)
      Waypoint.pixels(bigLeft, bigBottom, isStartPoint: true),
      Waypoint.pixels(bigLeft, bigTop + bigH * 0.5),
      Waypoint.pixels(bigLeft, bigTop),
      // Duże Ń - skos (góra-lewo -> dół-prawo)
      Waypoint.pixels(bigLeft + bigW * 0.5, bigTop + bigH * 0.5),
      Waypoint.pixels(bigRight, bigBottom),
      // Duże Ń - prawa pionowa (dół -> góra)
      Waypoint.pixels(bigRight, bigTop + bigH * 0.5),
      Waypoint.pixels(bigRight, bigTop),
      // Duże Ń - kreska nad literą (od dołu-lewo do góry-prawo)
      Waypoint.pixels(bigCx - 10, bigTop - 15),
      Waypoint.pixels(bigCx + 10, bigTop - 28),
      // Małe ń - laseczka (dół -> góra)
      Waypoint.pixels(smallLeft, smallBottom),
      Waypoint.pixels(smallLeft, smallArchTop + smallH * 0.15),
      // Małe ń - mostek (łuk w prawo)
      Waypoint.pixels(smallLeft + smallW * 0.5, smallArchTop),
      Waypoint.pixels(smallRight, smallArchTop + smallH * 0.25),
      // Małe ń - pion (prawo -> dół)
      Waypoint.pixels(smallRight, smallBottom),
      // Małe ń - kreska nad literą (na końcu!)
      Waypoint.pixels(smallCx - 8, smallTop - 12),
      Waypoint.pixels(smallCx + 8, smallTop - 22, isEndPoint: true),
    ];
  }

  /// Waypoints dla litery O o
  /// Duże O: pełny owal (gęsta siatka 12 punktów dla płynności)
  /// Małe o: mniejszy owal (8 punktów)
  List<Waypoint> _createWaypointsForO(
    double bigCx, double bigCy, double bigR,
    double smallCx, double smallCy, double smallR,
    double canvasWidth,
  ) {
    return [
      // Duże O - owal (start od góry, zgodnie z ruchem wskazówek zegara)
      // 12 punktów dla płynnego łuku
      Waypoint.pixels(bigCx, bigCy - bigR, isStartPoint: true),  // góra (12h)
      Waypoint.pixels(bigCx + bigR * 0.5, bigCy - bigR * 0.87),   // 1h
      Waypoint.pixels(bigCx + bigR * 0.87, bigCy - bigR * 0.5),   // 2h
      Waypoint.pixels(bigCx + bigR, bigCy),                        // prawo (3h)
      Waypoint.pixels(bigCx + bigR * 0.87, bigCy + bigR * 0.5),   // 4h
      Waypoint.pixels(bigCx + bigR * 0.5, bigCy + bigR * 0.87),   // 5h
      Waypoint.pixels(bigCx, bigCy + bigR),                        // dół (6h)
      Waypoint.pixels(bigCx - bigR * 0.5, bigCy + bigR * 0.87),   // 7h
      Waypoint.pixels(bigCx - bigR * 0.87, bigCy + bigR * 0.5),   // 8h
      Waypoint.pixels(bigCx - bigR, bigCy),                        // lewo (9h)
      Waypoint.pixels(bigCx - bigR * 0.87, bigCy - bigR * 0.5),   // 10h
      Waypoint.pixels(bigCx - bigR * 0.5, bigCy - bigR * 0.87),   // 11h
      // Małe o - owal (8 punktów)
      Waypoint.pixels(smallCx, smallCy - smallR),                  // góra
      Waypoint.pixels(smallCx + smallR * 0.71, smallCy - smallR * 0.71),  // prawo-góra
      Waypoint.pixels(smallCx + smallR, smallCy),                  // prawo
      Waypoint.pixels(smallCx + smallR * 0.71, smallCy + smallR * 0.71),  // prawo-dół
      Waypoint.pixels(smallCx, smallCy + smallR),                  // dół
      Waypoint.pixels(smallCx - smallR * 0.71, smallCy + smallR * 0.71),  // lewo-dół
      Waypoint.pixels(smallCx - smallR, smallCy),                  // lewo
      Waypoint.pixels(smallCx - smallR * 0.71, smallCy - smallR * 0.71, isEndPoint: true),  // lewo-góra (zamknięcie)
    ];
  }

  /// Waypoints dla litery P p
  /// Duże P: pionowa (dół->góra), brzuszek (góra->prawo->środek)
  /// Małe p: laseczka pod linię (góra->dół), brzuszek (kółko)
  List<Waypoint> _createWaypointsForP(
    double bigLeft, double bigTop, double bigW, double bigH,
    double smallLeft, double smallTop, double smallW, double smallH,
    double canvasWidth,
  ) {
    final bigRight = bigLeft + bigW * 0.9;
    final bigMid = bigTop + bigH / 2;
    final bigBottom = bigTop + bigH;

    // Małe p
    final smallR = smallH * 0.28;
    final smallCircleY = smallTop + smallR + smallH * 0.05;
    final smallTailBottom = smallTop + smallH + smallH * 0.35;

    return [
      // Duże P - pionowa (dół -> góra)
      Waypoint.pixels(bigLeft, bigBottom, isStartPoint: true),
      Waypoint.pixels(bigLeft, bigTop + bigH * 0.5),
      Waypoint.pixels(bigLeft, bigTop),
      // Duże P - górna część brzuszka (góra -> prawo)
      Waypoint.pixels(bigRight - 15, bigTop),
      Waypoint.pixels(bigRight, bigTop + bigH * 0.25),
      // Duże P - dolna część brzuszka (prawo -> środek)
      Waypoint.pixels(bigRight - 15, bigMid),
      Waypoint.pixels(bigLeft, bigMid),
      // Małe p - laseczka (góra -> dół pod linię)
      Waypoint.pixels(smallLeft, smallTop + smallH * 0.1),
      Waypoint.pixels(smallLeft, smallTop + smallH * 0.5),
      Waypoint.pixels(smallLeft, smallTailBottom),
      // Małe p - brzuszek (kółko: prawo -> dół -> lewo -> góra)
      Waypoint.pixels(smallLeft + smallR * 2, smallCircleY),        // prawa strona
      Waypoint.pixels(smallLeft + smallR, smallCircleY + smallR),   // dół
      Waypoint.pixels(smallLeft, smallCircleY, isEndPoint: true),   // lewa strona (zamknięcie)
    ];
  }

  /// Waypoints dla litery R r
  /// Duże R: pion (dół->góra), brzuszek (góra->prawo->środek), nóżka (środek->prawo-dół)
  /// Małe r: laseczka (dół->góra), mały łuk w prawo
  List<Waypoint> _createWaypointsForR(
    double bigLeft, double bigTop, double bigW, double bigH,
    double smallLeft, double smallTop, double smallW, double smallH,
    double canvasWidth,
  ) {
    final bigRight = bigLeft + bigW * 0.9;
    final bigMid = bigTop + bigH / 2;
    final bigBottom = bigTop + bigH;

    // Małe r
    final smallBottom = smallTop + smallH;

    return [
      // Duże R - pionowa (dół -> góra)
      Waypoint.pixels(bigLeft, bigBottom, isStartPoint: true),
      Waypoint.pixels(bigLeft, bigTop + bigH * 0.5),
      Waypoint.pixels(bigLeft, bigTop),
      // Duże R - górna część brzuszka (góra -> prawo)
      Waypoint.pixels(bigRight - 15, bigTop),
      Waypoint.pixels(bigRight, bigTop + bigH * 0.25),
      // Duże R - dolna część brzuszka (prawo -> środek)
      Waypoint.pixels(bigRight - 15, bigMid),
      Waypoint.pixels(bigLeft, bigMid),
      // Duże R - nóżka (środek -> prawo-dół)
      Waypoint.pixels(bigLeft + bigW * 0.35, bigMid),
      Waypoint.pixels(bigLeft + bigW, bigBottom),
      // Małe r - laseczka (dół -> góra)
      Waypoint.pixels(smallLeft, smallBottom),
      Waypoint.pixels(smallLeft, smallTop + smallH * 0.15),
      // Małe r - łuk w prawo
      Waypoint.pixels(smallLeft + smallW * 0.5, smallTop),
      Waypoint.pixels(smallLeft + smallW * 0.8, smallTop + smallH * 0.15, isEndPoint: true),
    ];
  }

  /// Waypoints dla litery S s
  /// Duże S: podwójny łuk "wąż" (gęsta siatka dla płynności)
  /// Małe s: analogiczny kształt (mniejszy)
  List<Waypoint> _createWaypointsForS(
    double bigCx, double bigTop, double bigW, double bigH,
    double smallCx, double smallTop, double smallW, double smallH,
    double canvasWidth,
  ) {
    final bigBottom = bigTop + bigH;
    final bigMid = bigTop + bigH / 2;

    final smallBottom = smallTop + smallH;
    final smallMid = smallTop + smallH / 2;

    return [
      // Duże S - start (prawo-góra)
      Waypoint.pixels(bigCx + bigW / 2, bigTop + bigH * 0.12, isStartPoint: true),
      // Duże S - górny łuk (prawo -> góra -> lewo)
      Waypoint.pixels(bigCx + bigW / 2, bigTop),
      Waypoint.pixels(bigCx, bigTop),
      Waypoint.pixels(bigCx - bigW / 2, bigTop),
      Waypoint.pixels(bigCx - bigW / 2, bigTop + bigH * 0.22),
      // Duże S - środek (lewo -> środek -> prawo)
      Waypoint.pixels(bigCx - bigW / 2, bigMid),
      Waypoint.pixels(bigCx, bigMid),
      Waypoint.pixels(bigCx + bigW / 2, bigMid),
      Waypoint.pixels(bigCx + bigW / 2, bigMid + bigH * 0.22),
      // Duże S - dolny łuk (prawo -> dół -> lewo)
      Waypoint.pixels(bigCx + bigW / 2, bigBottom),
      Waypoint.pixels(bigCx, bigBottom),
      Waypoint.pixels(bigCx - bigW / 2, bigBottom),
      Waypoint.pixels(bigCx - bigW / 2, bigBottom - bigH * 0.12),
      // Małe s - start (prawo-góra)
      Waypoint.pixels(smallCx + smallW / 2, smallTop + smallH * 0.15),
      // Małe s - górny łuk
      Waypoint.pixels(smallCx + smallW / 2, smallTop),
      Waypoint.pixels(smallCx, smallTop),
      Waypoint.pixels(smallCx - smallW / 2, smallTop + smallH * 0.22),
      // Małe s - środek
      Waypoint.pixels(smallCx - smallW / 2, smallMid),
      Waypoint.pixels(smallCx, smallMid),
      Waypoint.pixels(smallCx + smallW / 2, smallMid + smallH * 0.22),
      // Małe s - dolny łuk
      Waypoint.pixels(smallCx + smallW / 2, smallBottom),
      Waypoint.pixels(smallCx, smallBottom),
      Waypoint.pixels(smallCx - smallW / 2, smallBottom - smallH * 0.15, isEndPoint: true),
    ];
  }

  /// Waypoints dla litery Ś ś
  /// Jak S/s + kreska ukośna nad literą (na końcu!)
  List<Waypoint> _createWaypointsForSKreska(
    double bigCx, double bigTop, double bigW, double bigH,
    double smallCx, double smallTop, double smallW, double smallH,
    double canvasWidth,
  ) {
    final bigBottom = bigTop + bigH;
    final bigMid = bigTop + bigH / 2;

    final smallBottom = smallTop + smallH;
    final smallMid = smallTop + smallH / 2;

    return [
      // Duże Ś - start (prawo-góra)
      Waypoint.pixels(bigCx + bigW / 2, bigTop + bigH * 0.12, isStartPoint: true),
      // Duże Ś - górny łuk
      Waypoint.pixels(bigCx + bigW / 2, bigTop),
      Waypoint.pixels(bigCx, bigTop),
      Waypoint.pixels(bigCx - bigW / 2, bigTop),
      Waypoint.pixels(bigCx - bigW / 2, bigTop + bigH * 0.22),
      // Duże Ś - środek
      Waypoint.pixels(bigCx - bigW / 2, bigMid),
      Waypoint.pixels(bigCx, bigMid),
      Waypoint.pixels(bigCx + bigW / 2, bigMid),
      Waypoint.pixels(bigCx + bigW / 2, bigMid + bigH * 0.22),
      // Duże Ś - dolny łuk
      Waypoint.pixels(bigCx + bigW / 2, bigBottom),
      Waypoint.pixels(bigCx, bigBottom),
      Waypoint.pixels(bigCx - bigW / 2, bigBottom),
      Waypoint.pixels(bigCx - bigW / 2, bigBottom - bigH * 0.12),
      // Duże Ś - kreska nad literą (na końcu!)
      Waypoint.pixels(bigCx - 10, bigTop - 15),
      Waypoint.pixels(bigCx + 10, bigTop - 28),
      // Małe ś - start (prawo-góra)
      Waypoint.pixels(smallCx + smallW / 2, smallTop + smallH * 0.15),
      // Małe ś - górny łuk
      Waypoint.pixels(smallCx + smallW / 2, smallTop),
      Waypoint.pixels(smallCx, smallTop),
      Waypoint.pixels(smallCx - smallW / 2, smallTop + smallH * 0.22),
      // Małe ś - środek
      Waypoint.pixels(smallCx - smallW / 2, smallMid),
      Waypoint.pixels(smallCx, smallMid),
      Waypoint.pixels(smallCx + smallW / 2, smallMid + smallH * 0.22),
      // Małe ś - dolny łuk
      Waypoint.pixels(smallCx + smallW / 2, smallBottom),
      Waypoint.pixels(smallCx, smallBottom),
      Waypoint.pixels(smallCx - smallW / 2, smallBottom - smallH * 0.15),
      // Małe ś - kreska nad literą (na końcu!)
      Waypoint.pixels(smallCx - 8, smallTop - 12),
      Waypoint.pixels(smallCx + 8, smallTop - 22, isEndPoint: true),
    ];
  }

  /// Waypoints dla litery T t
  /// Duże T: poprzeczka (lewo->prawo), pion (góra->dół)
  /// Małe t: pion (góra->dół z haczykiem), poprzeczka
  List<Waypoint> _createWaypointsForT(
    double bigCx, double bigTop, double bigW, double bigH,
    double smallCx, double smallTop, double smallW, double smallH,
    double canvasWidth,
  ) {
    final bigLeft = bigCx - bigW / 2;
    final bigRight = bigCx + bigW / 2;
    final bigBottom = bigTop + bigH;

    // Małe t
    final smallCrossY = smallTop + smallH * 0.25;
    final smallBottom = smallTop + smallH;

    return [
      // Duże T - poprzeczka (lewo -> prawo)
      Waypoint.pixels(bigLeft, bigTop, isStartPoint: true),
      Waypoint.pixels(bigCx, bigTop),
      Waypoint.pixels(bigRight, bigTop),
      // Duże T - pion (góra -> dół)
      Waypoint.pixels(bigCx, bigTop),
      Waypoint.pixels(bigCx, bigTop + bigH * 0.5),
      Waypoint.pixels(bigCx, bigBottom),
      // Małe t - pion (góra -> dół z haczykiem)
      Waypoint.pixels(smallCx, smallTop),
      Waypoint.pixels(smallCx, smallTop + smallH * 0.5),
      Waypoint.pixels(smallCx, smallBottom - 8),
      Waypoint.pixels(smallCx + smallW * 0.3, smallBottom),
      // Małe t - poprzeczka (lewo -> prawo, na końcu!)
      Waypoint.pixels(smallCx - smallW * 0.3, smallCrossY),
      Waypoint.pixels(smallCx + smallW * 0.3, smallCrossY, isEndPoint: true),
    ];
  }

  /// Waypoints dla litery U u
  /// Duże U: duży łuk otwarty u góry (lewo-góra -> dół -> prawo-góra)
  /// Małe u: mały łuk + laseczka (połączenie z prawą stroną)
  List<Waypoint> _createWaypointsForU(
    double bigLeft, double bigTop, double bigW, double bigH,
    double smallLeft, double smallTop, double smallW, double smallH,
    double canvasWidth,
  ) {
    final bigRight = bigLeft + bigW;
    final bigBottom = bigTop + bigH;
    final bigCx = bigLeft + bigW / 2;

    // Małe u
    final smallRight = smallLeft + smallW;
    final smallBottom = smallTop + smallH;
    final smallCx = smallLeft + smallW / 2;

    return [
      // Duże U - lewa strona (góra -> dół)
      Waypoint.pixels(bigLeft, bigTop, isStartPoint: true),
      Waypoint.pixels(bigLeft, bigTop + bigH * 0.5),
      Waypoint.pixels(bigLeft, bigBottom - 25),
      // Duże U - łuk na dole (lewo -> środek -> prawo)
      Waypoint.pixels(bigLeft, bigBottom),
      Waypoint.pixels(bigCx, bigBottom),
      Waypoint.pixels(bigRight, bigBottom),
      Waypoint.pixels(bigRight, bigBottom - 25),
      // Duże U - prawa strona (dół -> góra)
      Waypoint.pixels(bigRight, bigTop + bigH * 0.5),
      Waypoint.pixels(bigRight, bigTop),
      // Małe u - lewa strona (góra -> dół)
      Waypoint.pixels(smallLeft, smallTop),
      Waypoint.pixels(smallLeft, smallBottom - 15),
      // Małe u - łuk na dole
      Waypoint.pixels(smallLeft, smallBottom),
      Waypoint.pixels(smallCx, smallBottom),
      Waypoint.pixels(smallRight, smallBottom),
      Waypoint.pixels(smallRight, smallBottom - 15),
      // Małe u - prawa strona (dół -> góra -> dół - laseczka)
      Waypoint.pixels(smallRight, smallTop),
      Waypoint.pixels(smallRight, smallBottom, isEndPoint: true),
    ];
  }

  /// Waypoints dla litery Ą ą
  /// Jak A/a + ogonek (łuk w prawo-dół) jako ostatni ruch
  List<Waypoint> _createWaypointsForAOgonek(
    double bigCx, double bigTop, double bigW, double bigH,
    double smallCx, double smallTop, double smallW, double smallH,
    double canvasWidth,
  ) {
    final bigLeft = bigCx - bigW / 2;
    final bigRight = bigCx + bigW / 2;
    final bigBottom = bigTop + bigH;
    final bigMidY = bigTop + bigH * 0.65;

    // Mała litera 'ą'
    final smallR = smallH * 0.35;
    final smallCircleY = smallTop + smallH - smallR;
    final smallRight = smallCx + smallW * 0.3;
    final smallBottom = smallTop + smallH;

    return [
      // Duże A - lewa noga (od dołu do góry)
      Waypoint.pixels(bigLeft, bigBottom, isStartPoint: true),
      Waypoint.pixels((bigLeft + bigCx) / 2, (bigBottom + bigTop) / 2),
      Waypoint.pixels(bigCx, bigTop),
      // Duże A - prawa noga (od góry do dołu)
      Waypoint.pixels((bigCx + bigRight) / 2, (bigTop + bigBottom) / 2),
      Waypoint.pixels(bigRight, bigBottom),
      // Duże A - poprzeczka
      Waypoint.pixels(bigLeft + bigW * 0.2, bigMidY),
      Waypoint.pixels(bigRight - bigW * 0.2, bigMidY),
      // Duże Ą - ogonek (na końcu!)
      Waypoint.pixels(bigRight - 3, bigBottom),
      Waypoint.pixels(bigRight + 8, bigBottom + 12),
      Waypoint.pixels(bigRight + 4, bigBottom + 20),
      // Mała a - kółko (góra)
      Waypoint.pixels(smallCx, smallCircleY - smallR),
      // Mała a - kółko (dół)
      Waypoint.pixels(smallCx, smallCircleY + smallR),
      // Mała a - kreska w dół
      Waypoint.pixels(smallRight, smallBottom),
      // Małe ą - ogonek (na końcu!)
      Waypoint.pixels(smallRight - 2, smallBottom),
      Waypoint.pixels(smallRight + 6, smallBottom + 10),
      Waypoint.pixels(smallRight + 3, smallBottom + 16, isEndPoint: true),
    ];
  }

  /// Waypoints dla litery Ć ć
  /// Jak C/c + kreska ukośna nad literą jako ostatni ruch
  List<Waypoint> _createWaypointsForCKreska(
    double bigCx, double bigCy, double bigR, double bigTop,
    double smallCx, double smallCy, double smallR, double smallTop,
    double canvasWidth,
  ) {
    return [
      // Duża C - łuk od góra-prawo do dół-prawo
      Waypoint.pixels(bigCx + bigR * 0.8, bigCy - bigR * 0.6, isStartPoint: true),
      Waypoint.pixels(bigCx, bigCy - bigR),        // góra
      Waypoint.pixels(bigCx - bigR, bigCy),         // lewo
      Waypoint.pixels(bigCx, bigCy + bigR),          // dół
      Waypoint.pixels(bigCx + bigR * 0.8, bigCy + bigR * 0.6),
      // Duże Ć - kreska nad literą (na końcu!)
      Waypoint.pixels(bigCx - 10, bigTop - 15),
      Waypoint.pixels(bigCx + 10, bigTop - 28),
      // Mała c - łuk
      Waypoint.pixels(smallCx + smallR * 0.8, smallCy - smallR * 0.6),
      Waypoint.pixels(smallCx, smallCy - smallR),   // góra
      Waypoint.pixels(smallCx - smallR, smallCy),    // lewo
      Waypoint.pixels(smallCx, smallCy + smallR),     // dół
      Waypoint.pixels(smallCx + smallR * 0.8, smallCy + smallR * 0.6),
      // Małe ć - kreska nad literą (na końcu!)
      Waypoint.pixels(smallCx - 8, smallTop - 12),
      Waypoint.pixels(smallCx + 8, smallTop - 22, isEndPoint: true),
    ];
  }

  /// Waypoints dla litery Ę ę
  /// Jak E/e + ogonek (łuk w prawo-dół) jako ostatni ruch
  List<Waypoint> _createWaypointsForEOgonek(
    double bigLeft, double bigTop, double bigW, double bigH,
    double smallCx, double smallCy, double smallR,
    double canvasWidth,
  ) {
    final bigRight = bigLeft + bigW;
    final bigMid = bigTop + bigH / 2;
    final bigBottom = bigTop + bigH;

    final smallBottom = smallCy + smallR;

    return [
      // Duże E - kreska pionowa (góra -> dół)
      Waypoint.pixels(bigLeft, bigTop, isStartPoint: true),
      Waypoint.pixels(bigLeft, bigMid),
      Waypoint.pixels(bigLeft, bigBottom),
      // Duże E - górna pozioma (lewo -> prawo)
      Waypoint.pixels(bigRight, bigTop),
      // Duże E - środkowa pozioma (lewo -> prawo)
      Waypoint.pixels(bigLeft, bigMid),  // powrót
      Waypoint.pixels(bigRight - 10, bigMid),
      // Duże E - dolna pozioma (lewo -> prawo)
      Waypoint.pixels(bigLeft, bigBottom),  // powrót
      Waypoint.pixels(bigRight, bigBottom),
      // Duże Ę - ogonek (na końcu!)
      Waypoint.pixels(bigRight - 3, bigBottom),
      Waypoint.pixels(bigRight + 8, bigBottom + 12),
      Waypoint.pixels(bigRight + 4, bigBottom + 20),
      // Małe e - kreska pozioma (lewo -> prawo)
      Waypoint.pixels(smallCx - smallR, smallCy),
      Waypoint.pixels(smallCx + smallR, smallCy),
      // Małe e - łuk (prawo -> góra -> lewo -> dół-lewo)
      Waypoint.pixels(smallCx, smallCy - smallR),   // góra
      Waypoint.pixels(smallCx - smallR, smallCy),    // lewo
      Waypoint.pixels(smallCx - smallR * 0.7, smallBottom),  // dół-lewo
      // Małe ę - ogonek (na końcu!)
      Waypoint.pixels(smallCx - smallR * 0.7, smallBottom),
      Waypoint.pixels(smallCx - smallR * 0.5 + 8, smallBottom + 10),
      Waypoint.pixels(smallCx - smallR * 0.5 + 5, smallBottom + 16, isEndPoint: true),
    ];
  }

  /// Waypoints dla litery Ó ó
  /// Jak O/o + kreska ukośna nad literą jako ostatni ruch
  List<Waypoint> _createWaypointsForOKreska(
    double bigCx, double bigCy, double bigR, double bigTop,
    double smallCx, double smallCy, double smallR, double smallTop,
    double canvasWidth,
  ) {
    return [
      // Duże O - owal (start od góry, zgodnie z ruchem wskazówek zegara)
      // 12 punktów dla płynnego łuku
      Waypoint.pixels(bigCx, bigCy - bigR, isStartPoint: true),  // góra (12h)
      Waypoint.pixels(bigCx + bigR * 0.5, bigCy - bigR * 0.87),   // 1h
      Waypoint.pixels(bigCx + bigR * 0.87, bigCy - bigR * 0.5),   // 2h
      Waypoint.pixels(bigCx + bigR, bigCy),                        // prawo (3h)
      Waypoint.pixels(bigCx + bigR * 0.87, bigCy + bigR * 0.5),   // 4h
      Waypoint.pixels(bigCx + bigR * 0.5, bigCy + bigR * 0.87),   // 5h
      Waypoint.pixels(bigCx, bigCy + bigR),                        // dół (6h)
      Waypoint.pixels(bigCx - bigR * 0.5, bigCy + bigR * 0.87),   // 7h
      Waypoint.pixels(bigCx - bigR * 0.87, bigCy + bigR * 0.5),   // 8h
      Waypoint.pixels(bigCx - bigR, bigCy),                        // lewo (9h)
      Waypoint.pixels(bigCx - bigR * 0.87, bigCy - bigR * 0.5),   // 10h
      Waypoint.pixels(bigCx - bigR * 0.5, bigCy - bigR * 0.87),   // 11h
      // Duże Ó - kreska nad literą (na końcu!)
      Waypoint.pixels(bigCx - 10, bigTop - 15),
      Waypoint.pixels(bigCx + 10, bigTop - 28),
      // Małe o - owal (8 punktów)
      Waypoint.pixels(smallCx, smallCy - smallR),                  // góra
      Waypoint.pixels(smallCx + smallR * 0.71, smallCy - smallR * 0.71),  // prawo-góra
      Waypoint.pixels(smallCx + smallR, smallCy),                  // prawo
      Waypoint.pixels(smallCx + smallR * 0.71, smallCy + smallR * 0.71),  // prawo-dół
      Waypoint.pixels(smallCx, smallCy + smallR),                  // dół
      Waypoint.pixels(smallCx - smallR * 0.71, smallCy + smallR * 0.71),  // lewo-dół
      Waypoint.pixels(smallCx - smallR, smallCy),                  // lewo
      Waypoint.pixels(smallCx - smallR * 0.71, smallCy - smallR * 0.71),  // lewo-góra
      // Małe ó - kreska nad literą (na końcu!)
      Waypoint.pixels(smallCx - 8, smallTop - 12),
      Waypoint.pixels(smallCx + 8, smallTop - 22, isEndPoint: true),
    ];
  }

  /// Waypoints dla litery W w
  /// Duże W: skos dół, skos góra, skos dół, skos góra (jak dwa V)
  /// Małe w: podobnie, mniejsza skala
  List<Waypoint> _createWaypointsForW(
    double bigLeft, double bigTop, double bigW, double bigH,
    double smallLeft, double smallTop, double smallW, double smallH,
    double canvasWidth,
  ) {
    final bigRight = bigLeft + bigW;
    final bigBottom = bigTop + bigH;
    final bigQ1 = bigLeft + bigW * 0.25;
    final bigQ2 = bigLeft + bigW * 0.5;
    final bigQ3 = bigLeft + bigW * 0.75;

    // Małe w
    final smallRight = smallLeft + smallW;
    final smallBottom = smallTop + smallH;
    final smallQ1 = smallLeft + smallW * 0.25;
    final smallQ2 = smallLeft + smallW * 0.5;
    final smallQ3 = smallLeft + smallW * 0.75;

    return [
      // Duże W - skos 1 (lewo-góra -> dół)
      Waypoint.pixels(bigLeft, bigTop, isStartPoint: true),
      Waypoint.pixels(bigQ1, bigBottom),
      // Duże W - skos 2 (dół -> środek-góra)
      Waypoint.pixels(bigQ2, bigTop + bigH * 0.45),
      // Duże W - skos 3 (środek-góra -> dół)
      Waypoint.pixels(bigQ3, bigBottom),
      // Duże W - skos 4 (dół -> prawo-góra)
      Waypoint.pixels(bigRight, bigTop),
      // Małe w - skos 1 (lewo-góra -> dół)
      Waypoint.pixels(smallLeft, smallTop),
      Waypoint.pixels(smallQ1, smallBottom),
      // Małe w - skos 2 (dół -> środek-góra)
      Waypoint.pixels(smallQ2, smallTop + smallH * 0.5),
      // Małe w - skos 3 (środek-góra -> dół)
      Waypoint.pixels(smallQ3, smallBottom),
      // Małe w - skos 4 (dół -> prawo-góra)
      Waypoint.pixels(smallRight, smallTop, isEndPoint: true),
    ];
  }

  /// Waypoints dla litery Y y
  /// Duże Y: dwa skosy łączące się w środku + pion w dół
  /// Małe y: krótki skos w prawo + długi skos w lewo pod linię
  List<Waypoint> _createWaypointsForY(
    double bigLeft, double bigTop, double bigW, double bigH,
    double smallLeft, double smallTop, double smallW, double smallH,
    double canvasWidth,
  ) {
    final bigRight = bigLeft + bigW;
    final bigCx = bigLeft + bigW / 2;
    final bigMid = bigTop + bigH / 2;
    final bigBottom = bigTop + bigH;

    // Małe y
    final smallRight = smallLeft + smallW;
    final smallCx = smallLeft + smallW / 2;
    final smallMid = smallTop + smallH * 0.6;
    final smallTailBottom = smallTop + smallH + smallH * 0.35;

    return [
      // Duże Y - skos lewy (lewo-góra -> środek)
      Waypoint.pixels(bigLeft, bigTop, isStartPoint: true),
      Waypoint.pixels(bigCx, bigMid),
      // Duże Y - skos prawy (prawo-góra -> środek)
      Waypoint.pixels(bigRight, bigTop),
      Waypoint.pixels(bigCx, bigMid),
      // Duże Y - pion (środek -> dół)
      Waypoint.pixels(bigCx, bigBottom),
      // Małe y - skos lewy (lewo-góra -> środek)
      Waypoint.pixels(smallLeft, smallTop),
      Waypoint.pixels(smallCx, smallMid),
      // Małe y - skos prawy (prawo-góra -> środek -> ogonek pod linię)
      Waypoint.pixels(smallRight, smallTop),
      Waypoint.pixels(smallCx, smallMid),
      Waypoint.pixels(smallCx - smallW * 0.2, smallTailBottom),
      // Małe y - haczyk na końcu ogonka
      Waypoint.pixels(smallCx - smallW * 0.5, smallTailBottom - 5, isEndPoint: true),
    ];
  }

  /// Waypoints dla litery Z z
  /// Duże Z: poziom góra, skos, poziom dół (zygzak)
  /// Małe z: tak samo, mniejsza skala
  List<Waypoint> _createWaypointsForZ(
    double bigLeft, double bigTop, double bigW, double bigH,
    double smallLeft, double smallTop, double smallW, double smallH,
    double canvasWidth,
  ) {
    final bigRight = bigLeft + bigW;
    final bigBottom = bigTop + bigH;

    // Małe z
    final smallRight = smallLeft + smallW;
    final smallBottom = smallTop + smallH;

    return [
      // Duże Z - górna pozioma (lewo -> prawo)
      Waypoint.pixels(bigLeft, bigTop, isStartPoint: true),
      Waypoint.pixels(bigLeft + bigW * 0.5, bigTop),
      Waypoint.pixels(bigRight, bigTop),
      // Duże Z - skos (prawo-góra -> lewo-dół)
      Waypoint.pixels(bigLeft + bigW * 0.5, bigTop + bigH * 0.5),
      Waypoint.pixels(bigLeft, bigBottom),
      // Duże Z - dolna pozioma (lewo -> prawo)
      Waypoint.pixels(bigLeft + bigW * 0.5, bigBottom),
      Waypoint.pixels(bigRight, bigBottom),
      // Małe z - górna pozioma (lewo -> prawo)
      Waypoint.pixels(smallLeft, smallTop),
      Waypoint.pixels(smallRight, smallTop),
      // Małe z - skos (prawo-góra -> lewo-dół)
      Waypoint.pixels(smallLeft + smallW * 0.5, smallTop + smallH * 0.5),
      Waypoint.pixels(smallLeft, smallBottom),
      // Małe z - dolna pozioma (lewo -> prawo)
      Waypoint.pixels(smallRight, smallBottom, isEndPoint: true),
    ];
  }

  /// Waypoints dla litery Ź ź
  /// Jak Z/z + kreska ukośna nad literą jako ostatni ruch
  List<Waypoint> _createWaypointsForZKreska(
    double bigLeft, double bigTop, double bigW, double bigH,
    double smallLeft, double smallTop, double smallW, double smallH,
    double canvasWidth,
  ) {
    final bigRight = bigLeft + bigW;
    final bigBottom = bigTop + bigH;
    final bigCx = bigLeft + bigW / 2;

    // Małe ź
    final smallRight = smallLeft + smallW;
    final smallBottom = smallTop + smallH;
    final smallCx = smallLeft + smallW / 2;

    return [
      // Duże Ź - górna pozioma (lewo -> prawo)
      Waypoint.pixels(bigLeft, bigTop, isStartPoint: true),
      Waypoint.pixels(bigLeft + bigW * 0.5, bigTop),
      Waypoint.pixels(bigRight, bigTop),
      // Duże Ź - skos (prawo-góra -> lewo-dół)
      Waypoint.pixels(bigLeft + bigW * 0.5, bigTop + bigH * 0.5),
      Waypoint.pixels(bigLeft, bigBottom),
      // Duże Ź - dolna pozioma (lewo -> prawo)
      Waypoint.pixels(bigLeft + bigW * 0.5, bigBottom),
      Waypoint.pixels(bigRight, bigBottom),
      // Duże Ź - kreska nad literą (na końcu!)
      Waypoint.pixels(bigCx - 10, bigTop - 15),
      Waypoint.pixels(bigCx + 10, bigTop - 28),
      // Małe ź - górna pozioma (lewo -> prawo)
      Waypoint.pixels(smallLeft, smallTop),
      Waypoint.pixels(smallRight, smallTop),
      // Małe ź - skos (prawo-góra -> lewo-dół)
      Waypoint.pixels(smallLeft + smallW * 0.5, smallTop + smallH * 0.5),
      Waypoint.pixels(smallLeft, smallBottom),
      // Małe ź - dolna pozioma (lewo -> prawo)
      Waypoint.pixels(smallRight, smallBottom),
      // Małe ź - kreska nad literą (na końcu!)
      Waypoint.pixels(smallCx - 8, smallTop - 12),
      Waypoint.pixels(smallCx + 8, smallTop - 22, isEndPoint: true),
    ];
  }

  /// Waypoints dla litery Ż ż
  /// Jak Z/z + kropka nad literą jako ostatni ruch
  List<Waypoint> _createWaypointsForZKropka(
    double bigLeft, double bigTop, double bigW, double bigH,
    double smallLeft, double smallTop, double smallW, double smallH,
    double canvasWidth,
  ) {
    final bigRight = bigLeft + bigW;
    final bigBottom = bigTop + bigH;
    final bigCx = bigLeft + bigW / 2;

    // Małe ż
    final smallRight = smallLeft + smallW;
    final smallBottom = smallTop + smallH;
    final smallCx = smallLeft + smallW / 2;

    return [
      // Duże Ż - górna pozioma (lewo -> prawo)
      Waypoint.pixels(bigLeft, bigTop, isStartPoint: true),
      Waypoint.pixels(bigLeft + bigW * 0.5, bigTop),
      Waypoint.pixels(bigRight, bigTop),
      // Duże Ż - skos (prawo-góra -> lewo-dół)
      Waypoint.pixels(bigLeft + bigW * 0.5, bigTop + bigH * 0.5),
      Waypoint.pixels(bigLeft, bigBottom),
      // Duże Ż - dolna pozioma (lewo -> prawo)
      Waypoint.pixels(bigLeft + bigW * 0.5, bigBottom),
      Waypoint.pixels(bigRight, bigBottom),
      // Duże Ż - kropka nad literą (na końcu!)
      Waypoint.pixels(bigCx, bigTop - 20),
      // Małe ż - górna pozioma (lewo -> prawo)
      Waypoint.pixels(smallLeft, smallTop),
      Waypoint.pixels(smallRight, smallTop),
      // Małe ż - skos (prawo-góra -> lewo-dół)
      Waypoint.pixels(smallLeft + smallW * 0.5, smallTop + smallH * 0.5),
      Waypoint.pixels(smallLeft, smallBottom),
      // Małe ż - dolna pozioma (lewo -> prawo)
      Waypoint.pixels(smallRight, smallBottom),
      // Małe ż - kropka nad literą (na końcu!)
      Waypoint.pixels(smallCx, smallTop - 15, isEndPoint: true),
    ];
  }
}
