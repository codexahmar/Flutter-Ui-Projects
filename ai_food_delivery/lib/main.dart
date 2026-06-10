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
      theme: AppTheme.darkTheme,
      home: const AiFoodDiscoveryScreen(),
    );
  }
}