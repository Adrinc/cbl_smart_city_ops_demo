import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:nethive_neo/helpers/formatters.dart';
import 'package:nethive_neo/providers/providers.dart';
import 'package:nethive_neo/theme/theme.dart';
import 'package:nethive_neo/widgets/shared/section_header.dart';
import 'package:provider/provider.dart';

class ReportesPage extends StatelessWidget {
  const ReportesPage({super.key});

  void _descargarPdfSimulado(BuildContext context, AppTheme theme) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          const SizedBox(height: 8),
          CircularProgressIndicator(color: theme.primaryColor, strokeWidth: 3),
          const SizedBox(height: 20),
          Text('Generando reporte PDF…',
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: theme.textPrimary)),
          const SizedBox(height: 6),
          Text('Compilando métricas operativas de Ensenada',
              style: TextStyle(fontSize: 12, color: theme.textSecondary),
              textAlign: TextAlign.center),
        ]),
      ),
    );
    Future.delayed(const Duration(seconds: 2), () {
      if (context.mounted) {
        Navigator.of(context, rootNavigator: true).pop();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Row(children: [
            const Icon(Icons.check_circle_outline,
                color: Colors.white, size: 18),
            const SizedBox(width: 10),
            const Text('Reporte PDF generado correctamente (simulado)'),
          ]),
          backgroundColor: theme.low,
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
        ));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final reporte = context.watch<ReporteProvider>();
    final kpiM = reporte.kpiMunicipal;
    final kpiE = reporte.kpiEstatal;
    final incProv = context.watch<IncidenciaProvider>();

    // Categoria breakdown
    final catMap = <String, int>{};
    for (final i in incProv.todas) {
      catMap[i.categoria] = (catMap[i.categoria] ?? 0) + 1;
    }
    final cats = catMap.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            title: 'Reportes y Analítica',
            subtitle:
                'Vista consolidada de métricas operativas — Ensenada · Baja California Norte',
            trailing: TextButton.icon(
              onPressed: () => _descargarPdfSimulado(context, theme),
              icon: const Icon(Icons.picture_as_pdf_outlined, size: 16),
              label: const Text('Descargar PDF'),
              style: TextButton.styleFrom(foregroundColor: theme.primaryColor),
            ),
          ),
          const SizedBox(height: 20),

          // KPI summary row — responsivo
          LayoutBuilder(builder: (ctx, box) {
            final isNarrow = box.maxWidth < 700;
            final resueltas = incProv.todas
                .where((i) => i.estatus == 'resuelto' || i.estatus == 'cerrado')
                .length;
            final tasaTexto = incProv.todas.isNotEmpty
                ? '${(resueltas / incProv.todas.length * 100).toStringAsFixed(0)}%'
                : '0%';
            final boxes = [
              _MetricBox(
                  label: 'Total incidencias',
                  value: '${incProv.todas.length}',
                  color: theme.medium,
                  theme: theme,
                  compact: isNarrow),
              _MetricBox(
                  label: 'Resueltas',
                  value: '$resueltas',
                  color: theme.low,
                  theme: theme,
                  compact: isNarrow),
              _MetricBox(
                  label: 'Tasa resolución',
                  value: tasaTexto,
                  color: theme.primaryColor,
                  theme: theme,
                  compact: isNarrow),
              _MetricBox(
                  label: 'SLA Municipal',
                  value: '${kpiM.cumplimientoSla.toStringAsFixed(1)}%',
                  color: kpiM.cumplimientoSla >= 90 ? theme.low : theme.high,
                  theme: theme,
                  compact: isNarrow),
              _MetricBox(
                  label: 'SLA Estatal',
                  value: '${kpiE.cumplimientoSla.toStringAsFixed(1)}%',
                  color: kpiE.cumplimientoSla >= 92 ? theme.low : theme.high,
                  theme: theme,
                  compact: isNarrow),
            ];
            if (isNarrow) {
              return Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: boxes
                      .map((b) =>
                          SizedBox(width: (box.maxWidth - 12) / 2, child: b))
                      .toList());
            }
            return Row(children: [
              for (int i = 0; i < boxes.length; i++) ...[
                if (i > 0) const SizedBox(width: 12),
                Expanded(child: boxes[i])
              ],
            ]);
          }),
          const SizedBox(height: 24),

          LayoutBuilder(builder: (ctx2, box2) {
            final isNarrowCharts = box2.maxWidth < 700;
            if (isNarrowCharts) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _TendenciaChartCard(reporte: reporte, theme: theme),
                  const SizedBox(height: 16),
                  _CategoriaBarCard(cats: cats, theme: theme),
                ],
              );
            }
            return IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                      flex: 5,
                      child:
                          _TendenciaChartCard(reporte: reporte, theme: theme)),
                  const SizedBox(width: 16),
                  Expanded(
                      flex: 5,
                      child: _CategoriaBarCard(cats: cats, theme: theme)),
                ],
              ),
            );
          }),
          const SizedBox(height: 24),

          // Status distribution
          _EstatusCard(incs: incProv.todas, theme: theme),
        ],
      ),
    );
  }
}

class _MetricBox extends StatelessWidget {
  const _MetricBox({
    required this.label,
    required this.value,
    required this.color,
    required this.theme,
    this.compact = false,
  });
  final String label, value;
  final Color color;
  final AppTheme theme;
  final bool compact;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(compact ? 12 : 16),
      decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.25))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(value,
            style: TextStyle(
                fontSize: compact ? 18 : 22,
                fontWeight: FontWeight.w800,
                color: color)),
        Text(label,
            style: TextStyle(
                fontSize: compact ? 11 : 12, color: theme.textSecondary)),
      ]),
    );
  }
}

