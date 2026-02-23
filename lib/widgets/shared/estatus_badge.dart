import 'package:flutter/material.dart';

class EstatusBadge extends StatelessWidget {
  final String estatus;
  const EstatusBadge({super.key, required this.estatus});

  static const _colors = <String, Color>{
    'recibido':    Color(0xFF64748B),
    'en_revision': Color(0xFFD97706),
    'aprobado':    Color(0xFF1D4ED8),
    'asignado':    Color(0xFF7A1E3A),
    'en_proceso':  Color(0xFF1D4ED8),
    'resuelto':    Color(0xFF2D7A4F),
    'cerrado':     Color(0xFF2D7A4F),
    'rechazado':   Color(0xFF64748B),
    'vencido':     Color(0xFFB91C1C),
  };

  static const _labels = <String, String>{
    'recibido':    'Recibido',
    'en_revision': 'En Revisión',
    'aprobado':    'Aprobado',
    'asignado':    'Asignado',
    'en_proceso':  'En Proceso',
    'resuelto':    'Resuelto',
    'cerrado':     'Cerrado',
    'rechazado':   'Rechazado',
    'vencido':     'Vencido',
  };

  @override
  Widget build(BuildContext context) {
    final color = _colors[estatus] ?? const Color(0xFF64748B);
    final label = _labels[estatus] ?? estatus;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.35)),
      ),
      child: Text(label, style: TextStyle(
        color: color, fontWeight: FontWeight.w500, fontSize: 11,
      )),
    );
  }
}
