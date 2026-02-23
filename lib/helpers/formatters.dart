import 'package:intl/intl.dart';

// ============================================================
// Formateadores — Terranex Smart City
// ============================================================

/// Fecha larga: "22 de febrero de 2026"
String formatFechaLarga(DateTime dt) {
  return DateFormat("d 'de' MMMM 'de' y", 'es_MX').format(dt);
}

/// Fecha corta: "22/02/2026"
String formatFechaCorta(DateTime dt) {
  return DateFormat('dd/MM/yyyy').format(dt);
}

/// Fecha + hora larga: "22 de febrero de 2026 a las 14:35 h"
/// Si son horas redondas: "22 de febrero de 2026 a las 14 h"
String formatFechaHora(DateTime dt) {
  final fecha = DateFormat("d 'de' MMMM 'de' y", 'es_MX').format(dt);
  final h = dt.hour;
  final m = dt.minute;
  if (m == 0) return '$fecha a las $h h';
  return '$fecha a las ${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')} h';
}

/// Fecha + hora corta para tablas: "22/02 14:35"
String formatFechaHoraCorta(DateTime dt) {
  return DateFormat('dd/MM HH:mm').format(dt);
}

/// Solo hora: "14:35"
String formatHora(DateTime dt) {
  return DateFormat('HH:mm').format(dt);
}

/// SLA restante a partir de una fecha limite
/// Retorna: "3h 28m", "1d 12h", "Vencido", "Sin SLA"
String formatSla(DateTime? fechaLimite) {
  if (fechaLimite == null) return 'Sin SLA';
  final ahora = DateTime.now();
  final diff = fechaLimite.difference(ahora);
  if (diff.isNegative) return 'Vencido';
  if (diff.inDays >= 1) {
    final horas = diff.inHours % 24;
    return '${diff.inDays}d ${horas}h';
  }
  if (diff.inHours >= 1) {
    final minutos = diff.inMinutes % 60;
    return '${diff.inHours}h ${minutos}m';
  }
  return '${diff.inMinutes}m';
}

/// Etiqueta legible de SLA ya vencido hace X tiempo
String formatSlaVencido(DateTime? fechaLimite) {
  if (fechaLimite == null) return '';
  final ahora = DateTime.now();
  final diff = ahora.difference(fechaLimite);
  if (diff.inDays >= 1) return 'Vencio hace ${diff.inDays}d';
  if (diff.inHours >= 1) return 'Vencio hace ${diff.inHours}h';
  return 'Vencio hace ${diff.inMinutes}m';
}

/// "89 %"
String formatPorcentaje(double valor) {
  return '${valor.toStringAsFixed(0)} %';
}

/// "#15420"
String formatIdIncidencia(String id) {
  return id.startsWith('#') ? id : '#$id';
}

/// Nombre legible de categoria
String labelCategoria(String cat) {
  const Map<String, String> labels = {
    'alumbrado': 'Alumbrado',
    'bacheo': 'Bacheo',
    'basura': 'Basura',
    'seguridad': 'Seguridad',
    'agua_drenaje': 'Agua / Drenaje',
    'senalizacion': 'Senalizacion',
  };
  return labels[cat] ?? cat;
}

/// Nombre legible de prioridad
String labelPrioridad(String p) {
  const Map<String, String> labels = {
    'critico': 'Critico',
    'alto': 'Alto',
    'medio': 'Medio',
    'bajo': 'Bajo',
  };
  return labels[p] ?? p;
}

/// Nombre legible de estatus
String labelEstatus(String s) {
  const Map<String, String> labels = {
    'recibido': 'Recibido',
    'en_revision': 'En Revision',
    'aprobado': 'Aprobado',
    'asignado': 'Asignado',
    'en_proceso': 'En Proceso',
    'resuelto': 'Resuelto',
    'cerrado': 'Cerrado',
    'rechazado': 'Rechazado',
  };
  return labels[s] ?? s;
}

/// Nombre legible de entorno
String labelEntorno(String e) {
  const Map<String, String> labels = {
    'residencial': 'Residencial',
    'comercial': 'Comercial',
    'industrial': 'Industrial',
    'institucional': 'Institucional',
  };
  return labels[e] ?? e;
}

/// Nombre legible de rol de tecnico
String labelRolTecnico(String rol) {
  const Map<String, String> labels = {
    'jefe_cuadrilla': 'Jefe de Cuadrilla',
    'tecnico_campo': 'Tecnico de Campo',
    'supervisor': 'Supervisor',
  };
  return labels[rol] ?? rol;
}

/// Nombre legible de estatus de tecnico
String labelEstatusTecnico(String s) {
  const Map<String, String> labels = {
    'activo': 'Activo',
    'en_campo': 'En Campo',
    'inactivo': 'Inactivo',
    'descanso': 'Descanso',
  };
  return labels[s] ?? s;
}
