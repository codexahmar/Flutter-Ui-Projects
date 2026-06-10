import 'package:flutter/material.dart';

import 'ai_food_discovery_screen.dart';
import 'app_theme.dart';

void main() {
  runApp(const AiFoodDeliveryConceptApp());
}

class AiFoodDeliveryConceptApp extends StatelessWidget {
  const AiFoodDeliveryConceptApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI Food Delivery Concept',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      theme: AppTheme.darkTheme,
      builder: (context, child) {
        return ScrollConfiguration(
          behavior: const _NoGlowScrollBehavior(),
          child: child ?? const SizedBox.shrink(),
        );
      },
      home: const AiFoodDiscoveryScreen(),
    );
  }
}

class _NoGlowScrollBehavior extends MaterialScrollBehavior {
  const _NoGlowScrollBehavior();

  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    return child;
  }
}