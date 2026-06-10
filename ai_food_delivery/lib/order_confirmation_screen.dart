import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';

import 'ai_delivery_tracking_screen.dart';
import 'app_theme.dart';
import 'food_item.dart';

class OrderConfirmationScreen extends StatefulWidget {
  final FoodItem food;

  const OrderConfirmationScreen({
    super.key,
    required this.food,
  });

  @override
  State<OrderConfirmationScreen> createState() =>
      _OrderConfirmationScreenState();
}

class _OrderConfirmationScreenState extends State<OrderConfirmationScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool confirmed = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _confirmOrder() async {
    setState(() => confirmed = true);

    await Future.delayed(const Duration(milliseconds: 900));

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 650),
        pageBuilder: (_, animation, __) {
          return FadeTransition(
            opacity: animation,
            child: AiDeliveryTrackingScreen(food: widget.food),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final food = widget.food;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: _ConfirmationBackgroundPainter(),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Header(onBack: () => Navigator.pop(context)),

                  const SizedBox(height: 26),

                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: 1),
                    duration: const Duration(milliseconds: 650),
                    curve: Curves.easeOutCubic,
                    builder: (context, value, child) {
                      return Opacity(
                        opacity: value,
                        child: Transform.translate(
                          offset: Offset(0, 24 * (1 - value)),
                          child: child,
                        ),
                      );
                    },
                    child: const Text(
                      'Confirm your\nAI selected meal',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 35,
                        height: 1.05,
                        letterSpacing: -1.4,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  const Text(
                    'Your order is optimized for fast delivery, high rating and best value.',
                    style: TextStyle(
                      color: AppTheme.muted,
                      fontSize: 13.5,
                      height: 1.45,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const SizedBox(height: 24),

                  Hero(
                    tag: food.name,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(36),
                        color: Colors.white.withOpacity(0.075),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.10),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: food.color.withOpacity(0.12),
                            blurRadius: 30,
                            offset: const Offset(0, 14),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 96,
                            height: 96,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(32),
                              gradient: LinearGradient(
                                colors: [
                                  food.color,
                                  AppTheme.green,
                                ],
                              ),
                            ),
                            child: Icon(
                              food.icon,
                              color: AppTheme.bg,
                              size: 50,
                            ),
                          ),

                          const SizedBox(width: 16),

                          Expanded(
                            child: Material(
                              color: Colors.transparent,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    food.name,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: -0.6,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    food.restaurant,
                                    style: const TextStyle(
                                      color: AppTheme.green,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    food.description,
                                    style: const TextStyle(
                                      color: AppTheme.muted,
                                      fontSize: 12.5,
                                      height: 1.4,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  _AiInsightCard(controller: _controller),

                  const SizedBox(height: 18),

                  _PriceBreakdown(food: food),

                  const Spacer(),

                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 350),
                    child: confirmed
                        ? Container(
                            key: const ValueKey('confirmed'),
                            height: 62,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(26),
                              color: AppTheme.green,
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.check_rounded,
                                  color: AppTheme.bg,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Order confirmed',
                                  style: TextStyle(
                                    color: AppTheme.bg,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : _ConfirmButton(
                            key: const ValueKey('button'),
                            onTap: _confirmOrder,
                          ),
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

class _ConfirmationBackgroundPainter extends CustomPainter {
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
            Color(0xFF101816),
            Color(0xFF101119),
          ],
        ).createShader(rect),
    );

    canvas.drawCircle(
      Offset(size.width * 0.80, size.height * 0.20),
      260,
      Paint()
        ..shader = RadialGradient(
          colors: [
            AppTheme.green.withOpacity(0.20),
            Colors.transparent,
          ],
        ).createShader(
          Rect.fromCircle(
            center: Offset(size.width * 0.80, size.height * 0.20),
            radius: 260,
          ),
        ),
    );

    canvas.drawCircle(
      Offset(size.width * 0.14, size.height * 0.38),
      220,
      Paint()
        ..shader = RadialGradient(
          colors: [
            AppTheme.orange.withOpacity(0.13),
            Colors.transparent,
          ],
        ).createShader(
          Rect.fromCircle(
            center: Offset(size.width * 0.14, size.height * 0.38),
            radius: 220,
          ),
        ),
    );
  }

  @override
  bool shouldRepaint(covariant _ConfirmationBackgroundPainter oldDelegate) {
    return false;
  }
}

class _Header extends StatelessWidget {
  final VoidCallback onBack;

  const _Header({required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _IconBox(
          icon: Icons.arrow_back_rounded,
          onTap: onBack,
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.07),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: Colors.white.withOpacity(0.08),
            ),
          ),
          child: const Row(
            children: [
              Icon(
                Icons.lock_rounded,
                color: AppTheme.green,
                size: 16,
              ),
              SizedBox(width: 6),
              Text(
                'Secure order',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _IconBox extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _IconBox({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withOpacity(0.07),
      borderRadius: BorderRadius.circular(17),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(17),
        child: Container(
          width: 45,
          height: 45,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(17),
            border: Border.all(
              color: Colors.white.withOpacity(0.08),
            ),
          ),
          child: Icon(icon, color: Colors.white),
        ),
      ),
    );
  }
}

class _AiInsightCard extends StatelessWidget {
  final AnimationController controller;

  const _AiInsightCard({
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.065),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: Colors.white.withOpacity(0.09),
            ),
          ),
          child: Row(
            children: [
              AnimatedBuilder(
                animation: controller,
                builder: (_, __) {
                  final pulse = sin(controller.value * pi * 2) * 0.5 + 0.5;

                  return Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [
                          AppTheme.orange,
                          AppTheme.green,
                          AppTheme.cyan,
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.green.withOpacity(0.18 + pulse * 0.18),
                          blurRadius: 18 + pulse * 14,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.auto_awesome_rounded,
                      color: AppTheme.bg,
                    ),
                  );
                },
              ),
              const SizedBox(width: 13),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AI delivery score: 98%',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Best match based on speed, rating, distance and freshness.',
                      style: TextStyle(
                        color: AppTheme.muted,
                        fontSize: 12.5,
                        height: 1.35,
                        fontWeight: FontWeight.w500,
                      ),
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

class _PriceBreakdown extends StatelessWidget {
  final FoodItem food;

  const _PriceBreakdown({required this.food});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.055),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: Colors.white.withOpacity(0.08),
        ),
      ),
      child: Column(
        children: [
          _PriceRow(label: 'Meal price', value: food.price),
          const SizedBox(height: 12),
          const _PriceRow(label: 'Delivery fee', value: 'Rs. 120'),
          const SizedBox(height: 12),
          const _PriceRow(label: 'AI discount', value: '- Rs. 100'),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 14),
            child: Divider(color: Color(0x22FFFFFF)),
          ),
          const _PriceRow(
            label: 'Total',
            value: 'Rs. 910',
            highlight: true,
          ),
        ],
      ),
    );
  }
}

class _PriceRow extends StatelessWidget {
  final String label;
  final String value;
  final bool highlight;

  const _PriceRow({
    required this.label,
    required this.value,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: TextStyle(
            color: highlight ? Colors.white : AppTheme.muted,
            fontSize: highlight ? 15 : 13,
            fontWeight: highlight ? FontWeight.w900 : FontWeight.w600,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            color: highlight ? AppTheme.green : Colors.white,
            fontSize: highlight ? 16 : 13,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

class _ConfirmButton extends StatelessWidget {
  final VoidCallback onTap;

  const _ConfirmButton({
    super.key,
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
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.payment_rounded, color: AppTheme.bg),
              SizedBox(width: 8),
              Text(
                'Confirm order',
                style: TextStyle(
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