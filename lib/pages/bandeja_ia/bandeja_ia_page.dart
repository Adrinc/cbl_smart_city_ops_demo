import 'package:flutter/material.dart';
import 'package:nethive_neo/models/models.dart';
import 'package:nethive_neo/providers/providers.dart';
import 'package:nethive_neo/theme/theme.dart';
import 'package:nethive_neo/widgets/shared/section_header.dart';
import 'package:provider/provider.dart';
import 'widgets/bandeja_card.dart';
import 'widgets/confirmar_accion_dialog.dart';
import 'widgets/filter_bar_bandeja.dart';
import 'widgets/helpers_bandeja.dart';
import 'widgets/mapa_ubicacion_dialog.dart';
import 'widgets/pluto_bandeja_view.dart';
import 'package:nethive_neo/helpers/formatters.dart';

class BandejaIAPage extends StatefulWidget {
  const BandejaIAPage({super.key});
  @override
  State<BandejaIAPage> createState() => _BandejaIAPageState();
}

class _BandejaIAPageState extends State<BandejaIAPage> {
  String? _filterCategoria;
  String _filterVeredicto = 'todos';
  String _search = '';

  List<Incidencia> _filter(List<Incidencia> all) {
    var r = all;
    if (_filterCategoria != null)
      r = r.where((i) => i.categoria == _filterCategoria).toList();
    if (_filterVeredicto == 'recomienda_aprobar')
      r = r.where((i) => !esRechazoIA(i)).toList();
    if (_filterVeredicto == 'recomienda_rechazar')
      r = r.where((i) => esRechazoIA(i)).toList();
    if (_search.isNotEmpty)
      r = r
          .where((i) =>
              i.descripcion.toLowerCase().contains(_search.toLowerCase()) ||
              i.id.contains(_search))
          .toList();
    return r;
  }

