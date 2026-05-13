import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:liquid_swipe/liquid_swipe.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.black,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  runApp(const UIForgeApp());
}

class UIForgeApp extends StatelessWidget {
  const UIForgeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'UIForge AI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
      ),
      home: const OnboardingScreen(),
    );
  }
}

class OnboardingData {
  final String eyebrow;
  final String title;
  final String description;
  final String image;
  final Color primaryColor;
  final Color secondaryColor;
  final Color darkColor;
  final Color glowColor;
  final String number;
  final List<_ChipData> chips;

  const OnboardingData({
    required this.eyebrow,
    required this.title,
    required this.description,
    required this.image,
    required this.primaryColor,
    required this.secondaryColor,
    required this.darkColor,
    required this.glowColor,
    required this.number,
    this.chips = const [],
  });
}

class _ChipData {
  final String label;
  final IconData icon;

  const _ChipData(this.label, this.icon);
}

const List<OnboardingData> _kPages = [
  OnboardingData(
    eyebrow: 'IDEA TO UI',
    title: 'Start With A Simple App Idea',
    description:
        'Describe what you want to build, then explore a clear direction for your first screens, layout flow, and product structure.',
    image: 'assets/images/ai_idea.png',
    primaryColor: Color(0xFF8B5CF6),
    secondaryColor: Color(0xFF22D3EE),
    darkColor: Color(0xFF07060F),
    glowColor: Color(0xFFB794F4),
    number: '01',
    chips: [
      _ChipData('Idea Brief', Icons.lightbulb_outline_rounded),
      _ChipData('Screen Flow', Icons.account_tree_rounded),
      _ChipData('First Draft', Icons.dashboard_rounded),
    ],
  ),
  OnboardingData(
    eyebrow: 'DESIGN SYSTEM',
    title: 'Build A Consistent Visual Style',
    description:
        'Create a clean design direction with matching colors, typography, spacing, and reusable UI components for every screen.',
    image: 'assets/images/color_palette.png',
    primaryColor: Color(0xFF00C2A8),
    secondaryColor: Color(0xFFFFD166),
    darkColor: Color(0xFF031715),
    glowColor: Color(0xFF5EEAD4),
    number: '02',
    chips: [
      _ChipData('Color System', Icons.palette_rounded),
      _ChipData('Typography', Icons.text_fields_rounded),
      _ChipData('Components', Icons.grid_view_rounded),
    ],
  ),
  OnboardingData(
    eyebrow: 'LIVE PREVIEW',
    title: 'Preview Screens Before Building',
    description:
        'Review app screens, dashboard cards, onboarding flows, and interface states before moving into development.',
    image: 'assets/images/mobile_preview.png',
    primaryColor: Color(0xFF38BDF8),
    secondaryColor: Color(0xFF6366F1),
    darkColor: Color(0xFF05101A),
    glowColor: Color(0xFF7DD3FC),
    number: '03',
    chips: [
      _ChipData('Mobile Preview', Icons.phone_iphone_rounded),
      _ChipData('UI States', Icons.layers_rounded),
      _ChipData('Screen Flow', Icons.view_carousel_rounded),
    ],
  ),
  OnboardingData(
    eyebrow: 'FLUTTER READY',
    title: 'Move From Concept To Code Faster',
    description:
        'Use your final design direction as a strong starting point for Flutter layouts, client demos, and polished app screens.',
    image: 'assets/images/flutter_build.png',
    primaryColor: Color(0xFFFF4D8D),
    secondaryColor: Color(0xFFFFB86B),
    darkColor: Color(0xFF13040C),
    glowColor: Color(0xFFFF8AB3),
    number: '04',
    chips: [
      _ChipData('Flutter Layouts', Icons.code_rounded),
      _ChipData('Clean Structure', Icons.account_tree_rounded),
      _ChipData('Client Demo', Icons.rocket_launch_rounded),
    ],
  ),
];

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final LiquidController _liquidController = LiquidController();

  int _currentPage = 0;

  void _skipToLastPage() {
    _liquidController.animateToPage(page: _kPages.length - 1, duration: 700);
  }

  void _showFinishedSheet() {
    HapticFeedback.mediumImpact();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => const _FinishedSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = List.generate(_kPages.length, (index) {
      return OnboardingPage(
        key: ValueKey('page_${index}_$_currentPage'),
        data: _kPages[index],
        pageIndex: index,
        currentPage: _currentPage,
        isLastPage: index == _kPages.length - 1,
        onStartPressed: _showFinishedSheet,
      );
    });

    final topPadding = MediaQuery.of(context).padding.top;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            LiquidSwipe(
              pages: pages,
              liquidController: _liquidController,
              enableLoop: false,
              fullTransitionValue: 620,
              waveType: WaveType.liquidReveal,
              enableSideReveal: true,
              positionSlideIcon: 0.58,
              slideIconWidget: _SwipeHandle(
                color: _kPages[_currentPage].glowColor,
              ),
              onPageChangeCallback: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
            ),

            Positioned(
              top: topPadding + 14,
              left: 22,
              child: BrandMark(
                text: 'UIForge AI',
                color: _kPages[_currentPage].glowColor,
              ),
            ),

            Positioned(
              top: topPadding + 12,
              right: 18,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, animation) {
                  return FadeTransition(opacity: animation, child: child);
                },
                child: _currentPage == _kPages.length - 1
                    ? const SizedBox.shrink(key: ValueKey('hidden_skip'))
                    : _SkipButton(
                        key: const ValueKey('visible_skip'),
                        onTap: _skipToLastPage,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SwipeHandle extends StatelessWidget {
  final Color color;

  const _SwipeHandle({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 46,
      width: 46,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.18),
        shape: BoxShape.circle,
        border: Border.all(color: color.withOpacity(0.55), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.35),
            blurRadius: 18,
            spreadRadius: 2,
          ),
        ],
      ),
      child: const Icon(
        Icons.chevron_left_rounded,
        color: Colors.white,
        size: 30,
      ),
    );
  }
}

