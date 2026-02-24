import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nethive_neo/helpers/constants.dart';
import 'package:nethive_neo/helpers/formatters.dart';
import 'package:nethive_neo/models/models.dart';
import 'package:nethive_neo/providers/providers.dart';
import 'package:nethive_neo/theme/theme.dart';
import 'package:nethive_neo/widgets/shared/estatus_badge.dart';
import 'package:nethive_neo/widgets/shared/kpi_card.dart';
import 'package:nethive_neo/widgets/shared/priority_badge.dart';
import 'package:nethive_neo/widgets/shared/responsive_layout.dart';
import 'package:nethive_neo/widgets/shared/section_header.dart';
import 'package:provider/provider.dart';

class DashboardMunicipalPage extends StatelessWidget {
  const DashboardMunicipalPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final reporte = context.watch<ReporteProvider>();
    final incProv = context.watch<IncidenciaProvider>();
    final tecProv = context.watch<TecnicoProvider>();
    final kpi = reporte.kpiMunicipal;

    final criticas = incProv.criticas.take(5).toList();
    final tecnicos = tecProv.activos.take(4).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            title: 'Dashboard Municipal — Tijuana',
            subtitle:
                'Centro de operaciones · SLA ${kpi.cumplimientoSla.toStringAsFixed(1)}% · Actualizado hace 2 min',
            trailing: _NivelBadge(theme: theme),
          ),
          const SizedBox(height: 20),

          // KPI Row — responsivo
          KpiGrid(children: [
            KpiCard(
                icon: Icons.assignment_outlined,
                accentColor: theme.medium,
                value: '${kpi.incidenciasActivas}',
                title: 'Activas',
                subtitle: 'Tijuana'),
            KpiCard(
                icon: Icons.warning_amber_rounded,
                accentColor: theme.critical,
                value: '${kpi.criticas}',
                title: 'Críticas',
                subtitle: 'Inmediatas'),
            KpiCard(
                icon: Icons.verified_outlined,
                accentColor: theme.low,
                value: '${kpi.cumplimientoSla.toStringAsFixed(1)} %',
                title: 'SLA',
                subtitle: 'Cumplimiento'),
            KpiCard(
                icon: Icons.timer_outlined,
                accentColor: theme.high,
                value: '${kpi.porVencer}',
                title: 'Por Vencer',
                subtitle: '≤ 4 horas'),
            KpiCard(
                icon: Icons.engineering_outlined,
                accentColor: theme.primaryColor,
                value: '${kpi.tecnicosActivos}',
                title: 'Técnicos',
                subtitle: 'En campo'),
          ]),
          const SizedBox(height: 24),

          // Incidencias críticas + Técnicos — responsivo
          TwoColumnLayout(
            left: _IncidenciasCriticasCard(criticas: criticas, theme: theme),
            right: _TecnicosCard(tecnicos: tecnicos, theme: theme),
          ),
          const SizedBox(height: 24),

          // Accesos rápidos
          _AccesosRapidos(theme: theme),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _NivelBadge extends StatelessWidget {
  const _NivelBadge({required this.theme});
  final AppTheme theme;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: theme.primaryColor.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.primaryColor.withOpacity(0.3)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.location_on_outlined, size: 14, color: theme.primaryColor),
        const SizedBox(width: 6),
        Text('NIVEL MUNICIPAL',
            style: TextStyle(
                color: theme.primaryColor,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5)),
      ]),
    );
  }
}

class _IncidenciasCriticasCard extends StatelessWidget {
  const _IncidenciasCriticasCard({required this.criticas, required this.theme});
  final List<Incidencia> criticas;
  final AppTheme theme;

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(Icons.warning_amber_rounded, size: 18, color: theme.critical),
            const SizedBox(width: 8),
            Text('Incidencias Críticas',
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: theme.textPrimary)),
            const Spacer(),
            TextButton(
              onPressed: () => context.go(routeOrdenes),
              child: Text('Ver todas →',
                  style: TextStyle(fontSize: 12, color: theme.primaryColor)),
            ),
          ]),
          const SizedBox(height: 8),
          if (criticas.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Center(
                  child: Text('Sin incidencias críticas activas',
                      style:
                          TextStyle(color: theme.textSecondary, fontSize: 13))),
            )
          else ...[
            // Table header
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(children: [
                SizedBox(
                    width: 55,
                    child: Text('ID',
                        style: TextStyle(
                            fontSize: 11,
                            color: theme.textSecondary,
                            fontWeight: FontWeight.w600))),
                Expanded(
                    child: Text('Descripción',
                        style: TextStyle(
                            fontSize: 11,
                            color: theme.textSecondary,
                            fontWeight: FontWeight.w600))),
                SizedBox(
                    width: 80,
                    child: Text('Categoría',
                        style: TextStyle(
                            fontSize: 11,
                            color: theme.textSecondary,
                            fontWeight: FontWeight.w600),
                        textAlign: TextAlign.center)),
                SizedBox(
                    width: 90,
                    child: Text('SLA',
                        style: TextStyle(
                            fontSize: 11,
                            color: theme.textSecondary,
                            fontWeight: FontWeight.w600),
                        textAlign: TextAlign.right)),
              ]),
            ),
            Divider(color: theme.border, height: 1),
            ...criticas.map((inc) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(children: [
                    SizedBox(
                        width: 55,
                        child: Text(formatIdIncidencia(inc.id),
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: theme.primaryColor))),
                    Expanded(
                        child: Text(inc.descripcion,
                            style: TextStyle(
                                fontSize: 12, color: theme.textPrimary),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis)),
                    SizedBox(
                        width: 80,
                        child: Center(
                            child: Text(labelCategoria(inc.categoria),
                                style: TextStyle(
                                    fontSize: 11,
                                    color: theme.textSecondary)))),
                    SizedBox(
                        width: 90,
                        child: Text(formatSla(inc.fechaLimite),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color:
                                  inc.estaVencida ? theme.critical : theme.high,
                            ),
                            textAlign: TextAlign.right)),
                  ]),
                )),
          ],
        ],
      ),
    );
  }
}

