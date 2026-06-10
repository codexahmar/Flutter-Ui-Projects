import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';

import 'app_theme.dart';
import 'food_item.dart';
import 'order_confirmation_screen.dart';

class AiFoodDiscoveryScreen extends StatefulWidget {
  const AiFoodDiscoveryScreen({super.key});

  @override
  State<AiFoodDiscoveryScreen> createState() => _AiFoodDiscoveryScreenState();
}

class _AiFoodDiscoveryScreenState extends State<AiFoodDiscoveryScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  int selectedIndex = 0;

  FoodItem get selectedFood => demoFoods[selectedIndex];

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _goToConfirmation() {
    Navigator.push(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 650),
        pageBuilder: (_, animation, __) {
          return FadeTransition(
            opacity: animation,
            child: OrderConfirmationScreen(food: selectedFood),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const _DiscoveryBackground(),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _TopBar(),

                  const SizedBox(height: 26),

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0, end: 1),
                          duration: const Duration(milliseconds: 700),
                          curve: Curves.easeOutCubic,
                          builder: (context, value, child) {
                            return Opacity(
                              opacity: value,
                              child: Transform.translate(
                                offset: Offset(0, 26 * (1 - value)),
                                child: child,
                              ),
                            );
                          },
                          child: const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'AI picked your\nperfect meal',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 36,
                                  fontWeight: FontWeight.w900,
                                  height: 1.05,
                                  letterSpacing: -1.5,
                                ),
                              ),
                              SizedBox(height: 12),
                              Text(
                                'Based on your mood, weather and nearby restaurants.',
                                style: TextStyle(
                                  color: AppTheme.muted,
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w500,
                                  height: 1.45,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(width: 12),

                      AnimatedBuilder(
                        animation: _controller,
                        builder: (_, __) {
                          return CustomPaint(
                            size: const Size(104, 104),
                            painter: _AiMiniOrbPainter(_controller.value),
                            child: const SizedBox(
                              width: 104,
                              height: 104,
                              child: Center(
                                child: Icon(
                                  Icons.auto_awesome_rounded,
                                  color: AppTheme.bg,
                                  size: 32,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  SizedBox(
                    height: 44,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: const [
                        _CategoryChip(label: 'Recommended', active: true),
                        _CategoryChip(label: 'Fast delivery'),
                        _CategoryChip(label: 'Burgers'),
                        _CategoryChip(label: 'Pizza'),
                        _CategoryChip(label: 'Desi'),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  Expanded(
                    child: ListView.separated(
                      padding: EdgeInsets.zero,
                      itemCount: demoFoods.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 14),
                      itemBuilder: (context, index) {
                        final food = demoFoods[index];

                        return GestureDetector(
                          onTap: () {
                            setState(() => selectedIndex = index);
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 350),
                            curve: Curves.easeOut,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: selectedIndex == index
                                  ? Colors.white.withOpacity(0.10)
                                  : Colors.white.withOpacity(0.055),
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(
                                color: selectedIndex == index
                                    ? AppTheme.green.withOpacity(0.45)
                                    : Colors.white.withOpacity(0.08),
                              ),
                              boxShadow: selectedIndex == index
                                  ? [
                                      BoxShadow(
                                        color: AppTheme.green.withOpacity(0.15),
                                        blurRadius: 26,
                                        offset: const Offset(0, 12),
                                      ),
                                    ]
                                  : [],
                            ),
                            child: Row(
                              children: [
                                Hero(
                                  tag: food.name,
                                  child: Container(
                                    width: 82,
                                    height: 82,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(26),
                                      gradient: LinearGradient(
                                        colors: [
                                          food.color,
                                          AppTheme.green,
                                        ],
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: food.color.withOpacity(0.24),
                                          blurRadius: 22,
                                          offset: const Offset(0, 10),
                                        ),
                                      ],
                                    ),
                                    child: Icon(
                                      food.icon,
                                      color: AppTheme.bg,
                                      size: 40,
                                    ),
                                  ),
                                ),

                                const SizedBox(width: 15),

                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        food.name,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 17,
                                          fontWeight: FontWeight.w900,
                                          letterSpacing: -0.4,
                                        ),
                                      ),
                                      const SizedBox(height: 5),
                                      Text(
                                        food.restaurant,
                                        style: const TextStyle(
                                          color: AppTheme.green,
                                          fontSize: 12.5,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                      const SizedBox(height: 7),
                                      Text(
                                        food.description,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          color: AppTheme.muted,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          height: 1.35,
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.star_rounded,
                                            color: Color(0xFFFFD166),
                                            size: 17,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            food.rating.toString(),
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 12.5,
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
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 16),

                  _PremiumButton(
                    label: 'Order with AI',
                    icon: Icons.bolt_rounded,
                    onTap: _goToConfirmation,
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

class _DiscoveryBackground extends StatelessWidget {
  const _DiscoveryBackground();

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: CustomPaint(
        painter: _DiscoveryBackgroundPainter(),
      ),
    );
  }
}

class _DiscoveryBackgroundPainter extends CustomPainter {
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
            Color(0xFF0C1918),
            Color(0xFF101119),
          ],
        ).createShader(rect),
    );

    final greenGlow = Paint()
      ..shader = RadialGradient(
        colors: [
          AppTheme.green.withOpacity(0.22),
          Colors.transparent,
        ],
      ).createShader(
        Rect.fromCircle(
          center: Offset(size.width * 0.84, size.height * 0.16),
          radius: 280,
        ),
      );

    final orangeGlow = Paint()
      ..shader = RadialGradient(
        colors: [
          AppTheme.orange.withOpacity(0.14),
          Colors.transparent,
        ],
      ).createShader(
        Rect.fromCircle(
          center: Offset(size.width * 0.12, size.height * 0.28),
          radius: 240,
        ),
      );

    canvas.drawCircle(
      Offset(size.width * 0.84, size.height * 0.16),
      280,
      greenGlow,
    );

    canvas.drawCircle(
      Offset(size.width * 0.12, size.height * 0.28),
      240,
      orangeGlow,
    );

    final dotPaint = Paint()..color = Colors.white.withOpacity(0.07);

    for (double x = 24; x < size.width; x += 38) {
      for (double y = 110; y < size.height; y += 38) {
        canvas.drawCircle(Offset(x, y), 1.1, dotPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DiscoveryBackgroundPainter oldDelegate) {
    return false;
  }
}

class _AiMiniOrbPainter extends CustomPainter {
  final double progress;

  _AiMiniOrbPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);

    for (int i = 0; i < 3; i++) {
      final p = (progress + i * 0.32) % 1;
      canvas.drawCircle(
        center,
        28 + p * 34,
        Paint()
          ..color = AppTheme.green.withOpacity((1 - p) * 0.25)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    }

    final rect = Rect.fromCircle(center: center, radius: 34);

    canvas.drawCircle(
      center,
      34,
      Paint()
        ..shader = const LinearGradient(
          colors: [
            AppTheme.orange,
            AppTheme.green,
            AppTheme.cyan,
          ],
        ).createShader(rect),
    );
  }

  @override
  bool shouldRepaint(covariant _AiMiniOrbPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const CircleAvatar(
          radius: 22,
          backgroundColor: Color(0xFF12211E),
          child: Icon(
            Icons.person_rounded,
            color: Colors.white,
          ),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Deliver to',
                style: TextStyle(
                  color: AppTheme.muted,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Home, Islamabad',
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
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.07),
            borderRadius: BorderRadius.circular(17),
            border: Border.all(
              color: Colors.white.withOpacity(0.08),
            ),
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

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool active;

  const _CategoryChip({
    required this.label,
    this.active = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: active ? AppTheme.green : Colors.white.withOpacity(0.065),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: active ? AppTheme.green : Colors.white.withOpacity(0.08),
        ),
      ),
      child: Center(
        child: Text(
          label,
          style: TextStyle(
            color: active ? AppTheme.bg : Colors.white,
            fontSize: 12.5,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _PremiumButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _PremiumButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(26),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(26),
        child: Ink(
          height: 62,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(26),
            gradient: const LinearGradient(
              colors: [
                AppTheme.orange,
                AppTheme.green,
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: AppTheme.green.withOpacity(0.24),
                blurRadius: 28,
                offset: const Offset(0, 14),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: AppTheme.bg),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: AppTheme.bg,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}