class _SkipButton extends StatelessWidget {
  final VoidCallback onTap;

  const _SkipButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(100),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.10),
              borderRadius: BorderRadius.circular(100),
              border: Border.all(color: Colors.white.withOpacity(0.22)),
            ),
            child: Text(
              'Skip',
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.2,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class BrandMark extends StatelessWidget {
  final String text;
  final Color color;

  const BrandMark({super.key, required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: 36,
          width: 36,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              colors: [color, Colors.white.withOpacity(0.9)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.55),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: const Icon(
            Icons.auto_awesome_rounded,
            color: Color(0xFF09090F),
            size: 18,
          ),
        ),
        const SizedBox(width: 10),
        Text(
          text,
          style: GoogleFonts.spaceGrotesk(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
      ],
    );
  }
}

class OnboardingPage extends StatelessWidget {
  final OnboardingData data;
  final int pageIndex;
  final int currentPage;
  final bool isLastPage;
  final VoidCallback onStartPressed;

  const OnboardingPage({
    super.key,
    required this.data,
    required this.pageIndex,
    required this.currentPage,
    required this.isLastPage,
    required this.onStartPressed,
  });

  bool get _isActive => pageIndex == currentPage;

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Container(
      color: data.darkColor,
      child: Stack(
        children: [
          PremiumBackground(data: data),

          Positioned(
            top: topPadding + 78,
            left: 0,
            right: 0,
            bottom: isLastPage ? bottomPadding + 150 : bottomPadding + 58,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TopMeta(data: data, isActive: _isActive),

                  const SizedBox(height: 14),

                  Expanded(
                    child: Center(
                      child: AnimatedHeroImage(
                        image: data.image,
                        glowColor: data.glowColor,
                        primaryColor: data.primaryColor,
                        secondaryColor: data.secondaryColor,
                        chips: data.chips,
                        isActive: _isActive,
                      ),
                    ),
                  ),

                  const SizedBox(height: 22),

                  AnimatedContentBlock(
                    isActive: _isActive,
                    delay: 80,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 62),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ShaderMask(
                            blendMode: BlendMode.srcIn,
                            shaderCallback: (bounds) {
                              return LinearGradient(
                                colors: [Colors.white, data.glowColor],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ).createShader(bounds);
                            },
                            child: Text(
                              data.title,
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 34,
                                height: 1.06,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: -1.2,
                              ),
                            ),
                          ),

                          const SizedBox(height: 22),

                          Text(
                            data.description,
                            style: GoogleFonts.inter(
                              fontSize: 15,
                              height: 1.62,
                              fontWeight: FontWeight.w400,
                              color: Colors.white.withOpacity(0.70),
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

          if (isLastPage)
            Positioned(
              left: 22,
              right: 22,
              bottom: bottomPadding + 72,
              child: AnimatedContentBlock(
                isActive: _isActive,
                delay: 160,
                child: PremiumButton(
                  text: 'Start Building',
                  onTap: onStartPressed,
                  primaryColor: data.primaryColor,
                  secondaryColor: data.secondaryColor,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class TopMeta extends StatelessWidget {
  final OnboardingData data;
  final bool isActive;

  const TopMeta({super.key, required this.data, required this.isActive});

  @override
  Widget build(BuildContext context) {
    return AnimatedContentBlock(
      isActive: isActive,
      delay: 0,
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
              child: Container(
                height: 38,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(color: Colors.white.withOpacity(0.18)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      height: 8,
                      width: 8,
                      decoration: BoxDecoration(
                        color: data.glowColor,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: data.glowColor.withOpacity(0.9),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 9),
                    Text(
                      data.eyebrow,
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const Spacer(),

          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                data.number,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 38,
                  fontWeight: FontWeight.w800,
                  color: Colors.white.withOpacity(0.88),
                  letterSpacing: -1.5,
                  shadows: [
                    Shadow(
                      color: data.glowColor.withOpacity(0.45),
                      blurRadius: 14,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 2),
              Container(
                height: 3,
                width: 30,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100),
                  gradient: LinearGradient(
                    colors: [data.primaryColor, data.secondaryColor],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: data.glowColor.withOpacity(0.55),
                      blurRadius: 8,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class PremiumBackground extends StatelessWidget {
  final OnboardingData data;

  const PremiumBackground({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  data.darkColor,
                  Color.lerp(data.darkColor, data.primaryColor, 0.18)!,
                  data.darkColor,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
          ),
        ),

        Positioned(
          top: -140,
          right: -80,
          child: _BlurGlow(
            size: 340,
            color: data.primaryColor.withOpacity(0.32),
          ),
        ),

        Positioned(
          bottom: 80,
          left: -110,
          child: _BlurGlow(
            size: 300,
            color: data.secondaryColor.withOpacity(0.22),
          ),
        ),

        Positioned(
          bottom: -100,
          right: -50,
          child: _BlurGlow(size: 270, color: data.glowColor.withOpacity(0.16)),
        ),

        Positioned(
          top: 200,
          left: 60,
          child: _BlurGlow(
            size: 220,
            color: data.primaryColor.withOpacity(0.13),
          ),
        ),

        Positioned.fill(
          child: CustomPaint(
            painter: GridPainter(lineColor: Colors.white.withOpacity(0.032)),
          ),
        ),

        Positioned(
          top: 0,
          left: -60,
          child: Transform.rotate(
            angle: -0.65,
            child: Container(
              height: 600,
              width: 60,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    data.glowColor.withOpacity(0.06),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class AnimatedHeroImage extends StatefulWidget {
  final String image;
  final Color glowColor;
  final Color primaryColor;
  final Color secondaryColor;
  final List<_ChipData> chips;
  final bool isActive;

  const AnimatedHeroImage({
    super.key,
    required this.image,
    required this.glowColor,
    required this.primaryColor,
    required this.secondaryColor,
    required this.chips,
    required this.isActive,
  });

  @override
  State<AnimatedHeroImage> createState() => _AnimatedHeroImageState();
}

class _AnimatedHeroImageState extends State<AnimatedHeroImage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _floatController;

  @override
  void initState() {
    super.initState();

    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      key: ValueKey('${widget.image}_${widget.isActive}'),
      tween: Tween<double>(
        begin: widget.isActive ? 0 : 1,
        end: widget.isActive ? 1 : 0,
      ),
      duration: const Duration(milliseconds: 820),
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        return Opacity(
          opacity: value.clamp(0.0, 1.0),
          child: Transform.translate(
            offset: Offset(0, (1 - value) * 42),
            child: Transform.scale(scale: 0.84 + value * 0.16, child: child),
          ),
        );
      },
      child: AnimatedBuilder(
        animation: _floatController,
        builder: (context, child) {
          final animationValue = _floatController.value;
          final floatY = -10 * math.sin(animationValue * math.pi);
          final rotationZ = 0.016 * math.sin(animationValue * math.pi * 2);

          return Transform.translate(
            offset: Offset(0, floatY),
            child: Transform.rotate(angle: rotationZ, child: child),
          );
        },
        child: SizedBox(
          height: 360,
          width: double.infinity,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                height: 290,
                width: 290,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      widget.glowColor.withOpacity(0.55),
                      widget.glowColor.withOpacity(0.18),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.5, 1.0],
                  ),
                ),
              ),

              Container(
                height: 308,
                width: 308,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: widget.glowColor.withOpacity(0.18),
                    width: 1,
                  ),
                ),
              ),

              Container(
                height: 340,
                width: 340,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: widget.glowColor.withOpacity(0.08),
                    width: 1,
                  ),
                ),
              ),

              Container(
                height: 300,
                width: 300,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.09),
                  borderRadius: BorderRadius.circular(48),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.16),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: widget.glowColor.withOpacity(0.32),
                      blurRadius: 80,
                      spreadRadius: 8,
                      offset: const Offset(0, 30),
                    ),
                    BoxShadow(
                      color: Colors.black.withOpacity(0.35),
                      blurRadius: 50,
                      offset: const Offset(0, 20),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(48),
                  child: Image.asset(
                    widget.image,
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) {
                      return Center(
                        child: Icon(
                          Icons.image_outlined,
                          color: widget.glowColor.withOpacity(0.85),
                          size: 90,
                        ),
                      );
                    },
                  ),
                ),
              ),

              if (widget.chips.isNotEmpty) ...[
                Positioned(
                  top: 18,
                  right: 14,
                  child: FloatingChip(
                    label: widget.chips[0].label,
                    icon: widget.chips[0].icon,
                    color: widget.secondaryColor,
                    delay: 0,
                  ),
                ),
                Positioned(
                  bottom: 30,
                  left: 10,
                  child: FloatingChip(
                    label: widget.chips[1].label,
                    icon: widget.chips[1].icon,
                    color: widget.primaryColor,
                    delay: 220,
                  ),
                ),
                if (widget.chips.length > 2)
                  Positioned(
                    top: 90,
                    left: 0,
                    child: FloatingChip(
                      label: widget.chips[2].label,
                      icon: widget.chips[2].icon,
                      color: widget.glowColor,
                      delay: 440,
                    ),
                  ),
              ],

              Positioned(
                top: 36,
                left: 42,
                child: _AccentDot(color: widget.primaryColor),
              ),

              Positioned(
                bottom: 50,
                right: 36,
                child: _AccentDot(color: widget.secondaryColor),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FloatingChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final int delay;

  const FloatingChip({
    super.key,
    required this.label,
    required this.icon,
    required this.color,
    required this.delay,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 700 + delay),
      curve: Curves.easeOutBack,
      builder: (_, value, child) {
        return Opacity(
          opacity: value.clamp(0.0, 1.0),
          child: Transform.scale(scale: value, child: child),
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(100),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.18),
              borderRadius: BorderRadius.circular(100),
              border: Border.all(color: color.withOpacity(0.4), width: 1),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.2),
                  blurRadius: 12,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: color, size: 13),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Colors.white.withOpacity(0.9),
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AnimatedContentBlock extends StatelessWidget {
  final bool isActive;
  final Widget child;
  final int delay;

  const AnimatedContentBlock({
    super.key,
    required this.isActive,
    required this.child,
    this.delay = 0,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      key: ValueKey('$isActive$delay'),
      tween: Tween<double>(begin: isActive ? 0 : 1, end: isActive ? 1 : 0),
      duration: Duration(milliseconds: 680 + delay),
      curve: Curves.easeOutCubic,
      builder: (_, value, child) {
        return Opacity(
          opacity: value.clamp(0.0, 1.0),
          child: Transform.translate(
            offset: Offset(0, (1 - value) * 28),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}

class PremiumButton extends StatefulWidget {
  final String text;
  final VoidCallback onTap;
  final Color primaryColor;
  final Color secondaryColor;

  const PremiumButton({
    super.key,
    required this.text,
    required this.onTap,
    required this.primaryColor,
    required this.secondaryColor,
  });

  @override
  State<PremiumButton> createState() => _PremiumButtonState();
}

class _PremiumButtonState extends State<PremiumButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        setState(() {
          _pressed = true;
        });
      },
      onTapCancel: () {
        setState(() {
          _pressed = false;
        });
      },
      onTapUp: (_) {
        setState(() {
          _pressed = false;
        });

        HapticFeedback.lightImpact();
        widget.onTap();
      },
      child: AnimatedScale(
        scale: _pressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 130),
        curve: Curves.easeOut,
        child: Container(
          height: 58,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            gradient: LinearGradient(
              colors: [widget.primaryColor, widget.secondaryColor],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            boxShadow: [
              BoxShadow(
                color: widget.primaryColor.withOpacity(0.45),
                blurRadius: 26,
                offset: const Offset(0, 14),
                spreadRadius: 1,
              ),
            ],
          ),
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.rocket_launch_rounded,
                  color: Colors.white,
                  size: 17,
                ),
                const SizedBox(width: 8),
                Text(
                  widget.text,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: -0.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FinishedSheet extends StatelessWidget {
  const _FinishedSheet();

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0D0D14),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(36)),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      padding: EdgeInsets.fromLTRB(24, 28, 24, 28 + bottomPadding),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 4,
            width: 42,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.18),
              borderRadius: BorderRadius.circular(100),
            ),
          ),

          const SizedBox(height: 28),

          Container(
            height: 64,
            width: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Color(0xFF8B5CF6), Color(0xFF22D3EE)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF8B5CF6).withOpacity(0.5),
                  blurRadius: 30,
                  offset: const Offset(0, 12),
                  spreadRadius: 2,
                ),
              ],
            ),
            child: const Icon(
              Icons.auto_awesome_rounded,
              color: Colors.white,
              size: 26,
            ),
          ),

          const SizedBox(height: 20),

          Text(
            'You\'re Ready to Build',
            textAlign: TextAlign.center,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -0.9,
            ),
          ),

          const SizedBox(height: 10),

          Text(
            'Your app idea now has a clear visual direction, screen flow, and Flutter-ready starting point.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 14.5,
              height: 1.65,
              color: Colors.white.withOpacity(0.62),
            ),
          ),

          const SizedBox(height: 28),

          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              height: 58,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: const LinearGradient(
                  colors: [Color(0xFF8B5CF6), Color(0xFF22D3EE)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF8B5CF6).withOpacity(0.42),
                    blurRadius: 24,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.rocket_launch_rounded,
                      color: Colors.white,
                      size: 17,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Launch UIForge AI',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 14),

          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              height: 52,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.08),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.white.withOpacity(0.12)),
              ),
              child: Center(
                child: Text(
                  'Back to Preview',
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AccentDot extends StatelessWidget {
  final Color color;

  const _AccentDot({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 10,
      width: 10,
      decoration: BoxDecoration(
        color: color.withOpacity(0.8),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.7),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
    );
  }
}

class _BlurGlow extends StatelessWidget {
  final double size;
  final Color color;

  const _BlurGlow({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: size,
      width: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

class GridPainter extends CustomPainter {
  final Color lineColor;

  const GridPainter({required this.lineColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = lineColor
      ..strokeWidth = 0.8;

    const gap = 38.0;

    for (double x = 0; x < size.width; x += gap) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    for (double y = 0; y < size.height; y += gap) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(GridPainter oldDelegate) {
    return oldDelegate.lineColor != lineColor;
  }
}
