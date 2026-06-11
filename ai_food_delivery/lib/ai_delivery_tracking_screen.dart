import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';

import 'app_theme.dart';
import 'food_item.dart';
import 'shared_widgets.dart';

class AiDeliveryTrackingScreen extends StatefulWidget {
  final FoodItem food;

  const AiDeliveryTrackingScreen({super.key, required this.food});

  @override
  State<AiDeliveryTrackingScreen> createState() =>
      _AiDeliveryTrackingScreenState();
}

class _AiDeliveryTrackingScreenState extends State<AiDeliveryTrackingScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  /// Route is moved upward so the bottom sheet does not cover it.
  final List<Offset> routePoints = const [
    Offset(0.16, 0.28),
    Offset(0.30, 0.24),
    Offset(0.46, 0.32),
    Offset(0.56, 0.42),
    Offset(0.70, 0.45),
    Offset(0.84, 0.54),
  ];

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 18),
    )..forward(); // Runs once only. No repeat.
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get isSearching => _controller.value < 0.18;
  bool get isAccepted => _controller.value >= 0.18 && _controller.value < 0.34;
  bool get isPreparing => _controller.value >= 0.34 && _controller.value < 0.50;
  bool get isRiderAssigned =>
      _controller.value >= 0.50 && _controller.value < 0.64;
  bool get isMoving => _controller.value >= 0.64 && _controller.value < 0.94;
  bool get isDelivered => _controller.value >= 0.94;

  double get routeProgress {
    if (_controller.value < 0.64) return 0;
    if (_controller.value >= 0.94) return 1;

    return ((_controller.value - 0.64) / 0.30).clamp(0.0, 1.0);
  }

  int get etaMinutes {
    if (isDelivered) return 0;

    final eta = 10 - (routeProgress * 10);
    return eta.ceil().clamp(1, 10);
  }

  int get activeStep {
    if (isSearching) return 0;
    if (isAccepted) return 1;
    if (isPreparing) return 2;
    if (isRiderAssigned || isMoving) return 3;
    return 4;
  }

  String get title {
    if (isSearching) return 'Finding nearby rider';
    if (isAccepted) return 'Order accepted';
    if (isPreparing) return 'Preparing your meal';
    if (isRiderAssigned) return 'Rider assigned';
    if (isMoving) return 'Out for delivery';
    return 'Delivered';
  }

  String get subtitle {
    if (isSearching) return 'Checking nearby riders and fastest route.';
    if (isAccepted) return '${widget.food.restaurant} confirmed your order';
    if (isPreparing) return 'Your meal is being prepared fresh';
    if (isRiderAssigned) return 'Hamza picked up your order';
    if (isMoving) return '$etaMinutes min away · Live tracking';
    return 'Your order has arrived.';
  }

  Path _buildRoutePath(Size size) {
    final points = routePoints
        .map((point) => Offset(point.dx * size.width, point.dy * size.height))
        .toList();

    final path = Path()..moveTo(points.first.dx, points.first.dy);

    for (int i = 1; i < points.length; i++) {
      final previous = points[i - 1];
      final current = points[i];

      final controlOne = Offset(
        previous.dx + (current.dx - previous.dx) * 0.42,
        previous.dy - 20,
      );

      final controlTwo = Offset(
        previous.dx + (current.dx - previous.dx) * 0.58,
        current.dy + 20,
      );

      path.cubicTo(
        controlOne.dx,
        controlOne.dy,
        controlTwo.dx,
        controlTwo.dy,
        current.dx,
        current.dy,
      );
    }

    return path;
  }

  Offset _scooterPosition(Size size) {
    final path = _buildRoutePath(size);
    final metric = path.computeMetrics().first;
    final distance = metric.length * routeProgress;
    final tangent = metric.getTangentForOffset(distance);

    return tangent?.position ?? metric.getTangentForOffset(0)!.position;
  }

  @override
  Widget build(BuildContext context) {
    final food = widget.food;

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final size = Size(constraints.maxWidth, constraints.maxHeight);

          /// Smaller bottom sheet so map + route stay visible.
          final bottomSheetHeight = min(255.0, size.height * 0.31);

          return AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              final scooterPosition = _scooterPosition(size);

              return Stack(
                children: [
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _DeliveryMapPainter(
                        routePoints: routePoints,
                        routeProgress: routeProgress,
                        pulseProgress: _controller.value,
                        isSearching: isSearching,
                      ),
                    ),
                  ),

                  /// Only slight readability overlays. Not covering the map heavily.
                  Positioned(
                    left: 0,
                    right: 0,
                    top: 0,
                    height: 150,
                    child: IgnorePointer(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withOpacity(0.48),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                      child: _TrackingTopCard(
                        title: title,
                        subtitle: subtitle,
                        etaMinutes: etaMinutes,
                        isDelivered: isDelivered,
                        isSearching: isSearching,
                      ),
                    ),
                  ),

                  if (isSearching)
                    Positioned(
                      top: size.height * 0.32,
                      left: 0,
                      right: 0,
                      child: const Center(child: _RiderSearchPulse()),
                    ),

                  Positioned(
                    left: size.width * routePoints.first.dx - 26,
                    top: size.height * routePoints.first.dy - 28,
                    child: const _MapMarker(
                      icon: Icons.restaurant_rounded,
                      label: 'Restaurant',
                      color: AppTheme.orange,
                    ),
                  ),

                  Positioned(
                    left: size.width * routePoints.last.dx - 26,
                    top: size.height * routePoints.last.dy - 28,
                    child: const _MapMarker(
                      icon: Icons.home_rounded,
                      label: 'Home',
                      color: AppTheme.green,
                    ),
                  ),

                  if (!isSearching && !isAccepted && !isPreparing)
                    Positioned(
                      left: scooterPosition.dx - 34,
                      top: scooterPosition.dy - 34,

                      /// No rotation. Scooter only moves on the route.
                      child: const _ScooterMarker(),
                    ),

                  Positioned(
                    left: 18,
                    right: 18,
                    bottom: 18,
                    child: SizedBox(
                      height: bottomSheetHeight,
                      child: _DeliveryBottomSheet(
                        food: food,
                        activeStep: activeStep,
                        isDelivered: isDelivered,
                        etaMinutes: etaMinutes,
                        onDone: () => Navigator.pop(context),
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

class _DeliveryMapPainter extends CustomPainter {
  final List<Offset> routePoints;
  final double routeProgress;
  final double pulseProgress;
  final bool isSearching;

  _DeliveryMapPainter({
    required this.routePoints,
    required this.routeProgress,
    required this.pulseProgress,
    required this.isSearching,
  });

  @override
  void paint(Canvas canvas, Size size) {
    _drawBackground(canvas, size);
    _drawRoads(canvas, size);
    _drawBlocks(canvas, size);
    _drawLabels(canvas, size);
    _drawDots(canvas, size);

    /// Route is drawn after roads and blocks, so it stays visible.
    _drawRoute(canvas, size);

    if (isSearching) {
      _drawSearchPulse(canvas, size);
    }
  }

  Path _buildRoutePath(Size size) {
    final points = routePoints
        .map((point) => Offset(point.dx * size.width, point.dy * size.height))
        .toList();

    final path = Path()..moveTo(points.first.dx, points.first.dy);

    for (int i = 1; i < points.length; i++) {
      final previous = points[i - 1];
      final current = points[i];

      final controlOne = Offset(
        previous.dx + (current.dx - previous.dx) * 0.42,
        previous.dy - 20,
      );

      final controlTwo = Offset(
        previous.dx + (current.dx - previous.dx) * 0.58,
        current.dy + 20,
      );

      path.cubicTo(
        controlOne.dx,
        controlOne.dy,
        controlTwo.dx,
        controlTwo.dy,
        current.dx,
        current.dy,
      );
    }

    return path;
  }

  void _drawBackground(Canvas canvas, Size size) {
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
            Color(0xFF10161F),
            Color(0xFF070B10),
          ],
        ).createShader(rect),
    );

    canvas.drawCircle(
      Offset(size.width * 0.82, size.height * 0.14),
      280,
      Paint()
        ..shader =
            RadialGradient(
              colors: [AppTheme.green.withOpacity(0.17), Colors.transparent],
            ).createShader(
              Rect.fromCircle(
                center: Offset(size.width * 0.82, size.height * 0.14),
                radius: 280,
              ),
            ),
    );

    canvas.drawCircle(
      Offset(size.width * 0.16, size.height * 0.34),
      240,
      Paint()
        ..shader =
            RadialGradient(
              colors: [AppTheme.orange.withOpacity(0.12), Colors.transparent],
            ).createShader(
              Rect.fromCircle(
                center: Offset(size.width * 0.16, size.height * 0.34),
                radius: 240,
              ),
            ),
    );
  }

  void _drawRoads(Canvas canvas, Size size) {
    final roadGlow = Paint()
      ..color = Colors.white.withOpacity(0.018)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 54
      ..strokeCap = StrokeCap.round;

    final roadBase = Paint()
      ..color = Colors.white.withOpacity(0.045)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 22
      ..strokeCap = StrokeCap.round;

    final roadThin = Paint()
      ..color = Colors.white.withOpacity(0.03)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;

    final roadA = Path()
      ..moveTo(-40, size.height * 0.25)
      ..cubicTo(
        size.width * 0.20,
        size.height * 0.14,
        size.width * 0.48,
        size.height * 0.40,
        size.width + 40,
        size.height * 0.24,
      );

    final roadB = Path()
      ..moveTo(size.width * 0.10, -40)
      ..cubicTo(
        size.width * 0.12,
        size.height * 0.24,
        size.width * 0.30,
        size.height * 0.54,
        size.width * 0.18,
        size.height + 40,
      );

    final roadC = Path()
      ..moveTo(size.width + 30, size.height * 0.58)
      ..cubicTo(
        size.width * 0.74,
        size.height * 0.48,
        size.width * 0.48,
        size.height * 0.66,
        -30,
        size.height * 0.67,
      );

    canvas.drawPath(roadA, roadGlow);
    canvas.drawPath(roadB, roadGlow);
    canvas.drawPath(roadC, roadGlow);

    canvas.drawPath(roadA, roadBase);
    canvas.drawPath(roadB, roadThin);
    canvas.drawPath(roadC, roadBase);
  }

  void _drawBlocks(Canvas canvas, Size size) {
    final fill = Paint()..color = Colors.white.withOpacity(0.03);

    final border = Paint()
      ..color = Colors.white.withOpacity(0.04)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final blocks = [
      Rect.fromLTWH(size.width * 0.08, size.height * 0.10, 88, 62),
      Rect.fromLTWH(size.width * 0.25, size.height * 0.12, 126, 74),
      Rect.fromLTWH(size.width * 0.58, size.height * 0.11, 126, 78),
      Rect.fromLTWH(size.width * 0.14, size.height * 0.46, 118, 82),
      Rect.fromLTWH(size.width * 0.56, size.height * 0.40, 132, 100),
      Rect.fromLTWH(size.width * 0.10, size.height * 0.68, 124, 70),
      Rect.fromLTWH(size.width * 0.62, size.height * 0.64, 116, 68),
    ];

    for (final rect in blocks) {
      final rRect = RRect.fromRectAndRadius(rect, const Radius.circular(20));

      canvas.drawRRect(rRect, fill);
      canvas.drawRRect(rRect, border);
    }
  }

  void _drawLabels(Canvas canvas, Size size) {
    _drawLabel(
      canvas,
      'Food District',
      Offset(size.width * 0.18, size.height * 0.20),
    );

    _drawLabel(
      canvas,
      'Central Route',
      Offset(size.width * 0.56, size.height * 0.36),
    );

    _drawLabel(
      canvas,
      'Home Zone',
      Offset(size.width * 0.66, size.height * 0.57),
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

  void _drawDots(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withOpacity(0.055);

    for (double x = 22; x < size.width; x += 40) {
      for (double y = 90; y < size.height - 70; y += 40) {
        canvas.drawCircle(Offset(x, y), 1, paint);
      }
    }
  }

  void _drawSearchPulse(Canvas canvas, Size size) {
    final center = Offset(size.width * 0.50, size.height * 0.38);

    for (int i = 0; i < 4; i++) {
      final progress = (pulseProgress * 4 + i * 0.24) % 1;
      final radius = 44 + progress * 126;

      canvas.drawCircle(
        center,
        radius,
        Paint()
          ..color = AppTheme.green.withOpacity((1 - progress) * 0.12)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.2,
      );
    }
  }

  void _drawRoute(Canvas canvas, Size size) {
    final path = _buildRoutePath(size);
    final metric = path.computeMetrics().first;
    final activeLength = metric.length * routeProgress;
    final activePath = metric.extractPath(0, activeLength);

    /// Bigger glow.
    canvas.drawPath(
      path,
      Paint()
        ..color = AppTheme.green.withOpacity(0.35)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 36
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 24),
    );

    /// Strong base route.
    canvas.drawPath(
      path,
      Paint()
        ..color = Colors.white.withOpacity(0.45)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 14
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    /// Dark inner cut.
    canvas.drawPath(
      path,
      Paint()
        ..color = const Color(0xFF07100F).withOpacity(0.92)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    /// Visible guide line even before movement starts.
    canvas.drawPath(
      path,
      Paint()
        ..color = AppTheme.green.withOpacity(0.70)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4.5
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    if (activeLength > 0) {
      canvas.drawPath(
        activePath,
        Paint()
          ..color = AppTheme.cyan.withOpacity(0.42)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 26
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 16),
      );

      canvas.drawPath(
        activePath,
        Paint()
          ..shader = const LinearGradient(
            colors: [AppTheme.orange, AppTheme.green, AppTheme.cyan],
          ).createShader(Offset.zero & size)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 10
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round,
      );

      final dashPaint = Paint()
        ..color = Colors.white.withOpacity(0.78)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.4
        ..strokeCap = StrokeCap.round;

      for (double i = 0; i < activeLength; i += 34) {
        final dash = metric.extractPath(i, min(i + 12, activeLength));
        canvas.drawPath(dash, dashPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DeliveryMapPainter oldDelegate) {
    return oldDelegate.routeProgress != routeProgress ||
        oldDelegate.pulseProgress != pulseProgress ||
        oldDelegate.isSearching != isSearching;
  }
}

class _TrackingTopCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final int etaMinutes;
  final bool isDelivered;
  final bool isSearching;

  const _TrackingTopCard({
    required this.title,
    required this.subtitle,
    required this.etaMinutes,
    required this.isDelivered,
    required this.isSearching,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(14),
      borderRadius: BorderRadius.circular(28),
      child: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 360),
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                colors: isDelivered
                    ? const [AppTheme.green, Color(0xFFB5FFE0)]
                    : const [AppTheme.orange, AppTheme.green],
              ),
            ),
            child: Icon(
              isDelivered
                  ? Icons.check_rounded
                  : isSearching
                  ? Icons.search_rounded
                  : Icons.delivery_dining_rounded,
              color: AppTheme.bg,
              size: 24,
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 260),
                  child: Text(
                    title,
                    key: ValueKey(title),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16.5,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.35,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 260),
                  child: Text(
                    subtitle,
                    key: ValueKey(subtitle),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppTheme.muted,
                      fontSize: 12,
                      height: 1.3,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.08)),
            ),
            child: Text(
              isDelivered ? 'Done' : '$etaMinutes min',
              style: const TextStyle(
                color: AppTheme.green,
                fontSize: 12,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RiderSearchPulse extends StatefulWidget {
  const _RiderSearchPulse();

  @override
  State<_RiderSearchPulse> createState() => _RiderSearchPulseState();
}

class _RiderSearchPulseState extends State<_RiderSearchPulse>
    with SingleTickerProviderStateMixin {
  late final AnimationController controller;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1700),
    )..repeat();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (_, __) {
        return CustomPaint(
          size: const Size(190, 190),
          painter: _RiderPulsePainter(controller.value),
          child: const SizedBox(
            width: 190,
            height: 190,
            child: Center(
              child: Icon(
                Icons.delivery_dining_rounded,
                color: AppTheme.green,
                size: 34,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _RiderPulsePainter extends CustomPainter {
  final double progress;

  _RiderPulsePainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);

    for (int i = 0; i < 4; i++) {
      final delayed = (progress + i * 0.22) % 1;

      canvas.drawCircle(
        center,
        30 + delayed * 78,
        Paint()
          ..color = AppTheme.green.withOpacity((1 - delayed) * 0.18)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.2,
      );
    }

    canvas.drawCircle(
      center,
      38,
      Paint()
        ..color = AppTheme.green.withOpacity(0.13)
        ..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(covariant _RiderPulsePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

class _MapMarker extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _MapMarker({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withOpacity(0.16),
            border: Border.all(color: color.withOpacity(0.78), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.30),
                blurRadius: 22,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Icon(icon, color: color, size: 21),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
          decoration: BoxDecoration(
            color: AppTheme.glass,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: Colors.white.withOpacity(0.08)),
          ),
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _ScooterMarker extends StatelessWidget {
  const _ScooterMarker();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 68,
      height: 68,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppTheme.green.withOpacity(0.34),
            blurRadius: 26,
            spreadRadius: 3,
          ),
        ],
      ),
      child: CustomPaint(painter: _ScooterPainter()),
    );
  }
}

class _ScooterPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);

    canvas.drawCircle(
      center,
      29,
      Paint()
        ..color = AppTheme.green.withOpacity(0.12)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12),
    );

    final bodyPaint = Paint()
      ..shader = const LinearGradient(
        colors: [AppTheme.orange, AppTheme.green],
      ).createShader(Offset.zero & size);

    final darkPaint = Paint()..color = AppTheme.bg.withOpacity(0.85);
    final whitePaint = Paint()..color = Colors.white.withOpacity(0.92);

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(center.dx + 3, center.dy),
          width: 42,
          height: 24,
        ),
        const Radius.circular(14),
      ),
      bodyPaint,
    );

    canvas.drawCircle(Offset(center.dx - 14, center.dy + 16), 8, darkPaint);
    canvas.drawCircle(Offset(center.dx + 18, center.dy + 16), 8, darkPaint);

    canvas.drawCircle(Offset(center.dx - 14, center.dy + 16), 3, whitePaint);
    canvas.drawCircle(Offset(center.dx + 18, center.dy + 16), 3, whitePaint);

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(center.dx + 5, center.dy - 15, 18, 11),
        const Radius.circular(6),
      ),
      Paint()..color = AppTheme.bg.withOpacity(0.74),
    );

    final handlePaint = Paint()
      ..color = Colors.white.withOpacity(0.9)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      Offset(center.dx + 18, center.dy - 8),
      Offset(center.dx + 30, center.dy - 18),
      handlePaint,
    );

    canvas.drawCircle(Offset(center.dx + 32, center.dy - 19), 2.5, whitePaint);
  }

  @override
  bool shouldRepaint(covariant _ScooterPainter oldDelegate) => false;
}

