import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nethive_neo/helpers/constants.dart';
import 'package:nethive_neo/helpers/formatters.dart';
import 'package:nethive_neo/models/models.dart';
import 'package:nethive_neo/providers/providers.dart';
import 'package:nethive_neo/theme/theme.dart';
import 'package:nethive_neo/widgets/shared/alerta_row.dart';
import 'package:nethive_neo/widgets/shared/kpi_card.dart';
import 'package:nethive_neo/widgets/shared/section_header.dart';
import 'package:provider/provider.dart';

class VisionNacionalPage extends StatelessWidget {
  const VisionNacionalPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final reporte = context.watch<ReporteProvider>();
    final kpi = reporte.kpiNacional;
    final alertas = reporte.alertas;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ────────────────────────────────────────────────────────
          SectionHeader(
            title: 'Visión Nacional — México',
            subtitle:
                'Monitoreo integrado de los 32 estados · Actualizado hace 2 min',
            trailing: _NivelBadge(theme: theme),
          ),
          const SizedBox(height: 20),

          // ── KPI Row ────────────────────────────────────────────────────────
          _KpiRow(kpi: kpi, theme: theme),
          const SizedBox(height: 24),

          // ── Charts Row ───────────────────────────────────────────────────
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                    flex: 6, child: _TendenciaCard(kpi: kpi, theme: theme)),
                const SizedBox(width: 16),
                Expanded(
                    flex: 4, child: _CategoriaCard(kpi: kpi, theme: theme)),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // ── Estados + Alertas ─────────────────────────────────────────────
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(flex: 5, child: _EstadosCard(kpi: kpi, theme: theme)),
                const SizedBox(width: 16),
                Expanded(
                    flex: 5,
                    child: _AlertasCard(alertas: alertas, theme: theme)),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // ── CTA Baja California ───────────────────────────────────────────
          _CtaBajaCaliforniaCard(theme: theme),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Badge de nivel
// ─────────────────────────────────────────────────────────────────────────────
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
        Icon(Icons.public, size: 14, color: theme.primaryColor),
        const SizedBox(width: 6),
        Text('NIVEL NACIONAL',
            style: TextStyle(
              color: theme.primaryColor,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            )),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// KPI Row
// ─────────────────────────────────────────────────────────────────────────────
class _KpiRow extends StatelessWidget {
  const _KpiRow({required this.kpi, required this.theme});
  final KpiNacional kpi;
  final AppTheme theme;

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Expanded(
          child: KpiCard(
        icon: Icons.assignment_outlined,
        accentColor: theme.medium,
        value:
            '${kpi.incidenciasActivas.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}',
        title: 'Activas',
        subtitle: 'En proceso activo',
      )),
      const SizedBox(width: 12),
      Expanded(
          child: KpiCard(
        icon: Icons.warning_amber_rounded,
        accentColor: theme.critical,
        value: '${kpi.criticas}',
        title: 'Críticas',
        subtitle: 'Requieren acción inmediata',
      )),
      const SizedBox(width: 12),
      Expanded(
          child: KpiCard(
        icon: Icons.verified_outlined,
        accentColor: theme.low,
        value: '${kpi.cumplimientoSla.toStringAsFixed(1)} %',
        title: 'SLA Cumplido',
        subtitle: 'Promedio nacional',
      )),
      const SizedBox(width: 12),
      Expanded(
          child: KpiCard(
        icon: Icons.timer_outlined,
        accentColor: theme.high,
        value: '${kpi.porVencer}',
        title: 'Por Vencer',
        subtitle: 'Próximas 4 horas',
      )),
      const SizedBox(width: 12),
      Expanded(
          child: KpiCard(
        icon: Icons.engineering_outlined,
        accentColor: theme.primaryColor,
        value:
            '${kpi.tecnicosActivos.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}',
        title: 'Técnicos',
        subtitle: 'Activos en campo',
      )),
    ]);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Tendencia 7 días
