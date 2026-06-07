import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';

class RideTrackingScreen extends StatefulWidget {
  const RideTrackingScreen({super.key});

  @override
  State<RideTrackingScreen> createState() => _RideTrackingScreenState();
}

class _RideTrackingScreenState extends State<RideTrackingScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  final List<Offset> routePoints = const [
    Offset(0.16, 0.74),
    Offset(0.31, 0.74),
    Offset(0.31, 0.58),
    Offset(0.56, 0.58),
    Offset(0.56, 0.40),
    Offset(0.80, 0.40),
    Offset(0.80, 0.22),
  ];

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 13),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _isSearching => _controller.value < 0.26;
  bool get _isFound => _controller.value >= 0.26 && _controller.value < 0.38;
  bool get _isReached => _controller.value >= 0.92;

  double get _carProgress {
    if (_controller.value < 0.38) return 0;
    if (_controller.value >= 0.92) return 1;

    return ((_controller.value - 0.38) / 0.54).clamp(0.0, 1.0);
  }

  int get _etaMinutes {
    if (_isReached) return 0;

    final remaining = 4 - (_carProgress * 4);
    return remaining.ceil().clamp(1, 4);
  }

  String get _statusTitle {
    if (_isSearching) return "Searching nearby drivers";
    if (_isFound) return "Driver found";
    if (_isReached) return "Ahsan Malik reached";
    return "Driver is arriving";
  }

  String get _statusSubtitle {
    if (_isSearching) return "Scanning the closest available rides...";
    if (_isFound) return "Ahsan Malik accepted your ride";
    if (_isReached) return "Your driver is waiting at pickup point";
    return "$_etaMinutes min away · Live route updating";
  }

  Tangent _getCarTangent(Size size, double progress) {
    final path = buildOrthogonalRoutePath(routePoints, size);
    final metric = path.computeMetrics().first;

    return metric.getTangentForOffset(metric.length * progress)!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF06110D),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final size = Size(constraints.maxWidth, constraints.maxHeight);

          return AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              final tangent = _getCarTangent(size, _carProgress);
              final carPosition = tangent.position;
              final carAngle = tangent.angle;

              return Stack(
                children: [
                  Positioned.fill(
                    child: CustomPaint(
                      painter: PremiumMapPainter(
                        routePoints: routePoints,
                        routeProgress: _carProgress,
                        radarProgress: _controller.value,
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
                            Colors.black.withOpacity(0.72),
                          ],
                        ),
                      ),
                    ),
                  ),

                  if (_isSearching)
                    Positioned(
                      left: 0,
                      right: 0,
                      top: size.height * 0.30,
                      child: const Center(child: RadarSearchWidget()),
                    ),

                  Positioned(
                    top: 58,
                    left: 20,
                    right: 20,
                    child: TopRideStatusCard(
                      title: _statusTitle,
                      subtitle: _statusSubtitle,
                      eta: _etaMinutes,
                      isSearching: _isSearching,
                      isReached: _isReached,
                    ),
                  ),

                  Positioned(
                    left: size.width * routePoints.first.dx - 19,
                    top: size.height * routePoints.first.dy - 19,
                    child: const LocationPin(
                      icon: Icons.my_location_rounded,
                      color: Color(0xFF54F4A7),
                    ),
                  ),

                  Positioned(
                    left: size.width * routePoints.last.dx - 19,
                    top: size.height * routePoints.last.dy - 19,
                    child: const LocationPin(
                      icon: Icons.flag_rounded,
                      color: Color(0xFF62D9FF),
                    ),
                  ),

                  if (!_isSearching)
                    Positioned(
                      left: carPosition.dx - 30,
                      top: carPosition.dy - 30,
                      child: Transform.rotate(
                        angle: carAngle,
                        child: const CustomCarMarker(),
                      ),
                    ),

                  Positioned(
                    left: 20,
                    right: 20,
                    bottom: 24,
                    child: DriverBottomSheet(
                      isSearching: _isSearching,
                      isReached: _isReached,
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

class PremiumMapPainter extends CustomPainter {
  final List<Offset> routePoints;
  final double routeProgress;
  final double radarProgress;
  final bool showRoute;

  PremiumMapPainter({
    required this.routePoints,
    required this.routeProgress,
    required this.radarProgress,
    required this.showRoute,
  });

  @override
  void paint(Canvas canvas, Size size) {
    _drawBackground(canvas, size);
    _drawCityBlocks(canvas, size);
    _drawRoads(canvas, size);
    _drawAmbientDots(canvas, size);

    if (showRoute) {
      _drawRoute(canvas, size);
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

      path.lineTo(current.dx, previous.dy);
      path.lineTo(current.dx, current.dy);
    }

    return path;
  }

  void _drawBackground(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    final backgroundPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF06140F), Color(0xFF09251A), Color(0xFF06110D)],
      ).createShader(rect);

    canvas.drawRect(rect, backgroundPaint);

    final glowPaint = Paint()
      ..shader =
          RadialGradient(
            colors: [
              const Color(0xFF54F4A7).withOpacity(0.20),
              Colors.transparent,
            ],
          ).createShader(
            Rect.fromCircle(
              center: Offset(size.width * 0.72, size.height * 0.16),
              radius: 280,
            ),
          );

    canvas.drawCircle(
      Offset(size.width * 0.72, size.height * 0.16),
      280,
      glowPaint,
    );
  }

  void _drawCityBlocks(Canvas canvas, Size size) {
    final blockPaint = Paint()
      ..color = Colors.white.withOpacity(0.035)
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = Colors.white.withOpacity(0.035)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final blocks = [
      Rect.fromLTWH(size.width * 0.08, size.height * 0.12, 88, 58),
      Rect.fromLTWH(size.width * 0.56, size.height * 0.12, 120, 72),
      Rect.fromLTWH(size.width * 0.18, size.height * 0.42, 110, 80),
      Rect.fromLTWH(size.width * 0.62, size.height * 0.43, 94, 110),
      Rect.fromLTWH(size.width * 0.10, size.height * 0.78, 130, 78),
      Rect.fromLTWH(size.width * 0.58, size.height * 0.72, 124, 70),
    ];

    for (final rect in blocks) {
      final rRect = RRect.fromRectAndRadius(rect, const Radius.circular(22));
      canvas.drawRRect(rRect, blockPaint);
      canvas.drawRRect(rRect, borderPaint);
    }
  }

  void _drawRoads(Canvas canvas, Size size) {
    final roadPaint = Paint()
      ..color = Colors.white.withOpacity(0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 28
      ..strokeCap = StrokeCap.round;

    final thinRoadPaint = Paint()
      ..color = Colors.white.withOpacity(0.045)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 16
      ..strokeCap = StrokeCap.round;

    final road1 = Path()
      ..moveTo(-40, size.height * 0.28)
      ..cubicTo(
        size.width * 0.22,
        size.height * 0.18,
        size.width * 0.38,
        size.height * 0.42,
        size.width + 40,
        size.height * 0.32,
      );

    final road2 = Path()
      ..moveTo(size.width * 0.16, -40)
      ..cubicTo(
        size.width * 0.22,
        size.height * 0.28,
        size.width * 0.14,
        size.height * 0.62,
        size.width * 0.36,
        size.height + 40,
      );

    final road3 = Path()
      ..moveTo(size.width + 40, size.height * 0.68)
      ..cubicTo(
        size.width * 0.72,
        size.height * 0.58,
        size.width * 0.42,
        size.height * 0.74,
        -40,
        size.height * 0.84,
      );

    canvas.drawPath(road1, roadPaint);
    canvas.drawPath(road2, thinRoadPaint);
    canvas.drawPath(road3, roadPaint);
  }

  void _drawRoute(Canvas canvas, Size size) {
    final path = _buildRoutePath(size);
    final metric = path.computeMetrics().first;

    final glowPaint = Paint()
      ..color = const Color(0xFF54F4A7).withOpacity(0.22)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 20
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20);

    final basePaint = Paint()
      ..color = Colors.white.withOpacity(0.18)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final activePaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF54F4A7), Color(0xFF62D9FF)],
      ).createShader(Offset.zero & size)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(path, glowPaint);
    canvas.drawPath(path, basePaint);

    final activePath = metric.extractPath(0, metric.length * routeProgress);

    canvas.drawPath(activePath, activePaint);

    final dashPaint = Paint()
      ..color = Colors.white.withOpacity(0.65)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    for (double i = 0; i < metric.length; i += 30) {
      final dashPath = metric.extractPath(i, min(i + 10, metric.length));
      canvas.drawPath(dashPath, dashPaint);
    }
  }

  void _drawAmbientDots(Canvas canvas, Size size) {
    final dotPaint = Paint()..color = Colors.white.withOpacity(0.12);

    final dots = [
      Offset(size.width * 0.18, size.height * 0.58),
      Offset(size.width * 0.78, size.height * 0.30),
      Offset(size.width * 0.42, size.height * 0.20),
      Offset(size.width * 0.50, size.height * 0.82),
      Offset(size.width * 0.86, size.height * 0.58),
    ];

    for (final dot in dots) {
      canvas.drawCircle(dot, 3.5, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant PremiumMapPainter oldDelegate) {
    return oldDelegate.routeProgress != routeProgress ||
        oldDelegate.radarProgress != radarProgress ||
        oldDelegate.showRoute != showRoute;
  }
}

class RadarSearchWidget extends StatefulWidget {
  const RadarSearchWidget({super.key});

  @override
  State<RadarSearchWidget> createState() => _RadarSearchWidgetState();
}

class _RadarSearchWidgetState extends State<RadarSearchWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _radarController;

  @override
  void initState() {
    super.initState();

    _radarController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();
  }

  @override
  void dispose() {
    _radarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _radarController,
      builder: (context, _) {
        return CustomPaint(
          size: const Size(220, 220),
          painter: RadarPainter(progress: _radarController.value),
          child: SizedBox(
            width: 220,
            height: 220,
            child: Center(
              child: Container(
                width: 74,
                height: 74,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0xFF54F4A7), Color(0xFF62D9FF)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF54F4A7).withOpacity(0.35),
                      blurRadius: 35,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.location_searching_rounded,
                  color: Color(0xFF06110D),
                  size: 34,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class RadarPainter extends CustomPainter {
  final double progress;

  RadarPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);

    for (int i = 0; i < 4; i++) {
      final delayedProgress = (progress + i * 0.25) % 1;
      final radius = 42 + delayedProgress * 82;

      final paint = Paint()
        ..color = const Color(
          0xFF54F4A7,
        ).withOpacity((1 - delayedProgress) * 0.22)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.2;

      canvas.drawCircle(center, radius, paint);
    }

    final sweepPaint = Paint()
      ..shader = SweepGradient(
        startAngle: 0,
        endAngle: pi * 2,
        colors: [
          Colors.transparent,
          const Color(0xFF54F4A7).withOpacity(0.32),
          Colors.transparent,
        ],
        stops: const [0.0, 0.55, 1.0],
        transform: GradientRotation(progress * pi * 2),
      ).createShader(Rect.fromCircle(center: center, radius: 105));

    canvas.drawCircle(center, 105, sweepPaint);

    final driverDotPaint = Paint()
      ..color = const Color(0xFF62D9FF).withOpacity(0.85);

    final dots = [
      Offset(center.dx - 74, center.dy - 28),
      Offset(center.dx + 68, center.dy - 42),
      Offset(center.dx + 42, center.dy + 70),
    ];

    for (final dot in dots) {
      canvas.drawCircle(dot, 4.5, driverDotPaint);
      canvas.drawCircle(
        dot,
        12,
        Paint()..color = const Color(0xFF62D9FF).withOpacity(0.10),
      );
    }
  }

  @override
  bool shouldRepaint(covariant RadarPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

class TopRideStatusCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final int eta;
  final bool isSearching;
  final bool isReached;

  const TopRideStatusCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.eta,
    required this.isSearching,
    required this.isReached,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: const Color(0xFF07110D).withOpacity(0.66),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: Colors.white.withOpacity(0.10)),
          ),
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 450),
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(17),
                  gradient: LinearGradient(
                    colors: isReached
                        ? const [Color(0xFF54F4A7), Color(0xFFB8FFDC)]
                        : const [Color(0xFF54F4A7), Color(0xFF62D9FF)],
                  ),
                ),
                child: Icon(
                  isSearching
                      ? Icons.radar_rounded
                      : isReached
                      ? Icons.check_rounded
                      : Icons.navigation_rounded,
                  color: const Color(0xFF06140F),
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 420),
                      transitionBuilder: (child, animation) {
                        return FadeTransition(
                          opacity: animation,
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0, 0.35),
                              end: Offset.zero,
                            ).animate(animation),
                            child: child,
                          ),
                        );
                      },
                      child: Text(
                        title,
                        key: ValueKey(title),
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
                      duration: const Duration(milliseconds: 420),
                      transitionBuilder: (child, animation) {
                        return FadeTransition(
                          opacity: animation,
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0, 0.35),
                              end: Offset.zero,
                            ).animate(animation),
                            child: child,
                          ),
                        );
                      },
                      child: Text(
                        subtitle,
                        key: ValueKey(subtitle),
                        style: const TextStyle(
                          color: Color(0xFFB8C7C0),
                          fontSize: 12.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              AnimatedSwitcher(
                duration: const Duration(milliseconds: 380),
                transitionBuilder: (child, animation) {
                  return ScaleTransition(
                    scale: animation,
                    child: FadeTransition(opacity: animation, child: child),
                  );
                },
                child: Container(
                  key: ValueKey("$eta-$isSearching-$isReached"),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 13,
                    vertical: 9,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: Colors.white.withOpacity(0.08)),
                  ),
                  child: Text(
                    isSearching
                        ? "..."
                        : isReached
                        ? "Here"
                        : "$eta min",
                    style: const TextStyle(
                      color: Color(0xFF54F4A7),
                      fontWeight: FontWeight.w900,
                      fontSize: 13,
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

class CustomCarMarker extends StatelessWidget {
  const CustomCarMarker({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 62,
      height: 62,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF54F4A7).withOpacity(0.35),
            blurRadius: 28,
            spreadRadius: 4,
          ),
        ],
      ),
      child: CustomPaint(painter: CarTopViewPainter()),
    );
  }
}

class CarTopViewPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);

    final glowPaint = Paint()
      ..color = const Color(0xFF54F4A7).withOpacity(0.18)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 16);

    canvas.drawCircle(center, 27, glowPaint);

    final bodyRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: center, width: 48, height: 28),
      const Radius.circular(14),
    );

    final bodyPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF54F4A7), Color(0xFF62D9FF)],
      ).createShader(bodyRect.outerRect);

    canvas.drawRRect(bodyRect, bodyPaint);

    final cabinRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(center.dx + 4, center.dy),
        width: 22,
        height: 18,
      ),
      const Radius.circular(8),
    );

    canvas.drawRRect(
      cabinRect,
      Paint()..color = const Color(0xFF06110D).withOpacity(0.72),
    );

    final frontPaint = Paint()..color = Colors.white.withOpacity(0.88);

    canvas.drawCircle(Offset(center.dx + 21, center.dy - 7), 2.3, frontPaint);
    canvas.drawCircle(Offset(center.dx + 21, center.dy + 7), 2.3, frontPaint);

    final tyrePaint = Paint()..color = const Color(0xFF03100B);

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(center.dx - 15, center.dy - 18, 11, 5),
        const Radius.circular(4),
      ),
      tyrePaint,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(center.dx - 15, center.dy + 13, 11, 5),
        const Radius.circular(4),
      ),
      tyrePaint,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(center.dx + 8, center.dy - 18, 11, 5),
        const Radius.circular(4),
      ),
      tyrePaint,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(center.dx + 8, center.dy + 13, 11, 5),
        const Radius.circular(4),
      ),
      tyrePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CarTopViewPainter oldDelegate) => false;
}

