import 'package:flutter/material.dart';

/// Custom PageRoute z animacją Fade (przenikanie)
/// Używany do płynnych przejść między ekranami
class FadePageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;

  FadePageRoute({required this.page})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: const Duration(milliseconds: 600),
          reverseTransitionDuration: const Duration(milliseconds: 400),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
        );
}

/// Helper function do łatwiejszego użycia
void navigateWithFade(BuildContext context, Widget page) {
  Navigator.push(
    context,
    FadePageRoute(page: page),
  );
}