class _TendenciaChartCard extends StatelessWidget {
  const _TendenciaChartCard({required this.reporte, required this.theme});
  final ReporteProvider reporte;
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
          ]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(Icons.trending_up, size: 18, color: theme.primaryColor),
          const SizedBox(width: 8),
          Text('Tendencia 7 Días',
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: theme.textPrimary)),
        ]),
        const SizedBox(height: 4),
        Row(children: [
          _Leg(color: theme.medium, label: 'Recibidas'),
          const SizedBox(width: 12),
          _Leg(color: theme.low, label: 'Resueltas'),
          const SizedBox(width: 12),
          _Leg(color: theme.critical, label: 'Críticas'),
        ]),
        const SizedBox(height: 16),
        SizedBox(
            height: 200,
            child: LineChart(LineChartData(
              gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (_) => FlLine(
                      color: theme.border.withOpacity(0.5), strokeWidth: 1)),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 36,
                        getTitlesWidget: (v, _) => Text('${v.toInt()}',
                            style: TextStyle(
                                fontSize: 10, color: theme.textSecondary)))),
                bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (v, _) {
                          const d = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];
                          final i = v.toInt();
                          if (i < 0 || i >= d.length) return const SizedBox();
                          return Text(d[i],
                              style: TextStyle(
                                  fontSize: 10, color: theme.textSecondary));
                        })),
                rightTitles:
                    AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles:
                    AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              borderData: FlBorderData(show: false),
              lineBarsData: [
                _line(reporte.tendenciaRecibidas, theme.medium),
                _line(reporte.tendenciaResueltas, theme.low),
                _line(reporte.tendenciaCriticas, theme.critical, dash: [4, 4]),
              ],
            ))),
      ]),
    );
  }

  LineChartBarData _line(List<double> vals, Color c, {List<int>? dash}) =>
      LineChartBarData(
          spots: [
            for (int i = 0; i < vals.length; i++) FlSpot(i.toDouble(), vals[i])
          ],
          isCurved: true,
          color: c,
          barWidth: 2.5,
          isStrokeCapRound: true,
          dotData: FlDotData(show: false),
          dashArray: dash,
          belowBarData:
              BarAreaData(show: dash == null, color: c.withOpacity(0.06)));
}

class _Leg extends StatelessWidget {
  const _Leg({required this.color, required this.label});
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

class _CategoriaBarCard extends StatelessWidget {
  const _CategoriaBarCard({required this.cats, required this.theme});
  final List<MapEntry<String, int>> cats;
  final AppTheme theme;
  static const _catColors = {
    'alumbrado': Color(0xFFD97706),
    'bacheo': Color(0xFF7A1E3A),
    'basura': Color(0xFF2D7A4F),
    'agua_drenaje': Color(0xFF1D4ED8),
    'senalizacion': Color(0xFF64748B),
    'seguridad': Color(0xFFB91C1C),
  };
  @override
  Widget build(BuildContext context) {
    final maxVal = cats.isEmpty ? 1 : cats.first.value;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: theme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.border),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)
          ]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(Icons.bar_chart, size: 18, color: theme.primaryColor),
          const SizedBox(width: 8),
          Text('Por Categoría',
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: theme.textPrimary)),
        ]),
        const SizedBox(height: 16),
        ...cats.map((e) {
          final color = _catColors[e.key] ?? theme.neutral;
          final pct = e.value / maxVal;
          return Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Row(children: [
                SizedBox(
                    width: 110,
                    child: Text(labelCategoria(e.key),
                        style:
                            TextStyle(fontSize: 12, color: theme.textPrimary))),
                Expanded(
                    child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                            value: pct,
                            minHeight: 10,
                            backgroundColor: theme.border,
                            valueColor: AlwaysStoppedAnimation(color)))),
                const SizedBox(width: 8),
                SizedBox(
                    width: 32,
                    child: Text('${e.value}',
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: theme.textSecondary),
                        textAlign: TextAlign.right)),
              ]));
        }),
      ]),
    );
  }
}

class _EstatusCard extends StatelessWidget {
  const _EstatusCard({required this.incs, required this.theme});
  final List<dynamic> incs;
  final AppTheme theme;
  @override
  Widget build(BuildContext context) {
    const statuses = [
      'recibido',
      'en_revision',
      'aprobado',
      'asignado',
      'en_proceso',
      'resuelto',
      'cerrado',
      'rechazado'
    ];
    final counts = <String, int>{for (final s in statuses) s: 0};
    for (final i in incs) {
      counts[i.estatus] = (counts[i.estatus] ?? 0) + 1;
    }
    final total = incs.length;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: theme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.border),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)
          ]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(Icons.pie_chart_outline, size: 18, color: theme.primaryColor),
          const SizedBox(width: 8),
          Text('Distribución por Estatus',
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: theme.textPrimary)),
        ]),
        const SizedBox(height: 16),
        Wrap(
            spacing: 12,
            runSpacing: 12,
            children: statuses.map((s) {
              final n = counts[s] ?? 0;
              final pct = total > 0 ? (n / total * 100) : 0.0;
              return Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                    color: theme.border.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(8)),
                child: Column(children: [
                  Text('$n',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: theme.textPrimary)),
                  Text(labelEstatus(s),
                      style:
                          TextStyle(fontSize: 11, color: theme.textSecondary)),
                  Text('${pct.toStringAsFixed(0)}%',
                      style:
                          TextStyle(fontSize: 10, color: theme.textSecondary)),
                ]),
              );
            }).toList()),
      ]),
    );
  }
}