class LocationPin extends StatelessWidget {
  final IconData icon;
  final Color color;

  const LocationPin({super.key, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withOpacity(0.16),
        border: Border.all(color: color.withOpacity(0.8), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.35),
            blurRadius: 22,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Icon(icon, color: color, size: 19),
    );
  }
}

class DriverBottomSheet extends StatelessWidget {
  final bool isSearching;
  final bool isReached;

  const DriverBottomSheet({
    super.key,
    required this.isSearching,
    required this.isReached,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(34),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
        child: Container(
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
          decoration: BoxDecoration(
            color: const Color(0xFF08140F).withOpacity(0.86),
            borderRadius: BorderRadius.circular(34),
            border: Border.all(color: Colors.white.withOpacity(0.10)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.35),
                blurRadius: 35,
                offset: const Offset(0, 18),
              ),
            ],
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 450),
            child: isSearching
                ? const _DriverBottomSheetSkeleton(key: ValueKey('loading'))
                : _DriverBottomSheetDetails(
                    key: const ValueKey('details'),
                    isReached: isReached,
                  ),
          ),
        ),
      ),
    );
  }
}

class _DriverBottomSheetSkeleton extends StatelessWidget {
  const _DriverBottomSheetSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 44,
          height: 5,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.18),
            borderRadius: BorderRadius.circular(100),
          ),
        ),
        const SizedBox(height: 18),
        const Row(
          children: [
            _ShimmerCircle(size: 66),
            SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ShimmerBar(widthFactor: 0.56, height: 16),
                  SizedBox(height: 10),
                  _ShimmerBar(widthFactor: 0.84, height: 11),
                  SizedBox(height: 10),
                  _ShimmerBar(widthFactor: 0.42, height: 11),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        const Row(
          children: [
            Expanded(child: _ShimmerTile(label: 'Fare', valueWidth: 0.44)),
            SizedBox(width: 10),
            Expanded(child: _ShimmerTile(label: 'Distance', valueWidth: 0.34)),
            SizedBox(width: 10),
            Expanded(child: _ShimmerTile(label: 'ETA', valueWidth: 0.30)),
          ],
        ),
        const SizedBox(height: 14),
        const _ShimmerRouteSummary(),
      ],
    );
  }
}

