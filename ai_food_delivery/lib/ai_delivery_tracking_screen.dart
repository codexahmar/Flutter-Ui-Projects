import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';

import 'app_theme.dart';
import 'food_item.dart';
import 'shared_widgets.dart';

class AiDeliveryTrackingScreen extends StatefulWidget {
  final FoodItem food;

  const AiDeliveryTrackingScreen({
    super.key,
    required this.food,
  });

  @override
  State<AiDeliveryTrackingScreen> createState() => _AiDeliveryTrackingScreenState();
}

class _AiDeliveryTrackingScreenState extends State<AiDeliveryTrackingScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  double _smoothedAngle = 0;

  final List<Offset> routePoints = const [
    Offset(0.16, 0.24),
    Offset(0.27, 0.36),
    Offset(0.42, 0.40),
    Offset(0.55, 0.53),
    Offset(0.67, 0.60),
    Offset(0.79, 0.74),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 18),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get isSearching => _controller.value < 0.18;
  bool get isAccepted => _controller.value >= 0.18 && _controller.value < 0.34;
  bool get isPreparing => _controller.value >= 0.34 && _controller.value < 0.50;
  bool get isRiderAssigned => _controller.value >= 0.50 && _controller.value < 0.64;
  bool get isMoving => _controller.value >= 0.64 && _controller.value < 0.94;
  bool get isDelivered => _controller.value >= 0.94;

  double get routeProgress {
    if (_controller.value < 0.64) {
      return 0;
    }
    if (_controller.value >= 0.94) {
      return 1;
    }

    return ((_controller.value - 0.64) / 0.30).clamp(0.0, 1.0);
  }

  int get etaMinutes {
    if (isDelivered) {
      return 0;
    }

    final eta = 10 - (routeProgress * 10);
    return eta.ceil().clamp(1, 10);
  }

  int get activeStep {
    if (isSearching) return 0;
    if (isAccepted) return 1;
    if (isPreparing) return 2;
    if (isRiderAssigned) return 3;
    if (isMoving) return 4;
    return 5;
  }

  String get title {
    if (isSearching) return 'AI finding best rider';
    if (isAccepted) return 'Order accepted';
    if (isPreparing) return 'Preparing your meal';
    if (isRiderAssigned) return 'Rider assigned';
    if (isMoving) return 'On the way';
    return 'Delivered';
  }

  String get subtitle {
    if (isSearching) return 'Scanning nearby riders and the fastest route.';
    if (isAccepted) return '${widget.food.restaurant} confirmed the order';
    if (isPreparing) return 'Fresh prep in progress inside the restaurant';
    if (isRiderAssigned) return 'Hamza is at the pickup point';
    if (isMoving) return 'Your rider is moving through the city';
    return 'Enjoy your meal. Delivered with care.';
  }

  String get badge {
    if (isSearching) return 'AI';
    if (isAccepted) return 'Accepted';
    if (isPreparing) return 'Cooking';
    if (isRiderAssigned) return 'Pickup';
    if (isMoving) return '$etaMinutes min';
    return 'Done';
  }

  Path _buildRoutePath(Size size) {
    final points = routePoints
        .map((p) => Offset(p.dx * size.width, p.dy * size.height))
        .toList();

    final path = Path()..moveTo(points.first.dx, points.first.dy);

    for (var i = 1; i < points.length; i++) {
      final previous = points[i - 1];
      final current = points[i];
      final control = Offset(
        (previous.dx + current.dx) / 2,
        min(previous.dy, current.dy) - 56,
      );

      path.quadraticBezierTo(
        control.dx,
        control.dy,
        current.dx,
        current.dy,
      );
    }

    return path;
  }

  Tangent _routeTangent(Size size) {
    final path = _buildRoutePath(size);
    final metric = path.computeMetrics().first;
    final offset = metric.length * routeProgress;
    return metric.getTangentForOffset(offset) ?? metric.getTangentForOffset(0)!;
  }

  double _normalizeAngle(double angle) {
    while (angle <= -pi) {
      angle += pi * 2;
    }
    while (angle > pi) {
      angle -= pi * 2;
    }
    return angle;
  }

  double _smoothAngle(double target) {
    final delta = _normalizeAngle(target - _smoothedAngle);
    _smoothedAngle += delta * 0.14;
    return _smoothedAngle;
  }

  @override
  Widget build(BuildContext context) {
    final food = widget.food;

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final size = Size(constraints.maxWidth, constraints.maxHeight);
          final bottomSheetHeight = min(392.0, size.height * 0.46);

          return AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              final tangent = _routeTangent(size);
              final scooterPosition = tangent.position;
              final scooterAngle = _smoothAngle(tangent.angle);

              return Stack(
                children: [
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _DeliveryMapPainter(
                        routePoints: routePoints,
                        routeProgress: routeProgress,
                        aiPulseProgress: _controller.value,
                        showRoute: !isSearching,
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Color(0x66000000),
                            Colors.transparent,
                            Color(0xB9000000),
                          ],
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
                        badge: badge,
                        etaMinutes: etaMinutes,
                        isDelivered: isDelivered,
                      ),
                    ),
                  ),
                  if (isSearching)
                    Positioned(
                      top: size.height * 0.31,
                      left: 0,
                      right: 0,
                      child: const Center(child: _AiSearchOrb()),
                    ),
                  Positioned(
                    left: size.width * routePoints.first.dx - 28,
                    top: size.height * routePoints.first.dy - 30,
                    child: const _MapMarker(
                      icon: Icons.restaurant_rounded,
                      label: 'Restaurant',
                      color: AppTheme.orange,
                    ),
                  ),
                  Positioned(
                    left: size.width * routePoints.last.dx - 28,
                    top: size.height * routePoints.last.dy - 30,
                    child: const _MapMarker(
                      icon: Icons.home_rounded,
                      label: 'Your location',
                      color: AppTheme.green,
                    ),
                  ),
                  if (!isSearching && !isAccepted && !isPreparing)
                    Positioned(
                      left: scooterPosition.dx - 34,
                      top: scooterPosition.dy - 34,
                      child: Transform.rotate(
                        angle: scooterAngle,
                        child: const _ScooterMarker(),
                      ),
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
                        isMoving: isMoving,
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
  final double aiPulseProgress;
  final bool showRoute;

  _DeliveryMapPainter({
    required this.routePoints,
    required this.routeProgress,
    required this.aiPulseProgress,
    required this.showRoute,
  });

  @override
  void paint(Canvas canvas, Size size) {
    _drawBackground(canvas, size);
    _drawRoads(canvas, size);
    _drawBlocks(canvas, size);
    _drawLabels(canvas, size);
    _drawDots(canvas, size);

    if (showRoute) {
      _drawRoute(canvas, size);
    } else {
      _drawAiScan(canvas, size);
    }
  }

  Path _buildRoutePath(Size size) {
    final points = routePoints
        .map((p) => Offset(p.dx * size.width, p.dy * size.height))
        .toList();

    final path = Path()..moveTo(points.first.dx, points.first.dy);

    for (var i = 1; i < points.length; i++) {
      final previous = points[i - 1];
      final current = points[i];
      final control = Offset(
        (previous.dx + current.dx) / 2,
        min(previous.dy, current.dy) - 56,
      );

      path.quadraticBezierTo(
        control.dx,
        control.dy,
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
        ..shader = RadialGradient(
          colors: [AppTheme.green.withOpacity(0.16), Colors.transparent],
        ).createShader(Rect.fromCircle(center: Offset(size.width * 0.82, size.height * 0.14), radius: 280)),
    );

    canvas.drawCircle(
      Offset(size.width * 0.18, size.height * 0.32),
      250,
      Paint()
        ..shader = RadialGradient(
          colors: [AppTheme.orange.withOpacity(0.12), Colors.transparent],
        ).createShader(Rect.fromCircle(center: Offset(size.width * 0.18, size.height * 0.32), radius: 250)),
    );
  }

  void _drawRoads(Canvas canvas, Size size) {
    final roadGlow = Paint()
      ..color = Colors.white.withOpacity(0.02)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 54
      ..strokeCap = StrokeCap.round;

    final roadBase = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 22
      ..strokeCap = StrokeCap.round;

    final roadThin = Paint()
      ..color = Colors.white.withOpacity(0.03)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;

    final roadA = Path()
      ..moveTo(-40, size.height * 0.28)
      ..cubicTo(
        size.width * 0.20,
        size.height * 0.18,
        size.width * 0.48,
        size.height * 0.42,
        size.width + 40,
        size.height * 0.26,
      );
    final roadB = Path()
      ..moveTo(size.width * 0.10, -40)
      ..cubicTo(
        size.width * 0.12,
        size.height * 0.24,
        size.width * 0.30,
        size.height * 0.60,
        size.width * 0.18,
        size.height + 40,
      );
    final roadC = Path()
      ..moveTo(size.width + 30, size.height * 0.68)
      ..cubicTo(
        size.width * 0.74,
        size.height * 0.58,
        size.width * 0.48,
        size.height * 0.84,
        -30,
        size.height * 0.82,
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
      Rect.fromLTWH(size.width * 0.14, size.height * 0.46, 118, 88),
      Rect.fromLTWH(size.width * 0.56, size.height * 0.42, 132, 114),
      Rect.fromLTWH(size.width * 0.10, size.height * 0.75, 124, 78),
      Rect.fromLTWH(size.width * 0.62, size.height * 0.74, 116, 74),
    ];

    for (final rect in blocks) {
      final rRect = RRect.fromRectAndRadius(rect, const Radius.circular(20));
      canvas.drawRRect(rRect, fill);
      canvas.drawRRect(rRect, border);
    }
  }

  void _drawLabels(Canvas canvas, Size size) {
    _drawLabel(canvas, 'North Ridge', Offset(size.width * 0.18, size.height * 0.21));
    _drawLabel(canvas, 'Food District', Offset(size.width * 0.57, size.height * 0.39));
    _drawLabel(canvas, 'Central Loop', Offset(size.width * 0.34, size.height * 0.70));
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
    final paint = Paint()..color = Colors.white.withOpacity(0.06);

    for (double x = 22; x < size.width; x += 40) {
      for (double y = 100; y < size.height - 110; y += 40) {
        canvas.drawCircle(Offset(x, y), 1, paint);
      }
    }
  }

  void _drawAiScan(Canvas canvas, Size size) {
    final center = Offset(size.width * 0.50, size.height * 0.38);

    for (int i = 0; i < 4; i++) {
      final progress = (aiPulseProgress * 4 + i * 0.24) % 1;
      final radius = 44 + progress * 126;

      canvas.drawCircle(
        center,
        radius,
        Paint()
          ..color = AppTheme.green.withOpacity((1 - progress) * 0.14)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.2,
      );
    }

    canvas.drawCircle(
      center,
      170,
      Paint()
        ..shader = SweepGradient(
          colors: [
            Colors.transparent,
            AppTheme.green.withOpacity(0.22),
            Colors.transparent,
          ],
          stops: const [0.0, 0.58, 1.0],
          transform: GradientRotation(aiPulseProgress * pi * 4),
        ).createShader(Rect.fromCircle(center: center, radius: 170)),
    );
  }

  void _drawRoute(Canvas canvas, Size size) {
    final path = _buildRoutePath(size);
    final metric = path.computeMetrics().first;
    final activeLength = metric.length * routeProgress;
    final activePath = metric.extractPath(0, activeLength);

    canvas.drawPath(
      path,
      Paint()
        ..color = AppTheme.green.withOpacity(0.14)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 24
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18),
    );

    canvas.drawPath(
      path,
      Paint()
        ..color = Colors.white.withOpacity(0.16)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    canvas.drawPath(
      activePath,
      Paint()
        ..shader = const LinearGradient(
          colors: [AppTheme.orange, AppTheme.green, AppTheme.cyan],
        ).createShader(Offset.zero & size)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    canvas.drawPath(
      activePath,
      Paint()
        ..color = AppTheme.cyan.withOpacity(0.22)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 18
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12),
    );

    final dashPaint = Paint()
      ..color = Colors.white.withOpacity(0.56)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    for (double i = 0; i < activeLength; i += 34) {
      final dash = metric.extractPath(i, min(i + 12, activeLength));
      canvas.drawPath(dash, dashPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _DeliveryMapPainter oldDelegate) {
    return oldDelegate.routeProgress != routeProgress ||
        oldDelegate.aiPulseProgress != aiPulseProgress ||
        oldDelegate.showRoute != showRoute;
  }
}

class _TrackingTopCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String badge;
  final int etaMinutes;
  final bool isDelivered;

  const _TrackingTopCard({
    required this.title,
    required this.subtitle,
    required this.badge,
    required this.etaMinutes,
    required this.isDelivered,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      borderRadius: BorderRadius.circular(30),
      child: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 360),
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              gradient: LinearGradient(
                colors: isDelivered
                    ? const [AppTheme.green, Color(0xFFB5FFE0)]
                    : const [AppTheme.orange, AppTheme.green],
              ),
            ),
            child: Icon(
              isDelivered ? Icons.check_rounded : Icons.delivery_dining_rounded,
              color: AppTheme.bg,
              size: 27,
            ),
          ),
          const SizedBox(width: 14),
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
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.35,
                    ),
                  ),
                ),
                const SizedBox(height: 5),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 260),
                  child: Text(
                    subtitle,
                    key: ValueKey(subtitle),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppTheme.muted,
                      fontSize: 12.5,
                      height: 1.35,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 260),
            child: Container(
              key: ValueKey(badge),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.08),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.white.withOpacity(0.08)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'ETA',
                    style: TextStyle(
                      color: AppTheme.muted,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    isDelivered ? 'Now' : '$etaMinutes min',
                    style: const TextStyle(
                      color: AppTheme.green,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w900,
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

class _AiSearchOrb extends StatefulWidget {
  const _AiSearchOrb();

  @override
  State<_AiSearchOrb> createState() => _AiSearchOrbState();
}

class _AiSearchOrbState extends State<_AiSearchOrb>
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
          size: const Size(220, 220),
          painter: _AiOrbPainter(controller.value),
          child: const SizedBox(
            width: 220,
            height: 220,
            child: Center(
              child: Icon(Icons.auto_awesome_rounded, color: AppTheme.bg, size: 36),
            ),
          ),
        );
      },
    );
  }
}

