import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';

class AiDeliveryTrackingScreen extends StatefulWidget {
  const AiDeliveryTrackingScreen({super.key});

  @override
  State<AiDeliveryTrackingScreen> createState() =>
      _AiDeliveryTrackingScreenState();
}

class _AiDeliveryTrackingScreenState extends State<AiDeliveryTrackingScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  final List<Offset> routePoints = const [
    Offset(0.18, 0.28), // Restaurant
    Offset(0.28, 0.40),
    Offset(0.44, 0.43),
    Offset(0.54, 0.55),
    Offset(0.66, 0.62),
    Offset(0.78, 0.76), // Home
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

  bool get _isSearching => _controller.value < 0.20;
  bool get _isAccepted => _controller.value >= 0.20 && _controller.value < 0.34;
  bool get _isPreparing => _controller.value >= 0.34 && _controller.value < 0.48;
  bool get _isRiderAssigned =>
      _controller.value >= 0.48 && _controller.value < 0.62;
  bool get _isMoving => _controller.value >= 0.62 && _controller.value < 0.94;
  bool get _isDelivered => _controller.value >= 0.94;

  double get _routeProgress {
    if (_controller.value < 0.62) return 0;
    if (_controller.value >= 0.94) return 1;

    return ((_controller.value - 0.62) / 0.32).clamp(0.0, 1.0);
  }

  int get _etaMinutes {
    if (_isDelivered) return 0;

    final eta = 8 - (_routeProgress * 8);
    return eta.ceil().clamp(1, 8);
  }

  String get _statusTitle {
    if (_isSearching) return "AI finding best restaurant";
    if (_isAccepted) return "Order accepted";
    if (_isPreparing) return "Preparing your meal";
    if (_isRiderAssigned) return "Rider assigned";
    if (_isDelivered) return "Order delivered";
    return "Rider is on the way";
  }

  String get _statusSubtitle {
    if (_isSearching) return "Scanning nearby restaurants and fastest routes...";
    if (_isAccepted) return "Burger House confirmed your order";
    if (_isPreparing) return "Your food is being prepared fresh";
    if (_isRiderAssigned) return "Hamza is picking up your order";
    if (_isDelivered) return "Enjoy your meal. Bon appétit!";
    return "$_etaMinutes min away · Live delivery tracking";
  }

  String get _statusBadge {
    if (_isSearching) return "AI";
    if (_isAccepted) return "Accepted";
    if (_isPreparing) return "Cooking";
    if (_isRiderAssigned) return "Picked";
    if (_isDelivered) return "Done";
    return "$_etaMinutes min";
  }

  Path _buildRoutePath(Size size) {
    final points = routePoints
        .map((point) => Offset(point.dx * size.width, point.dy * size.height))
        .toList();

    final path = Path()..moveTo(points.first.dx, points.first.dy);

    for (int i = 1; i < points.length; i++) {
      final previous = points[i - 1];
      final current = points[i];

      final controlPoint = Offset(
        (previous.dx + current.dx) / 2,
        min(previous.dy, current.dy) - 48,
      );

      path.quadraticBezierTo(
        controlPoint.dx,
        controlPoint.dy,
        current.dx,
        current.dy,
      );
    }

    return path;
  }

  Tangent _getScooterTangent(Size size, double progress) {
    final path = _buildRoutePath(size);
    final metric = path.computeMetrics().first;

    return metric.getTangentForOffset(metric.length * progress)!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF070B10),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final size = Size(constraints.maxWidth, constraints.maxHeight);

          return AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              final tangent = _getScooterTangent(size, _routeProgress);
              final scooterPosition = tangent.position;
              final scooterAngle = tangent.angle;

              return Stack(
                children: [
                  Positioned.fill(
                    child: CustomPaint(
                      painter: DeliveryMapPainter(
                        routePoints: routePoints,
                        routeProgress: _routeProgress,
                        aiPulseProgress: _controller.value,
                        showRoute: !_isSearching,
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

                  Positioned(
                    top: 58,
                    left: 20,
                    right: 20,
                    child: DeliveryStatusCard(
                      title: _statusTitle,
                      subtitle: _statusSubtitle,
                      badge: _statusBadge,
                      isSearching: _isSearching,
                      isDelivered: _isDelivered,
                    ),
                  ),

                  if (_isSearching)
                    Positioned(
                      top: size.height * 0.28,
                      left: 0,
                      right: 0,
                      child: const Center(
                        child: AiSearchOrb(),
                      ),
                    ),

                  Positioned(
                    left: size.width * routePoints.first.dx - 22,
                    top: size.height * routePoints.first.dy - 22,
                    child: const MapMarker(
                      icon: Icons.restaurant_rounded,
                      label: "Burger House",
                      color: Color(0xFFFFB84D),
                    ),
                  ),

                  Positioned(
                    left: size.width * routePoints.last.dx - 22,
                    top: size.height * routePoints.last.dy - 22,
                    child: const MapMarker(
                      icon: Icons.home_rounded,
                      label: "Your location",
                      color: Color(0xFF4DFFB5),
                    ),
                  ),

                  if (!_isSearching && !_isAccepted && !_isPreparing)
                    Positioned(
                      left: scooterPosition.dx - 34,
                      top: scooterPosition.dy - 34,
                      child: Transform.rotate(
                        angle: scooterAngle,
                        child: const ScooterMarker(),
                      ),
                    ),

                  Positioned(
                    left: 20,
                    right: 20,
                    bottom: 24,
                    child: DeliveryBottomSheet(
                      activeStep: _activeStep,
                      isDelivered: _isDelivered,
                      etaMinutes: _etaMinutes,
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

  int get _activeStep {
    if (_isSearching) return 0;
    if (_isAccepted) return 1;
    if (_isPreparing) return 2;
    if (_isRiderAssigned || _isMoving) return 3;
    return 4;
  }
}

class DeliveryMapPainter extends CustomPainter {
  final List<Offset> routePoints;
  final double routeProgress;
  final double aiPulseProgress;
  final bool showRoute;

  DeliveryMapPainter({
    required this.routePoints,
    required this.routeProgress,
    required this.aiPulseProgress,
    required this.showRoute,
  });

  @override
  void paint(Canvas canvas, Size size) {
    _drawBackground(canvas, size);
    _drawSoftGlows(canvas, size);
    _drawCityBlocks(canvas, size);
    _drawRoads(canvas, size);
    _drawGridDots(canvas, size);

    if (showRoute) {
      _drawRoute(canvas, size);
    }

    if (!showRoute) {
      _drawAiScan(canvas, size);
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

      final controlPoint = Offset(
        (previous.dx + current.dx) / 2,
        min(previous.dy, current.dy) - 48,
      );

      path.quadraticBezierTo(
        controlPoint.dx,
        controlPoint.dy,
        current.dx,
        current.dy,
      );
    }

    return path;
  }

  void _drawBackground(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    final paint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFF070B10),
          Color(0xFF0A1715),
          Color(0xFF101219),
        ],
      ).createShader(rect);

    canvas.drawRect(rect, paint);
  }

  void _drawSoftGlows(Canvas canvas, Size size) {
    final greenGlow = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF4DFFB5).withOpacity(0.20),
          Colors.transparent,
        ],
      ).createShader(
        Rect.fromCircle(
          center: Offset(size.width * 0.78, size.height * 0.14),
          radius: 280,
        ),
      );

    final orangeGlow = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFFFFB84D).withOpacity(0.13),
          Colors.transparent,
        ],
      ).createShader(
        Rect.fromCircle(
          center: Offset(size.width * 0.18, size.height * 0.32),
          radius: 230,
        ),
      );

    canvas.drawCircle(
      Offset(size.width * 0.78, size.height * 0.14),
      280,
      greenGlow,
    );

    canvas.drawCircle(
      Offset(size.width * 0.18, size.height * 0.32),
      230,
      orangeGlow,
    );
  }

  void _drawCityBlocks(Canvas canvas, Size size) {
    final fillPaint = Paint()
      ..color = Colors.white.withOpacity(0.035)
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
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

      canvas.drawRRect(rRect, fillPaint);
      canvas.drawRRect(rRect, borderPaint);
    }
  }

  void _drawRoads(Canvas canvas, Size size) {
    final roadPaint = Paint()
      ..color = Colors.white.withOpacity(0.075)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 30
      ..strokeCap = StrokeCap.round;

    final innerRoadPaint = Paint()
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

    canvas.drawPath(roadOne, roadPaint);
    canvas.drawPath(roadTwo, innerRoadPaint);
    canvas.drawPath(roadThree, roadPaint);
  }

  void _drawGridDots(Canvas canvas, Size size) {
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

      final paint = Paint()
        ..color = const Color(0xFF4DFFB5).withOpacity((1 - progress) * 0.16)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.2;

      canvas.drawCircle(center, radius, paint);
    }

    final sweepPaint = Paint()
      ..shader = SweepGradient(
        colors: [
          Colors.transparent,
          const Color(0xFF4DFFB5).withOpacity(0.26),
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

    final glowPaint = Paint()
      ..color = const Color(0xFF4DFFB5).withOpacity(0.24)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 22
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20);

    final basePaint = Paint()
      ..color = Colors.white.withOpacity(0.17)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final activePaint = Paint()
      ..shader = const LinearGradient(
        colors: [
          Color(0xFFFFB84D),
          Color(0xFF4DFFB5),
          Color(0xFF45D5FF),
        ],
      ).createShader(Offset.zero & size)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(path, glowPaint);
    canvas.drawPath(path, basePaint);

    final activePath = metric.extractPath(
      0,
      metric.length * routeProgress,
    );

    canvas.drawPath(activePath, activePaint);

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
  bool shouldRepaint(covariant DeliveryMapPainter oldDelegate) {
    return oldDelegate.routeProgress != routeProgress ||
        oldDelegate.aiPulseProgress != aiPulseProgress ||
        oldDelegate.showRoute != showRoute;
  }
}

class DeliveryStatusCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String badge;
  final bool isSearching;
  final bool isDelivered;

  const DeliveryStatusCard({
    super.key,
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
            color: const Color(0xFF07100F).withOpacity(0.72),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: Colors.white.withOpacity(0.10),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.28),
                blurRadius: 28,
                offset: const Offset(0, 16),
              ),
            ],
          ),
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 450),
                curve: Curves.easeOut,
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(19),
                  gradient: LinearGradient(
                    colors: isDelivered
                        ? const [
                            Color(0xFF4DFFB5),
                            Color(0xFFB6FFE2),
                          ]
                        : const [
                            Color(0xFFFFB84D),
                            Color(0xFF4DFFB5),
                          ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF4DFFB5).withOpacity(0.25),
                      blurRadius: 22,
                    ),
                  ],
                ),
                child: Icon(
                  isSearching
                      ? Icons.auto_awesome_rounded
                      : isDelivered
                          ? Icons.check_rounded
                          : Icons.delivery_dining_rounded,
                  color: const Color(0xFF07100F),
                  size: 27,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AnimatedSwitcher(
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
                        title,
                        key: ValueKey(title),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 17.5,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.4,
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),
                    AnimatedSwitcher(
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
                        subtitle,
                        key: ValueKey(subtitle),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFFB9C8C1),
                          fontSize: 12.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 360),
                transitionBuilder: (child, animation) {
                  return ScaleTransition(
                    scale: animation,
                    child: FadeTransition(opacity: animation, child: child),
                  );
                },
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
                      color: Color(0xFF4DFFB5),
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

