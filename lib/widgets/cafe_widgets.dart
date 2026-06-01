import 'package:flutter/material.dart';
import 'package:loafncatting_mobile/core/api_config.dart';
import 'package:loafncatting_mobile/theme/app_theme.dart';

const String loafLogoAsset =
    'assets/images/loafcattinglogo-removebg-preview.png';

class CafeBrandLogo extends StatelessWidget {
  const CafeBrandLogo({
    super.key,
    this.width = 196,
    this.height = 150,
  });

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: Image.asset(
        loafLogoAsset,
        fit: BoxFit.contain,
      ),
    );
  }
}

class CafeSurface extends StatelessWidget {
  const CafeSurface({super.key, required this.child, this.padding});

  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.white, loafCream],
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: padding ?? EdgeInsets.zero,
          child: child,
        ),
      ),
    );
  }
}

class CafeHeroHeader extends StatelessWidget {
  const CafeHeroHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.icon = Icons.pets,
    this.trailing,
    this.playful = false,
  });

  final String title;
  final String? subtitle;
  final IconData icon;
  final Widget? trailing;
  final bool playful;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: playful
              ? const [loafLightCream, Colors.white]
              : const [loafSoftOrange, loafOrange],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        border: playful ? Border.all(color: loafBorder) : null,
        boxShadow: const [
          BoxShadow(
              color: Color(0x24D2691E), blurRadius: 22, offset: Offset(0, 10)),
        ],
      ),
      child: Row(
        children: [
          CafeIconBadge(icon: icon, inverted: !playful),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: playful ? loafBrown : Colors.white,
                        height: 1.05,
                      ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    subtitle!,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: playful
                              ? loafMuted
                              : Colors.white.withValues(alpha: .88),
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

class CafeIconBadge extends StatelessWidget {
  const CafeIconBadge({
    super.key,
    required this.icon,
    this.inverted = false,
    this.size = 46,
  });

  final IconData icon;
  final bool inverted;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: inverted ? Colors.white : loafLightCream,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
              color: Color(0x1FD2691E), blurRadius: 14, offset: Offset(0, 7)),
        ],
      ),
      child: Icon(icon, color: loafOrange),
    );
  }
}

class CafeCard extends StatelessWidget {
  const CafeCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(14),
    this.margin,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: loafBorder),
        boxShadow: const [
          BoxShadow(
              color: Color(0x14D2691E), blurRadius: 18, offset: Offset(0, 8)),
        ],
      ),
      child: child,
    );
  }
}

class CafePlaceholderArt extends StatelessWidget {
  const CafePlaceholderArt({
    super.key,
    this.icon = Icons.local_cafe,
    this.label,
    this.compact = false,
  });

  final IconData icon;
  final String? label;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFC18A), loafLightCream],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(compact ? 14 : 20),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: loafOrange, size: compact ? 24 : 44),
            if (label != null && !compact) ...[
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  label!,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: loafBrown,
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class CafeImageFrame extends StatelessWidget {
  const CafeImageFrame({
    super.key,
    required this.imageUrl,
    this.icon = Icons.local_cafe,
    this.label,
    this.borderRadius = 16,
    this.fit = BoxFit.cover,
  });

  final String? imageUrl;
  final IconData icon;
  final String? label;
  final double borderRadius;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    final resolved = resolveCafeMediaUrl(imageUrl);
    final fallback = CafePlaceholderArt(icon: icon, label: label);

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: resolved == null
          ? fallback
          : Image.network(
              resolved,
              fit: fit,
              width: double.infinity,
              height: double.infinity,
              errorBuilder: (_, __, ___) => fallback,
              loadingBuilder: (context, child, progress) {
                if (progress == null) return child;
                return DecoratedBox(
                  decoration: BoxDecoration(
                    color: loafLightCream,
                    borderRadius: BorderRadius.circular(borderRadius),
                  ),
                  child: const Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                );
              },
            ),
    );
  }
}

String? resolveCafeMediaUrl(String? value) {
  if (value == null || value.trim().isEmpty) return null;
  final raw = value.trim();
  final parsed = Uri.tryParse(raw);
  if (parsed != null && parsed.hasScheme) return raw;

  final base = Uri.parse(ApiConfig.baseUrl);
  if (raw.startsWith('/')) {
    return base.replace(path: raw, query: null, fragment: null).toString();
  }
  return base.resolve(raw).toString();
}

class CafeInfoChip extends StatelessWidget {
  const CafeInfoChip({
    super.key,
    required this.label,
    this.icon,
    this.color = loafOrange,
  });

  final String label;
  final IconData? icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 5),
          ],
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class CafeSectionTitle extends StatelessWidget {
  const CafeSectionTitle({
    super.key,
    required this.title,
    this.subtitle,
    this.padding = const EdgeInsets.fromLTRB(16, 8, 16, 10),
  });

  final String title;
  final String? subtitle;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(subtitle!,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: loafMuted)),
          ],
        ],
      ),
    );
  }
}

class CafeMetricRow extends StatelessWidget {
  const CafeMetricRow(
      {super.key,
      required this.icon,
      required this.label,
      required this.value});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return CafeCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          CafeIconBadge(icon: icon, size: 38),
          const SizedBox(width: 12),
          Expanded(
            child: Text(label,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: loafMuted)),
          ),
          Text(value, style: Theme.of(context).textTheme.titleMedium),
        ],
      ),
    );
  }
}
