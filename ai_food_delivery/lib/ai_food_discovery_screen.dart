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
  bool _showOrderBar = false;

  List<FoodItem> get _visibleFoods {
    final category = demoCategories[_selectedCategoryIndex].label;

    if (category == 'Recommended') {
      return demoFoods;
    }

    return demoFoods.where((food) => food.category == category).toList();
  }

  FoodItem get _selectedFood {
    final foods = _visibleFoods;

    if (foods.isEmpty) {
      return demoFoods.first;
    }

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
      _showOrderBar = false;
    });
  }

  void _selectFood(int index) {
    setState(() {
      _selectedFoodIndex = index;
      _showOrderBar = true;
    });
  }

  void _selectTopChoice() {
    setState(() {
      _showOrderBar = true;
    });
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
                    Color(0x08000000),
                    Color(0xB0000000),
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.fromLTRB(
                20,
                16,
                20,
                _showOrderBar ? 118 : 28,
              ),
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
                            hintText: 'Search burgers, pizza, pasta...',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.065),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.09),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.18),
                                blurRadius: 18,
                                offset: const Offset(0, 10),
                              ),
                            ],
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
                                'Discover premium dishes, fast riders, and top-rated restaurants near you.',
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
                                    Icons.restaurant_rounded,
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

                    GestureDetector(
                      onTap: _selectTopChoice,
                      child: PremiumSurface(
                        padding: const EdgeInsets.all(16),
                        borderRadius: BorderRadius.circular(30),
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final imageSize = constraints.maxWidth < 360
                                ? 92.0
                                : 104.0;

                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Wrap(
                                        spacing: 10,
                                        runSpacing: 8,
                                        crossAxisAlignment:
                                            WrapCrossAlignment.center,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 7,
                                            ),
                                            decoration: BoxDecoration(
                                              color: AppTheme.green.withOpacity(
                                                0.14,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(999),
                                              border: Border.all(
                                                color: AppTheme.green
                                                    .withOpacity(0.22),
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
                                          const Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
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
                                          const SizedBox(width: 7),
                                          _PillStat(
                                            icon: Icons.schedule_rounded,
                                            label: _selectedFood.time,
                                            accent: AppTheme.cyan,
                                          ),
                                          const SizedBox(width: 7),
                                          _PillStat(
                                            icon: Icons.local_offer_rounded,
                                            label: _selectedFood.discount,
                                            accent: AppTheme.green,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(width: 10),

                                Stack(
                                  children: [
                                    SizedBox(
                                      width: imageSize,
                                      height: imageSize,
                                      child: PremiumNetworkImage(
                                        imageUrl: _selectedFood.imageUrl,
                                        heroTag: _selectedFood.imageUrl,
                                        borderRadius: BorderRadius.circular(26),
                                      ),
                                    ),
                                    Positioned(
                                      right: 8,
                                      top: 8,
                                      child: Container(
                                        width: 28,
                                        height: 28,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: const Color(0xEE07100F),
                                          border: Border.all(
                                            color: Colors.white.withOpacity(
                                              0.12,
                                            ),
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.add_rounded,
                                          color: AppTheme.green,
                                          size: 18,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            );
                          },
                        ),
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
                          'Premium spots with standout dishes and fast delivery.',
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
                          'Tap a dish and continue instantly from the bottom bar.',
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
                  ],
                ),
              ),
            ),
          ),

          AnimatedPositioned(
            duration: const Duration(milliseconds: 360),
            curve: Curves.easeOutCubic,
            left: 16,
            right: 16,
            bottom: _showOrderBar ? 16 : -120,
            child: SafeArea(
              top: false,
              child: _StickyOrderBar(
                food: _selectedFood,
                onTap: _goToConfirmation,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StickyOrderBar extends StatelessWidget {
  final FoodItem food;
  final VoidCallback onTap;

  const _StickyOrderBar({required this.food, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 10, 10),
      decoration: BoxDecoration(
        color: const Color(0xF207100F),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withOpacity(0.10)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.38),
            blurRadius: 26,
            offset: const Offset(0, 12),
          ),
          BoxShadow(
            color: food.accent.withOpacity(0.10),
            blurRadius: 26,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Image.network(
              food.imageUrl,
              width: 52,
              height: 52,
              fit: BoxFit.cover,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  food.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14.5,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${food.restaurant} · ${food.time}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppTheme.muted,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 10),

          GestureDetector(
            onTap: onTap,
            child: Container(
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 17),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: const LinearGradient(
                  colors: [AppTheme.green, AppTheme.cyan],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.green.withOpacity(0.22),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Row(
                children: [
                  Text(
                    'Order',
                    style: TextStyle(
                      color: AppTheme.bg,
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  SizedBox(width: 6),
                  Icon(
                    Icons.arrow_forward_rounded,
                    color: AppTheme.bg,
                    size: 19,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
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
      height: 32,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: accent.withOpacity(0.12),
        border: Border.all(color: accent.withOpacity(0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: accent, size: 13),
          const SizedBox(width: 4),
          Text(
            label,
            maxLines: 1,
            softWrap: false,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10.5,
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
                overlayColors: const [Colors.transparent, Color(0xAA000000)],
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
              Stack(
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
                  if (selected)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        width: 26,
                        height: 26,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppTheme.green,
                          border: Border.all(
                            color: Colors.white.withOpacity(0.25),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.green.withOpacity(0.35),
                              blurRadius: 14,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.check_rounded,
                          color: AppTheme.bg,
                          size: 17,
                        ),
                      ),
                    ),
                ],
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
    return CustomPaint(painter: _DiscoveryBackdropPainter());
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
          colors: [AppTheme.bg, AppTheme.bgAlt, Color(0xFF080D14)],
        ).createShader(rect),
    );

    canvas.drawCircle(
      Offset(size.width * 0.82, size.height * 0.12),
      260,
      Paint()
        ..shader =
            RadialGradient(
              colors: [AppTheme.green.withOpacity(0.17), Colors.transparent],
            ).createShader(
              Rect.fromCircle(
                center: Offset(size.width * 0.82, size.height * 0.12),
                radius: 260,
              ),
            ),
    );

    canvas.drawCircle(
      Offset(size.width * 0.10, size.height * 0.30),
      230,
      Paint()
        ..shader =
            RadialGradient(
              colors: [AppTheme.orange.withOpacity(0.12), Colors.transparent],
            ).createShader(
              Rect.fromCircle(
                center: Offset(size.width * 0.10, size.height * 0.30),
                radius: 230,
              ),
            ),
    );

    final dotPaint = Paint()..color = Colors.white.withOpacity(0.045);

    for (double x = 24; x < size.width; x += 42) {
      for (double y = 90; y < size.height; y += 42) {
        canvas.drawCircle(Offset(x, y), 1, dotPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DiscoveryBackdropPainter oldDelegate) {
    return false;
  }
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
          ..color = AppTheme.green.withOpacity((1 - wave) * 0.18)
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
