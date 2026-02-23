import 'package:flutter/material.dart';

class PriorityBadge extends StatelessWidget {
  final String prioridad;
  const PriorityBadge({super.key, required this.prioridad});

  static const _colors = <String, Color>{
    'critico': Color(0xFFB91C1C),
    'alto':    Color(0xFFD97706),
    'medio':   Color(0xFF1D4ED8),
    'bajo':    Color(0xFF2D7A4F),
  };

  static const _labels = <String, String>{
    'critico': 'CRÍTICO',
    'alto':    'ALTO',
    'medio':   'MEDIO',
    'bajo':    'BAJO',
  };

  static Color colorOf(String p) => _colors[p] ?? const Color(0xFF64748B);

  @override
  Widget build(BuildContext context) {
    final color = _colors[prioridad] ?? const Color(0xFF64748B);
    final label = _labels[prioridad] ?? prioridad.toUpperCase();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(label, style: TextStyle(
        color: color, fontWeight: FontWeight.w600, fontSize: 11,
      )),
    );
  }
}
