import 'dart:math';
import 'package:flutter/material.dart';
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
    return [
      // A a
      TracingPattern(
        name: 'A a',
        hint: 'Dwie kreski do gory i poprzeczka',
        path: _combinePaths([
          _createBigA(bigLetterCenterX, topY, bigLetterWidth, bigLetterHeight),
          _createSmallA(smallLetterCenterX, smallLetterTopY, smallLetterWidth, smallLetterHeight),
        ]),
      ),
      // Ą ą
      TracingPattern(
        name: 'Ą ą',
        hint: 'Litera A z ogonkiem',
        path: _combinePaths([
          _createBigAOgonek(bigLetterCenterX, topY, bigLetterWidth, bigLetterHeight),
          _createSmallAOgonek(smallLetterCenterX, smallLetterTopY, smallLetterWidth, smallLetterHeight),
        ]),
      ),
      // B b
      TracingPattern(
        name: 'B b',
        hint: 'Kreska pionowa i brzuszki',
        path: _combinePaths([
          _createBigB(bigLetterCenterX - bigLetterWidth / 2, topY, bigLetterWidth, bigLetterHeight),
          _createSmallB(smallLetterCenterX - smallLetterWidth / 2, smallLetterTopY, smallLetterWidth, smallLetterHeight),
        ]),
      ),
      // C c
      TracingPattern(
        name: 'C c',
        hint: 'Polkole otwarte w prawo',
        path: _combinePaths([
          _createBigC(bigLetterCenterX, topY + bigLetterHeight / 2, bigLetterHeight / 2.2),
          _createSmallC(smallLetterCenterX, smallLetterTopY + smallLetterHeight / 2, smallLetterHeight / 2.2),
        ]),
      ),
      // Ć ć
      TracingPattern(
        name: 'Ć ć',
        hint: 'Litera C z kreska na gorze',
        path: _combinePaths([
          _createBigCKreska(bigLetterCenterX, topY + bigLetterHeight / 2, bigLetterHeight / 2.2, topY),
          _createSmallCKreska(smallLetterCenterX, smallLetterTopY + smallLetterHeight / 2, smallLetterHeight / 2.2, smallLetterTopY),
        ]),
      ),
      // D d
      TracingPattern(
        name: 'D d',
        hint: 'Kreska i duzy brzuszek',
        path: _combinePaths([
          _createBigD(bigLetterCenterX - bigLetterWidth / 2, topY, bigLetterWidth, bigLetterHeight),
          _createSmallD(smallLetterCenterX - smallLetterWidth / 2, smallLetterTopY, smallLetterWidth, smallLetterHeight),
        ]),
      ),
      // E e
      TracingPattern(
        name: 'E e',
        hint: 'Kreska i trzy poziome',
        path: _combinePaths([
          _createBigE(bigLetterCenterX - bigLetterWidth / 2, topY, bigLetterWidth, bigLetterHeight),
          _createSmallE(smallLetterCenterX, smallLetterTopY + smallLetterHeight / 2, smallLetterHeight / 2.2),
        ]),
      ),
      // Ę ę
      TracingPattern(
        name: 'Ę ę',
        hint: 'Litera E z ogonkiem',
        path: _combinePaths([
          _createBigEOgonek(bigLetterCenterX - bigLetterWidth / 2, topY, bigLetterWidth, bigLetterHeight),
          _createSmallEOgonek(smallLetterCenterX, smallLetterTopY + smallLetterHeight / 2, smallLetterHeight / 2.2),
        ]),
      ),
      // F f
      TracingPattern(
        name: 'F f',
        hint: 'Kreska i dwie poziome na gorze',
        path: _combinePaths([
          _createBigF(bigLetterCenterX - bigLetterWidth / 2, topY, bigLetterWidth, bigLetterHeight),
          _createSmallF(smallLetterCenterX, smallLetterTopY, smallLetterWidth, smallLetterHeight),
        ]),
      ),
      // G g
      TracingPattern(
        name: 'G g',
        hint: 'Litera C z kreska do srodka',
        path: _combinePaths([
          _createBigG(bigLetterCenterX, topY + bigLetterHeight / 2, bigLetterHeight / 2.2),
          _createSmallG(smallLetterCenterX, smallLetterTopY, smallLetterWidth, smallLetterHeight),
        ]),
      ),
      // H h
      TracingPattern(
        name: 'H h',
        hint: 'Dwie pionowe polaczone w srodku',
        path: _combinePaths([
          _createBigH(bigLetterCenterX - bigLetterWidth / 2, topY, bigLetterWidth, bigLetterHeight),
          _createSmallH(smallLetterCenterX - smallLetterWidth / 2, smallLetterTopY, smallLetterWidth, smallLetterHeight),
        ]),
      ),
      // I i
      TracingPattern(
        name: 'I i',
        hint: 'Prosta kreska w dol',
        path: _combinePaths([
          _createBigI(bigLetterCenterX, topY, bigLetterHeight),
          _createSmallI(smallLetterCenterX, smallLetterTopY, smallLetterHeight),
        ]),
      ),
      // J j
      TracingPattern(
        name: 'J j',
        hint: 'Kreska zakrecona w lewo na dole',
        path: _combinePaths([
          _createBigJ(bigLetterCenterX, topY, bigLetterHeight),
          _createSmallJ(smallLetterCenterX, smallLetterTopY, smallLetterHeight),
        ]),
      ),
      // K k
      TracingPattern(
        name: 'K k',
        hint: 'Pionowa i dwie skosne',
        path: _combinePaths([
          _createBigK(bigLetterCenterX - bigLetterWidth / 2, topY, bigLetterWidth, bigLetterHeight),
          _createSmallK(smallLetterCenterX - smallLetterWidth / 2, smallLetterTopY, smallLetterWidth, smallLetterHeight),
        ]),
      ),
      // L l
      TracingPattern(
        name: 'L l',
        hint: 'Kreska w dol i w prawo',
        path: _combinePaths([
          _createBigL(bigLetterCenterX - bigLetterWidth / 2, topY, bigLetterWidth, bigLetterHeight),
          _createSmallL(smallLetterCenterX, smallLetterTopY, smallLetterHeight),
        ]),
      ),
      // Ł ł
      TracingPattern(
        name: 'Ł ł',
        hint: 'Litera L z kreska w poprzek',
        path: _combinePaths([
          _createBigLKreska(bigLetterCenterX - bigLetterWidth / 2, topY, bigLetterWidth, bigLetterHeight),
          _createSmallLKreska(smallLetterCenterX, smallLetterTopY, smallLetterHeight),
        ]),
      ),
      // M m
      TracingPattern(
        name: 'M m',
        hint: 'Dwa szczyty jak gory',
        path: _combinePaths([
          _createBigM(bigLetterCenterX - bigLetterWidth / 2, topY, bigLetterWidth, bigLetterHeight),
          _createSmallM(smallLetterCenterX - smallLetterWidth / 2, smallLetterTopY, smallLetterWidth, smallLetterHeight),
        ]),
      ),
      // N n
      TracingPattern(
        name: 'N n',
        hint: 'Dwie pionowe z ukosna',
        path: _combinePaths([
          _createBigN(bigLetterCenterX - bigLetterWidth / 2, topY, bigLetterWidth, bigLetterHeight),
          _createSmallN(smallLetterCenterX - smallLetterWidth / 2, smallLetterTopY, smallLetterWidth, smallLetterHeight),
        ]),
      ),
      // Ń ń
      TracingPattern(
        name: 'Ń ń',
        hint: 'Litera N z kreska na gorze',
        path: _combinePaths([
          _createBigNKreska(bigLetterCenterX - bigLetterWidth / 2, topY, bigLetterWidth, bigLetterHeight),
          _createSmallNKreska(smallLetterCenterX - smallLetterWidth / 2, smallLetterTopY, smallLetterWidth, smallLetterHeight),
        ]),
      ),
      // O o
      TracingPattern(
        name: 'O o',
        hint: 'Duze kolko',
        path: _combinePaths([
          _createBigO(bigLetterCenterX, topY + bigLetterHeight / 2, bigLetterHeight / 2.2),
          _createSmallO(smallLetterCenterX, smallLetterTopY + smallLetterHeight / 2, smallLetterHeight / 2.2),
        ]),
      ),
      // Ó ó
      TracingPattern(
        name: 'Ó ó',
        hint: 'Litera O z kreska na gorze',
        path: _combinePaths([
          _createBigOKreska(bigLetterCenterX, topY + bigLetterHeight / 2, bigLetterHeight / 2.2, topY),
          _createSmallOKreska(smallLetterCenterX, smallLetterTopY + smallLetterHeight / 2, smallLetterHeight / 2.2, smallLetterTopY),
        ]),
      ),
      // P p
      TracingPattern(
        name: 'P p',
        hint: 'Pionowa i brzuszek na gorze',
        path: _combinePaths([
          _createBigP(bigLetterCenterX - bigLetterWidth / 2, topY, bigLetterWidth, bigLetterHeight),
          _createSmallP(smallLetterCenterX - smallLetterWidth / 2, smallLetterTopY, smallLetterWidth, smallLetterHeight),
        ]),
      ),
      // R r
      TracingPattern(
        name: 'R r',
        hint: 'Jak P ale z nozka',
        path: _combinePaths([
          _createBigR(bigLetterCenterX - bigLetterWidth / 2, topY, bigLetterWidth, bigLetterHeight),
          _createSmallR(smallLetterCenterX - smallLetterWidth / 2, smallLetterTopY, smallLetterWidth, smallLetterHeight),
        ]),
      ),
      // S s
      TracingPattern(
        name: 'S s',
        hint: 'Waz - zakret w jedna i druga strone',
        path: _combinePaths([
          _createBigS(bigLetterCenterX, topY, bigLetterWidth * 0.6, bigLetterHeight),
          _createSmallS(smallLetterCenterX, smallLetterTopY, smallLetterWidth * 0.6, smallLetterHeight),
        ]),
      ),
      // Ś ś
      TracingPattern(
        name: 'Ś ś',
        hint: 'Litera S z kreska na gorze',
        path: _combinePaths([
          _createBigSKreska(bigLetterCenterX, topY, bigLetterWidth * 0.6, bigLetterHeight),
          _createSmallSKreska(smallLetterCenterX, smallLetterTopY, smallLetterWidth * 0.6, smallLetterHeight),
        ]),
      ),
      // T t
      TracingPattern(
        name: 'T t',
        hint: 'Kreska pozioma i pionowa w dol',
        path: _combinePaths([
          _createBigT(bigLetterCenterX, topY, bigLetterWidth, bigLetterHeight),
          _createSmallT(smallLetterCenterX, smallLetterTopY, smallLetterWidth, smallLetterHeight),
        ]),
      ),
      // U u
      TracingPattern(
        name: 'U u',
        hint: 'Jak miseczka',
        path: _combinePaths([
          _createBigU(bigLetterCenterX - bigLetterWidth / 2, topY, bigLetterWidth, bigLetterHeight),
          _createSmallU(smallLetterCenterX - smallLetterWidth / 2, smallLetterTopY, smallLetterWidth, smallLetterHeight),
        ]),
      ),
      // W w
      TracingPattern(
        name: 'W w',
        hint: 'Jak dwa V obok siebie',
        path: _combinePaths([
          _createBigW(bigLetterCenterX - bigLetterWidth / 2, topY, bigLetterWidth, bigLetterHeight),
          _createSmallW(smallLetterCenterX - smallLetterWidth / 2, smallLetterTopY, smallLetterWidth, smallLetterHeight),
        ]),
      ),
      // Y y
      TracingPattern(
        name: 'Y y',
        hint: 'Dwie skosne i kreska w dol',
        path: _combinePaths([
          _createBigY(bigLetterCenterX - bigLetterWidth / 2, topY, bigLetterWidth, bigLetterHeight),
          _createSmallY(smallLetterCenterX - smallLetterWidth / 2, smallLetterTopY, smallLetterWidth, smallLetterHeight),
        ]),
      ),
      // Z z
      TracingPattern(
        name: 'Z z',
        hint: 'Zygzak - pozioma, skos, pozioma',
        path: _combinePaths([
          _createBigZ(bigLetterCenterX - bigLetterWidth / 2, topY, bigLetterWidth, bigLetterHeight),
          _createSmallZ(smallLetterCenterX - smallLetterWidth / 2, smallLetterTopY, smallLetterWidth, smallLetterHeight),
        ]),
      ),
      // Ź ź
      TracingPattern(
        name: 'Ź ź',
        hint: 'Litera Z z kreska na gorze',
        path: _combinePaths([
          _createBigZKreska(bigLetterCenterX - bigLetterWidth / 2, topY, bigLetterWidth, bigLetterHeight),
          _createSmallZKreska(smallLetterCenterX - smallLetterWidth / 2, smallLetterTopY, smallLetterWidth, smallLetterHeight),
        ]),
      ),
      // Ż ż
      TracingPattern(
        name: 'Ż ż',
        hint: 'Litera Z z kropka na gorze',
        path: _combinePaths([
          _createBigZKropka(bigLetterCenterX - bigLetterWidth / 2, topY, bigLetterWidth, bigLetterHeight),
          _createSmallZKropka(smallLetterCenterX - smallLetterWidth / 2, smallLetterTopY, smallLetterWidth, smallLetterHeight),
        ]),
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
    // Mala litera 'p' - kreska w dol i kolko na gorze
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
}