class _AiOrbPainter extends CustomPainter {
  final double progress;

  _AiOrbPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);

    canvas.drawCircle(
      center,
      40,
      Paint()
        ..shader = const LinearGradient(
          colors: [AppTheme.orange, AppTheme.green, AppTheme.cyan],
        ).createShader(Rect.fromCircle(center: center, radius: 40)),
    );

    for (int i = 0; i < 4; i++) {
      final delayed = (progress + i * 0.22) % 1;
      canvas.drawCircle(
        center,
        42 + delayed * 88,
        Paint()
          ..color = AppTheme.green.withOpacity((1 - delayed) * 0.18)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.2,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _AiOrbPainter oldDelegate) {
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
          width: 50,
          height: 50,
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
          child: Icon(icon, color: color, size: 22),
        ),
        const SizedBox(height: 7),
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
              fontSize: 10.5,
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
      width: 70,
      height: 70,
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
      child: CustomPaint(
        painter: _ScooterPainter(),
      ),
    );
  }
}

class _ScooterPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);

    canvas.drawCircle(
      center,
      30,
      Paint()
        ..color = AppTheme.green.withOpacity(0.12)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12),
    );

    final bodyPaint = Paint()
      ..shader = const LinearGradient(
        colors: [AppTheme.orange, AppTheme.green],
      ).createShader(Offset.zero & size);

    final shadowPaint = Paint()..color = AppTheme.bg.withOpacity(0.8);
    final wheelPaint = Paint()..color = Colors.white.withOpacity(0.92);

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(center.dx + 3, center.dy), width: 42, height: 24),
        const Radius.circular(14),
      ),
      bodyPaint,
    );

    canvas.drawCircle(Offset(center.dx - 14, center.dy + 16), 8, shadowPaint);
    canvas.drawCircle(Offset(center.dx + 18, center.dy + 16), 8, shadowPaint);
    canvas.drawCircle(Offset(center.dx - 14, center.dy + 16), 3, wheelPaint);
    canvas.drawCircle(Offset(center.dx + 18, center.dy + 16), 3, wheelPaint);

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
    canvas.drawCircle(Offset(center.dx + 32, center.dy - 19), 2.5, wheelPaint);
  }

  @override
  bool shouldRepaint(covariant _ScooterPainter oldDelegate) => false;
}

