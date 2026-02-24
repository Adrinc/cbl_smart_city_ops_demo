import 'package:flutter/material.dart';

/// Configuración de una categoría de incidencias.
///
/// Modelo central que define las categorías operativas del sistema.
/// Las categorías nativas (esNativa == true) no pueden eliminarse porque
/// el historial de incidencias y las pantallas del sistema las referencian.
/// Las categorías personalizadas pueden eliminarse SÓLO si no tienen
/// reglas de priorización ni incidencias asociadas; en caso contrario,
/// únicamente se pueden desactivar (soft-delete).
class CategoriaConfig {
  final String id; // clave interna, e.g. 'alumbrado'
  final String label; // nombre que ve el operador
  final int iconCodePoint; // codePoint de IconData (MaterialIcons)
  final bool
      activa; // false = desactivada (no disponible para nuevos registros)
  final bool esNativa; // true = categoría del sistema, no se puede eliminar

  const CategoriaConfig({
    required this.id,
    required this.label,
    required this.iconCodePoint,
    this.activa = true,
    this.esNativa = false,
  });

  /// Icono como [IconData] listo para usar en widgets.
  IconData get icon => IconData(iconCodePoint, fontFamily: 'MaterialIcons');

  CategoriaConfig copyWith({
    String? label,
    int? iconCodePoint,
    bool? activa,
  }) {
    return CategoriaConfig(
      id: id,
      label: label ?? this.label,
      iconCodePoint: iconCodePoint ?? this.iconCodePoint,
      activa: activa ?? this.activa,
      esNativa: esNativa,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CategoriaConfig &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

// ──────────────────────────────────────────────────────────────────────────────
// Catálogo de íconos disponibles para el selector
// ──────────────────────────────────────────────────────────────────────────────

/// Par icono-etiqueta para el selector visual en los diálogos.
class IconOption {
  final IconData icon;
  final String label;
  const IconOption(this.icon, this.label);
}

/// Íconos curados para operaciones de ciudad inteligente.
const List<IconOption> kCityIcons = [
  // Infraestructura urbana
  IconOption(Icons.lightbulb_outline, 'Alumbrado'),
  IconOption(Icons.construction, 'Bacheo / Obra'),
  IconOption(Icons.delete_outline, 'Basura'),
  IconOption(Icons.water_drop_outlined, 'Agua / Drenaje'),
  IconOption(Icons.traffic, 'Señalización'),
  IconOption(Icons.security, 'Seguridad'),
  // Servicios públicos
  IconOption(Icons.electrical_services, 'Electricidad'),
  IconOption(Icons.local_gas_station, 'Gas / Combustible'),
  IconOption(Icons.wifi_outlined, 'Conectividad'),
  IconOption(Icons.phone_outlined, 'Telefonía'),
  // Transporte
  IconOption(Icons.directions_bus_outlined, 'Transporte'),
  IconOption(Icons.directions_walk, 'Peatonal'),
  IconOption(Icons.pedal_bike, 'Ciclovía'),
  IconOption(Icons.local_parking, 'Estacionamiento'),
  // Medio ambiente
  IconOption(Icons.park_outlined, 'Parque / Jardín'),
  IconOption(Icons.eco_outlined, 'Medio Ambiente'),
  IconOption(Icons.forest_outlined, 'Áreas Verdes'),
  IconOption(Icons.wb_sunny_outlined, 'Clima / Emergencia'),
  // Edificios y espacio público
  IconOption(Icons.domain_outlined, 'Edificio'),
  IconOption(Icons.holiday_village_outlined, 'Colonia'),
  IconOption(Icons.stadium_outlined, 'Instalación Deportiva'),
  IconOption(Icons.school_outlined, 'Educación'),
  IconOption(Icons.local_hospital_outlined, 'Salud'),
  IconOption(Icons.account_balance_outlined, 'Gobierno'),
  // Emergencias
  IconOption(Icons.local_fire_department_outlined, 'Incendio'),
  IconOption(Icons.warning_amber_outlined, 'Riesgo / Alerta'),
  IconOption(Icons.pest_control, 'Plagas'),
  IconOption(Icons.flood_outlined, 'Inundación'),
  // Genéricos
  IconOption(Icons.build_outlined, 'Mantenimiento'),
  IconOption(Icons.category_outlined, 'General'),
];
