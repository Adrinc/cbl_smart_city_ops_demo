import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nethive_neo/helpers/constants.dart';
import 'package:nethive_neo/models/models.dart';
import 'package:nethive_neo/providers/providers.dart';
import 'package:nethive_neo/theme/theme.dart';
import 'package:nethive_neo/widgets/shared/alerta_row.dart';
import 'package:nethive_neo/widgets/shared/kpi_card.dart';
import 'package:nethive_neo/widgets/shared/section_header.dart';
import 'package:provider/provider.dart';

class CentroEstatalPage extends StatelessWidget {
  const CentroEstatalPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme   = AppTheme.of(context);
    final reporte = context.watch<ReporteProvider>();
    final kpi     = reporte.kpiEstatal;
    final alertas = reporte.alertas;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            title: 'Centro Operativo Estatal — Baja California Norte',
            subtitle: 'Coordinación de 5 municipios · SLA regional ${kpi.cumplimientoSla.toStringAsFixed(1)}%',
            trailing: _NivelBadge(theme: theme),
          ),
          const SizedBox(height: 20),

          // KPI Row
          Row(children: [
            Expanded(child: KpiCard(
              icon: Icons.assignment_outlined,
              accentColor: theme.medium,
              value: '${kpi.incidenciasActivas}',
              title: 'Activas',
              subtitle: 'Estado completo',
            )),
            const SizedBox(width: 12),
            Expanded(child: KpiCard(
              icon: Icons.warning_amber_rounded,
              accentColor: theme.critical,
              value: '${kpi.criticas}',
              title: 'Críticas',
              subtitle: 'Acción inmediata',
            )),
            const SizedBox(width: 12),
            Expanded(child: KpiCard(
              icon: Icons.verified_outlined,
              accentColor: theme.low,
              value: '${kpi.cumplimientoSla.toStringAsFixed(1)} %',
              title: 'SLA Regional',
              subtitle: 'Cumplimiento',
            )),
            const SizedBox(width: 12),
            Expanded(child: KpiCard(
              icon: Icons.timer_outlined,
              accentColor: theme.high,
              value: '${kpi.porVencer}',
              title: 'Por Vencer',
              subtitle: 'Próximas 4 h',
            )),
            const SizedBox(width: 12),
            Expanded(child: KpiCard(
              icon: Icons.engineering_outlined,
              accentColor: theme.primaryColor,
              value: '${kpi.tecnicosActivos}',
              title: 'Técnicos',
              subtitle: 'En campo',
            )),
          ]),
          const SizedBox(height: 24),

          // Municipios + Alertas
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(flex: 6, child: _MunicipiosCard(kpi: kpi, theme: theme)),
                const SizedBox(width: 16),
                Expanded(flex: 4, child: _AlertasCard(alertas: alertas, theme: theme)),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // CTA Ensenada
          _CtaEnsenadaCard(theme: theme),
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
        color: theme.medium.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.medium.withOpacity(0.3)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.account_balance_outlined, size: 14, color: theme.medium),
        const SizedBox(width: 6),
        Text('NIVEL ESTATAL', style: TextStyle(
          color: theme.medium, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.5)),
      ]),
    );
  }
}

class _MunicipiosCard extends StatelessWidget {
  const _MunicipiosCard({required this.kpi, required this.theme});
  final KpiEstatal kpi;
  final AppTheme theme;

  static const _municipioCriticas = {
    'Tijuana': 22, 'Mexicali': 11, 'Ensenada': 10, 'Tecate': 5, 'Rosarito': 2,
  };
  static const _municipioSla = {
    'Tijuana': 88.4, 'Mexicali': 92.7, 'Ensenada': 89.0, 'Tecate': 94.2, 'Rosarito': 96.8,
  };

  Color _slaColor(double sla) {
    if (sla >= 93) return const Color(0xFF2D7A4F);
    if (sla >= 88) return const Color(0xFFD97706);
    return const Color(0xFFB91C1C);
  }

