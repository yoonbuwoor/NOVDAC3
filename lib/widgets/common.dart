import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../controllers/app_controller.dart';
import '../core/theme.dart';

class AmbientBackground extends StatelessWidget {
  const AmbientBackground({
    super.key,
    required this.child,
    this.padding = EdgeInsets.zero,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Stack(
      children: [
        Positioned.fill(
          child: IgnorePointer(
            child: CustomPaint(
              painter: _AmbientPainter(dark: dark),
            ),
          ),
        ),
        Padding(padding: padding, child: child),
      ],
    );
  }
}

class _AmbientPainter extends CustomPainter {
  const _AmbientPainter({required this.dark});

  final bool dark;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final cyanCenter = Offset(size.width * .78, size.height * .10);
    final violetCenter = Offset(size.width * .10, size.height * .47);
    final blueCenter = Offset(size.width * .90, size.height * .78);

    paint.shader = RadialGradient(
      colors: [
        cyan.withOpacity(dark ? .11 : .08),
        cyan.withOpacity(0),
      ],
    ).createShader(Rect.fromCircle(center: cyanCenter, radius: size.width * .48));
    canvas.drawCircle(cyanCenter, size.width * .48, paint);

    paint.shader = RadialGradient(
      colors: [
        violet.withOpacity(dark ? .08 : .055),
        violet.withOpacity(0),
      ],
    ).createShader(Rect.fromCircle(center: violetCenter, radius: size.width * .38));
    canvas.drawCircle(violetCenter, size.width * .38, paint);

    paint.shader = RadialGradient(
      colors: [
        electricBlue.withOpacity(dark ? .07 : .045),
        electricBlue.withOpacity(0),
      ],
    ).createShader(Rect.fromCircle(center: blueCenter, radius: size.width * .42));
    canvas.drawCircle(blueCenter, size.width * .42, paint);

    final grid = Paint()
      ..color = (dark ? Colors.white : ink).withOpacity(dark ? .018 : .022)
      ..strokeWidth = 1;
    const step = 44.0;
    for (double x = 0; x <= size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), grid);
    }
    for (double y = 0; y <= size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }
  }

  @override
  bool shouldRepaint(covariant _AmbientPainter oldDelegate) => oldDelegate.dark != dark;
}

class BrandBar extends StatelessWidget {
  const BrandBar({
    super.key,
    required this.isDark,
    required this.onToggleTheme,
    this.title,
    this.subtitle,
    this.trailing,
  });

  final bool isDark;
  final VoidCallback onToggleTheme;
  final String? title;
  final String? subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.of(context);
    final compact = MediaQuery.sizeOf(context).width < 430;
    return Padding(
      padding: EdgeInsets.fromLTRB(compact ? 16 : 22, 16, compact ? 16 : 22, 12),
      child: Row(
        children: [
          Container(
            width: compact ? 60 : 78,
            height: 52,
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(17),
              border: Border.all(color: cyan.withOpacity(.22)),
              boxShadow: [
                BoxShadow(
                  color: cyan.withOpacity(.12),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Image.asset('assets/images/logo_full.webp', fit: BoxFit.contain),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        title ?? 'DroneAtlas',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -.65,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle ?? 'Par Novateur221 • ${controller.learnerName} • ${controller.xp} XP',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          if (trailing != null) ...[
            trailing!,
            const SizedBox(width: 5),
          ],
          IconButton.filledTonal(
            tooltip: isDark ? 'Mode clair' : 'Mode sombre',
            onPressed: onToggleTheme,
            icon: Icon(isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded),
          ),
        ],
      ),
    );
  }
}

class NovaDot extends StatelessWidget {
  const NovaDot({super.key, required this.label, this.color = cyan});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(.13),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withOpacity(.25)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 9,
          fontWeight: FontWeight.w900,
          letterSpacing: .7,
        ),
      ),
    );
  }
}

class SectionHeading extends StatelessWidget {
  const SectionHeading({
    super.key,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
    this.eyebrow,
  });

  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;
  final String? eyebrow;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (eyebrow != null) ...[
                Text(
                  eyebrow!.toUpperCase(),
                  style: const TextStyle(
                    color: cyan,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.6,
                  ),
                ),
                const SizedBox(height: 6),
              ],
              Text(
                title,
                style: const TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -.7,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 5),
                Text(
                  subtitle!,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    height: 1.38,
                  ),
                ),
              ],
            ],
          ),
        ),
        if (actionLabel != null)
          TextButton.icon(
            onPressed: onAction,
            icon: const Icon(Icons.arrow_forward_rounded, size: 17),
            label: Text(actionLabel!),
          ),
      ],
    );
  }
}

class Pill extends StatelessWidget {
  const Pill({
    super.key,
    required this.label,
    this.icon,
    this.color = cyan,
  });

  final String label;
  final IconData? icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: color.withOpacity(.13),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withOpacity(.23)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 6),
          ],
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: color,
                fontSize: 10.5,
                fontWeight: FontWeight.w900,
                letterSpacing: .35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class NovaCard extends StatelessWidget {
  const NovaCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.onTap,
    this.gradient,
    this.borderColor,
    this.radius = 26,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final Gradient? gradient;
  final Color? borderColor;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final body = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: gradient == null ? Theme.of(context).cardTheme.color : null,
        gradient: gradient,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(
          color: borderColor ??
              (dark ? Colors.white.withOpacity(.075) : const Color(0xFFE0E9EE)),
        ),
        boxShadow: [
          BoxShadow(
            color: dark ? Colors.black.withOpacity(.13) : const Color(0x10142F3E),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: child,
    );
    if (onTap == null) return body;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(radius),
        child: body,
      ),
    );
  }
}