// ─────────────────────────────────────────────────────────────────────────────
class _TendenciaCard extends StatelessWidget {
  const _TendenciaCard({required this.kpi, required this.theme});
  final KpiNacional kpi;
  final AppTheme theme;

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CardHeader(
            title: 'Tendencia — Últimos 7 días',
            icon: Icons.trending_up,
            theme: theme,
          ),
          const SizedBox(height: 4),
          Row(children: [
            _LegendDot(color: theme.medium, label: 'Recibidas'),
            const SizedBox(width: 16),
            _LegendDot(color: theme.low, label: 'Resueltas'),
            const SizedBox(width: 16),
            _LegendDot(color: theme.critical, label: 'Críticas'),
          ]),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (_) => FlLine(
                    color: theme.border.withOpacity(0.5),
                    strokeWidth: 1,
                  ),
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (v, m) => Text(
                        v.toInt().toString(),
                        style:
                            TextStyle(fontSize: 10, color: theme.textSecondary),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (v, m) {
                        const days = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];
                        final i = v.toInt();
                        if (i < 0 || i >= days.length) return const SizedBox();
                        return Text(days[i],
                            style: TextStyle(
                                fontSize: 10, color: theme.textSecondary));
                      },
                    ),
                  ),
                  rightTitles:
                      AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles:
                      AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  _buildLine(kpi.tendencia7Dias, theme.medium),
                  _buildLine(kpi.tendenciaResueltas, theme.low),
                  _buildLine(kpi.tendenciaCriticas, theme.critical,
                      dashed: true),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  LineChartBarData _buildLine(List<double> vals, Color color,
      {bool dashed = false}) {
    return LineChartBarData(
      spots: [
        for (int i = 0; i < vals.length; i++) FlSpot(i.toDouble(), vals[i])
      ],
      isCurved: true,
      color: color,
      barWidth: 2.5,
      isStrokeCapRound: true,
      dotData: FlDotData(show: false),
      dashArray: dashed ? [4, 4] : null,
      belowBarData: BarAreaData(
        show: !dashed,
        color: color.withOpacity(0.06),
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});
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

// ─────────────────────────────────────────────────────────────────────────────
// Categorías
// ─────────────────────────────────────────────────────────────────────────────
class _CategoriaCard extends StatelessWidget {
  const _CategoriaCard({required this.kpi, required this.theme});
  final KpiNacional kpi;
  final AppTheme theme;

  static const _catColors = {
    'alumbrado': Color(0xFFD97706),
    'bacheo': Color(0xFF7A1E3A),
    'basura': Color(0xFF2D7A4F),
    'agua_drenaje': Color(0xFF1D4ED8),
    'senalizacion': Color(0xFF64748B),
    'seguridad': Color(0xFFB91C1C),
  };

  static const _catIcons = {
    'alumbrado': Icons.lightbulb_outline,
    'bacheo': Icons.construction,
    'basura': Icons.delete_outline,
    'agua_drenaje': Icons.water_drop_outlined,
    'senalizacion': Icons.signpost_outlined,
    'seguridad': Icons.security,
  };

  @override
  Widget build(BuildContext context) {
    final sorted = kpi.porCategoria.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final total = sorted.fold(0, (s, e) => s + e.value);

    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CardHeader(
            title: 'Por Categoría',
            icon: Icons.category_outlined,
            theme: theme,
          ),
          const SizedBox(height: 16),
          ...sorted.map((e) {
            final pct = total > 0 ? e.value / total : 0.0;
            final color = _catColors[e.key] ?? theme.neutral;
            final icon = _catIcons[e.key] ?? Icons.help_outline;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(children: [
                Icon(icon, size: 16, color: color),
                const SizedBox(width: 8),
                SizedBox(
                  width: 90,
                  child: Text(
                    labelCategoria(e.key),
                    style: TextStyle(fontSize: 12, color: theme.textPrimary),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: LinearProgressIndicator(
                      value: pct,
                      minHeight: 8,
                      backgroundColor: theme.border,
                      valueColor: AlwaysStoppedAnimation(color),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 34,
                  child: Text(
                    '${e.value}',
                    style: TextStyle(
                        fontSize: 11,
                        color: theme.textSecondary,
                        fontWeight: FontWeight.w600),
                    textAlign: TextAlign.right,
                  ),
                ),
              ]),
            );
          }),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Top Estados
// ─────────────────────────────────────────────────────────────────────────────
class _EstadosCard extends StatelessWidget {
  const _EstadosCard({required this.kpi, required this.theme});
  final KpiNacional kpi;
  final AppTheme theme;

  // Datos enriquecidos por estado (criticas, sla) — hardcodeados para demo
  static const _estadoMeta = {
    'Ciudad de México': {'criticas': 78, 'sla': 82.1},
    'Jalisco': {'criticas': 42, 'sla': 88.5},
    'Nuevo León': {'criticas': 38, 'sla': 90.2},
    'Veracruz': {'criticas': 51, 'sla': 79.4},
    'Estado de México': {'criticas': 29, 'sla': 85.7},
    'Guanajuato': {'criticas': 21, 'sla': 91.8},
    'Baja California Norte': {'criticas': 43, 'sla': 91.2},
    'Sonora': {'criticas': 18, 'sla': 93.1},
    'Chihuahua': {'criticas': 16, 'sla': 88.9},
    'Otros': {'criticas': 53, 'sla': 86.3},
  };

  Color _slaColor(double sla) {
    if (sla >= 90) return const Color(0xFF2D7A4F);
    if (sla >= 80) return const Color(0xFFD97706);
    return const Color(0xFFB91C1C);
  }

  @override
  Widget build(BuildContext context) {
    final sorted = kpi.porEstado.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final maxVal = sorted.isEmpty ? 1 : sorted.first.value;

    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CardHeader(
            title: 'Distribución por Estado',
            icon: Icons.map_outlined,
            theme: theme,
          ),
          const SizedBox(height: 8),
          // Table header
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(children: [
              Expanded(
                  flex: 4,
                  child: Text('Estado',
                      style: TextStyle(
                          fontSize: 11,
                          color: theme.textSecondary,
                          fontWeight: FontWeight.w600))),
              SizedBox(
                  width: 80,
                  child: Text('Incidencias',
                      style: TextStyle(
                          fontSize: 11,
                          color: theme.textSecondary,
                          fontWeight: FontWeight.w600),
                      textAlign: TextAlign.center)),
              SizedBox(
                  width: 50,
                  child: Text('Crit.',
                      style: TextStyle(
                          fontSize: 11,
                          color: theme.textSecondary,
                          fontWeight: FontWeight.w600),
                      textAlign: TextAlign.center)),
              SizedBox(
                  width: 55,
                  child: Text('SLA %',
                      style: TextStyle(
                          fontSize: 11,
                          color: theme.textSecondary,
                          fontWeight: FontWeight.w600),
                      textAlign: TextAlign.right)),
            ]),
          ),
          Divider(color: theme.border, height: 1),
          ...sorted.map((e) {
            final pct = e.value / maxVal;
            final meta = _estadoMeta[e.key] ?? {'criticas': 0, 'sla': 87.0};
            final criticas = meta['criticas'] as int;
            final sla = (meta['sla'] as double);
            final isDemo = e.key == 'Baja California Norte';

            return Container(
              decoration: isDemo
                  ? BoxDecoration(
                      color: theme.primaryColor.withOpacity(0.04),
                      border: Border(
                          left:
                              BorderSide(color: theme.primaryColor, width: 3)))
                  : null,
              child: Padding(
                padding: EdgeInsets.symmetric(
                    vertical: 8, horizontal: isDemo ? 8 : 0),
                child: Row(children: [
                  Expanded(
                      flex: 4,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(e.key,
                              style: TextStyle(
                                fontSize: 12,
                                color: theme.textPrimary,
                                fontWeight:
                                    isDemo ? FontWeight.w700 : FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 3),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(2),
                            child: LinearProgressIndicator(
                              value: pct,
                              minHeight: 4,
                              backgroundColor: theme.border,
                              valueColor: AlwaysStoppedAnimation(isDemo
                                  ? theme.primaryColor
                                  : theme.medium.withOpacity(0.6)),
                            ),
                          ),
                        ],
                      )),
                  SizedBox(
                      width: 80,
                      child: Text('${e.value}',
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: theme.textPrimary),
                          textAlign: TextAlign.center)),
                  SizedBox(
                      width: 50,
                      child: Text('$criticas',
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: criticas > 40
                                  ? theme.critical
                                  : theme.textSecondary),
                          textAlign: TextAlign.center)),
                  SizedBox(
                      width: 55,
                      child: Text('${sla.toStringAsFixed(1)}%',
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: _slaColor(sla)),
                          textAlign: TextAlign.right)),
                ]),
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Alertas Críticas
// ─────────────────────────────────────────────────────────────────────────────
class _AlertasCard extends StatelessWidget {
  const _AlertasCard({required this.alertas, required this.theme});
  final List<AlertaEstatal> alertas;
  final AppTheme theme;

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CardHeader(
            title: 'Alertas Activas',
            icon: Icons.notifications_active_outlined,
            theme: theme,
            badge: alertas.length.toString(),
            badgeColor: theme.critical,
          ),
          const SizedBox(height: 8),
          ...alertas.map((a) => AlertaRow(alerta: a)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CTA Baja California Norte
// ─────────────────────────────────────────────────────────────────────────────
class _CtaBajaCaliforniaCard extends StatelessWidget {
  const _CtaBajaCaliforniaCard({required this.theme});
  final AppTheme theme;

  @override
  Widget build(BuildContext context) {
    final appLevel = context.read<AppLevelProvider>();
    return InkWell(
      onTap: () {
        appLevel.setNivel(NivelTerritorial.estatal);
        context.go(routeEstatal);
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [theme.primaryColor, const Color(0xFF9B2C4E)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: theme.primaryColor.withOpacity(0.3),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(children: [
          const Icon(Icons.location_on_outlined, color: Colors.white, size: 32),
          const SizedBox(width: 16),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                const Text('Estado Seleccionado — Demo',
                    style: TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                        letterSpacing: 0.5)),
                const SizedBox(height: 2),
                const Text('Baja California Norte',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text(
                    '329 incidencias activas · 43 críticas · 91.2% SLA · 58 técnicos',
                    style:
                        const TextStyle(color: Colors.white70, fontSize: 12)),
              ])),
          const SizedBox(width: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white.withOpacity(0.4)),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: const [
              Text('Ir al Estado',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 13)),
              SizedBox(width: 6),
              Icon(Icons.arrow_forward, color: Colors.white, size: 16),
            ]),
          ),
        ]),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared card container
// ─────────────────────────────────────────────────────────────────────────────
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
              offset: const Offset(0, 2)),
        ],
      ),
      child: child,
    );
  }
}

class _CardHeader extends StatelessWidget {
  const _CardHeader({
    required this.title,
    required this.icon,
    required this.theme,
    this.badge,
    this.badgeColor,
  });
  final String title;
  final IconData icon;
  final AppTheme theme;
  final String? badge;
  final Color? badgeColor;

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Icon(icon, size: 18, color: theme.primaryColor),
      const SizedBox(width: 8),
      Text(title,
          style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: theme.textPrimary)),
      if (badge != null) ...[
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: (badgeColor ?? theme.critical).withOpacity(0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(badge!,
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: badgeColor ?? theme.critical)),
        ),
      ],
    ]);
  }
}
