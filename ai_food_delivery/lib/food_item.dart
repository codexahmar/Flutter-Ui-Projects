import 'package:flutter/material.dart';

import 'app_theme.dart';

class FoodItem {
  final String name;
  final String restaurant;
  final String description;
  final String price;
  final int priceValue;
  final String time;
  final double rating;
  final String imageUrl;
  final String discount;
  final String category;
  final Color accent;
  final List<String> addOns;
  final int calories;
  final String distance;

  const FoodItem({
    required this.name,
    required this.restaurant,
    required this.description,
    required this.price,
    required this.priceValue,
    required this.time,
    required this.rating,
    required this.imageUrl,
    required this.discount,
    required this.category,
    required this.accent,
    required this.addOns,
    required this.calories,
    required this.distance,
  });
}

class RestaurantSpot {
  final String name;
  final String cuisine;
  final String eta;
  final String imageUrl;
  final double rating;
  final String tag;
  final Color accent;

  const RestaurantSpot({
    required this.name,
    required this.cuisine,
    required this.eta,
    required this.imageUrl,
    required this.rating,
    required this.tag,
    required this.accent,
  });
}

class FoodCategory {
  final String label;
  final IconData icon;

  const FoodCategory(this.label, this.icon);
}

const List<FoodItem> demoFoods = [
  FoodItem(
    name: 'Black Label Wagyu Burger',
    restaurant: 'Midnight Grill',
    description: 'Seared wagyu, truffle mayo, aged cheddar and crisp fries.',
    price: 'Rs. 1,490',
    priceValue: 1490,
    time: '18 min',
    rating: 4.9,
    imageUrl: 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?auto=format&fit=crop&w=1200&q=80',
    discount: '25% OFF',
    category: 'Burgers',
    accent: AppTheme.orange,
    addOns: const ['Extra cheese', 'Truffle dip', 'Garlic fries'],
    calories: 920,
    distance: '1.2 km',
  ),
  FoodItem(
    name: 'Creamy Alfredo Pasta',
    restaurant: 'Pasta Lab',
    description: 'Silky parmesan alfredo with grilled chicken and herb oil.',
    price: 'Rs. 1,050',
    priceValue: 1050,
    time: '22 min',
    rating: 4.8,
    imageUrl: 'https://images.unsplash.com/photo-1473093295043-cdd812d0e601?auto=format&fit=crop&w=1200&q=80',
    discount: '15% OFF',
    category: 'Pasta',
    accent: AppTheme.green,
    addOns: const ['Parmesan boost', 'Chicken strips', 'Garlic bread'],
    calories: 780,
    distance: '2.1 km',
  ),
  FoodItem(
    name: 'Stone Oven Pepperoni Pizza',
    restaurant: 'Crust Club',
    description: 'Thin crust, smoked pepperoni, fresh basil and molten mozzarella.',
    price: 'Rs. 1,280',
    priceValue: 1280,
    time: '16 min',
    rating: 4.8,
    imageUrl: 'https://images.unsplash.com/photo-1513104890138-7c749659a591?auto=format&fit=crop&w=1200&q=80',
    discount: '30% OFF',
    category: 'Pizza',
    accent: AppTheme.cyan,
    addOns: const ['Chili flakes', 'Cheese dip', 'Extra olives'],
    calories: 1040,
    distance: '0.9 km',
  ),
  FoodItem(
    name: 'Korean Chili Fries',
    restaurant: 'Snack Station',
    description: 'Crispy fries with sweet chili glaze, sesame, and fresh herbs.',
    price: 'Rs. 620',
    priceValue: 620,
    time: '14 min',
    rating: 4.7,
    imageUrl: 'https://images.unsplash.com/photo-1576107232684-1279f390859f?auto=format&fit=crop&w=1200&q=80',
    discount: '12% OFF',
    category: 'Snacks',
    accent: AppTheme.orange,
    addOns: const ['Spicy mayo', 'Cheese dust', 'Jalapeños'],
    calories: 510,
    distance: '0.7 km',
  ),
  FoodItem(
    name: 'Neon Citrus Cooler',
    restaurant: 'Aroma Bar',
    description: 'Chilled citrus mocktail with mint, soda and crushed ice.',
    price: 'Rs. 390',
    priceValue: 390,
    time: '10 min',
    rating: 4.6,
    imageUrl: 'https://images.unsplash.com/photo-1544145945-f90425340c7e?auto=format&fit=crop&w=1200&q=80',
    discount: 'BOGO',
    category: 'Drinks',
    accent: AppTheme.cyan,
    addOns: const ['Extra mint', 'Less ice', 'Vitamin boost'],
    calories: 180,
    distance: '0.5 km',
  ),
  FoodItem(
    name: 'Chef’s Plate Rice Bowl',
    restaurant: 'Urban Spoon',
    description: 'Restaurant-style rice bowl with grilled chicken, salad and sauce.',
    price: 'Rs. 980',
    priceValue: 980,
    time: '20 min',
    rating: 4.9,
    imageUrl: 'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?auto=format&fit=crop&w=1200&q=80',
    discount: 'Free drink',
    category: 'Restaurant',
    accent: AppTheme.green,
    addOns: const ['Egg topping', 'Garlic sauce', 'Salad upgrade'],
    calories: 690,
    distance: '1.7 km',
  ),
];

const List<RestaurantSpot> featuredRestaurants = [
  RestaurantSpot(
    name: 'Midnight Grill',
    cuisine: 'Burgers · Steak · Fries',
    eta: '18 min',
    imageUrl: 'https://images.unsplash.com/photo-1504674900247-0877df9cc836?auto=format&fit=crop&w=1200&q=80',
    rating: 4.9,
    tag: 'Premium',
    accent: AppTheme.orange,
  ),
  RestaurantSpot(
    name: 'Crust Club',
    cuisine: 'Pizza · Wings · Sides',
    eta: '16 min',
    imageUrl: 'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?auto=format&fit=crop&w=1200&q=80',
    rating: 4.8,
    tag: 'Fastest',
    accent: AppTheme.cyan,
  ),
  RestaurantSpot(
    name: 'Pasta Lab',
    cuisine: 'Pasta · Risotto · Desserts',
    eta: '22 min',
    imageUrl: 'https://images.unsplash.com/photo-1482049016688-2d3e1b311543?auto=format&fit=crop&w=1200&q=80',
    rating: 4.8,
    tag: 'Chef-picked',
    accent: AppTheme.green,
  ),
];

const List<FoodCategory> demoCategories = [
  FoodCategory('Recommended', Icons.auto_awesome_rounded),
  FoodCategory('Burgers', Icons.lunch_dining_rounded),
  FoodCategory('Pizza', Icons.local_pizza_rounded),
  FoodCategory('Pasta', Icons.ramen_dining_rounded),
  FoodCategory('Snacks', Icons.fastfood_rounded),
  FoodCategory('Drinks', Icons.local_drink_rounded),
];