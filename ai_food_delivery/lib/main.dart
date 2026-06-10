import 'package:ai_food_delivery/ai_delivery_screen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const FoodDeliveryConceptApp());
}

class FoodDeliveryConceptApp extends StatelessWidget {
  const FoodDeliveryConceptApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AiDeliveryTrackingScreen(),
    );
  }
}
