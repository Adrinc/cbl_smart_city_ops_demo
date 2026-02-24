import 'package:flutter/material.dart';
import 'package:nethive_neo/helpers/formatters.dart';
import 'package:nethive_neo/models/models.dart';
import 'package:nethive_neo/theme/theme.dart';
import 'package:nethive_neo/widgets/shared/priority_badge.dart';
import 'helpers_bandeja.dart';
import 'imagen_viewer_dialog.dart';
import 'mapa_ubicacion_dialog.dart';

class BandejaCard extends StatefulWidget {
  const BandejaCard({
    super.key,
    required this.inc,
    required this.onAprobar,
    required this.onRechazar,
    required this.onVerMapa,
  });
  final Incidencia inc;
  final ValueChanged<Incidencia> onAprobar, onRechazar, onVerMapa;
  @override
  State<BandejaCard> createState() => _BandejaCardState();
}

class _BandejaCardState extends State<BandejaCard> {
  bool _expanded = true;

  @override
  Widget build(BuildContext context) {
    final theme     = AppTheme.of(context);
    final inc       = widget.inc;
    final conf      = inc.iaConfianza ?? 0.0;
    final confColor = conf >= 0.90 ? theme.low : conf >= 0.70 ? theme.high : theme.critical;
    final igRechaza = esRechazoIA(inc);
    final icon      = catIcon(inc.categoria);

    return Container(
      decoration: BoxDecoration(
        color: theme.surface, borderRadius: BorderRadius.circular(14),
        border: Border.all(color: igRechaza ? theme.neutral.withOpacity(0.35) : theme.border),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 3))]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