  // Flujo confirmación → actualizar providers
  void _confirmAccion(BuildContext ctx, String tipo, Incidencia inc) {
    final iaRechaza = esRechazoIA(inc);
    showDialog(
      context: ctx,
      barrierDismissible: false,
      builder: (_) => ConfirmarAccionDialog(
        tipo: tipo,
        inc: inc,
        iaRechaza: iaRechaza,
        onConfirm: (motivo) {
          final bIa = ctx.read<BandejaIAProvider>();
          final bInc = ctx.read<IncidenciaProvider>();
          final aud = ctx.read<AuditoriaProvider>();
          if (tipo == 'aprobar') {
            bIa.aprobar(inc.id, prioridadOverride: inc.iaPrioridadSugerida);
            bInc.actualizarEstatus(inc.id, 'aprobado');
            aud.registrar(
              modulo: 'Bandeja IA',
              accion: 'APROBAR',
              descripcion:
                  'Aprobó incidencia ${formatIdIncidencia(inc.id)} — ${labelCategoria(inc.categoria)}',
              referenciaId: inc.id,
            );
            ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
                content: Text(
                    '${formatIdIncidencia(inc.id)} aprobado — enviado a Órdenes'),
                backgroundColor: const Color(0xFF2D7A4F)));
          } else {
            bIa.rechazar(inc.id);
            bInc.actualizarEstatus(inc.id, 'rechazado');
            aud.registrar(
              modulo: 'Bandeja IA',
              accion: 'RECHAZAR',
              descripcion: 'Rechazó incidencia ${formatIdIncidencia(inc.id)}'
                  '${motivo.isNotEmpty ? " · $motivo" : ""} — ${labelCategoria(inc.categoria)}',
              referenciaId: inc.id,
            );
            ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
                content: Text(
                    '${formatIdIncidencia(inc.id)} rechazado${motivo.isNotEmpty ? " · $motivo" : ""}'),
                backgroundColor: const Color(0xFF64748B)));
          }
        },
      ),
    );
  }

  void _bulkAprobar(BuildContext ctx, List<Incidencia> recomendados) {
    final bIa = ctx.read<BandejaIAProvider>();
    final bInc = ctx.read<IncidenciaProvider>();
    final aud = ctx.read<AuditoriaProvider>();
    for (final inc in recomendados) {
      bIa.aprobar(inc.id, prioridadOverride: inc.iaPrioridadSugerida);
      bInc.actualizarEstatus(inc.id, 'aprobado');
    }
    aud.registrar(
      modulo: 'Bandeja IA',
      accion: 'BULK_APROBAR',
      descripcion:
          'Aprobó en lote ${recomendados.length} incidencias recomendadas por IA',
    );
    ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
      content: Text(
          '${recomendados.length} incidencias aprobadas — enviadas a Órdenes'),
      backgroundColor: const Color(0xFF2D7A4F),
      duration: const Duration(seconds: 3),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final bandeja = context.watch<BandejaIAProvider>();
    final all = bandeja.pendientes;
    final pending = _filter(all);
    final cats = all.map((i) => i.categoria).toSet().toList()..sort();

    // Stats
    final nAprobar = all.where((i) => !esRechazoIA(i)).length;
    final nRechazar = all.where((i) => esRechazoIA(i)).length;
    final recomendados = all.where((i) => !esRechazoIA(i)).toList();

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Header
        SectionHeader(
          title: 'Bandeja de Revisión IA',
          subtitle:
              'Reportes ciudadanos clasificados por IA — requieren validación humana',
          trailing: all.isNotEmpty
              ? Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                      color: theme.high.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: theme.high.withOpacity(0.3))),
                  child: Text('${all.length} pendientes',
                      style: TextStyle(
                          color: theme.high,
                          fontSize: 12,
                          fontWeight: FontWeight.w700)))
              : null,
        ),
        const SizedBox(height: 10),

        // ─ Stats + Bulk action ────────────────────────────────────────
        if (all.isNotEmpty) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
                color: theme.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: theme.border),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.03), blurRadius: 6)
                ]),
            child: Row(children: [
              // Stat: recomienda aprobar
              _StatPill(
                icon: Icons.thumb_up_outlined,
                label: 'Recomienda aprobar',
                count: nAprobar,
                color: theme.low,
                theme: theme,
              ),
              Container(
                  width: 1,
                  height: 28,
                  color: theme.border,
                  margin: const EdgeInsets.symmetric(horizontal: 12)),
              // Stat: recomienda rechazar
              _StatPill(
                icon: Icons.thumb_down_outlined,
                label: 'Recomienda rechazar',
                count: nRechazar,
                color: theme.critical,
                theme: theme,
              ),
              const Spacer(),
              // Bulk approve
              if (nAprobar > 0)
                FilledButton.icon(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text('Aprobar todos los recomendados'),
                        content: Text(
                            'Se aprobarán $nAprobar incidencias que la IA recomienda aprobar.\n'
                            '¿Deseas continuar?'),
                        actions: [
                          TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Cancelar')),
                          FilledButton(
                            onPressed: () {
                              Navigator.pop(context);
                              _bulkAprobar(context, recomendados);
                            },
                            style: FilledButton.styleFrom(
                                backgroundColor: theme.low),
                            child: Text('Aprobar $nAprobar'),
                          ),
                        ],
                      ),
                    );
                  },
                  icon: const Icon(Icons.done_all, size: 16),
                  label: Text('Aprobar todos ($nAprobar)'),
                  style: FilledButton.styleFrom(
                    backgroundColor: theme.low,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    textStyle: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w700),
                  ),
                ),
            ]),
          ),
        ],

        // Info banner
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          margin: const EdgeInsets.only(bottom: 14),
          decoration: BoxDecoration(
              color: theme.medium.withOpacity(0.07),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: theme.medium.withOpacity(0.2))),
          child: Row(children: [
            Icon(Icons.psychology_outlined, color: theme.medium, size: 18),
            const SizedBox(width: 10),
            Expanded(
                child: Text(
                    'La IA valida coherencia texto-imagen y sugiere categoría y prioridad. '
                    'El operador aprueba o rechaza antes de generar la orden.',
                    style:
                        TextStyle(fontSize: 12, color: theme.textSecondary))),
          ]),
        ),

        // Filtros
        FilterBarBandeja(
          search: _search,
          filterCategoria: _filterCategoria,
          filterVeredicto: _filterVeredicto,
          cats: cats,
          theme: theme,
          onSearch: (v) => setState(() => _search = v),
          onCategoria: (v) => setState(() => _filterCategoria = v),
          onVeredicto: (v) => setState(() => _filterVeredicto = v ?? 'todos'),
        ),
        const SizedBox(height: 10),

        if (pending.length != all.length)
          Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text('${pending.length} de ${all.length} registros',
                  style: TextStyle(
                      fontSize: 12,
                      color: theme.textSecondary,
                      fontStyle: FontStyle.italic))),

        // Contenido
        if (pending.isEmpty)
          Expanded(
              child: Center(
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.check_circle_outline, size: 56, color: theme.low),
            const SizedBox(height: 12),
            Text('Sin resultados para la selección actual',
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: theme.textPrimary)),
          ])))
        else
          Expanded(child: LayoutBuilder(builder: (ctx, box) {
            if (box.maxWidth >= 800) {
              return PlutoBandejaView(
                items: pending,
                theme: theme,
                onConfirmAccion: (tipo, inc) =>
                    _confirmAccion(context, tipo, inc),
              );
            }
            return ListView.separated(
              itemCount: pending.length,
              separatorBuilder: (_, __) => const SizedBox(height: 14),
              itemBuilder: (_, i) => BandejaCard(
                inc: pending[i],
                onAprobar: (inc) => _confirmAccion(context, 'aprobar', inc),
                onRechazar: (inc) => _confirmAccion(context, 'rechazar', inc),
                onVerMapa: (inc) => showDialog(
                    context: context,
                    builder: (_) =>
                        MapaUbicacionDialog(inc: pending[i], theme: theme)),
              ),
            );
          })),
      ]),
    );
  }
}

// ---------------------------------------------------------------------------
class _StatPill extends StatelessWidget {
  const _StatPill({
    required this.icon,
    required this.label,
    required this.count,
    required this.color,
    required this.theme,
  });
  final IconData icon;
  final String label;
  final int count;
  final Color color;
  final AppTheme theme;

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
            color: color.withOpacity(0.10), shape: BoxShape.circle),
        child: Icon(icon, size: 14, color: color),
      ),
      const SizedBox(width: 8),
      Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('$count',
                style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w800, color: color)),
            Text(label,
                style: TextStyle(fontSize: 10, color: theme.textSecondary)),
          ]),
    ]);
  }
}
