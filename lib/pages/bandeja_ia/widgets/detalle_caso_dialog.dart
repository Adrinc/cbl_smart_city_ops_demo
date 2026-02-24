import 'package:flutter/material.dart';
import 'package:nethive_neo/helpers/formatters.dart';
import 'package:nethive_neo/models/models.dart';
import 'package:nethive_neo/theme/theme.dart';
import 'package:nethive_neo/widgets/shared/priority_badge.dart';
import 'helpers_bandeja.dart';
import 'imagen_viewer_dialog.dart';

class DetalleCasoDialog extends StatelessWidget {
  const DetalleCasoDialog({
    super.key,
    required this.inc,
    required this.theme,
    required this.onAprobar,
    required this.onRechazar,
    required this.onVerMapa,
  });
  final Incidencia inc;
  final AppTheme theme;
  final VoidCallback onAprobar;
  final VoidCallback onRechazar;
  final VoidCallback onVerMapa;

  @override
  Widget build(BuildContext context) {
    final igRechaza = esRechazoIA(inc);
    final conf      = inc.iaConfianza ?? 0.0;
    final confColor = conf >= 0.90 ? theme.low : conf >= 0.70 ? theme.high : theme.critical;
    final icon      = catIcon(inc.categoria);
    final dir       = approxDireccion(inc.latitud, inc.longitud);
    final total     = MediaQuery.of(context).size;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      insetPadding: const EdgeInsets.all(20),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 680, maxHeight: total.height * 0.88),
        child: Column(children: [
          // ── Header ────────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 20, 14, 14),
            child: Row(children: [
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                  color: (igRechaza ? theme.neutral : theme.primaryColor).withOpacity(0.1),
                  shape: BoxShape.circle),
                child: Icon(icon,
                  color: igRechaza ? theme.neutral : theme.primaryColor, size: 22)),
              const SizedBox(width: 14),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Text(formatIdIncidencia(inc.id),
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800,
                      color: igRechaza ? theme.textSecondary : theme.primaryColor)),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(color: theme.border.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(6)),
                    child: Text(labelCategoria(inc.categoria),
                      style: TextStyle(fontSize: 11, color: theme.textSecondary))),
                  const Spacer(),
                  PriorityBadge(prioridad: inc.prioridad),
                ]),
                const SizedBox(height: 3),
                Text(inc.descripcion,
                  style: TextStyle(fontSize: 13, color: theme.textPrimary),
                  maxLines: 2, overflow: TextOverflow.ellipsis),
              ])),
              const SizedBox(width: 6),
              IconButton(icon: Icon(Icons.close, color: theme.textSecondary, size: 20),
                onPressed: () => Navigator.pop(context)),
            ]),
          ),
          Divider(height: 1, color: theme.border),

          // ── Cuerpo scrollable ─────────────────────────────────────────────
          Expanded(child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              // Fila imagen + datos
              LayoutBuilder(builder: (_, box) {
                final wide = box.maxWidth > 500;
                final imageWidget = _ImageSection(inc: inc, theme: theme);
                final infoWidget  = _InfoSection(inc: inc, theme: theme, dir: dir,
                  conf: conf, confColor: confColor, igRechaza: igRechaza);
                if (wide) return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Expanded(flex: 2, child: imageWidget),
                  const SizedBox(width: 16),
                  Expanded(flex: 3, child: infoWidget),
                ]);
                return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [imageWidget, const SizedBox(height: 16), infoWidget]);
              }),

              const SizedBox(height: 16),

              // Veredicto IA
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: (igRechaza ? theme.neutral : theme.low).withOpacity(0.07),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: (igRechaza ? theme.neutral : theme.low).withOpacity(0.3))),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Icon(Icons.psychology_outlined, size: 14, color: theme.medium),
                    const SizedBox(width: 5),
                    Text('ANÁLISIS IA', style: TextStyle(
                      fontSize: 10, fontWeight: FontWeight.w700, color: theme.medium, letterSpacing: 0.8)),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(color: confColor.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                      child: Text('${(conf * 100).toStringAsFixed(1)}% confianza',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: confColor))),
                  ]),
                  const SizedBox(height: 10),
                  Row(children: [
                    Expanded(child: _InfoRow(label: 'Categoría sugerida', value: labelCategoria(inc.iaCategoriaSugerida ?? inc.categoria), theme: theme)),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('Prioridad sugerida', style: TextStyle(fontSize: 10, color: theme.textSecondary, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 2),
                      PriorityBadge(prioridad: inc.iaPrioridadSugerida ?? inc.prioridad),
                    ])),
                  ]),
                  if (inc.iaCoherenciaNota != null) ...[
                    const SizedBox(height: 8),
                    Text(inc.iaCoherenciaNota!,
                      style: TextStyle(fontSize: 11, color: theme.textSecondary, fontStyle: FontStyle.italic)),
                  ],
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: (igRechaza ? theme.neutral : theme.low).withOpacity(0.08),
                      borderRadius: BorderRadius.circular(7),
                      border: Border.all(color: (igRechaza ? theme.neutral : theme.low).withOpacity(0.25))),
                    child: Row(children: [
                      Icon(igRechaza ? Icons.report_off : Icons.check_circle_outline, size: 14,
                        color: igRechaza ? theme.neutral : theme.low),
                      const SizedBox(width: 7),
                      Expanded(child: Text(
                        igRechaza
                          ? 'IA recomienda RECHAZAR — imagen no relevante para infraestructura pública.'
                          : 'IA recomienda APROBAR — descripción e imagen son coherentes con la categoría.',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
                          color: igRechaza ? theme.neutral : theme.low))),
                    ]),
                  ),
                ]),
              ),
            ]),
          )),

          // ── Footer actions ────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 18),
            child: Row(children: [
              OutlinedButton.icon(
                onPressed: onVerMapa,
                icon: Icon(Icons.map_outlined, size: 14, color: theme.medium),
                label: Text('Ver en mapa', style: TextStyle(color: theme.medium)),
                style: OutlinedButton.styleFrom(side: BorderSide(color: theme.medium.withOpacity(0.4)))),
              const Spacer(),
              OutlinedButton.icon(
                onPressed: () { Navigator.pop(context); onRechazar(); },
                icon: const Icon(Icons.close, size: 14),
                label: const Text('Rechazar'),
                style: OutlinedButton.styleFrom(foregroundColor: theme.critical,
                  side: BorderSide(color: theme.critical.withOpacity(0.4)))),
              const SizedBox(width: 10),
              ElevatedButton.icon(
                onPressed: igRechaza ? null : () { Navigator.pop(context); onAprobar(); },
                icon: const Icon(Icons.check, size: 14),
                label: const Text('Aprobar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: igRechaza ? theme.neutral : theme.low,
                  foregroundColor: Colors.white)),
            ]),
          ),
        ]),
      ),
    );
  }
}