class MetricCard extends StatelessWidget {
  const MetricCard({
    super.key,
    required this.value,
    required this.label,
    required this.icon,
    this.accent = cyan,
    this.compact = false,
    this.delta,
  });

  final String value;
  final String label;
  final IconData icon;
  final Color accent;
  final bool compact;
  final String? delta;

  @override
  Widget build(BuildContext context) {
    return NovaCard(
      padding: EdgeInsets.all(compact ? 14 : 17),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(compact ? 8 : 10),
                decoration: BoxDecoration(
                  color: accent.withOpacity(.13),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: accent.withOpacity(.16)),
                ),
                child: Icon(icon, color: accent, size: compact ? 19 : 23),
              ),
              const Spacer(),
              if (delta != null) NovaDot(label: delta!, color: accent),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            value,
            style: TextStyle(
              fontSize: compact ? 21 : 27,
              fontWeight: FontWeight.w900,
              letterSpacing: -.8,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: compact ? 11 : 12,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class ProgressRing extends StatelessWidget {
  const ProgressRing({
    super.key,
    required this.value,
    required this.label,
    this.size = 62,
    this.color = cyan,
    this.strokeWidth = 6,
  });

  final double value;
  final String label;
  final double size;
  final Color color;
  final double strokeWidth;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        fit: StackFit.expand,
        children: [
          CircularProgressIndicator(
            value: value.clamp(0.0, 1.0).toDouble(),
            strokeWidth: strokeWidth,
            strokeCap: StrokeCap.round,
            backgroundColor: color.withOpacity(.13),
            valueColor: AlwaysStoppedAnimation(color),
          ),
          Center(
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: size > 80 ? 15 : 12,
                letterSpacing: -.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class GradientIcon extends StatelessWidget {
  const GradientIcon({
    super.key,
    required this.icon,
    this.color = cyan,
    this.size = 52,
  });

  final IconData icon;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color.withOpacity(.30), color.withOpacity(.07)],
        ),
        borderRadius: BorderRadius.circular(size * .31),
        border: Border.all(color: color.withOpacity(.23)),
        boxShadow: [
          BoxShadow(color: color.withOpacity(.08), blurRadius: 18, offset: const Offset(0, 8)),
        ],
      ),
      child: Icon(icon, color: color, size: size * .45),
    );
  }
}

class SkillRadar extends StatelessWidget {
  const SkillRadar({
    super.key,
    required this.values,
    this.size = 190,
    this.color = cyan,
  });

  final List<double> values;
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _SkillRadarPainter(
          values: values,
          color: color,
          gridColor: Theme.of(context).colorScheme.onSurface.withOpacity(.11),
        ),
      ),
    );
  }
}

class _SkillRadarPainter extends CustomPainter {
  const _SkillRadarPainter({
    required this.values,
    required this.color,
    required this.gridColor,
  });

  final List<double> values;
  final Color color;
  final Color gridColor;

  @override
  void paint(Canvas canvas, Size size) {
    final count = math.max(values.length, 3);
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) * .39;
    final gridPaint = Paint()
      ..color = gridColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    for (var level = 1; level <= 4; level++) {
      final path = Path();
      for (var i = 0; i < count; i++) {
        final angle = -math.pi / 2 + (math.pi * 2 * i / count);
        final r = radius * level / 4;
        final point = center + Offset(math.cos(angle) * r, math.sin(angle) * r);
        if (i == 0) {
          path.moveTo(point.dx, point.dy);
        } else {
          path.lineTo(point.dx, point.dy);
        }
      }
      path.close();
      canvas.drawPath(path, gridPaint);
    }

    for (var i = 0; i < count; i++) {
      final angle = -math.pi / 2 + (math.pi * 2 * i / count);
      final point = center + Offset(math.cos(angle) * radius, math.sin(angle) * radius);
      canvas.drawLine(center, point, gridPaint);
    }

    final dataPath = Path();
    for (var i = 0; i < count; i++) {
      final raw = i < values.length ? values[i] : 0.0;
      final value = raw.clamp(0.0, 1.0).toDouble();
      final angle = -math.pi / 2 + (math.pi * 2 * i / count);
      final point = center + Offset(
        math.cos(angle) * radius * value,
        math.sin(angle) * radius * value,
      );
      if (i == 0) {
        dataPath.moveTo(point.dx, point.dy);
      } else {
        dataPath.lineTo(point.dx, point.dy);
      }
    }
    dataPath.close();
    canvas.drawPath(
      dataPath,
      Paint()
        ..color = color.withOpacity(.18)
        ..style = PaintingStyle.fill,
    );
    canvas.drawPath(
      dataPath,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.2
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(covariant _SkillRadarPainter oldDelegate) {
    return oldDelegate.values != values ||
        oldDelegate.color != color ||
        oldDelegate.gridColor != gridColor;
  }
}

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GradientIcon(icon: icon, size: 72),
            const SizedBox(height: 18),
            Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}

class MaxWidthBox extends StatelessWidget {
  const MaxWidthBox({super.key, required this.child, this.maxWidth = 1240});

  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}