  @override
  Widget build(BuildContext context) {
    final sorted = kpi.porMunicipio.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final maxVal = sorted.isEmpty ? 1 : sorted.first.value;

    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CardHeader(title: 'Municipios — Baja California Norte', icon: Icons.location_city, theme: theme),
          const SizedBox(height: 8),
          // header row
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(children: [
              Expanded(flex: 3, child: Text('Municipio', style: TextStyle(fontSize: 11, color: theme.textSecondary, fontWeight: FontWeight.w600))),
              SizedBox(width: 80, child: Text('Incidencias', style: TextStyle(fontSize: 11, color: theme.textSecondary, fontWeight: FontWeight.w600), textAlign: TextAlign.center)),
              SizedBox(width: 50, child: Text('Crit.', style: TextStyle(fontSize: 11, color: theme.textSecondary, fontWeight: FontWeight.w600), textAlign: TextAlign.center)),
              SizedBox(width: 55, child: Text('SLA %', style: TextStyle(fontSize: 11, color: theme.textSecondary, fontWeight: FontWeight.w600), textAlign: TextAlign.right)),
            ]),
          ),
          Divider(color: theme.border, height: 1),
          ...sorted.map((e) {
            final isDemo = e.key == 'Ensenada';
            final pct = e.value / maxVal;
            final criticas = _municipioCriticas[e.key] ?? 0;
            final sla = _municipioSla[e.key] ?? 90.0;

            return Container(
              decoration: isDemo
                ? BoxDecoration(
                    color: theme.primaryColor.withOpacity(0.05),
                    border: Border(left: BorderSide(color: theme.primaryColor, width: 3)))
                : null,
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: isDemo ? 8.0 : 0.0),
                child: Row(children: [
                  Expanded(flex: 3, child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(e.key, style: TextStyle(
                        fontSize: 13, color: theme.textPrimary,
                        fontWeight: isDemo ? FontWeight.w700 : FontWeight.w500)),
                      const SizedBox(height: 3),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(2),
                        child: LinearProgressIndicator(
                          value: pct, minHeight: 5,
                          backgroundColor: theme.border,
                          valueColor: AlwaysStoppedAnimation(
                              isDemo ? theme.primaryColor : theme.medium.withOpacity(0.6)),
                        ),
                      ),
                    ],
                  )),
                  SizedBox(width: 80, child: Text('${e.value}',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: theme.textPrimary),
                    textAlign: TextAlign.center)),
                  SizedBox(width: 50, child: Text('$criticas',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
                        color: criticas > 15 ? theme.critical : theme.textSecondary),
                    textAlign: TextAlign.center)),
                  SizedBox(width: 55, child: Text('${sla.toStringAsFixed(1)}%',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: _slaColor(sla)),
                    textAlign: TextAlign.right)),
                ]),
              ),
            );
          }),
          const SizedBox(height: 12),
          Text('* Municipio seleccionado para demo operativo',
            style: TextStyle(fontSize: 11, color: theme.textSecondary, fontStyle: FontStyle.italic)),
        ],
      ),
    );
  }
}

class _AlertasCard extends StatelessWidget {
  const _AlertasCard({required this.alertas, required this.theme});
  final List<AlertaEstatal> alertas;
  final AppTheme theme;

  @override
  Widget build(BuildContext context) {
    final filtered = alertas.take(4).toList();
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CardHeader(
            title: 'Alertas Activas', icon: Icons.notifications_active_outlined,
            theme: theme, badge: alertas.length.toString(), badgeColor: theme.critical,
          ),
          const SizedBox(height: 8),
          ...filtered.map((a) => AlertaRow(alerta: a)),
          if (alertas.length > 4)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text('+${alertas.length - 4} alertas más',
                style: TextStyle(fontSize: 11, color: theme.textSecondary)),
            ),
        ],
      ),
    );
  }
}

class _CtaEnsenadaCard extends StatelessWidget {
  const _CtaEnsenadaCard({required this.theme});
  final AppTheme theme;

  @override
  Widget build(BuildContext context) {
    final appLevel = context.read<AppLevelProvider>();
    return InkWell(
      onTap: () {
        appLevel.setNivel(NivelTerritorial.municipal);
        context.go(routeMunicipal);
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [theme.primaryColor, const Color(0xFF9B2C4E)],
            begin: Alignment.centerLeft, end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: theme.primaryColor.withOpacity(0.3), blurRadius: 16, offset: const Offset(0, 4))],
        ),
        child: Row(children: [
          const Icon(Icons.location_on_outlined, color: Colors.white, size: 32),
          const SizedBox(width: 16),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Municipio Seleccionado — Demo',
              style: TextStyle(color: Colors.white70, fontSize: 11, letterSpacing: 0.5)),
            const SizedBox(height: 2),
            const Text('Ensenada', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            const Text('56 activas · 10 críticas · 89.0% SLA · 13 técnicos',
              style: TextStyle(color: Colors.white70, fontSize: 12)),
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
              Text('Entrar al Municipio', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
              SizedBox(width: 6),
              Icon(Icons.arrow_forward, color: Colors.white, size: 16),
            ]),
          ),
        ]),
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
      width: double.infinity, padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.surface, borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.border),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: child,
    );
  }
}

class _CardHeader extends StatelessWidget {
  const _CardHeader({required this.title, required this.icon, required this.theme, this.badge, this.badgeColor});
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
      Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: theme.textPrimary)),
      if (badge != null) ...[
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: (badgeColor ?? theme.critical).withOpacity(0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(badge!, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: badgeColor ?? theme.critical)),
        ),
      ],
    ]);
  }
}
