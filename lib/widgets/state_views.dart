import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:loafncatting_mobile/core/constants/app_strings.dart';
import 'package:loafncatting_mobile/theme/app_theme.dart';
import 'package:loafncatting_mobile/widgets/cafe_widgets.dart';

class EmptyView extends StatelessWidget {
  const EmptyView(this.message, {super.key});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: CafeCard(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CafeIconBadge(icon: Icons.pets),
              const SizedBox(height: 12),
              Text(
                message,
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(color: loafMuted),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ErrorView extends StatelessWidget {
  const ErrorView(this.message, {super.key, this.onRetry});
  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CafeIconBadge(icon: Icons.error_outline),
            const SizedBox(height: 12),
            Text(message,
                textAlign: TextAlign.center,
                style: TextStyle(color: Theme.of(context).colorScheme.error)),
            if (onRetry != null) ...[
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: onRetry,
                child: const Text(AppStrings.retryButton),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

String money(double value) {
  final digits = value.toStringAsFixed(0);
  final formatted = digits.replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (_) => '.',
  );
  return '$formatted VND';
}

TextStyle? moneyTextStyle(
  TextStyle? style, {
  Color? color,
  FontWeight? fontWeight,
}) =>
    style?.copyWith(
      color: color,
      fontWeight: fontWeight,
      fontFeatures: const [FontFeature.tabularFigures()],
    );
