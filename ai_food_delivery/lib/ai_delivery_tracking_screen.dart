import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';

import 'app_theme.dart';
import 'food_item.dart';

class AiDeliveryTrackingScreen extends StatefulWidget {
  final FoodItem food;

  const AiDeliveryTrackingScreen({
    super.key,
    required this.food,
  });

  @override
  State<AiDeliveryTrackingScreen> createState() =>
      _AiDeliveryTrackingScreenState();
}

class _AiDeliveryTrackingScreenState extends State<AiDeliveryTrackingScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  final List<Offset> routePoints = const [
    Offset(0.18, 0.28),
    Offset(0.30, 0.41),
    Offset(0.45, 0.43),
    Offset(0.55, 0.56),
    Offset(0.67, 0.62),
    Offset(0.80, 0.76),
  ];

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 16),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get isSearching => _controller.value < 0.20;
  bool get isAccepted => _controller.value >= 0.20 && _controller.value < 0.34;
  bool get isPreparing => _controller.value >= 0.34 && _controller.value < 0.48;
  bool get isRiderAssigned =>
      _controller.value >= 0.48 && _controller.value < 0.62;
  bool get isMoving => _controller.value >= 0.62 && _controller.value < 0.94;
  bool get isDelivered => _controller.value >= 0.94;

  double get routeProgress {
    if (_controller.value < 0.62) return 0;
    if (_controller.value >= 0.94) return 1;

    return ((_controller.value - 0.62) / 0.32).clamp(0.0, 1.0);
  }

  int get etaMinutes {
    if (isDelivered) return 0;
    final eta = 8 - (routeProgress * 8);
    return eta.ceil().clamp(1, 8);
  }

  int get activeStep {
    if (isSearching) return 0;
    if (isAccepted) return 1;
    if (isPreparing) return 2;
    if (isRiderAssigned || isMoving) return 3;
    return 4;
  }

  String get title {
    if (isSearching) return 'AI finding best rider';
    if (isAccepted) return 'Order accepted';
    if (isPreparing) return 'Preparing your meal';
    if (isRiderAssigned) return 'Rider assigned';
    if (isDelivered) return 'Order delivered';
    return 'Rider is on the way';
  }

  String get subtitle {
    if (isSearching) return 'Scanning nearby riders and fastest routes...';
    if (isAccepted) return '${widget.food.restaurant} confirmed your order';
    if (isPreparing) return 'Your food is being prepared fresh';
    if (isRiderAssigned) return 'Hamza is picking up your order';
    if (isDelivered) return 'Enjoy your meal. Bon appétit!';
    return '$etaMinutes min away · Live delivery tracking';
  }

  String get badge {
    if (isSearching) return 'AI';
    if (isAccepted) return 'Accepted';
    if (isPreparing) return 'Cooking';
    if (isRiderAssigned) return 'Picked';
    if (isDelivered) return 'Done';
    return '$etaMinutes min';
  }

  Path _buildRoutePath(Size size) {
    final points = routePoints
        .map((p) => Offset(p.dx * size.width, p.dy * size.height))
        .toList();

    final path = Path()..moveTo(points.first.dx, points.first.dy);

    for (int i = 1; i < points.length; i++) {
      final previous = points[i - 1];
      final current = points[i];

      final control = Offset(
        (previous.dx + current.dx) / 2,
        min(previous.dy, current.dy) - 48,
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

  Tangent _getScooterTangent(Size size) {
    final path = _buildRoutePath(size);
    final metric = path.computeMetrics().first;

    return metric.getTangentForOffset(metric.length * routeProgress)!;
  }

  @override
  Widget build(BuildContext context) {
    final food = widget.food;

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final size = Size(constraints.maxWidth, constraints.maxHeight);

          return AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              final tangent = _getScooterTangent(size);
              final scooterPosition = tangent.position;
              final scooterAngle = tangent.angle;

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
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withOpacity(0.05),
                            Colors.transparent,
                            Colors.black.withOpacity(0.78),
                          ],
                        ),
                      ),
                    ),
                  ),

                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                      child: _TrackingTopCard(
                        title: title,
                        subtitle: subtitle,
                        badge: badge,
                        isSearching: isSearching,
                        isDelivered: isDelivered,
                      ),
                    ),
                  ),

                  if (isSearching)
                    Positioned(
                      top: size.height * 0.30,
                      left: 0,
                      right: 0,
                      child: const Center(
                        child: _AiSearchOrb(),
                      ),
                    ),

                  Positioned(
                    left: size.width * routePoints.first.dx - 22,
                    top: size.height * routePoints.first.dy - 22,
                    child: const _MapMarker(
                      icon: Icons.restaurant_rounded,
                      label: 'Restaurant',
                      color: AppTheme.orange,
                    ),
                  ),

                  Positioned(
                    left: size.width * routePoints.last.dx - 22,
                    top: size.height * routePoints.last.dy - 22,
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
                    left: 20,
                    right: 20,
                    bottom: 24,
                    child: _DeliveryBottomSheet(
                      food: food,
                      activeStep: activeStep,
                      isDelivered: isDelivered,
                      etaMinutes: etaMinutes,
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

    for (int i = 1; i < points.length; i++) {
      final previous = points[i - 1];
      final current = points[i];

      final control = Offset(
        (previous.dx + current.dx) / 2,
        min(previous.dy, current.dy) - 48,
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
            Color(0xFF0A1715),
            Color(0xFF101219),
          ],
        ).createShader(rect),
    );

    canvas.drawCircle(
      Offset(size.width * 0.78, size.height * 0.14),
      280,
      Paint()
        ..shader = RadialGradient(
          colors: [
            AppTheme.green.withOpacity(0.20),
            Colors.transparent,
          ],
        ).createShader(
          Rect.fromCircle(
            center: Offset(size.width * 0.78, size.height * 0.14),
            radius: 280,
          ),
        ),
    );

    canvas.drawCircle(
      Offset(size.width * 0.18, size.height * 0.32),
      230,
      Paint()
        ..shader = RadialGradient(
          colors: [
            AppTheme.orange.withOpacity(0.13),
            Colors.transparent,
          ],
        ).createShader(
          Rect.fromCircle(
            center: Offset(size.width * 0.18, size.height * 0.32),
            radius: 230,
          ),
        ),
    );
  }

  void _drawRoads(Canvas canvas, Size size) {
    final road = Paint()
      ..color = Colors.white.withOpacity(0.075)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 30
      ..strokeCap = StrokeCap.round;

    final thinRoad = Paint()
      ..color = Colors.white.withOpacity(0.045)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 15
      ..strokeCap = StrokeCap.round;

    final roadOne = Path()
      ..moveTo(-50, size.height * 0.36)
      ..cubicTo(
        size.width * 0.24,
        size.height * 0.22,
        size.width * 0.52,
        size.height * 0.42,
        size.width + 50,
        size.height * 0.30,
      );

    final roadTwo = Path()
      ..moveTo(size.width * 0.15, -50)
      ..cubicTo(
        size.width * 0.10,
        size.height * 0.30,
        size.width * 0.32,
        size.height * 0.62,
        size.width * 0.18,
        size.height + 50,
      );

    final roadThree = Path()
      ..moveTo(size.width + 50, size.height * 0.70)
      ..cubicTo(
        size.width * 0.74,
        size.height * 0.58,
        size.width * 0.44,
        size.height * 0.82,
        -50,
        size.height * 0.84,
      );

    canvas.drawPath(roadOne, road);
    canvas.drawPath(roadTwo, thinRoad);
    canvas.drawPath(roadThree, road);
  }

  void _drawBlocks(Canvas canvas, Size size) {
    final fill = Paint()
      ..color = Colors.white.withOpacity(0.035)
      ..style = PaintingStyle.fill;

    final border = Paint()
      ..color = Colors.white.withOpacity(0.045)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final blocks = [
      Rect.fromLTWH(size.width * 0.07, size.height * 0.12, 88, 64),
      Rect.fromLTWH(size.width * 0.47, size.height * 0.10, 132, 76),
      Rect.fromLTWH(size.width * 0.18, size.height * 0.48, 116, 88),
      Rect.fromLTWH(size.width * 0.60, size.height * 0.40, 108, 122),
      Rect.fromLTWH(size.width * 0.10, size.height * 0.76, 124, 80),
      Rect.fromLTWH(size.width * 0.58, size.height * 0.72, 128, 74),
    ];

    for (final rect in blocks) {
      final rRect = RRect.fromRectAndRadius(
        rect,
        const Radius.circular(24),
      );

      canvas.drawRRect(rRect, fill);
      canvas.drawRRect(rRect, border);
    }
  }

  void _drawDots(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withOpacity(0.08);

    for (double x = 30; x < size.width; x += 42) {
      for (double y = 90; y < size.height - 120; y += 42) {
        canvas.drawCircle(Offset(x, y), 1.1, paint);
      }
    }
  }

  void _drawAiScan(Canvas canvas, Size size) {
    final center = Offset(size.width * 0.50, size.height * 0.38);

    for (int i = 0; i < 4; i++) {
      final progress = (aiPulseProgress * 4 + i * 0.22) % 1;
      final radius = 44 + progress * 128;

      canvas.drawCircle(
        center,
        radius,
        Paint()
          ..color = AppTheme.green.withOpacity((1 - progress) * 0.16)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.2,
      );
    }

    final sweepPaint = Paint()
      ..shader = SweepGradient(
        colors: [
          Colors.transparent,
          AppTheme.green.withOpacity(0.26),
          Colors.transparent,
        ],
        stops: const [0.0, 0.58, 1.0],
        transform: GradientRotation(aiPulseProgress * pi * 8),
      ).createShader(
        Rect.fromCircle(center: center, radius: 170),
      );

    canvas.drawCircle(center, 170, sweepPaint);
  }

  void _drawRoute(Canvas canvas, Size size) {
    final path = _buildRoutePath(size);
    final metric = path.computeMetrics().first;

    canvas.drawPath(
      path,
      Paint()
        ..color = AppTheme.green.withOpacity(0.24)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 22
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20),
    );

    canvas.drawPath(
      path,
      Paint()
        ..color = Colors.white.withOpacity(0.17)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    final activePath = metric.extractPath(
      0,
      metric.length * routeProgress,
    );

    canvas.drawPath(
      activePath,
      Paint()
        ..shader = const LinearGradient(
          colors: [
            AppTheme.orange,
            AppTheme.green,
            AppTheme.cyan,
          ],
        ).createShader(Offset.zero & size)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    final dashPaint = Paint()
      ..color = Colors.white.withOpacity(0.66)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    for (double i = 0; i < metric.length; i += 32) {
      final dash = metric.extractPath(i, min(i + 10, metric.length));
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
  final bool isSearching;
  final bool isDelivered;

  const _TrackingTopCard({
    required this.title,
    required this.subtitle,
    required this.badge,
    required this.isSearching,
    required this.isDelivered,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppTheme.glass,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: Colors.white.withOpacity(0.10),
            ),
          ),
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 450),
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(19),
                  gradient: LinearGradient(
                    colors: isDelivered
                        ? const [
                            AppTheme.green,
                            Color(0xFFB6FFE2),
                          ]
                        : const [
                            AppTheme.orange,
                            AppTheme.green,
                          ],
                  ),
                ),
                child: Icon(
                  isSearching
                      ? Icons.auto_awesome_rounded
                      : isDelivered
                          ? Icons.check_rounded
                          : Icons.delivery_dining_rounded,
                  color: AppTheme.bg,
                  size: 27,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _AnimatedText(
                      text: title,
                      fontSize: 17.5,
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                    ),
                    const SizedBox(height: 5),
                    _AnimatedText(
                      text: subtitle,
                      fontSize: 12.5,
                      color: AppTheme.muted,
                      fontWeight: FontWeight.w500,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 360),
                child: Container(
                  key: ValueKey(badge),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 13,
                    vertical: 9,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.08),
                    ),
                  ),
                  child: Text(
                    badge,
                    style: const TextStyle(
                      color: AppTheme.green,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AnimatedText extends StatelessWidget {
  final String text;
  final double fontSize;
  final Color color;
  final FontWeight fontWeight;

  const _AnimatedText({
    required this.text,
    required this.fontSize,
    required this.color,
    required this.fontWeight,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 450),
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.30),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        );
      },
      child: Text(
        text,
        key: ValueKey(text),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: color,
          fontSize: fontSize,
          fontWeight: fontWeight,
          letterSpacing: -0.2,
        ),
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
      duration: const Duration(milliseconds: 1800),
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
          size: const Size(230, 230),
          painter: _AiOrbPainter(controller.value),
          child: const SizedBox(
            width: 230,
            height: 230,
            child: Center(
              child: Icon(
                Icons.auto_awesome_rounded,
                color: AppTheme.bg,
                size: 38,
              ),
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

    for (int i = 0; i < 4; i++) {
      final delayed = (progress + i * 0.24) % 1;

      canvas.drawCircle(
        center,
        42 + delayed * 86,
        Paint()
          ..color = AppTheme.green.withOpacity((1 - delayed) * 0.22)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.4,
      );
    }

    canvas.drawCircle(
      center,
      42,
      Paint()
        ..shader = const LinearGradient(
          colors: [
            AppTheme.orange,
            AppTheme.green,
            AppTheme.cyan,
          ],
        ).createShader(
          Rect.fromCircle(center: center, radius: 42),
        ),
    );

    final particles = [
      Offset(center.dx - 76, center.dy - 28),
      Offset(center.dx + 72, center.dy - 44),
      Offset(center.dx + 54, center.dy + 68),
      Offset(center.dx - 48, center.dy + 72),
    ];

    for (int i = 0; i < particles.length; i++) {
      final pulse = sin((progress * pi * 2) + i) * 0.5 + 0.5;

      canvas.drawCircle(
        particles[i],
        4 + pulse * 2,
        Paint()..color = AppTheme.orange.withOpacity(0.85),
      );

      canvas.drawCircle(
        particles[i],
        13 + pulse * 4,
        Paint()..color = AppTheme.orange.withOpacity(0.08),
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
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withOpacity(0.15),
            border: Border.all(
              color: color.withOpacity(0.85),
              width: 1.6,
            ),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.35),
                blurRadius: 24,
                spreadRadius: 2,
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
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: Colors.white.withOpacity(0.08),
            ),
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
      width: 68,
      height: 68,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppTheme.green.withOpacity(0.35),
            blurRadius: 30,
            spreadRadius: 4,
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
        ..color = AppTheme.green.withOpacity(0.14)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14),
    );

    final bodyPaint = Paint()
      ..shader = const LinearGradient(
        colors: [
          AppTheme.orange,
          AppTheme.green,
        ],
      ).createShader(Offset.zero & size);

    final darkPaint = Paint()..color = AppTheme.bg;
    final whitePaint = Paint()..color = Colors.white.withOpacity(0.9);

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(center.dx + 3, center.dy),
          width: 42,
          height: 25,
        ),
        const Radius.circular(14),
      ),
      bodyPaint,
    );

    canvas.drawCircle(Offset(center.dx - 14, center.dy + 15), 8, darkPaint);
    canvas.drawCircle(Offset(center.dx + 18, center.dy + 15), 8, darkPaint);

    canvas.drawCircle(Offset(center.dx - 14, center.dy + 15), 3, whitePaint);
    canvas.drawCircle(Offset(center.dx + 18, center.dy + 15), 3, whitePaint);

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(center.dx + 4, center.dy - 15, 18, 10),
        const Radius.circular(6),
      ),
      Paint()..color = AppTheme.bg.withOpacity(0.72),
    );

    final handlePaint = Paint()
      ..color = Colors.white.withOpacity(0.9)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      Offset(center.dx + 18, center.dy - 8),
      Offset(center.dx + 28, center.dy - 17),
      handlePaint,
    );

    canvas.drawCircle(Offset(center.dx + 31, center.dy - 18), 2.5, whitePaint);
  }

  @override
  bool shouldRepaint(covariant _ScooterPainter oldDelegate) => false;
}

