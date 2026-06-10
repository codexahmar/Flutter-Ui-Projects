import 'package:flutter/material.dart';

import 'app_theme.dart';

class FoodItem {
  final String name;
  final String restaurant;
  final String description;
  final String price;
  final String time;
  final double rating;
  final IconData icon;
  final Color color;

  const FoodItem({
    required this.name,
    required this.restaurant,
    required this.description,
    required this.price,
    required this.time,
    required this.rating,
    required this.icon,
    required this.color,
  });
}

const List<FoodItem> demoFoods = [
  FoodItem(
    name: 'Classic Beef Burger',
    restaurant: 'Burger House',
    description: 'Double patty, cheese, fries and smoky sauce',
    price: 'Rs. 890',
    time: '18 min',
    rating: 4.9,
    icon: Icons.lunch_dining_rounded,
    color: AppTheme.orange,
  ),
  FoodItem(
    name: 'Creamy Alfredo Pasta',
    restaurant: 'Pasta Lab',
    description: 'Creamy white sauce pasta with grilled chicken',
    price: 'Rs. 1050',
    time: '22 min',
    rating: 4.8,
    icon: Icons.ramen_dining_rounded,
    color: AppTheme.green,
  ),
  FoodItem(
    name: 'Loaded Pizza Slice',
    restaurant: 'Crust Club',
    description: 'Cheese burst slice with spicy toppings',
    price: 'Rs. 650',
    time: '16 min',
    rating: 4.7,
    icon: Icons.local_pizza_rounded,
    color: AppTheme.cyan,
  ),
];