// ── Sección imagen ─────────────────────────────────────────────────────────────
class _ImageSection extends StatelessWidget {
  const _ImageSection({required this.inc, required this.theme});
  final Incidencia inc;
  final AppTheme theme;

  @override
  Widget build(BuildContext context) {
    if (inc.imagenPath == null)
      return Container(height: 180,
        decoration: BoxDecoration(color: theme.background, borderRadius: BorderRadius.circular(10),
          border: Border.all(color: theme.border)),
        child: Center(child: Icon(Icons.image_not_supported_outlined, size: 40, color: theme.textDisabled)));
    return GestureDetector(
      onTap: () => showDialog(context: context,
        builder: (_) => ImagenViewerDialog(imagenPath: inc.imagenPath!, theme: theme)),
      child: Stack(children: [
        Container(height: 200,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: theme.background,
            border: Border.all(color: theme.border)),
          child: ClipRRect(borderRadius: BorderRadius.circular(9),
            child: Image.asset(inc.imagenPath!, fit: BoxFit.cover, width: double.infinity, height: 200,
              errorBuilder: (_, __, ___) => Center(child: Icon(Icons.broken_image_outlined,
                size: 36, color: theme.textDisabled))))),
        Positioned(bottom: 6, right: 6, child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
          decoration: BoxDecoration(color: Colors.black.withOpacity(0.55), borderRadius: BorderRadius.circular(5)),
          child: const Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.zoom_in, size: 11, color: Colors.white),
            SizedBox(width: 3),
            Text('Ampliar', style: TextStyle(color: Colors.white, fontSize: 9)),
          ]))),
      ]),
    );
  }
}

// ── Sección info del caso ──────────────────────────────────────────────────────
class _InfoSection extends StatelessWidget {
  const _InfoSection({required this.inc, required this.theme, required this.dir,
    required this.conf, required this.confColor, required this.igRechaza});
  final Incidencia inc;
  final AppTheme theme;
  final String dir;
  final double conf;
  final Color confColor;
  final bool igRechaza;

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _InfoRow(label: 'Fecha de reporte', value: formatFechaHora(inc.fechaReporte), theme: theme),
      _InfoRow(label: 'Entorno', value: labelEntorno(inc.entorno), theme: theme),
      _InfoRow(label: 'Estatus actual', value: labelEstatus(inc.estatus), theme: theme),
      _InfoRow(label: 'Reincidente', value: inc.esReincidente ? 'Sí — caso previo registrado' : 'No', theme: theme),
      const SizedBox(height: 10),
      // Ubicación
      Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: theme.background, borderRadius: BorderRadius.circular(8),
          border: Border.all(color: theme.border.withOpacity(0.6))),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Icon(Icons.location_on_outlined, size: 13, color: theme.primaryColor),
            const SizedBox(width: 4),
            Text('UBICACIÓN', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700,
              color: theme.textSecondary, letterSpacing: 0.8)),
          ]),
          const SizedBox(height: 4),
          Text(dir, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: theme.textPrimary)),
          Text('${inc.latitud.toStringAsFixed(5)}, ${inc.longitud.toStringAsFixed(5)}',
            style: TextStyle(fontSize: 10, color: theme.textSecondary)),
        ])),
      if (inc.fechaLimite != null) ...[
        const SizedBox(height: 8),
        _InfoRow(label: 'SLA límite', value: formatFechaHora(inc.fechaLimite!), theme: theme),
      ],
    ]);
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value, required this.theme});
  final String label, value;
  final AppTheme theme;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(width: 110, child: Text(label,
          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: theme.textSecondary))),
        Expanded(child: Text(value,
          style: TextStyle(fontSize: 12, color: theme.textPrimary, fontWeight: FontWeight.w500))),
      ]),
    );
  }
}