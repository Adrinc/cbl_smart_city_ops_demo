import 'package:flutter/material.dart';
import 'package:nethive_neo/theme/theme.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final EdgeInsetsGeometry? padding;

  const SectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    return Padding(
      padding: padding ?? const EdgeInsets.only(bottom: 12),
      child: Row(children: [
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(
              fontSize: 15, fontWeight: FontWeight.w700, color: theme.textPrimary,
            )),
            if (subtitle != null) ...[
              const SizedBox(height: 2),
              Text(subtitle!, style: TextStyle(
                fontSize: 12, color: theme.textSecondary,
              )),
            ],
          ],
        )),
        if (trailing != null) trailing!,
      ]),
    );
  }
}
