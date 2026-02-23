import 'package:flutter/material.dart';
import 'package:nethive_neo/helpers/formatters.dart';
import 'package:nethive_neo/models/models.dart';
import 'package:nethive_neo/providers/providers.dart';
import 'package:nethive_neo/theme/theme.dart';
import 'package:nethive_neo/widgets/shared/priority_badge.dart';
import 'package:nethive_neo/widgets/shared/section_header.dart';
import 'package:provider/provider.dart';

class BandejaIAPage extends StatelessWidget {
  const BandejaIAPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme   = AppTheme.of(context);
    final bandeja = context.watch<BandejaIAProvider>();
    final pending = bandeja.pendientes;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            title: 'Bandeja de Revisión IA',
            subtitle: 'Reportes clasificados por IA que requieren validación humana',
            trailing: pending.isNotEmpty
              ? Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: theme.high.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: theme.high.withOpacity(0.3)),
                  ),
                  child: Text('${pending.length} pendientes',
                    style: TextStyle(color: theme.high, fontSize: 12, fontWeight: FontWeight.w700)),
                )
              : null,
          ),
          const SizedBox(height: 8),

          // Explicación IA
          Container(
            padding: const EdgeInsets.all(14),
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: theme.medium.withOpacity(0.07),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: theme.medium.withOpacity(0.2)),
            ),
            child: Row(children: [
              Icon(Icons.psychology_outlined, color: theme.medium, size: 20),
              const SizedBox(width: 10),
              Expanded(child: Text(
                'La IA valida la coherencia texto-imagen y sugiere categoría y prioridad. '
                'El operador humano revisa y aprueba o rechaza cada reporte antes de generar la orden de trabajo.',
                style: TextStyle(fontSize: 12, color: theme.textSecondary),
              )),
            ]),
          ),

          if (pending.isEmpty)
            Center(child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 48),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.check_circle_outline, size: 56, color: theme.low),
                const SizedBox(height: 12),
                Text('Bandeja vacía — todos los reportes han sido revisados',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: theme.textPrimary)),
                const SizedBox(height: 4),
                Text('¡Excelente trabajo!', style: TextStyle(fontSize: 13, color: theme.textSecondary)),
              ]),
            ))
          else
            ...pending.map((inc) => _BandejaCard(inc: inc, theme: theme)),
        ],
      ),
    );
  }
}

class _BandejaCard extends StatefulWidget {
  const _BandejaCard({required this.inc, required this.theme});
  final Incidencia inc;
  final AppTheme theme;
  @override
  State<_BandejaCard> createState() => _BandejaCardState();
}

class _BandejaCardState extends State<_BandejaCard> {
  bool _expanded = false;

  static const _catIcons = <String, IconData>{
    'alumbrado':    Icons.lightbulb_outline,
    'bacheo':       Icons.construction,
    'basura':       Icons.delete_outline,
    'agua_drenaje': Icons.water_drop_outlined,
    'senalizacion': Icons.signpost_outlined,
    'seguridad':    Icons.security,
  };

  @override
  Widget build(BuildContext context) {
    final theme  = widget.theme;
    final inc    = widget.inc;
    final conf   = inc.iaConfianza ?? 0.0;
    final confColor = conf >= 0.90 ? theme.low : conf >= 0.70 ? theme.high : theme.critical;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.border),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(children: [
                // Category icon
                Container(
                  width: 42, height: 42,
                  decoration: BoxDecoration(color: theme.primaryColor.withOpacity(0.1), shape: BoxShape.circle),
                  child: Icon(_catIcons[inc.categoria] ?? Icons.help_outline, color: theme.primaryColor, size: 20),
                ),
                const SizedBox(width: 14),
                // Info
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Text(formatIdIncidencia(inc.id),
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: theme.primaryColor)),
                      const SizedBox(width: 8),
                      Text(labelCategoria(inc.categoria),
                        style: TextStyle(fontSize: 12, color: theme.textSecondary)),
                      const Spacer(),
                      Text(formatFechaHora(inc.fechaReporte),
                        style: TextStyle(fontSize: 11, color: theme.textSecondary)),
                    ]),
                    const SizedBox(height: 4),
                    Text(inc.descripcion,
                      style: TextStyle(fontSize: 13, color: theme.textPrimary),
                      maxLines: 2, overflow: TextOverflow.ellipsis),
                  ],
                )),
                const SizedBox(width: 12),
                Icon(_expanded ? Icons.expand_less : Icons.expand_more, color: theme.textSecondary),
              ]),
            ),
          ),

          // IA Suggestion bar
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.medium.withOpacity(0.06),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: theme.medium.withOpacity(0.2)),
            ),
            child: Row(children: [
              Icon(Icons.psychology_outlined, size: 16, color: theme.medium),
              const SizedBox(width: 8),
              Text('IA — ', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: theme.medium)),
              Text('Categoría: ', style: TextStyle(fontSize: 12, color: theme.textSecondary)),
              Text(labelCategoria(inc.iaCategoriaSugerida ?? inc.categoria),
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: theme.textPrimary)),
              const SizedBox(width: 12),
              Text('Prioridad: ', style: TextStyle(fontSize: 12, color: theme.textSecondary)),
              PriorityBadge(prioridad: inc.iaPrioridadSugerida ?? inc.prioridad),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: confColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text('${(conf * 100).toStringAsFixed(1)}% confianza',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: confColor)),
              ),
            ]),
          ),

          // Expanded detail
          if (_expanded && inc.iaCoherenciaNota != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: theme.high.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: theme.high.withOpacity(0.2)),
                ),
                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Icon(Icons.info_outline, size: 14, color: theme.high),
                  const SizedBox(width: 6),
                  Expanded(child: Text(inc.iaCoherenciaNota!,
                    style: TextStyle(fontSize: 12, color: theme.textSecondary))),
                ]),
              ),
            ),

          // Actions
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(children: [
              if (inc.esReincidente)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: theme.high.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.repeat, size: 13, color: theme.high),
                    const SizedBox(width: 4),
                    Text('Reincidente', style: TextStyle(fontSize: 11, color: theme.high, fontWeight: FontWeight.w600)),
                  ]),
                ),
              const Spacer(),
              OutlinedButton.icon(
                onPressed: () {
                  context.read<BandejaIAProvider>().rechazar(inc.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${formatIdIncidencia(inc.id)} rechazado'),
                      backgroundColor: theme.neutral));
                },
                icon: const Icon(Icons.close, size: 16),
                label: const Text('Rechazar'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: theme.critical,
                  side: BorderSide(color: theme.critical.withOpacity(0.5)),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: () {
                  context.read<BandejaIAProvider>().aprobar(inc.id,
                    prioridadOverride: inc.iaPrioridadSugerida);
                  context.read<IncidenciaProvider>().actualizarEstatus(inc.id, 'aprobado');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${formatIdIncidencia(inc.id)} aprobado y enviado a Órdenes'),
                      backgroundColor: theme.low,
                    ));
                },
                icon: const Icon(Icons.check, size: 16),
                label: const Text('Aprobar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.low,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }
}
