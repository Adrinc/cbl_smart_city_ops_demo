import 'package:flutter/material.dart';
import 'package:nethive_neo/models/models.dart';
import 'package:nethive_neo/theme/theme.dart';
import 'package:nethive_neo/helpers/formatters.dart';

class AlertaRow extends StatelessWidget {
  final AlertaEstatal alerta;
  const AlertaRow({super.key, required this.alerta});

  static const _prioColors = <String, Color>{
    'critico': Color(0xFFB91C1C),
    'alto':    Color(0xFFD97706),
    'medio':   Color(0xFF1D4ED8),
    'bajo':    Color(0xFF2D7A4F),
  };

  static const _catIcons = <String, IconData>{
    'alumbrado':    Icons.lightbulb_outline,
    'bacheo':       Icons.construction_outlined,
    'basura':       Icons.delete_outline,
    'agua_drenaje': Icons.water_drop_outlined,
    'senalizacion': Icons.signpost_outlined,
    'seguridad':    Icons.security_outlined,
  };

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final color = _prioColors[alerta.prioridad] ?? const Color(0xFF64748B);
    final icon = _catIcons[alerta.categoria] ?? Icons.warning_amber_outlined;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 10),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(alerta.estado, style: TextStyle(
              fontSize: 12, fontWeight: FontWeight.w600, color: theme.textPrimary,
            )),
            Text(alerta.descripcion, style: TextStyle(
              fontSize: 11, color: theme.textSecondary,
            ), maxLines: 1, overflow: TextOverflow.ellipsis),
          ],
        )),
        const SizedBox(width: 8),
        Text(
          'Vence: ${formatFechaHora(alerta.expira)}',
          style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w500),
        ),
      ]),
    );
  }
}