class _DeliveryBottomSheet extends StatelessWidget {
  final FoodItem food;
  final int activeStep;
  final bool isDelivered;
  final int etaMinutes;
  final bool isMoving;

  const _DeliveryBottomSheet({
    required this.food,
    required this.activeStep,
    required this.isDelivered,
    required this.etaMinutes,
    required this.isMoving,
  });

  @override
  Widget build(BuildContext context) {
    final steps = [
      _TimelineEntry(
        title: 'Order confirmed',
        subtitle: 'Restaurant accepted the order',
        icon: Icons.check_circle_rounded,
      ),
      _TimelineEntry(
        title: 'Preparing',
        subtitle: 'Chef is preparing your meal fresh',
        icon: Icons.kitchen_rounded,
      ),
      _TimelineEntry(
        title: 'Picked up',
        subtitle: 'Rider collected the package',
        icon: Icons.local_shipping_rounded,
      ),
      _TimelineEntry(
        title: 'En route',
        subtitle: 'The route is being tracked live',
        icon: Icons.route_rounded,
      ),
      _TimelineEntry(
        title: 'Delivered',
        subtitle: 'Order handed over successfully',
        icon: Icons.celebration_rounded,
      ),
    ];

    return GlassCard(
      padding: const EdgeInsets.all(16),
      borderRadius: BorderRadius.circular(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isDelivered ? 'Delivered successfully' : '$etaMinutes min away',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.4,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isDelivered ? 'Enjoy your meal.' : '${food.restaurant} · live route tracking',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppTheme.muted,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Colors.white.withOpacity(0.08)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.timer_rounded, color: AppTheme.green, size: 16),
                    const SizedBox(width: 6),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 260),
                      child: Text(
                        isDelivered ? 'Now' : '$etaMinutes min',
                        key: ValueKey(etaMinutes),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          PremiumSurface(
            padding: const EdgeInsets.all(14),
            borderRadius: BorderRadius.circular(24),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: isDelivered
                          ? const [AppTheme.green, Color(0xFFB5FFE0)]
                          : const [AppTheme.orange, AppTheme.green],
                    ),
                  ),
                  child: Icon(
                    isDelivered ? Icons.check_rounded : Icons.person_rounded,
                    color: AppTheme.bg,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Rider: Hamza',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14.5,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '4.9 rating · 1,200+ deliveries · scooter',
                        style: TextStyle(
                          color: AppTheme.muted,
                          fontSize: 12,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: Colors.white.withOpacity(0.08)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.call_rounded, color: AppTheme.green, size: 16),
                      SizedBox(width: 6),
                      Text(
                        'Call',
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
            ),
          ),
          const SizedBox(height: 14),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Order timeline',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15.5,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...List.generate(steps.length, (index) {
                    final step = steps[index];
                    final completed = index < activeStep;
                    final active = index == activeStep;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: TimelineStepCard(
                        title: step.title,
                        subtitle: step.subtitle,
                        icon: step.icon,
                        active: active,
                        completed: completed,
                      ),
                    );
                  }),
                  const SizedBox(height: 2),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 260),
                    child: isDelivered
                        ? GlassCard(
                            key: const ValueKey('delivered'),
                            padding: const EdgeInsets.all(16),
                            borderRadius: BorderRadius.circular(24),
                            child: Row(
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: const LinearGradient(
                                      colors: [AppTheme.green, Color(0xFFA6FFD9)],
                                    ),
                                  ),
                                  child: const Icon(Icons.celebration_rounded, color: AppTheme.bg),
                                ),
                                const SizedBox(width: 12),
                                const Expanded(
                                  child: Text(
                                    'Delivery completed with a premium success state and a clear next action for the portfolio showcase.',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12.8,
                                      height: 1.4,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : GlassCard(
                            key: const ValueKey('moving'),
                            padding: const EdgeInsets.all(14),
                            borderRadius: BorderRadius.circular(24),
                            child: Row(
                              children: [
                                const Icon(Icons.route_rounded, color: AppTheme.orange),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    isMoving
                                        ? 'Route is active and the scooter is moving smoothly.'
                                        : 'Waiting for the rider handoff to complete.',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12.8,
                                      height: 1.4,
                                      fontWeight: FontWeight.w600,
                                    ),
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
        ],
      ),
    );
  }
}

class _TimelineEntry {
  final String title;
  final String subtitle;
  final IconData icon;

  const _TimelineEntry({
    required this.title,
    required this.subtitle,
    required this.icon,
  });
}