        // ── Header tap para expandir ──────────────────────────────────────
        InkWell(
          onTap: () => setState(() => _expanded = !_expanded),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
            child: Row(children: [
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                  color: (igRechaza ? theme.neutral : theme.primaryColor).withOpacity(0.1),
                  shape: BoxShape.circle),
                child: Icon(icon,
                  color: igRechaza ? theme.neutral : theme.primaryColor, size: 20)),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Text(formatIdIncidencia(inc.id),
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800,
                      color: igRechaza ? theme.textSecondary : theme.primaryColor)),
                  const SizedBox(width: 6),
                  Flexible(child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: theme.border.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(5)),
                    child: Text(labelCategoria(inc.categoria),
                      style: TextStyle(fontSize: 10, color: theme.textSecondary),
                      overflow: TextOverflow.ellipsis))),
                ]),
                const SizedBox(height: 4),
                Text(inc.descripcion,
                  style: TextStyle(fontSize: 12, color: theme.textPrimary),
                  maxLines: 2, overflow: TextOverflow.ellipsis),
              ])),
              const SizedBox(width: 6),
              Icon(_expanded ? Icons.expand_less : Icons.expand_more,
                color: theme.textSecondary, size: 20),
            ]),
          ),
        ),

        // ── Body expandido ────────────────────────────────────────────────
        if (_expanded) ...[
          Divider(height: 1, color: theme.border.withOpacity(0.5)),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              // Imagen
              if (inc.imagenPath != null) ...[
                Row(children: [
                  Icon(Icons.camera_alt_outlined, size: 12, color: theme.textSecondary),
                  const SizedBox(width: 4),
                  Text('IMAGEN DEL CIUDADANO', style: TextStyle(
                    fontSize: 10, fontWeight: FontWeight.w700, color: theme.textSecondary, letterSpacing: 0.7)),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: () => showDialog(context: context,
                      builder: (_) => ImagenViewerDialog(imagenPath: inc.imagenPath!, theme: theme)),
                    icon: Icon(Icons.open_in_full, size: 12, color: theme.medium),
                    label: Text('Ver grande', style: TextStyle(fontSize: 11, color: theme.medium)),
                    style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2))),
                ]),
                const SizedBox(height: 5),
                GestureDetector(
                  onTap: () => showDialog(context: context,
                    builder: (_) => ImagenViewerDialog(imagenPath: inc.imagenPath!, theme: theme)),
                  child: Container(
                    height: 150,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(9),
                      border: Border.all(color: igRechaza ? theme.neutral.withOpacity(0.3) : theme.border),
                      color: theme.background),
                    child: ClipRRect(borderRadius: BorderRadius.circular(8),
                      child: Stack(fit: StackFit.expand, children: [
                        Image.asset(inc.imagenPath!, fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Center(child: Icon(Icons.broken_image_outlined,
                            color: theme.textDisabled, size: 28))),
                        if (igRechaza)
                          Positioned(top: 7, right: 7, child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                            decoration: BoxDecoration(color: Colors.black.withOpacity(0.65),
                              borderRadius: BorderRadius.circular(5)),
                            child: const Row(mainAxisSize: MainAxisSize.min, children: [
                              Icon(Icons.not_interested, size: 10, color: Colors.white),
                              SizedBox(width: 2),
                              Text('No relevante', style: TextStyle(color: Colors.white,
                                fontSize: 9, fontWeight: FontWeight.w600)),
                            ]))),
                        Positioned(bottom: 5, left: 5, child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                          decoration: BoxDecoration(color: Colors.black.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(4)),
                          child: const Row(mainAxisSize: MainAxisSize.min, children: [
                            Icon(Icons.zoom_in, size: 10, color: Colors.white),
                            SizedBox(width: 2),
                            Text('Toca para ampliar', style: TextStyle(color: Colors.white, fontSize: 9)),
                          ]))),
                      ]))),
                ),
                const SizedBox(height: 12),
              ],

              // Ubicación
              GestureDetector(
                onTap: () => showDialog(context: context,
                  builder: (_) => MapaUbicacionDialog(inc: inc, theme: theme)),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(color: theme.background, borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: theme.border.withOpacity(0.6))),
                  child: Row(children: [
                    Icon(Icons.location_on_outlined, size: 14, color: theme.primaryColor),
                    const SizedBox(width: 8),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(approxDireccion(inc.latitud, inc.longitud),
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: theme.textPrimary),
                        overflow: TextOverflow.ellipsis),
                      Text('${inc.latitud.toStringAsFixed(4)}, ${inc.longitud.toStringAsFixed(4)}',
                        style: TextStyle(fontSize: 10, color: theme.textSecondary)),
                    ])),
                    Icon(Icons.map_outlined, size: 14, color: theme.medium),
                  ])),
              ),
              const SizedBox(height: 12),

              // IA panel
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: theme.medium.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: theme.medium.withOpacity(0.2))),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Icon(Icons.psychology_outlined, size: 13, color: theme.medium),
                    const SizedBox(width: 5),
                    Text('ANÁLISIS IA', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700,
                      color: theme.medium, letterSpacing: 0.8)),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(color: confColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20)),
                      child: Text('${(conf * 100).toStringAsFixed(1)}% confianza',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: confColor))),
                  ]),
                  const SizedBox(height: 8),
                  Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('Categoría sugerida', style: TextStyle(fontSize: 10,
                        color: theme.textSecondary, fontWeight: FontWeight.w600)),
                      Text(labelCategoria(inc.iaCategoriaSugerida ?? inc.categoria),
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: theme.textPrimary)),
                    ])),
                    const SizedBox(width: 12),
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('Prioridad sugerida', style: TextStyle(fontSize: 10,
                        color: theme.textSecondary, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 2),
                      PriorityBadge(prioridad: inc.iaPrioridadSugerida ?? inc.prioridad),
                    ]),
                  ]),
                  if (inc.iaCoherenciaNota != null) ...[
                    const SizedBox(height: 8),
                    Text(inc.iaCoherenciaNota!,
                      style: TextStyle(fontSize: 11, color: theme.textSecondary, fontStyle: FontStyle.italic),
                      maxLines: 3, overflow: TextOverflow.ellipsis),
                  ],
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                    decoration: BoxDecoration(
                      color: (igRechaza ? theme.neutral : theme.low).withOpacity(0.08),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: (igRechaza ? theme.neutral : theme.low).withOpacity(0.25))),
                    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Padding(padding: const EdgeInsets.only(top: 1),
                        child: Icon(igRechaza ? Icons.report_off : Icons.check_circle_outline,
                          size: 14, color: igRechaza ? theme.neutral : theme.low)),
                      const SizedBox(width: 6),
                      Expanded(child: Text(
                        igRechaza
                          ? 'IA recomienda RECHAZAR — imagen no relevante.'
                          : 'IA recomienda APROBAR — descripción e imagen coherentes.',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
                          color: igRechaza ? theme.neutral : theme.low))),
                    ]),
                  ),
                ]),
              ),
            ]),
          ),
        ],

        // ── Barra de acciones ─────────────────────────────────────────────
        Container(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
          decoration: BoxDecoration(color: theme.background,
            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(14))),
          child: Row(children: [
            if (inc.esReincidente)
              Container(
                margin: const EdgeInsets.only(right: 6),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(color: theme.high.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(5)),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.repeat, size: 11, color: theme.high),
                  const SizedBox(width: 2),
                  Text('Reincidente', style: TextStyle(fontSize: 10, color: theme.high, fontWeight: FontWeight.w600)),
                ])),
            const Spacer(),
            TextButton.icon(
              onPressed: () => widget.onVerMapa(inc),
              icon: Icon(Icons.map_outlined, size: 14, color: theme.medium),
              label: Text('Mapa', style: TextStyle(fontSize: 12, color: theme.medium)),
              style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6))),
            const SizedBox(width: 4),
            OutlinedButton.icon(
              onPressed: () => widget.onRechazar(inc),
              icon: const Icon(Icons.close, size: 14),
              label: const Text('Rechazar', overflow: TextOverflow.ellipsis),
              style: OutlinedButton.styleFrom(foregroundColor: theme.critical,
                side: BorderSide(color: theme.critical.withOpacity(0.45)),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6))),
            const SizedBox(width: 6),
            ElevatedButton.icon(
              onPressed: igRechaza ? null : () => widget.onAprobar(inc),
              icon: const Icon(Icons.check, size: 14),
              label: const Text('Aprobar', overflow: TextOverflow.ellipsis),
              style: ElevatedButton.styleFrom(
                backgroundColor: igRechaza ? theme.neutral : theme.low,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6))),
          ]),
        ),
      ]),
    );
  }
}