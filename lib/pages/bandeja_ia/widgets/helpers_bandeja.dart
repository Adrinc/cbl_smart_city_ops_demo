import 'package:flutter/material.dart';
import 'package:nethive_neo/models/models.dart';

// ── Veredicto IA ─────────────────────────────────────────────────────────────
bool esRechazoIA(Incidencia inc) {
  final p = inc.imagenPath ?? '';
  return p.contains('rechazar') || p.contains('happyface') || p.contains('papelito');
}

// ── Dirección aproximada (Ensenada) ──────────────────────────────────────────
String approxDireccion(double lat, double lon) {
  if (lat > 31.876) return 'Col. Reforma Norte';
  if (lat > 31.872) return 'Col. El Sauzal';
  if (lat > 31.868) return 'Zona Centro Norte';
  if (lat > 31.864) return 'Centro Histórico';
  if (lat > 31.858) return 'Col. Miramar';
  if (lat > 31.854) return 'Col. Los Viñedos';
  return 'Col. Chapultepec';
}

// ── Iconos por categoría (usados en toda la app) ──────────────────────────────
const Map<String, IconData> kCatIcons = {
  'alumbrado':    Icons.lightbulb_outline,
  'bacheo':       Icons.construction,
  'basura':       Icons.delete_outline,
  'agua_drenaje': Icons.water_drop_outlined,
  'señalizacion': Icons.traffic,
  'senalizacion': Icons.traffic,
  'seguridad':    Icons.shield_outlined,
};

IconData catIcon(String categoria) =>
    kCatIcons[categoria] ?? Icons.help_outline;

// ── Color por prioridad ───────────────────────────────────────────────────────
Color prioColor(String prioridad) {
  switch (prioridad) {
    case 'critico': return const Color(0xFFB91C1C);
    case 'alto':    return const Color(0xFFD97706);
    case 'medio':   return const Color(0xFF1D4ED8);
    default:        return const Color(0xFF2D7A4F);
  }
}