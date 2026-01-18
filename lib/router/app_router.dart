import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../screens/preloader_screen.dart';
import '../screens/home_screen.dart';
import '../screens/drawing_screen.dart';
import '../screens/learning_screen.dart';
import '../screens/fun_screen.dart';
import '../screens/pet_screen.dart';
import '../screens/games/maze_game_screen.dart';
import '../screens/games/matching_game_screen.dart';
import '../screens/games/dots_game_screen.dart';

/// Custom Fade Transition dla go_router
CustomTransitionPage<void> _buildFadeTransition({
  required BuildContext context,
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
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

/// Konfiguracja routera aplikacji
/// Uzywa go_router dla deklaratywnej nawigacji z Fade Transition
final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      name: 'preloader',
      builder: (context, state) => const PreloaderScreen(),
    ),
    GoRoute(
      path: '/home',
      name: 'home',
      pageBuilder: (context, state) => _buildFadeTransition(
        context: context,
        state: state,
        child: const HomeScreen(),
      ),
    ),
    GoRoute(
      path: '/drawing',
      name: 'drawing',
      pageBuilder: (context, state) => _buildFadeTransition(
        context: context,
        state: state,
        child: const DrawingScreen(),
      ),
    ),
    GoRoute(
      path: '/pet',
      name: 'pet',
      pageBuilder: (context, state) => _buildFadeTransition(
        context: context,
        state: state,
        child: const PetScreen(),
      ),
    ),
    GoRoute(
      path: '/learning',
      name: 'learning',
      pageBuilder: (context, state) => _buildFadeTransition(
        context: context,
        state: state,
        child: const LearningScreen(),
      ),
    ),
    GoRoute(
      path: '/fun',
      name: 'fun',
      pageBuilder: (context, state) => _buildFadeTransition(
        context: context,
        state: state,
        child: const FunScreen(),
      ),
      routes: [
        GoRoute(
          path: 'maze',
          name: 'maze',
          pageBuilder: (context, state) => _buildFadeTransition(
            context: context,
            state: state,
            child: const MazeGameScreen(),
          ),
        ),
        GoRoute(
          path: 'matching',
          name: 'matching',
          pageBuilder: (context, state) => _buildFadeTransition(
            context: context,
            state: state,
            child: const MatchingGameScreen(),
          ),
        ),
        GoRoute(
          path: 'dots',
          name: 'dots',
          pageBuilder: (context, state) => _buildFadeTransition(
            context: context,
            state: state,
            child: const DotsGameScreen(),
          ),
        ),
      ],
    ),
  ],
);
