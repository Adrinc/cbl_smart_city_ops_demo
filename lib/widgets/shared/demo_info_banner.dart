import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:nethive_neo/providers/providers.dart';
import 'package:nethive_neo/theme/theme.dart';

/// Banner informativo descartable que explica al visitante de la demo
/// para qué sirve la pantalla actual.
///
/// Se renderiza una sola vez desde [MainContainerPage] usando el mapa
/// [demoPageDescriptions], que asocia cada ruta con un texto descriptivo.
class DemoInfoBanner extends StatelessWidget {
  const DemoInfoBanner({
    super.key,
    required this.pageKey,
    required this.message,
  });

  /// Identificador único de la página (la ruta, e.g. '/', '/ordenes').
  final String pageKey;

  /// Texto explicativo mostrado en el banner.
  final String message;

  @override
  Widget build(BuildContext context) {
    final appLevel = context.watch<AppLevelProvider>();
    if (appLevel.bannerDescartado(pageKey)) return const SizedBox.shrink();

    final theme = AppTheme.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bgColor = isDark ? const Color(0xFF1A2235) : const Color(0xFFEFF6FF);
    final borderColor =
        isDark ? const Color(0xFF2A3F5F) : const Color(0xFFBFDBFE);
    final iconColor =
        isDark ? const Color(0xFF60A5FA) : const Color(0xFF1D4ED8);
    final textColor =
        isDark ? const Color(0xFF93C5FD) : const Color(0xFF1E40AF);
    final closeColor =
        isDark ? const Color(0xFF60A5FA) : const Color(0xFF1D4ED8);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 10, 16, 4),
      padding: const EdgeInsets.fromLTRB(12, 9, 8, 9),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 1),
            child: Icon(Icons.info_outline_rounded, size: 15, color: iconColor),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontSize: 12,
                color: textColor,
                height: 1.45,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Tooltip(
            message: 'Cerrar aviso',
            child: InkWell(
              borderRadius: BorderRadius.circular(6),
              onTap: () =>
                  context.read<AppLevelProvider>().descartarBanner(pageKey),
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: Icon(Icons.close_rounded,
                    size: 14, color: closeColor.withOpacity(0.6)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Mapa de ruta → descripción demo. Úsalo en [MainContainerPage].
const Map<String, String> demoPageDescriptions = {
  '/': 'DEMO · Visión Nacional: KPIs agregados de los 32 estados de México. '
      'Monitoreo estratégico de incidencias, cumplimiento de SLA y alertas críticas a nivel país.',
  '/state':
      'DEMO · Centro Operativo Estatal: coordinación de los municipios de Baja California Norte. '
          'Aquí el operador estatal hace seguimiento de SLA regional y puede perforar hacia cada municipio.',
  '/municipal':
      'DEMO · Dashboard Municipal de Tijuana: vista operativa en tiempo real. '
          'KPIs de incidencias activas, técnicos disponibles y alertas pendientes de atención.',
  '/ordenes':
      'DEMO · Órdenes e Incidencias: tabla completa de reportes ciudadanos. '
          'Filtra, ordena y accede al detalle de cada orden de trabajo asignada en Tijuana.',
  '/mapa':
      'DEMO · Mapa Operativo: visualización georreferenciada de incidencias y técnicos. '
          'El zoom y los marcadores se adaptan automáticamente al nivel territorial activo (Nacional / Estatal / Municipal).',
  '/tecnicos':
      'DEMO · Gestión de Técnicos y Cuadrillas: disponibilidad, especialidades y carga de trabajo '
          'de los 13 técnicos activos en Tijuana.',
  '/inventario':
      'DEMO · Inventario de Materiales: stock en tiempo real de los insumos '
          'necesarios para atender las órdenes de trabajo abiertas.',
  '/bandeja-ia':
      'DEMO · Bandeja IA: la inteligencia artificial pre-clasifica y sugiere prioridad '
          'para cada reporte ciudadano antes de que el operador humano lo apruebe o rechace.',
  '/aprobaciones':
      'DEMO · Aprobaciones: bandeja de órdenes pendientes de validación humana. '
          'Operador debe revisar y autorizar cada incidencia antes de asignarla a un técnico.',
  '/sla': 'DEMO · Monitor de SLA: semáforo de cumplimiento de tiempos de respuesta. '
      'Muestra incidencias próximas a vencer y las ya vencidas que requieren atención inmediata.',
  '/reportes':
      'DEMO · Analítica y Reportes: gráficas consolidadas de eficiencia operativa, '
          'tendencias por categoría y comparativos de desempeño en Tijuana.',
  '/configuracion':
      'DEMO · Motor de Priorización: reglas configurables que determinan prioridad y SLA '
          'automáticamente según categoría, entorno y reincidencia de cada incidencia.',
  '/catalogos':
      'DEMO · Catálogos: gestión de categorías, zonas geográficas y dependencias municipales '
          'que estructuran el sistema de incidencias.',
  '/usuarios': 'DEMO · Usuarios del Sistema: administración de roles y accesos. '
      'En producción se controlaría qué operador accede a qué nivel territorial.',
  '/auditoria':
      'DEMO · Log de Auditoría: registro inmutable de cada acción realizada en el sistema. '
          'Permite trazabilidad completa para cumplimiento normativo.',
};