class _DriverBottomSheetDetails extends StatelessWidget {
  final bool isReached;

  const _DriverBottomSheetDetails({super.key, required this.isReached});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 44,
          height: 5,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.18),
            borderRadius: BorderRadius.circular(100),
          ),
        ),
        const SizedBox(height: 18),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 66,
              height: 66,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [Color(0xFF54F4A7), Color(0xFF62D9FF)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF54F4A7).withOpacity(0.28),
                    blurRadius: 24,
                    spreadRadius: 2,
                  ),
                ],
              ),
              padding: const EdgeInsets.all(3),
              child: Container(
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF0E2018),
                ),
                child: const Center(
                  child: Text(
                    'AM',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 19,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ahsan Malik',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.6,
                    ),
                  ),
                  SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        Icons.star_rounded,
                        color: Color(0xFFFFC857),
                        size: 18,
                      ),
                      SizedBox(width: 4),
                      Text(
                        '4.9',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Honda Civic · LEA 4821',
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Color(0xFFB8C7C0),
                            fontSize: 12.5,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Column(
              children: [
                _ActionButton(
                  icon: Icons.call_rounded,
                  color: const Color(0xFF54F4A7),
                  onTap: () {},
                ),
                const SizedBox(height: 10),
                _ActionButton(
                  icon: Icons.chat_bubble_rounded,
                  color: const Color(0xFF62D9FF),
                  onTap: () {},
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: _MetricCard(
                label: 'Fare',
                value: '\$12.40',
                icon: Icons.payments_rounded,
                accent: const Color(0xFF54F4A7),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _MetricCard(
                label: 'Distance',
                value: '2.8 km',
                icon: Icons.straighten_rounded,
                accent: const Color(0xFF62D9FF),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _MetricCard(
                label: 'ETA',
                value: '6 min',
                icon: Icons.schedule_rounded,
                accent: const Color(0xFFFFC857),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _MetricCard(
                label: 'Ride',
                value: isReached ? 'At pickup' : 'Arriving',
                icon: isReached ? Icons.verified_rounded : Icons.route_rounded,
                accent: const Color(0xFF54F4A7),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isReached
                ? const Color(0xFF54F4A7).withOpacity(0.13)
                : Colors.white.withOpacity(0.055),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isReached
                  ? const Color(0xFF54F4A7).withOpacity(0.25)
                  : Colors.white.withOpacity(0.07),
            ),
          ),
          child: Row(
            children: [
              Icon(
                isReached ? Icons.verified_rounded : Icons.route_rounded,
                color: const Color(0xFF54F4A7),
                size: 21,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  isReached
                      ? 'Driver has reached your pickup location'
                      : 'Fastest route active · Live tracking enabled',
                  style: const TextStyle(
                    color: Color(0xFFD8E7E0),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Icon(
                Icons.keyboard_arrow_right_rounded,
                color: Color(0xFFB8C7C0),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color accent;

  const _MetricCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.055),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withOpacity(0.07)),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: accent.withOpacity(0.16),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: accent, size: 19),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label.toUpperCase(),
                style: const TextStyle(
                  color: Color(0xFF8FA39A),
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.35,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ShimmerRouteSummary extends StatelessWidget {
  const _ShimmerRouteSummary();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.055),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.07)),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ShimmerBar(widthFactor: 0.52, height: 14),
          SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _ShimmerBar(widthFactor: 0.24, height: 10)),
              SizedBox(width: 10),
              Expanded(child: _ShimmerBar(widthFactor: 0.42, height: 10)),
              SizedBox(width: 10),
              Expanded(child: _ShimmerBar(widthFactor: 0.28, height: 10)),
            ],
          ),
        ],
      ),
    );
  }
}

