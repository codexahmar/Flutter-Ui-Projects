import 'dart:math';

import 'package:flutter/material.dart';

import 'app_theme.dart';
import 'food_item.dart';

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

  final List<Offset> routePoints = const [
    Offset(0.16, 0.38),
    Offset(0.30, 0.31),
    Offset(0.46, 0.39),
    Offset(0.56, 0.50),
    Offset(0.70, 0.45),
    Offset(0.84, 0.56),
  ];

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 18),
    )..forward();
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
    if (isSearching) return 'Finding rider';
    if (isAccepted) return 'Order accepted';
    if (isPreparing) return 'Preparing meal';
    if (isRiderAssigned) return 'Rider assigned';
    if (isMoving) return 'Out for delivery';
    return 'Delivered';
  }

  String get subtitle {
    if (isSearching) return 'Checking fastest route';
    if (isAccepted) return '${widget.food.restaurant} confirmed';
    if (isPreparing) return 'Fresh preparation in progress';
    if (isRiderAssigned) return 'Hamza picked up your order';
    if (isMoving) return '$etaMinutes min away';
    return 'Your order has arrived';
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
        previous.dy - 18,
      );

      final controlTwo = Offset(
        previous.dx + (current.dx - previous.dx) * 0.58,
        current.dy + 18,
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
      backgroundColor: AppTheme.bg,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final size = Size(constraints.maxWidth, constraints.maxHeight);
          final bottomSheetHeight = min(198.0, size.height * 0.23);

          return AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              final scooterPosition = _scooterPosition(size);

              return Stack(
                clipBehavior: Clip.none,
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

                  Positioned(
                    top: MediaQuery.of(context).padding.top + 58,
                    left: 22,
                    right: 22,
                    child: _FloatingStatusChip(
                      title: title,
                      subtitle: subtitle,
                      etaMinutes: etaMinutes,
                      isDelivered: isDelivered,
                      isSearching: isSearching,
                    ),
                  ),

                  if (isSearching)
                    Positioned(
                      top: size.height * 0.36,
                      left: 0,
                      right: 0,
                      child: const Center(child: _RiderSearchPulse()),
                    ),

                  Positioned(
                    left: size.width * routePoints.first.dx - 22,
                    top: size.height * routePoints.first.dy - 24,
                    child: const _SimpleMapMarker(
                      icon: Icons.restaurant_rounded,
                      label: 'Restaurant',
                      color: AppTheme.orange,
                    ),
                  ),

                  Positioned(
                    left: size.width * routePoints.last.dx - 22,
                    top: size.height * routePoints.last.dy - 24,
                    child: const _SimpleMapMarker(
                      icon: Icons.home_rounded,
                      label: 'Home',
                      color: AppTheme.green,
                    ),
                  ),

                  if (!isSearching &&
                      !isAccepted &&
                      !isPreparing &&
                      !isDelivered)
                    Positioned(
                      left: scooterPosition.dx - 32,
                      top: scooterPosition.dy - 32,
                      child: const _ScooterMarker(),
                    ),

                  Positioned(
                    left: 16,
                    right: 16,
                    bottom: 16,
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
        previous.dy - 18,
      );

      final controlTwo = Offset(
        previous.dx + (current.dx - previous.dx) * 0.58,
        current.dy + 18,
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
            Color(0xFF05090F),
            Color(0xFF071712),
            Color(0xFF0A1018),
            Color(0xFF05080D),
          ],
        ).createShader(rect),
    );

    canvas.drawCircle(
      Offset(size.width * 0.82, size.height * 0.16),
      300,
      Paint()
        ..shader =
            RadialGradient(
              colors: [AppTheme.green.withOpacity(0.24), Colors.transparent],
            ).createShader(
              Rect.fromCircle(
                center: Offset(size.width * 0.82, size.height * 0.16),
                radius: 300,
              ),
            ),
    );

    canvas.drawCircle(
      Offset(size.width * 0.20, size.height * 0.40),
      270,
      Paint()
        ..shader =
            RadialGradient(
              colors: [AppTheme.orange.withOpacity(0.18), Colors.transparent],
            ).createShader(
              Rect.fromCircle(
                center: Offset(size.width * 0.20, size.height * 0.40),
                radius: 270,
              ),
            ),
    );

    canvas.drawCircle(
      Offset(size.width * 0.67, size.height * 0.58),
      250,
      Paint()
        ..shader =
            RadialGradient(
              colors: [AppTheme.cyan.withOpacity(0.16), Colors.transparent],
            ).createShader(
              Rect.fromCircle(
                center: Offset(size.width * 0.67, size.height * 0.58),
                radius: 250,
              ),
            ),
    );
  }

  void _drawRoads(Canvas canvas, Size size) {
    final roadGlow = Paint()
      ..color = Colors.white.withOpacity(0.06)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 62
      ..strokeCap = StrokeCap.round;

    final roadBase = Paint()
      ..color = Colors.white.withOpacity(0.14)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 28
      ..strokeCap = StrokeCap.round;

    final roadInner = Paint()
      ..color = const Color(0xFF101B21).withOpacity(0.95)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 17
      ..strokeCap = StrokeCap.round;

    final roadA = Path()
      ..moveTo(-50, size.height * 0.31)
      ..cubicTo(
        size.width * 0.20,
        size.height * 0.20,
        size.width * 0.52,
        size.height * 0.43,
        size.width + 50,
        size.height * 0.29,
      );

    final roadB = Path()
      ..moveTo(size.width * 0.11, -50)
      ..cubicTo(
        size.width * 0.14,
        size.height * 0.26,
        size.width * 0.32,
        size.height * 0.56,
        size.width * 0.18,
        size.height + 50,
      );

    final roadC = Path()
      ..moveTo(size.width + 50, size.height * 0.64)
      ..cubicTo(
        size.width * 0.72,
        size.height * 0.50,
        size.width * 0.46,
        size.height * 0.69,
        -50,
        size.height * 0.71,
      );

    final roadD = Path()
      ..moveTo(-50, size.height * 0.80)
      ..cubicTo(
        size.width * 0.25,
        size.height * 0.72,
        size.width * 0.58,
        size.height * 0.76,
        size.width + 50,
        size.height * 0.68,
      );

    for (final road in [roadA, roadB, roadC, roadD]) {
      canvas.drawPath(road, roadGlow);
      canvas.drawPath(road, roadBase);
      canvas.drawPath(road, roadInner);
    }
  }

  void _drawBlocks(Canvas canvas, Size size) {
    final fill = Paint()..color = Colors.white.withOpacity(0.075);

    final border = Paint()
      ..color = Colors.white.withOpacity(0.11)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final blocks = [
      Rect.fromLTWH(size.width * 0.06, size.height * 0.12, 86, 58),
      Rect.fromLTWH(size.width * 0.30, size.height * 0.13, 120, 72),
      Rect.fromLTWH(size.width * 0.62, size.height * 0.12, 112, 74),
      Rect.fromLTWH(size.width * 0.08, size.height * 0.50, 126, 80),
      Rect.fromLTWH(size.width * 0.55, size.height * 0.35, 132, 96),
      Rect.fromLTWH(size.width * 0.12, size.height * 0.68, 122, 68),
      Rect.fromLTWH(size.width * 0.61, size.height * 0.67, 118, 68),
    ];

    for (final rect in blocks) {
      final rRect = RRect.fromRectAndRadius(rect, const Radius.circular(22));

      canvas.drawRRect(rRect, fill);
      canvas.drawRRect(rRect, border);
    }
  }

  void _drawLabels(Canvas canvas, Size size) {
    _drawLabel(
      canvas,
      'Food District',
      Offset(size.width * 0.18, size.height * 0.27),
    );

    _drawLabel(
      canvas,
      'Central Route',
      Offset(size.width * 0.54, size.height * 0.36),
    );

    _drawLabel(
      canvas,
      'Home Zone',
      Offset(size.width * 0.64, size.height * 0.62),
    );
  }

  void _drawLabel(Canvas canvas, String text, Offset offset) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: Colors.white.withOpacity(0.24),
          fontSize: 12,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.2,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    painter.paint(canvas, offset);
  }

  void _drawDots(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withOpacity(0.12);

    for (double x = 22; x < size.width; x += 40) {
      for (double y = 90; y < size.height - 55; y += 40) {
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
          ..color = AppTheme.green.withOpacity((1 - progress) * 0.14)
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

    canvas.drawPath(
      path,
      Paint()
        ..color = AppTheme.green.withOpacity(0.62)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 44
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 28),
    );

    canvas.drawPath(
      path,
      Paint()
        ..color = Colors.white.withOpacity(0.82)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 17
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    canvas.drawPath(
      path,
      Paint()
        ..color = const Color(0xFF06100E)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 9.5
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    canvas.drawPath(
      path,
      Paint()
        ..color = AppTheme.green.withOpacity(1)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5.8
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    if (activeLength > 0) {
      canvas.drawPath(
        activePath,
        Paint()
          ..color = AppTheme.cyan.withOpacity(0.58)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 32
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18),
      );

      canvas.drawPath(
        activePath,
        Paint()
          ..shader = const LinearGradient(
            colors: [AppTheme.orange, AppTheme.green, AppTheme.cyan],
          ).createShader(Offset.zero & size)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 11.5
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round,
      );

      final dashPaint = Paint()
        ..color = Colors.white.withOpacity(0.95)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
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

class _FloatingStatusChip extends StatelessWidget {
  final String title;
  final String subtitle;
  final int etaMinutes;
  final bool isDelivered;
  final bool isSearching;

  const _FloatingStatusChip({
    required this.title,
    required this.subtitle,
    required this.etaMinutes,
    required this.isDelivered,
    required this.isSearching,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 255),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xF0061115),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withOpacity(0.10)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.24),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 39,
              height: 39,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                gradient: const LinearGradient(
                  colors: [AppTheme.orange, AppTheme.green],
                ),
              ),
              child: Icon(
                isSearching
                    ? Icons.search_rounded
                    : Icons.delivery_dining_rounded,
                color: AppTheme.bg,
                size: 21,
              ),
            ),
            const SizedBox(width: 11),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 240),
                    child: Text(
                      title,
                      key: ValueKey(title),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15.5,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ),
                  const SizedBox(height: 2),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 240),
                    child: Text(
                      subtitle,
                      key: ValueKey(subtitle),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppTheme.muted,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
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
          size: const Size(170, 170),
          painter: _RiderPulsePainter(controller.value),
          child: const SizedBox(
            width: 170,
            height: 170,
            child: Center(
              child: Icon(
                Icons.delivery_dining_rounded,
                color: AppTheme.green,
                size: 30,
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
        30 + delayed * 75,
        Paint()
          ..color = AppTheme.green.withOpacity((1 - delayed) * 0.20)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.2,
      );
    }

    canvas.drawCircle(
      center,
      36,
      Paint()
        ..color = AppTheme.green.withOpacity(0.14)
        ..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(covariant _RiderPulsePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

class _SimpleMapMarker extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _SimpleMapMarker({
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
            color: color.withOpacity(0.18),
            border: Border.all(color: color.withOpacity(0.86), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.38),
                blurRadius: 22,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 5),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xF0061115),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: Colors.white.withOpacity(0.10)),
          ),
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 9.5,
              fontWeight: FontWeight.w800,
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
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppTheme.green.withOpacity(0.38),
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
      28,
      Paint()
        ..color = AppTheme.green.withOpacity(0.12)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12),
    );

    final bodyPaint = Paint()
      ..shader = const LinearGradient(
        colors: [AppTheme.orange, AppTheme.green],
      ).createShader(Offset.zero & size);

    final darkPaint = Paint()..color = AppTheme.bg.withOpacity(0.86);
    final whitePaint = Paint()..color = Colors.white.withOpacity(0.94);

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(center.dx + 3, center.dy),
          width: 40,
          height: 23,
        ),
        const Radius.circular(14),
      ),
      bodyPaint,
    );

    canvas.drawCircle(Offset(center.dx - 13, center.dy + 15), 7.5, darkPaint);
    canvas.drawCircle(Offset(center.dx + 17, center.dy + 15), 7.5, darkPaint);

    canvas.drawCircle(Offset(center.dx - 13, center.dy + 15), 3, whitePaint);
    canvas.drawCircle(Offset(center.dx + 17, center.dy + 15), 3, whitePaint);

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(center.dx + 4, center.dy - 14, 17, 10),
        const Radius.circular(6),
      ),
      Paint()..color = AppTheme.bg.withOpacity(0.74),
    );

    final handlePaint = Paint()
      ..color = Colors.white.withOpacity(0.9)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      Offset(center.dx + 17, center.dy - 8),
      Offset(center.dx + 28, center.dy - 17),
      handlePaint,
    );

    canvas.drawCircle(Offset(center.dx + 30, center.dy - 18), 2.4, whitePaint);
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
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
      decoration: BoxDecoration(
        color: const Color(0xF207100F),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withOpacity(0.09)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.34),
            blurRadius: 20,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.16),
              borderRadius: BorderRadius.circular(100),
            ),
          ),

          const SizedBox(height: 9),

          Row(
            children: [
              Expanded(
                child: Text(
                  isDelivered ? 'Delivered successfully' : 'Out for delivery',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
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

          const SizedBox(height: 9),

          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.network(
                  'https://images.unsplash.com/photo-1599566150163-29194dcaad36?q=80&w=400&auto=format&fit=crop',
                  width: 38,
                  height: 38,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 10),
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
                        fontSize: 14,
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
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 7),
              const _CircleAction(
                icon: Icons.call_rounded,
                color: AppTheme.green,
              ),
              const SizedBox(width: 6),
              const _CircleAction(
                icon: Icons.chat_rounded,
                color: AppTheme.cyan,
              ),
            ],
          ),

          const SizedBox(height: 9),

          _ConnectedStepIndicator(activeStep: activeStep),
        ],
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
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(0.06),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Icon(icon, color: color, size: 16),
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
                      width: isCurrent ? 30 : 27,
                      height: isCurrent ? 30 : 27,
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
                                  blurRadius: 14,
                                  spreadRadius: 1,
                                ),
                              ]
                            : [],
                      ),
                      child: Icon(
                        steps[index].icon,
                        size: 14,
                        color: isActive
                            ? AppTheme.bg
                            : Colors.white.withOpacity(0.36),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      steps[index].label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: isActive ? Colors.white : AppTheme.muted,
                        fontSize: 9.5,
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
                    margin: const EdgeInsets.only(bottom: 19),
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