class AiSearchOrb extends StatefulWidget {
  const AiSearchOrb({super.key});

  @override
  State<AiSearchOrb> createState() => _AiSearchOrbState();
}

class _AiSearchOrbState extends State<AiSearchOrb>
    with SingleTickerProviderStateMixin {
  late final AnimationController _orbController;

  @override
  void initState() {
    super.initState();

    _orbController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();
  }

  @override
  void dispose() {
    _orbController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _orbController,
      builder: (context, _) {
        return CustomPaint(
          size: const Size(230, 230),
          painter: AiOrbPainter(progress: _orbController.value),
          child: SizedBox(
            width: 230,
            height: 230,
            child: Center(
              child: Container(
                width: 82,
                height: 82,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFFFFB84D),
                      Color(0xFF4DFFB5),
                      Color(0xFF45D5FF),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF4DFFB5).withOpacity(0.38),
                      blurRadius: 38,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  color: Color(0xFF07100F),
                  size: 38,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class AiOrbPainter extends CustomPainter {
  final double progress;

  AiOrbPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);

    for (int i = 0; i < 4; i++) {
      final delayed = (progress + i * 0.24) % 1;
      final radius = 42 + delayed * 86;

      final paint = Paint()
        ..color = const Color(0xFF4DFFB5).withOpacity((1 - delayed) * 0.22)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.4;

      canvas.drawCircle(center, radius, paint);
    }

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
        Paint()..color = const Color(0xFFFFB84D).withOpacity(0.85),
      );

      canvas.drawCircle(
        particles[i],
        13 + pulse * 4,
        Paint()..color = const Color(0xFFFFB84D).withOpacity(0.08),
      );
    }
  }

  @override
  bool shouldRepaint(covariant AiOrbPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

class MapMarker extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const MapMarker({
    super.key,
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
            color: const Color(0xFF07100F).withOpacity(0.74),
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

class ScooterMarker extends StatelessWidget {
  const ScooterMarker({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 68,
      height: 68,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4DFFB5).withOpacity(0.35),
            blurRadius: 30,
            spreadRadius: 4,
          ),
        ],
      ),
      child: CustomPaint(
        painter: ScooterPainter(),
      ),
    );
  }
}

class ScooterPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);

    canvas.drawCircle(
      center,
      30,
      Paint()
        ..color = const Color(0xFF4DFFB5).withOpacity(0.14)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14),
    );

    final bodyPaint = Paint()
      ..shader = const LinearGradient(
        colors: [
          Color(0xFFFFB84D),
          Color(0xFF4DFFB5),
        ],
      ).createShader(Offset.zero & size);

    final darkPaint = Paint()..color = const Color(0xFF07100F);
    final whitePaint = Paint()..color = Colors.white.withOpacity(0.9);

    final body = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(center.dx + 3, center.dy),
        width: 42,
        height: 25,
      ),
      const Radius.circular(14),
    );

    canvas.drawRRect(body, bodyPaint);

    canvas.drawCircle(
      Offset(center.dx - 14, center.dy + 15),
      8,
      darkPaint,
    );
    canvas.drawCircle(
      Offset(center.dx + 18, center.dy + 15),
      8,
      darkPaint,
    );

    canvas.drawCircle(
      Offset(center.dx - 14, center.dy + 15),
      3,
      whitePaint,
    );
    canvas.drawCircle(
      Offset(center.dx + 18, center.dy + 15),
      3,
      whitePaint,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(center.dx + 4, center.dy - 15, 18, 10),
        const Radius.circular(6),
      ),
      Paint()..color = const Color(0xFF07100F).withOpacity(0.72),
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

    canvas.drawCircle(
      Offset(center.dx + 31, center.dy - 18),
      2.5,
      whitePaint,
    );
  }

  @override
  bool shouldRepaint(covariant ScooterPainter oldDelegate) => false;
}

