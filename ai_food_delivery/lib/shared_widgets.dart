import 'dart:ui';

import 'package:flutter/material.dart';

import 'app_theme.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final BorderRadius borderRadius;
  final Color? color;
  final Color? borderColor;

  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.borderRadius = const BorderRadius.all(Radius.circular(28)),
    this.color,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return PremiumSurface(
      padding: padding,
      borderRadius: borderRadius,
      color: color,
      borderColor: borderColor,
      child: child,
    );
  }
}

class PremiumSurface extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final BorderRadius borderRadius;
  final Color? color;
  final Color? borderColor;

  const PremiumSurface({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.borderRadius = const BorderRadius.all(Radius.circular(28)),
    this.color,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: color ?? AppTheme.glass,
            borderRadius: borderRadius,
            border: Border.all(
              color: borderColor ?? Colors.white.withOpacity(0.09),
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}

class PremiumNetworkImage extends StatelessWidget {
  final String imageUrl;
  final String heroTag;
  final double? width;
  final double? height;
  final BorderRadius borderRadius;
  final BoxFit fit;
  final List<Color> overlayColors;
  final Alignment overlayBegin;
  final Alignment overlayEnd;
  final Widget? placeholderChild;

  const PremiumNetworkImage({
    super.key,
    required this.imageUrl,
    required this.heroTag,
    this.width,
    this.height,
    this.borderRadius = const BorderRadius.all(Radius.circular(28)),
    this.fit = BoxFit.cover,
    this.overlayColors = const [Colors.transparent, Color(0xAA000000)],
    this.overlayBegin = Alignment.topCenter,
    this.overlayEnd = Alignment.bottomCenter,
    this.placeholderChild,
  });

  @override
  Widget build(BuildContext context) {
    final image = ClipRRect(
      borderRadius: borderRadius,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            imageUrl,
            fit: fit,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF101722), Color(0xFF0A1018)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: placeholderChild ?? const Center(child: _ImageLoader()),
              );
            },
            errorBuilder: (context, error, stackTrace) {
              return Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF101722), Color(0xFF0A1018)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: placeholderChild ?? const Center(child: _BrokenImage()),
              );
            },
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: overlayBegin,
                end: overlayEnd,
                colors: overlayColors,
              ),
            ),
          ),
        ],
      ),
    );

    if (width == null && height == null) {
      return Hero(tag: heroTag, child: image);
    }

    return Hero(
      tag: heroTag,
      child: SizedBox(width: width, height: height, child: image),
    );
  }
}

class PremiumSectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  const PremiumSectionHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.55,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  color: AppTheme.muted,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w500,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
        if (actionLabel != null) ...[
          const SizedBox(width: 12),
          TextButton(onPressed: onAction, child: Text(actionLabel!)),
        ],
      ],
    );
  }
}

class CategoryPill extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final Color accentColor;
  final VoidCallback onTap;

  const CategoryPill({
    super.key,
    required this.label,
    required this.icon,
    required this.selected,
    required this.accentColor,
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
          duration: const Duration(milliseconds: 240),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: selected ? accentColor : Colors.white.withOpacity(0.055),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: selected ? accentColor : Colors.white.withOpacity(0.08),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: selected ? AppTheme.bg : accentColor),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: selected ? AppTheme.bg : Colors.white,
                  fontSize: 12.5,
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

class PremiumSearchBar extends StatelessWidget {
  final String hintText;
  final VoidCallback? onTap;

  const PremiumSearchBar({super.key, required this.hintText, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.065),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withOpacity(0.08)),
          ),
          child: Row(
            children: [
              const Icon(Icons.search_rounded, color: AppTheme.muted),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  hintText,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppTheme.muted,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppTheme.orange, AppTheme.green],
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.tune_rounded,
                  color: AppTheme.bg,
                  size: 18,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class QuantityStepper extends StatelessWidget {
  final int value;
  final VoidCallback onAdd;
  final VoidCallback onRemove;

  const QuantityStepper({
    super.key,
    required this.value,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _StepperButton(icon: Icons.remove_rounded, onTap: onRemove),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Text(
              value.toString(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          _StepperButton(icon: Icons.add_rounded, onTap: onAdd),
        ],
      ),
    );
  }
}

class PriceLine extends StatelessWidget {
  final String label;
  final String value;
  final bool emphasize;

  const PriceLine({
    super.key,
    required this.label,
    required this.value,
    this.emphasize = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: emphasize ? Colors.white : AppTheme.muted,
              fontSize: emphasize ? 15 : 13,
              fontWeight: emphasize ? FontWeight.w800 : FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          value,
          style: TextStyle(
            color: emphasize ? AppTheme.green : Colors.white,
            fontSize: emphasize ? 16 : 13,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

class PrimaryActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback? onTap;
  final bool busy;

  const PrimaryActionButton({
    super.key,
    required this.label,
    required this.icon,
    this.onTap,
    this.busy = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(28),
      child: InkWell(
        onTap: busy ? null : onTap,
        borderRadius: BorderRadius.circular(28),
        child: Ink(
          height: 64,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            gradient: const LinearGradient(
              colors: [AppTheme.orange, AppTheme.green],
            ),
            boxShadow: [
              BoxShadow(
                color: AppTheme.green.withOpacity(0.28),
                blurRadius: 26,
                offset: const Offset(0, 14),
              ),
            ],
          ),
          child: Center(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              child: busy
                  ? const SizedBox(
                      key: ValueKey('busy'),
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.4,
                        valueColor: AlwaysStoppedAnimation<Color>(AppTheme.bg),
                      ),
                    )
                  : Row(
                      key: const ValueKey('ready'),
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(icon, color: AppTheme.bg),
                        const SizedBox(width: 10),
                        Text(
                          label,
                          style: const TextStyle(
                            color: AppTheme.bg,
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.2,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

class TimelineStepCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool active;
  final bool completed;

  const TimelineStepCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.active,
    required this.completed,
  });

  @override
  Widget build(BuildContext context) {
    final color = completed || active ? AppTheme.green : AppTheme.mutedAlt;

    return Row(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 260),
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withOpacity(0.14),
            border: Border.all(color: color.withOpacity(0.7)),
          ),
          child: Icon(icon, color: color, size: 17),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: completed || active ? Colors.white : AppTheme.muted,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppTheme.muted,
                  fontSize: 12,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StepperButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _StepperButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withOpacity(0.08),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: SizedBox(
          width: 32,
          height: 32,
          child: Icon(icon, color: Colors.white, size: 18),
        ),
      ),
    );
  }
}

class _ImageLoader extends StatelessWidget {
  const _ImageLoader();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(strokeWidth: 2.2),
      ),
    );
  }
}

class _BrokenImage extends StatelessWidget {
  const _BrokenImage();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Icon(Icons.broken_image_rounded, color: AppTheme.muted, size: 30),
    );
  }
}