class _DeliveryBottomSheet extends StatelessWidget {
  final FoodItem food;
  final int activeStep;
  final bool isDelivered;
  final int etaMinutes;
  final VoidCallback onDone;

  const _DeliveryBottomSheet({
    required this.food,
    required this.activeStep,
    required this.isDelivered,
    required this.etaMinutes,
    required this.onDone,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          decoration: BoxDecoration(
            color: const Color(0xDD07100F),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            border: Border.all(color: Colors.white.withOpacity(0.09)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(100),
                ),
              ),

              const SizedBox(height: 13),

              Row(
                children: [
                  Expanded(
                    child: Text(
                      isDelivered
                          ? 'Delivered successfully'
                          : 'Out for delivery',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.4,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: isDelivered ? onDone : null,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 13,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isDelivered
                            ? AppTheme.green
                            : AppTheme.green.withOpacity(0.10),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        isDelivered ? 'Done' : '$etaMinutes min',
                        style: TextStyle(
                          color: isDelivered ? AppTheme.bg : AppTheme.green,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image.network(
                      'https://images.unsplash.com/photo-1599566150163-29194dcaad36?q=80&w=400&auto=format&fit=crop',
                      width: 44,
                      height: 44,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 11),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Hamza Khan',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14.5,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          isDelivered
                              ? 'Order delivered to your location'
                              : 'Honda 125 · 4.9 rating · $etaMinutes min away',
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
                  const SizedBox(width: 8),
                  const _CircleAction(
                    icon: Icons.call_rounded,
                    color: AppTheme.green,
                  ),
                  const SizedBox(width: 7),
                  const _CircleAction(
                    icon: Icons.chat_rounded,
                    color: AppTheme.cyan,
                  ),
                ],
              ),

              const SizedBox(height: 16),

              _ConnectedStepIndicator(activeStep: activeStep),
            ],
          ),
        ),
      ),
    );
  }
}