class DeliveryBottomSheet extends StatelessWidget {
  final int activeStep;
  final bool isDelivered;
  final int etaMinutes;

  const DeliveryBottomSheet({
    super.key,
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
            color: const Color(0xFF07100F).withOpacity(0.88),
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
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFFFFB84D),
                          Color(0xFF4DFFB5),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFFB84D).withOpacity(0.22),
                          blurRadius: 26,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.lunch_dining_rounded,
                      color: Color(0xFF07100F),
                      size: 34,
                    ),
                  ),

                  const SizedBox(width: 14),

                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Classic Beef Burger",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 19,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.5,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          "Burger House · Extra cheese · Fries",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Color(0xFFB9C8C1),
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
                      isDelivered ? "Done" : "$etaMinutes min",
                      style: const TextStyle(
                        color: Color(0xFF4DFFB5),
                        fontSize: 12.5,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              DeliveryTimeline(activeStep: activeStep),

              const SizedBox(height: 18),

              AnimatedContainer(
                duration: const Duration(milliseconds: 480),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isDelivered
                      ? const Color(0xFF4DFFB5).withOpacity(0.13)
                      : Colors.white.withOpacity(0.055),
                  borderRadius: BorderRadius.circular(26),
                  border: Border.all(
                    color: isDelivered
                        ? const Color(0xFF4DFFB5).withOpacity(0.28)
                        : Colors.white.withOpacity(0.07),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 47,
                      height: 47,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFF4DFFB5),
                            Color(0xFF45D5FF),
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF4DFFB5).withOpacity(0.24),
                            blurRadius: 20,
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Text(
                          "HZ",
                          style: TextStyle(
                            color: Color(0xFF07100F),
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
                                  ? "Hamza delivered your order"
                                  : "Hamza is your delivery rider",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14.5,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.2,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              isDelivered
                                  ? "Thank you for ordering with us"
                                  : "Honda 125 · KHI 5821 · 4.9 rating",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Color(0xFFB9C8C1),
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
                      color: const Color(0xFF4DFFB5),
                      onTap: () {},
                    ),

                    const SizedBox(width: 9),

                    _MiniActionButton(
                      icon: Icons.chat_bubble_rounded,
                      color: const Color(0xFF45D5FF),
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

class DeliveryTimeline extends StatelessWidget {
  final int activeStep;

  const DeliveryTimeline({
    super.key,
    required this.activeStep,
  });

  @override
  Widget build(BuildContext context) {
    final steps = [
      _TimelineStepData("AI Match", Icons.auto_awesome_rounded),
      _TimelineStepData("Accepted", Icons.receipt_long_rounded),
      _TimelineStepData("Cooking", Icons.local_fire_department_rounded),
      _TimelineStepData("On way", Icons.delivery_dining_rounded),
      _TimelineStepData("Done", Icons.check_rounded),
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
                      curve: Curves.easeOut,
                      width: isCurrent ? 42 : 36,
                      height: isCurrent ? 42 : 36,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isActive
                            ? const Color(0xFF4DFFB5)
                            : Colors.white.withOpacity(0.075),
                        boxShadow: isCurrent
                            ? [
                                BoxShadow(
                                  color:
                                      const Color(0xFF4DFFB5).withOpacity(0.28),
                                  blurRadius: 20,
                                  spreadRadius: 2,
                                ),
                              ]
                            : [],
                      ),
                      child: Icon(
                        steps[index].icon,
                        color: isActive
                            ? const Color(0xFF07100F)
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
                        ? const Color(0xFF4DFFB5)
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

class _TimelineStepData {
  final String label;
  final IconData icon;

  const _TimelineStepData(this.label, this.icon);
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