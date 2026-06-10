import 'package:flutter/material.dart';

import 'app_theme.dart';
import 'food_item.dart';
import 'order_confirmation_screen.dart';
import 'shared_widgets.dart';

class AiFoodDiscoveryScreen extends StatefulWidget {
  const AiFoodDiscoveryScreen({super.key});

  @override
  State<AiFoodDiscoveryScreen> createState() => _AiFoodDiscoveryScreenState();
}

class _AiFoodDiscoveryScreenState extends State<AiFoodDiscoveryScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _orbController;
  int _selectedFoodIndex = 0;
  int _selectedCategoryIndex = 0;

  List<FoodItem> get _visibleFoods {
    final category = demoCategories[_selectedCategoryIndex].label;
    if (category == 'Recommended') {
      return demoFoods;
    }

    return demoFoods.where((food) => food.category == category).toList();
  }

  FoodItem get _selectedFood {
    final foods = _visibleFoods;
    if (_selectedFoodIndex >= foods.length) {
      return foods.first;
    }

    return foods[_selectedFoodIndex];
  }

  @override
  void initState() {
    super.initState();
    _orbController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    )..repeat();
  }

  @override
  void dispose() {
    _orbController.dispose();
    super.dispose();
  }

  void _selectCategory(int index) {
    setState(() {
      _selectedCategoryIndex = index;
      _selectedFoodIndex = 0;
    });
  }

  void _selectFood(int index) {
    setState(() => _selectedFoodIndex = index);
  }

  void _goToConfirmation() {
    Navigator.push(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 560),
        pageBuilder: (_, animation, __) {
          return FadeTransition(
            opacity: animation,
            child: OrderConfirmationScreen(food: _selectedFood),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final visibleFoods = _visibleFoods;

    return Scaffold(
      body: Stack(
        children: [
          const Positioned.fill(child: _DiscoveryBackdrop()),
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Color(0x11000000),
                    Color(0xB8000000),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 1),
                duration: const Duration(milliseconds: 520),
                curve: Curves.easeOutCubic,
                builder: (context, value, child) {
                  return Opacity(
                    opacity: value,
                    child: Transform.translate(
                      offset: Offset(0, 22 * (1 - value)),
                      child: child,
                    ),
                  );
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Expanded(
                          child: PremiumSearchBar(
                            hintText: 'Crave something? Search here...',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.06),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.08),
                            ),
                          ),
                          child: const Icon(
                            Icons.person_rounded,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Fresh flavors,\ndelivered fast.',
                                style: Theme.of(context).textTheme.displayLarge,
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                'Discover top-rated dishes and local favorites, selected for quality and speed.',
                                style: TextStyle(
                                  color: AppTheme.muted,
                                  fontSize: 14,
                                  height: 1.5,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 14),
                        AnimatedBuilder(
                          animation: _orbController,
                          builder: (context, _) {
                            return CustomPaint(
                              size: const Size(98, 98),
                              painter: _RecommendationOrbPainter(
                                _orbController.value,
                              ),
                              child: const SizedBox(
                                width: 98,
                                height: 98,
                                child: Center(
                                  child: Icon(
                                    Icons.auto_awesome_rounded,
                                    color: AppTheme.bg,
                                    size: 30,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    PremiumSurface(
                      padding: const EdgeInsets.all(16),
                      borderRadius: BorderRadius.circular(30),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Wrap(
                                  spacing: 10,
                                  runSpacing: 8,
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 7,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppTheme.green.withOpacity(0.14),
                                        borderRadius: BorderRadius.circular(
                                          999,
                                        ),
                                      ),
                                      child: const Text(
                                        'Top Choice',
                                        style: TextStyle(
                                          color: AppTheme.green,
                                          fontSize: 11.5,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: const [
                                        Icon(
                                          Icons.bolt_rounded,
                                          color: AppTheme.orange,
                                          size: 18,
                                        ),
                                        SizedBox(width: 4),
                                        Text(
                                          '98% match',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  _selectedFood.name,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: -0.7,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '${_selectedFood.restaurant} · ${_selectedFood.distance} away · ${_selectedFood.calories} kcal',
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: AppTheme.muted,
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w500,
                                    height: 1.35,
                                  ),
                                ),
                                const SizedBox(height: 14),
                                Row(
                                  children: [
                                    _PillStat(
                                      icon: Icons.star_rounded,
                                      label: _selectedFood.rating
                                          .toStringAsFixed(1),
                                      accent: AppTheme.orange,
                                    ),
                                    const SizedBox(width: 8),
                                    _PillStat(
                                      icon: Icons.schedule_rounded,
                                      label: _selectedFood.time,
                                      accent: AppTheme.cyan,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: _PillStat(
                                        icon: Icons.local_offer_rounded,
                                        label: _selectedFood.discount,
                                        accent: AppTheme.green,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 14),
                          SizedBox(
                            width: 122,
                            height: 122,
                            child: PremiumNetworkImage(
                              imageUrl: _selectedFood.imageUrl,
                              heroTag: _selectedFood.imageUrl,
                              borderRadius: BorderRadius.circular(28),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      height: 48,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        itemBuilder: (context, index) {
                          final category = demoCategories[index];
                          final selected = _selectedCategoryIndex == index;

                          return CategoryPill(
                            label: category.label,
                            icon: category.icon,
                            selected: selected,
                            accentColor: selected
                                ? AppTheme.green
                                : AppTheme.cyan,
                            onTap: () => _selectCategory(index),
                          );
                        },
                        separatorBuilder: (_, __) => const SizedBox(width: 10),
                        itemCount: demoCategories.length,
                      ),
                    ),
                    const SizedBox(height: 22),
                    const PremiumSectionHeader(
                      title: 'Featured restaurants',
                      subtitle:
                          'Premium spots with standout photography and fast delivery.',
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      height: 208,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        itemBuilder: (context, index) {
                          final restaurant = featuredRestaurants[index];

                          return _RestaurantCard(restaurant: restaurant);
                        },
                        separatorBuilder: (_, __) => const SizedBox(width: 14),
                        itemCount: featuredRestaurants.length,
                      ),
                    ),
                    const SizedBox(height: 24),
                    PremiumSectionHeader(
                      title: 'Curated for you',
                      subtitle:
                          'Tap a dish to preview the AI-selected item and continue to checkout.',
                      actionLabel: 'View all',
                      onAction: () {},
                    ),
                    const SizedBox(height: 14),
                    if (visibleFoods.isEmpty)
                      const PremiumSurface(
                        child: Text(
                          'No dishes found for this category.',
                          style: TextStyle(color: AppTheme.muted),
                        ),
                      )
                    else
                      ListView.separated(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          final food = visibleFoods[index];
                          final selected = index == _selectedFoodIndex;

                          return _FoodCard(
                            food: food,
                            selected: selected,
                            onTap: () => _selectFood(index),
                          );
                        },
                        separatorBuilder: (_, __) => const SizedBox(height: 14),
                        itemCount: visibleFoods.length,
                      ),
                    const SizedBox(height: 24),
                    PrimaryActionButton(
                      label: 'Order from ${_selectedFood.restaurant}',
                      icon: Icons.arrow_forward_rounded,
                      onTap: _goToConfirmation,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withOpacity(0.08)),
            gradient: const LinearGradient(
              colors: [Color(0xFF1A2330), Color(0xFF0D141B)],
            ),
          ),
          child: const Icon(
            Icons.person_rounded,
            color: Colors.white,
            size: 22,
          ),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Delivering to',
                style: TextStyle(
                  color: AppTheme.muted,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 3),
              Text(
                'Home · Islamabad',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14.5,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Colors.white.withOpacity(0.07),
            border: Border.all(color: Colors.white.withOpacity(0.08)),
          ),
          child: const Icon(
            Icons.notifications_none_rounded,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}

class _PillStat extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color accent;

  const _PillStat({
    required this.icon,
    required this.label,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: accent.withOpacity(0.12),
        border: Border.all(color: accent.withOpacity(0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: accent, size: 14),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11.5,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _RestaurantCard extends StatelessWidget {
  final RestaurantSpot restaurant;

  const _RestaurantCard({required this.restaurant});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 190,
      height: 198,
      child: PremiumSurface(
        padding: EdgeInsets.zero,
        borderRadius: BorderRadius.circular(26),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 96,
              child: PremiumNetworkImage(
                imageUrl: restaurant.imageUrl,
                heroTag: 'res_${restaurant.imageUrl}',
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(26),
                ),
                overlayColors: const [Colors.transparent, Color(0x99000000)],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          restaurant.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: restaurant.accent.withOpacity(0.14),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          restaurant.tag,
                          style: TextStyle(
                            color: restaurant.accent,
                            fontSize: 10.5,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    restaurant.cuisine,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppTheme.muted,
                      fontSize: 11.4,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.star_rounded,
                        color: AppTheme.orange,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        restaurant.rating.toStringAsFixed(1),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        restaurant.eta,
                        style: const TextStyle(
                          color: AppTheme.green,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FoodCard extends StatelessWidget {
  final FoodItem food;
  final bool selected;
  final VoidCallback onTap;

  const _FoodCard({
    required this.food,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(30),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            color: selected
                ? Colors.white.withOpacity(0.095)
                : Colors.white.withOpacity(0.055),
            border: Border.all(
              color: selected
                  ? food.accent.withOpacity(0.55)
                  : Colors.white.withOpacity(0.08),
            ),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: food.accent.withOpacity(0.16),
                      blurRadius: 30,
                      offset: const Offset(0, 16),
                    ),
                  ]
                : const [],
          ),
          child: Row(
            children: [
              SizedBox(
                width: 96,
                height: 96,
                child: PremiumNetworkImage(
                  imageUrl: food.imageUrl,
                  heroTag: '${food.imageUrl}_list',
                  borderRadius: BorderRadius.circular(26),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            food.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.3,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: food.accent.withOpacity(0.14),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            food.discount,
                            style: TextStyle(
                              color: food.accent,
                              fontSize: 10.5,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      food.restaurant,
                      style: const TextStyle(
                        color: AppTheme.green,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      food.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppTheme.muted,
                        fontSize: 12.2,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          color: AppTheme.orange,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          food.rating.toStringAsFixed(1),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          food.time,
                          style: const TextStyle(
                            color: AppTheme.muted,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          food.distance,
                          style: const TextStyle(
                            color: AppTheme.muted,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          food.price,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DiscoveryBackdrop extends StatelessWidget {
  const _DiscoveryBackdrop();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppTheme.bg, AppTheme.bgAlt],
        ),
      ),
    );
  }
}

class _DiscoveryBackdropPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    canvas.drawRect(
      rect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.bg,
            AppTheme.bgAlt,
            Color(0xFF0D131D),
            Color(0xFF070B10),
          ],
        ).createShader(rect),
    );

    canvas.drawCircle(
      Offset(size.width * 0.82, size.height * 0.16),
      220,
      Paint()
        ..shader =
            RadialGradient(
              colors: [AppTheme.green.withOpacity(0.20), Colors.transparent],
            ).createShader(
              Rect.fromCircle(
                center: Offset(size.width * 0.82, size.height * 0.16),
                radius: 220,
              ),
            ),
    );

    canvas.drawCircle(
      Offset(size.width * 0.12, size.height * 0.22),
      180,
      Paint()
        ..shader =
            RadialGradient(
              colors: [AppTheme.orange.withOpacity(0.18), Colors.transparent],
            ).createShader(
              Rect.fromCircle(
                center: Offset(size.width * 0.12, size.height * 0.22),
                radius: 180,
              ),
            ),
    );

    final gridPaint = Paint()..color = Colors.white.withOpacity(0.04);
    for (double x = 18; x < size.width; x += 38) {
      for (double y = 98; y < size.height; y += 38) {
        canvas.drawCircle(Offset(x, y), 1.1, gridPaint);
      }
    }

    final roads = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 20
      ..strokeCap = StrokeCap.round;

    final roadsThin = Paint()
      ..color = Colors.white.withOpacity(0.03)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(
      Path()
        ..moveTo(-40, size.height * 0.32)
        ..cubicTo(
          size.width * 0.28,
          size.height * 0.18,
          size.width * 0.46,
          size.height * 0.46,
          size.width + 40,
          size.height * 0.28,
        ),
      roads,
    );
    canvas.drawPath(
      Path()
        ..moveTo(size.width * 0.08, -40)
        ..cubicTo(
          size.width * 0.10,
          size.height * 0.24,
          size.width * 0.32,
          size.height * 0.56,
          size.width * 0.20,
          size.height + 40,
        ),
      roadsThin,
    );
    canvas.drawPath(
      Path()
        ..moveTo(size.width + 30, size.height * 0.70)
        ..cubicTo(
          size.width * 0.72,
          size.height * 0.58,
          size.width * 0.48,
          size.height * 0.84,
          -50,
          size.height * 0.83,
        ),
      roads,
    );

    final blocks = Paint()..color = Colors.white.withOpacity(0.03);
    final border = Paint()
      ..color = Colors.white.withOpacity(0.04)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final rects = [
      Rect.fromLTWH(size.width * 0.08, size.height * 0.10, 84, 58),
      Rect.fromLTWH(size.width * 0.24, size.height * 0.12, 122, 72),
      Rect.fromLTWH(size.width * 0.56, size.height * 0.11, 128, 78),
      Rect.fromLTWH(size.width * 0.14, size.height * 0.46, 118, 86),
      Rect.fromLTWH(size.width * 0.58, size.height * 0.42, 128, 110),
      Rect.fromLTWH(size.width * 0.11, size.height * 0.76, 118, 76),
      Rect.fromLTWH(size.width * 0.62, size.height * 0.74, 118, 72),
    ];

    for (final rect in rects) {
      final rRect = RRect.fromRectAndRadius(rect, const Radius.circular(20));
      canvas.drawRRect(rRect, blocks);
      canvas.drawRRect(rRect, border);
    }

    _drawLabel(
      canvas,
      'North Ridge',
      Offset(size.width * 0.18, size.height * 0.20),
    );
    _drawLabel(
      canvas,
      'Food District',
      Offset(size.width * 0.58, size.height * 0.40),
    );
    _drawLabel(
      canvas,
      'Central Loop',
      Offset(size.width * 0.34, size.height * 0.70),
    );
  }

  void _drawLabel(Canvas canvas, String text, Offset offset) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: Colors.white.withOpacity(0.12),
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.2,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    painter.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _RecommendationOrbPainter extends CustomPainter {
  final double progress;

  _RecommendationOrbPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);

    for (int i = 0; i < 3; i++) {
      final wave = (progress + i * 0.3) % 1;
      canvas.drawCircle(
        center,
        26 + wave * 30,
        Paint()
          ..color = AppTheme.green.withOpacity((1 - wave) * 0.22)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    }

    canvas.drawCircle(
      center,
      31,
      Paint()
        ..shader = const LinearGradient(
          colors: [AppTheme.orange, AppTheme.green, AppTheme.cyan],
        ).createShader(Rect.fromCircle(center: center, radius: 31)),
    );
  }

  @override
  bool shouldRepaint(covariant _RecommendationOrbPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