class _CircleAction extends StatelessWidget {
  final IconData icon;
  final Color color;

  const _CircleAction({required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(0.06),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Icon(icon, color: color, size: 17),
    );
  }
}

class _ConnectedStepIndicator extends StatelessWidget {
  final int activeStep;

  const _ConnectedStepIndicator({required this.activeStep});

  @override
  Widget build(BuildContext context) {
    final steps = [
      _StepData('Order', Icons.receipt_long_rounded),
      _StepData('Prep', Icons.restaurant_rounded),
      _StepData('Pickup', Icons.delivery_dining_rounded),
      _StepData('Home', Icons.home_rounded),
    ];

    return Row(
      children: List.generate(steps.length, (index) {
        final isActive = index < activeStep;
        final isCurrent = index == activeStep - 1;

        return Expanded(
          child: Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: isCurrent ? 36 : 32,
                      height: isCurrent ? 36 : 32,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isActive
                            ? AppTheme.green
                            : Colors.white.withOpacity(0.07),
                        border: Border.all(
                          color: isActive
                              ? AppTheme.green
                              : Colors.white.withOpacity(0.12),
                        ),
                        boxShadow: isCurrent
                            ? [
                                BoxShadow(
                                  color: AppTheme.green.withOpacity(0.28),
                                  blurRadius: 16,
                                  spreadRadius: 1,
                                ),
                              ]
                            : [],
                      ),
                      child: Icon(
                        steps[index].icon,
                        size: 16,
                        color: isActive
                            ? AppTheme.bg
                            : Colors.white.withOpacity(0.36),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      steps[index].label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: isActive ? Colors.white : AppTheme.muted,
                        fontSize: 10,
                        fontWeight: isActive
                            ? FontWeight.w800
                            : FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              if (index != steps.length - 1)
                Expanded(
                  child: Container(
                    height: 3,
                    margin: const EdgeInsets.only(bottom: 23),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(99),
                      color: index < activeStep - 1
                          ? AppTheme.green
                          : Colors.white.withOpacity(0.10),
                    ),
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }
}

class _StepData {
  final String label;
  final IconData icon;

  const _StepData(this.label, this.icon);
}