class _ShimmerTile extends StatelessWidget {
  final String label;
  final double valueWidth;

  const _ShimmerTile({required this.label, required this.valueWidth});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.055),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.07)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              color: Color(0xFF8FA39A),
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 10),
          _ShimmerBar(widthFactor: valueWidth, height: 14),
        ],
      ),
    );
  }
}

class _ShimmerBar extends StatelessWidget {
  final double widthFactor;
  final double height;

  const _ShimmerBar({required this.widthFactor, required this.height});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth * widthFactor;

        return Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(height),
            gradient: LinearGradient(
              colors: [
                Colors.white.withOpacity(0.10),
                Colors.white.withOpacity(0.16),
                Colors.white.withOpacity(0.10),
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
        );
      },
    );
  }
}

class _ShimmerCircle extends StatelessWidget {
  final double size;

  const _ShimmerCircle({required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.10),
            Colors.white.withOpacity(0.16),
            Colors.white.withOpacity(0.10),
          ],
        ),
      ),
    );
  }
}

Path buildOrthogonalRoutePath(List<Offset> normalizedPoints, Size size) {
  final points = normalizedPoints
      .map((point) => Offset(point.dx * size.width, point.dy * size.height))
      .toList();

  final path = Path()..moveTo(points.first.dx, points.first.dy);

  for (int i = 1; i < points.length; i++) {
    final previous = points[i - 1];
    final current = points[i];

    path.lineTo(current.dx, previous.dy);
    path.lineTo(current.dx, current.dy);
  }

  return path;
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withOpacity(0.14),
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: color.withOpacity(0.24)),
          ),
          child: Icon(icon, color: color, size: 21),
        ),
      ),
    );
  }
}