class _TecnicosCard extends StatelessWidget {
  const _TecnicosCard({required this.tecnicos, required this.theme});
  final List<Tecnico> tecnicos;
  final AppTheme theme;

  Color _statusColor(String estatus) {
    switch (estatus) {
      case 'en_campo':
        return theme.low;
      case 'activo':
        return theme.medium;
      case 'inactivo':
        return theme.neutral;
      default:
        return theme.neutral;
    }
  }

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(Icons.engineering_outlined,
                size: 18, color: theme.primaryColor),
            const SizedBox(width: 8),
            Text('Técnicos Activos',
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: theme.textPrimary)),
            const Spacer(),
            TextButton(
              onPressed: () => context.go(routeTecnicos),
              child: Text('Ver todos →',
                  style: TextStyle(fontSize: 12, color: theme.primaryColor)),
            ),
          ]),
          const SizedBox(height: 8),
          ...tecnicos.map((t) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(children: [
                  // Avatar
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: theme.primaryColor.withOpacity(0.12),
                    backgroundImage:
                        t.avatarPath != null ? AssetImage(t.avatarPath!) : null,
                    child: t.avatarPath == null
                        ? Text(t.iniciales,
                            style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: theme.primaryColor))
                        : null,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                      child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(t.nombre,
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: theme.textPrimary)),
                      Text(labelEstatusTecnico(t.estatus),
                          style: TextStyle(
                              fontSize: 11, color: _statusColor(t.estatus))),
                    ],
                  )),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: theme.medium.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text('${t.incidenciasActivas}',
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: theme.medium)),
                  ),
                ]),
              )),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () => context.go(routeTecnicos),
            icon: Icon(Icons.group_outlined, size: 16),
            label: const Text('Gestionar técnicos'),
            style: OutlinedButton.styleFrom(
              foregroundColor: theme.primaryColor,
              side: BorderSide(color: theme.primaryColor.withOpacity(0.4)),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          ),
        ],
      ),
    );
  }
}

class _AccesosRapidos extends StatelessWidget {
  const _AccesosRapidos({required this.theme});
  final AppTheme theme;

  @override
  Widget build(BuildContext context) {
    final items = [
      (
        Icons.list_alt_outlined,
        'Órdenes',
        'PlutoGrid completo',
        routeOrdenes,
        theme.medium
      ),
      (
        Icons.map_outlined,
        'Mapa Operativo',
        'Vista geoespacial',
        routeMapa,
        theme.low
      ),
      (
        Icons.psychology_outlined,
        'Bandeja IA',
        'Revisión pendiente',
        routeBandejaIA,
        theme.high
      ),
      (
        Icons.check_circle_outline,
        'Aprobaciones',
        'En espera',
        routeAprobaciones,
        theme.critical
      ),
      (
        Icons.show_chart,
        'SLA Monitor',
        'Métricas de tiempo',
        routeSla,
        const Color(0xFF7A1E3A)
      ),
      (
        Icons.bar_chart_outlined,
        'Reportes',
        'Analítica y KPIs',
        routeReportes,
        const Color(0xFF64748B)
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Accesos Rápidos',
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: theme.textPrimary)),
        const SizedBox(height: 12),
        LayoutBuilder(builder: (context, box) {
          final cols = box.maxWidth < 480
              ? 2
              : box.maxWidth < 800
                  ? 3
                  : 6;
          // ratio más bajo = tarjetas más altas → evita overflow en icono + texto
          final ratio = box.maxWidth < 480
              ? 1.4
              : box.maxWidth < 800
                  ? 1.65
                  : 1.2;
          return GridView.count(
            crossAxisCount: cols,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: ratio,
            children: items
                .map((item) => _QuickCard(
                      icon: item.$1,
                      label: item.$2,
                      sublabel: item.$3,
                      route: item.$4,
                      color: item.$5,
                      theme: theme,
                    ))
                .toList(),
          );
        }),
      ],
    );
  }
}

class _QuickCard extends StatelessWidget {
  const _QuickCard({
    required this.icon,
    required this.label,
    required this.sublabel,
    required this.route,
    required this.color,
    required this.theme,
  });
  final IconData icon;
  final String label, sublabel, route;
  final Color color;
  final AppTheme theme;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.go(route),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: theme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.border),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2))
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                  color: color.withOpacity(0.12), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 8),
            Text(label,
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: theme.textPrimary),
                textAlign: TextAlign.center),
            const SizedBox(height: 2),
            Text(sublabel,
                style: TextStyle(fontSize: 10, color: theme.textSecondary),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.border),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 2))
        ],
      ),
      child: child,
    );
  }
}