class _DeliveryBottomSheet extends StatelessWidget {
  final FoodItem food;
  final int activeStep;
  final bool isDelivered;
  final int etaMinutes;

  const _DeliveryBottomSheet({
    required this.food,
    required this.activeStep,
    required this.isDelivered,
    required this.etaMinutes,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(36),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Container(
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
          decoration: BoxDecoration(
            color: AppTheme.glass,
            borderRadius: BorderRadius.circular(36),
            border: Border.all(
              color: Colors.white.withOpacity(0.10),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.38),
                blurRadius: 38,
                offset: const Offset(0, 20),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 46,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(100),
                ),
              ),

              const SizedBox(height: 18),

              Row(
                children: [
                  Container(
                    width: 66,
                    height: 66,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
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
                      size: 34,
                    ),
                  ),
                  const SizedBox(width: 14),
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
                            fontSize: 19,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          '${food.restaurant} · Extra cheese · Fries',
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 9,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.07),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.08),
                      ),
                    ),
                    child: Text(
                      isDelivered ? 'Done' : '$etaMinutes min',
                      style: const TextStyle(
                        color: AppTheme.green,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              _DeliveryTimeline(activeStep: activeStep),

              const SizedBox(height: 18),

              AnimatedContainer(
                duration: const Duration(milliseconds: 480),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isDelivered
                      ? AppTheme.green.withOpacity(0.13)
                      : Colors.white.withOpacity(0.055),
                  borderRadius: BorderRadius.circular(26),
                  border: Border.all(
                    color: isDelivered
                        ? AppTheme.green.withOpacity(0.28)
                        : Colors.white.withOpacity(0.07),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 47,
                      height: 47,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            AppTheme.green,
                            AppTheme.cyan,
                          ],
                        ),
                      ),
                      child: const Center(
                        child: Text(
                          'HZ',
                          style: TextStyle(
                            color: AppTheme.bg,
                            fontWeight: FontWeight.w900,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 400),
                        child: Column(
                          key: ValueKey(isDelivered),
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isDelivered
                                  ? 'Hamza delivered your order'
                                  : 'Hamza is your delivery rider',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14.5,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              isDelivered
                                  ? 'Thank you for ordering with us'
                                  : 'Honda 125 · KHI 5821 · 4.9 rating',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: AppTheme.muted,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    _MiniActionButton(
                      icon: Icons.call_rounded,
                      color: AppTheme.green,
                      onTap: () {},
                    ),
                    const SizedBox(width: 9),
                    _MiniActionButton(
                      icon: Icons.chat_bubble_rounded,
                      color: AppTheme.cyan,
                      onTap: () {},
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

class _DeliveryTimeline extends StatelessWidget {
  final int activeStep;

  const _DeliveryTimeline({
    required this.activeStep,
  });

  @override
  Widget build(BuildContext context) {
    final steps = [
      _StepData('AI', Icons.auto_awesome_rounded),
      _StepData('Accepted', Icons.receipt_long_rounded),
      _StepData('Cooking', Icons.local_fire_department_rounded),
      _StepData('On way', Icons.delivery_dining_rounded),
      _StepData('Done', Icons.check_rounded),
    ];

    return Row(
      children: List.generate(steps.length, (index) {
        final isActive = index <= activeStep;
        final isCurrent = index == activeStep;

        return Expanded(
          child: Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 420),
                      width: isCurrent ? 42 : 36,
                      height: isCurrent ? 42 : 36,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isActive
                            ? AppTheme.green
                            : Colors.white.withOpacity(0.075),
                        boxShadow: isCurrent
                            ? [
                                BoxShadow(
                                  color: AppTheme.green.withOpacity(0.28),
                                  blurRadius: 20,
                                  spreadRadius: 2,
                                ),
                              ]
                            : [],
                      ),
                      child: Icon(
                        steps[index].icon,
                        color: isActive
                            ? AppTheme.bg
                            : Colors.white.withOpacity(0.38),
                        size: 18,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Text(
                      steps[index].label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: isActive
                            ? Colors.white
                            : Colors.white.withOpacity(0.35),
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              if (index != steps.length - 1)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 420),
                  width: 18,
                  height: 2,
                  margin: const EdgeInsets.only(bottom: 22),
                  decoration: BoxDecoration(
                    color: index < activeStep
                        ? AppTheme.green
                        : Colors.white.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(20),
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

class _MiniActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _MiniActionButton({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withOpacity(0.13),
      borderRadius: BorderRadius.circular(17),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(17),
        child: Container(
          width: 43,
          height: 43,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(17),
            border: Border.all(
              color: color.withOpacity(0.24),
            ),
          ),
          child: Icon(
            icon,
            color: color,
            size: 20,
          ),
        ),
      ),
    );
  }
}