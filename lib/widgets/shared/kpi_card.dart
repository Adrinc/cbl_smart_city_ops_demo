import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:nethive_neo/theme/theme.dart';

class KpiCard extends StatelessWidget {
  final String title;
  final String value;
  final String? subtitle;
  final IconData icon;
  final Color? accentColor;
  final VoidCallback? onTap;

  const KpiCard({
    super.key,
    required this.title,
    required this.value,
    this.subtitle,
    required this.icon,
    this.accentColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final color = accentColor ?? theme.primaryColor;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(title, style: TextStyle(
                fontSize: 12, color: theme.textSecondary,
                fontWeight: FontWeight.w500,
              )),
              const SizedBox(height: 2),
              AutoSizeText(
                value,
                style: TextStyle(
                  fontSize: 24, fontWeight: FontWeight.w700, color: color,
                ),
                maxLines: 1,
              ),
              if (subtitle != null)
                Text(subtitle!, style: TextStyle(
                  fontSize: 11, color: theme.textDisabled,
                )),
            ],
          )),
        ]),
      ),
    );
  }
}
