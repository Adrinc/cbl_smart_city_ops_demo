import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:nethive_neo/helpers/formatters.dart';
import 'package:nethive_neo/widgets/shared/responsive_layout.dart';
import 'package:nethive_neo/models/models.dart';
import 'package:nethive_neo/providers/providers.dart';
import 'package:nethive_neo/theme/theme.dart';
import 'package:nethive_neo/widgets/shared/priority_badge.dart';
import 'package:nethive_neo/widgets/shared/section_header.dart';
import 'package:provider/provider.dart';

class SlaPage extends StatelessWidget {
  const SlaPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final slaProv = context.watch<SlaProvider>();
    final incProv = context.watch<IncidenciaProvider>();
    final reporte = context.watch<ReporteProvider>();

    final enRiesgo = slaProv.enRiesgo;
    final vencidas = slaProv.vencidas;
    final pct = slaProv.porcentajeCumplimiento;

    // Incidencias ordenadas por SLA (mas urgentes primero)
    final urgentes = incProv.activas
        .where((i) => i.fechaLimite != null)
        .toList()
      ..sort((a, b) => a.fechaLimite!.compareTo(b.fechaLimite!));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            title: 'Monitor de SLA — Tijuana',
            subtitle:
                'Seguimiento de tiempos de respuesta y cumplimiento de compromisos',
          ),
          const SizedBox(height: 20),

          // KPI Row
          KpiGrid(children: [
            _SlaKpiCard(
              value: '${pct.toStringAsFixed(1)} %',
              label: 'Cumplimiento',
              sublabel: 'del total de incidencias',
              color: pct >= 90
                  ? theme.low
                  : pct >= 80
                      ? theme.high
                      : theme.critical,
              icon: Icons.verified_outlined,
            ),
            _SlaKpiCard(
              value: '${vencidas.length}',
              label: 'Vencidas',
              sublabel: 'SLA superado',
              color: theme.critical,
              icon: Icons.timer_off_outlined,
            ),
            _SlaKpiCard(
              value: '${enRiesgo.length}',
              label: 'En Riesgo',
              sublabel: 'Vencen en ≤ 4 h',
              color: theme.high,
              icon: Icons.timer_outlined,
            ),
            _SlaKpiCard(
              value:
                  '${incProv.activas.length - vencidas.length - enRiesgo.length}',
              label: 'En Plazo',
              sublabel: 'Sin riesgo inmediato',
              color: theme.low,
              icon: Icons.check_circle_outline,
            ),
          ]),
          const SizedBox(height: 24),

          // Chart + Urgentes list
          TwoColumnLayout(
            leftFlex: 4,
            rightFlex: 6,
            gap: 16,
            left: _SlaDonutCard(
                pct: pct,
                vencidas: vencidas.length,
                enRiesgo: enRiesgo.length,
                total: incProv.activas.length,
                theme: theme),
            right: _UrgentesList(
                urgentes: urgentes.take(10).toList(), theme: theme),
          ),
        ],
      ),
    );
  }
}

class _SlaKpiCard extends StatelessWidget {
  const _SlaKpiCard(
      {required this.value,
      required this.label,
      required this.sublabel,
      required this.color,
      required this.icon});
  final String value, label, sublabel;
  final Color color;
  final IconData icon;
  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.border),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 12),
        Text(value,
            style: TextStyle(
                fontSize: 26, fontWeight: FontWeight.w800, color: color)),
        Text(label,
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: theme.textPrimary)),
        Text(sublabel,
            style: TextStyle(fontSize: 11, color: theme.textSecondary)),
      ]),
    );
  }
}

class _SlaDonutCard extends StatelessWidget {
  const _SlaDonutCard(
      {required this.pct,
      required this.vencidas,
      required this.enRiesgo,
      required this.total,
      required this.theme});
  final double pct;
  final int vencidas, enRiesgo, total;
  final AppTheme theme;

  @override
  Widget build(BuildContext context) {
    final cumplidas = (total > 0)
        ? (total - vencidas - enRiesgo).clamp(0, total).toDouble()
        : 0.0;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.border),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(Icons.donut_large, size: 18, color: theme.primaryColor),
          const SizedBox(width: 8),
          Text('Distribución SLA',
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: theme.textPrimary)),
        ]),
        const SizedBox(height: 16),
        SizedBox(
          height: 200,
          child: PieChart(PieChartData(
            sections: [
              if (vencidas > 0)
                PieChartSectionData(
                    value: vencidas.toDouble(),
                    color: theme.critical,
                    title: '$vencidas',
                    radius: 55,
                    titleStyle: const TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                        fontWeight: FontWeight.w700)),
              if (enRiesgo > 0)
                PieChartSectionData(
                    value: enRiesgo.toDouble(),
                    color: theme.high,
                    title: '$enRiesgo',
                    radius: 55,
                    titleStyle: const TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                        fontWeight: FontWeight.w700)),
              if (cumplidas > 0)
                PieChartSectionData(
                    value: cumplidas,
                    color: theme.low,
                    title: '${cumplidas.toInt()}',
                    radius: 55,
                    titleStyle: const TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                        fontWeight: FontWeight.w700)),
            ],
            borderData: FlBorderData(show: false),
            centerSpaceRadius: 50,
            sectionsSpace: 2,
          )),
        ),
        const SizedBox(height: 12),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          _Legend(color: theme.critical, label: 'Vencidas'),
          const SizedBox(width: 12),
          _Legend(color: theme.high, label: 'En riesgo'),
          const SizedBox(width: 12),
          _Legend(color: theme.low, label: 'En plazo'),
        ]),
        const SizedBox(height: 8),
        Center(
            child: Text('${pct.toStringAsFixed(1)}% de cumplimiento',
                style: TextStyle(
                    fontSize: 12,
                    color: theme.textSecondary,
                    fontWeight: FontWeight.w600))),
      ]),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend({required this.color, required this.label});
  final Color color;
  final String label;
  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
      const SizedBox(width: 4),
      Text(label, style: TextStyle(fontSize: 11, color: theme.textSecondary)),
    ]);
  }
}

class _UrgentesList extends StatelessWidget {
  const _UrgentesList({required this.urgentes, required this.theme});
  final List<Incidencia> urgentes;
  final AppTheme theme;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.border),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(Icons.access_alarm, size: 18, color: theme.critical),
          const SizedBox(width: 8),
          Text('Más Urgentes',
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: theme.textPrimary)),
          const SizedBox(width: 4),
          Text('(por vencimiento)',
              style: TextStyle(fontSize: 12, color: theme.textSecondary)),
        ]),
        const SizedBox(height: 8),
        // Header
        Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(children: [
              SizedBox(
                  width: 60,
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
                  child: Text('Prioridad',
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
            ])),
        Divider(color: theme.border, height: 1),
        ...urgentes.map((inc) {
          final vencido = inc.estaVencida;
          return Container(
            color: vencido ? theme.critical.withOpacity(0.04) : null,
            child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(children: [
                  SizedBox(
                      width: 60,
                      child: Text(formatIdIncidencia(inc.id),
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: theme.primaryColor))),
                  Expanded(
                      child: Text(inc.descripcion,
                          style:
                              TextStyle(fontSize: 12, color: theme.textPrimary),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis)),
                  SizedBox(
                      width: 80,
                      child: Center(
                          child: PriorityBadge(prioridad: inc.prioridad))),
                  SizedBox(
                      width: 90,
                      child: Text(formatSla(inc.fechaLimite),
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: vencido ? theme.critical : theme.high),
                          textAlign: TextAlign.right)),
                ])),
          );
        }),
      ]),
    );
  }
}
