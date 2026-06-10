import 'package:flutter/material.dart';

import 'ai_delivery_tracking_screen.dart';
import 'app_theme.dart';
import 'food_item.dart';
import 'shared_widgets.dart';

class OrderConfirmationScreen extends StatefulWidget {
  final FoodItem food;

  const OrderConfirmationScreen({super.key, required this.food});

  @override
  State<OrderConfirmationScreen> createState() =>
      _OrderConfirmationScreenState();
}

class _OrderConfirmationScreenState extends State<OrderConfirmationScreen> {
  int quantity = 1;
  bool isSubmitting = false;
  final Set<int> selectedAddonIndices = {0};

  static const List<_AddonOption> _extraOptions = [
    _AddonOption(label: 'Extra cheese', price: 60),
    _AddonOption(label: 'Garlic dip', price: 40),
    _AddonOption(label: 'Chili flakes', price: 25),
    _AddonOption(label: 'Loaded fries', price: 95),
  ];

  int get _basePrice => widget.food.priceValue * quantity;

  int get _addonsPrice {
    var total = 0;
    for (final index in selectedAddonIndices) {
      total += _extraOptions[index].price;
    }
    return total;
  }

  int get _deliveryFee => 120;
  int get _serviceFee => 49;
  int get _discount => 100 + (quantity > 1 ? 40 : 0);
  int get _total =>
      (_basePrice + _addonsPrice + _deliveryFee + _serviceFee - _discount)
          .clamp(0, 999999);

  void _incrementQuantity() {
    setState(() => quantity += 1);
  }

  void _decrementQuantity() {
    if (quantity == 1) return;
    setState(() => quantity -= 1);
  }

  void _toggleAddon(int index) {
    setState(() {
      if (selectedAddonIndices.contains(index)) {
        selectedAddonIndices.remove(index);
      } else {
        selectedAddonIndices.add(index);
      }
    });
  }

  Future<void> _confirmOrder() async {
    setState(() => isSubmitting = true);

    await Future<void>.delayed(const Duration(milliseconds: 850));
    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 600),
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
          const Positioned.fill(child: _ConfirmationBackdrop()),
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Color(0x10000000),
                    Color(0xCC000000),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Header(onBack: () => Navigator.pop(context)),
                  const SizedBox(height: 22),
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: 1),
                    duration: const Duration(milliseconds: 520),
                    curve: Curves.easeOutCubic,
                    builder: (context, value, child) {
                      return Opacity(
                        opacity: value,
                        child: Transform.translate(
                          offset: Offset(0, 18 * (1 - value)),
                          child: child,
                        ),
                      );
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Confirm your order',
                          style: Theme.of(context).textTheme.displayMedium,
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Fine-tune quantity, add-ons, payment and delivery details before checkout.',
                          style: TextStyle(
                            color: AppTheme.muted,
                            fontSize: 13.5,
                            height: 1.45,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  GlassCard(
                    padding: EdgeInsets.zero,
                    borderRadius: BorderRadius.circular(32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 280,
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              PremiumNetworkImage(
                                imageUrl: food.imageUrl,
                                heroTag: food.imageUrl,
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(32),
                                ),
                                overlayColors: const [
                                  Colors.transparent,
                                  Color(0x99000000),
                                ],
                              ),
                              Positioned(
                                right: 16,
                                top: 16,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 11,
                                    vertical: 7,
                                  ),
                                  decoration: BoxDecoration(
                                    color: food.accent.withOpacity(0.16),
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: Text(
                                    food.discount,
                                    style: TextStyle(
                                      color: food.accent,
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                left: 16,
                                right: 16,
                                bottom: 16,
                                child: Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: [
                                    _InfoChip(
                                      label: food.restaurant,
                                      icon: Icons.storefront_rounded,
                                      accent: AppTheme.green,
                                    ),
                                    _InfoChip(
                                      label: food.time,
                                      icon: Icons.schedule_rounded,
                                      accent: AppTheme.orange,
                                    ),
                                    _InfoChip(
                                      label:
                                          '${food.rating.toStringAsFixed(1)} rating',
                                      icon: Icons.star_rounded,
                                      accent: AppTheme.cyan,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      food.name,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 22,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: -0.7,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    food.price,
                                    style: const TextStyle(
                                      color: AppTheme.green,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                food.description,
                                style: const TextStyle(
                                  color: AppTheme.muted,
                                  fontSize: 12.8,
                                  height: 1.45,
                                ),
                              ),
                              const SizedBox(height: 14),
                              Row(
                                children: [
                                  const Text(
                                    'Quantity',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const Spacer(),
                                  QuantityStepper(
                                    value: quantity,
                                    onAdd: _incrementQuantity,
                                    onRemove: _decrementQuantity,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  PremiumSurface(
                    padding: const EdgeInsets.all(18),
                    borderRadius: BorderRadius.circular(30),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Add-ons',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Tap to personalize the order without clutter.',
                          style: TextStyle(
                            color: AppTheme.muted,
                            fontSize: 12.5,
                            height: 1.35,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: List.generate(_extraOptions.length, (
                            index,
                          ) {
                            final option = _extraOptions[index];
                            final selected = selectedAddonIndices.contains(
                              index,
                            );

                            return _AddonChip(
                              label: option.label,
                              price: option.price,
                              selected: selected,
                              onTap: () => _toggleAddon(index),
                            );
                          }),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: PremiumSurface(
                          padding: const EdgeInsets.all(16),
                          borderRadius: BorderRadius.circular(28),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Delivery address',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'House 12, Street 8\nF-10/2 Islamabad',
                                style: const TextStyle(
                                  color: AppTheme.muted,
                                  fontSize: 12.8,
                                  height: 1.45,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: PremiumSurface(
                          padding: const EdgeInsets.all(16),
                          borderRadius: BorderRadius.circular(28),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Payment method',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: const [
                                  Icon(
                                    Icons.credit_card_rounded,
                                    color: AppTheme.green,
                                    size: 18,
                                  ),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Visa ending 4472',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: AppTheme.muted,
                                        fontSize: 12.8,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  PremiumSurface(
                    padding: const EdgeInsets.all(18),
                    borderRadius: BorderRadius.circular(30),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Price breakdown',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 14),
                        PriceLine(
                          label: 'Meal subtotal',
                          value: 'Rs. $_basePrice',
                        ),
                        const SizedBox(height: 12),
                        PriceLine(label: 'Add-ons', value: 'Rs. $_addonsPrice'),
                        const SizedBox(height: 12),
                        const PriceLine(
                          label: 'Delivery fee',
                          value: 'Rs. 120',
                        ),
                        const SizedBox(height: 12),
                        const PriceLine(label: 'Service fee', value: 'Rs. 49'),
                        const SizedBox(height: 12),
                        PriceLine(
                          label: 'AI discount',
                          value: '- Rs. $_discount',
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 14),
                          child: Divider(),
                        ),
                        PriceLine(
                          label: 'Total',
                          value: 'Rs. $_total',
                          emphasize: true,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 240),
                    child: isSubmitting
                        ? const GlassCard(
                            key: ValueKey('submitting'),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.2,
                                  ),
                                ),
                                SizedBox(width: 10),
                                Text(
                                  'Confirming order...',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : PrimaryActionButton(
                            key: const ValueKey('confirm'),
                            label: 'Confirm order · Rs. $_total',
                            icon: Icons.payment_rounded,
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

class _ConfirmationBackdrop extends StatelessWidget {
  const _ConfirmationBackdrop();

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

class _ConfirmationBackdropPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    canvas.drawRect(
      rect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppTheme.bg, AppTheme.bgAlt, Color(0xFF111820)],
        ).createShader(rect),
    );

    canvas.drawCircle(
      Offset(size.width * 0.82, size.height * 0.16),
      220,
      Paint()
        ..shader =
            RadialGradient(
              colors: [AppTheme.green.withOpacity(0.18), Colors.transparent],
            ).createShader(
              Rect.fromCircle(
                center: Offset(size.width * 0.82, size.height * 0.16),
                radius: 220,
              ),
            ),
    );

    canvas.drawCircle(
      Offset(size.width * 0.16, size.height * 0.30),
      200,
      Paint()
        ..shader =
            RadialGradient(
              colors: [AppTheme.orange.withOpacity(0.14), Colors.transparent],
            ).createShader(
              Rect.fromCircle(
                center: Offset(size.width * 0.16, size.height * 0.30),
                radius: 200,
              ),
            ),
    );
  }

  @override
  bool shouldRepaint(covariant _ConfirmationBackdropPainter oldDelegate) =>
      false;
}

class _Header extends StatelessWidget {
  final VoidCallback onBack;

  const _Header({required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Material(
          color: Colors.white.withOpacity(0.07),
          borderRadius: BorderRadius.circular(18),
          child: InkWell(
            onTap: onBack,
            borderRadius: BorderRadius.circular(18),
            child: const SizedBox(
              width: 46,
              height: 46,
              child: Icon(Icons.arrow_back_rounded, color: Colors.white),
            ),
          ),
        ),
        const Spacer(),
        Text('Checkout', style: Theme.of(context).textTheme.titleLarge),
        const Spacer(),
        const SizedBox(width: 46),
      ],
    );
  }
}

class _AddonOption {
  final String label;
  final int price;

  const _AddonOption({required this.label, required this.price});
}

class _AddonChip extends StatelessWidget {
  final String label;
  final int price;
  final bool selected;
  final VoidCallback onTap;

  const _AddonChip({
    required this.label,
    required this.price,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: selected
                ? AppTheme.green.withOpacity(0.16)
                : Colors.white.withOpacity(0.055),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: selected
                  ? AppTheme.green.withOpacity(0.55)
                  : Colors.white.withOpacity(0.08),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: selected ? Colors.white : Colors.white,
                  fontSize: 12.2,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                '+ Rs. $price',
                style: TextStyle(
                  color: selected ? AppTheme.green : AppTheme.muted,
                  fontSize: 11.2,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color accent;

  const _InfoChip({
    required this.label,
    required this.icon,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.34),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
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
              fontSize: 11.2,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
