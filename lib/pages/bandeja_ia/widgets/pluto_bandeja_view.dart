import 'package:flutter/material.dart';
import 'package:nethive_neo/helpers/formatters.dart';
import 'package:nethive_neo/models/models.dart';
import 'package:nethive_neo/theme/theme.dart';
import 'package:nethive_neo/widgets/shared/priority_badge.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'helpers_bandeja.dart';
import 'imagen_viewer_dialog.dart';
import 'mapa_ubicacion_dialog.dart';
import 'detalle_caso_dialog.dart';

class PlutoBandejaView extends StatelessWidget {
  const PlutoBandejaView({
    super.key,
    required this.items,
    required this.theme,
    required this.onConfirmAccion,
  });
  final List<Incidencia> items;
  final AppTheme theme;
  final void Function(String tipo, Incidencia inc) onConfirmAccion;

  // ── Columnas ────────────────────────────────────────────────────────────────
  List<PlutoColumn> _cols(BuildContext context) => [
        // ID
        PlutoColumn(
            title: 'ID',
            field: 'id',
            type: PlutoColumnType.text(),
            width: 88,
            renderer: (r) => Text(formatIdIncidencia(r.cell.value),
                style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: theme.primaryColor,
                    fontSize: 12))),

        // Imagen thumbnail
        PlutoColumn(
            title: '',
            field: 'img',
            type: PlutoColumnType.text(),
            width: 70,
            enableSorting: false,
            enableFilterMenuItem: false,
            renderer: (r) {
              final inc = _inc(r);
              final path = inc?.imagenPath;
              if (path == null || path.isEmpty) {
                return Center(
                    child: Icon(catIcon(inc?.categoria ?? ''),
                        size: 20, color: theme.textDisabled));
              }
              return GestureDetector(
                  onTap: () => showDialog(
                      context: context,
                      builder: (_) =>
                          ImagenViewerDialog(imagenPath: path, theme: theme)),
                  child: Tooltip(
                      message: 'Clic para ampliar',
                      child: Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: theme.border)),
                          child: ClipRRect(
                              borderRadius: BorderRadius.circular(5),
                              child: Image.asset(path,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Center(
                                      child: Icon(catIcon(inc?.categoria ?? ''),
                                          size: 20,
                                          color: theme.textDisabled)))))));
            }),

        // Categoría con ícono
        PlutoColumn(
            title: 'Categoría',
            field: 'categoria',
            type: PlutoColumnType.text(),
            width: 130,
            renderer: (r) => Row(children: [
                  Icon(catIcon(r.cell.value),
                      size: 14, color: theme.textSecondary),
                  const SizedBox(width: 5),
                  Flexible(
                      child: Text(labelCategoria(r.cell.value),
                          style:
                              TextStyle(fontSize: 12, color: theme.textPrimary),
                          overflow: TextOverflow.ellipsis)),
                ])),

        // Descripción
        PlutoColumn(
            title: 'Descripción',
            field: 'descripcion',
            type: PlutoColumnType.text(),
            width: 210,
            renderer: (r) => Tooltip(
                message: r.cell.value,
                child: Text(r.cell.value,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 12, color: theme.textPrimary)))),

        // Confianza IA
        PlutoColumn(
            title: 'Confianza IA',
            field: 'confianza',
            type: PlutoColumnType.text(),
            width: 105,
            renderer: (r) {
              final conf = double.tryParse(r.cell.value) ?? 0.0;
              final c = conf >= 0.90
                  ? theme.low
                  : conf >= 0.70
                      ? theme.high
                      : theme.critical;
              return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                      color: c.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20)),
                  child: Text('${(conf * 100).toStringAsFixed(1)}%',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: c)));
            }),

        // Prioridad IA
        PlutoColumn(
            title: 'Prioridad IA',
            field: 'prio_ia',
            type: PlutoColumnType.text(),
            width: 112,
            renderer: (r) => r.cell.value.isEmpty
                ? Text('—', style: TextStyle(color: theme.textDisabled))
                : PriorityBadge(prioridad: r.cell.value)),

        // Veredicto IA
        PlutoColumn(
            title: 'Veredicto IA',
            field: 'veredicto',
            type: PlutoColumnType.text(),
            width: 140,
            renderer: (r) {
              final rechaza = r.cell.value == '1';
              final c = rechaza ? theme.neutral : theme.low;
              return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                      color: c.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6)),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(
                        rechaza ? Icons.report_off : Icons.check_circle_outline,
                        size: 12,
                        color: c),
                    const SizedBox(width: 4),
                    Flexible(
                        child: Text(rechaza ? 'Rec. rechazar' : 'Rec. aprobar',
                            style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: c))),
                  ]));
            }),

        // Ubicación
        PlutoColumn(
            title: 'Ubicación',
            field: 'ubicacion',
            type: PlutoColumnType.text(),
            width: 135,
            renderer: (r) => Text(r.cell.value,
                style: TextStyle(fontSize: 11, color: theme.textSecondary))),

        // Fecha
        PlutoColumn(
            title: 'Fecha',
            field: 'fecha',
            type: PlutoColumnType.text(),
            width: 108,
            renderer: (r) => Text(r.cell.value,
                style: TextStyle(fontSize: 11, color: theme.textSecondary))),

        // Acciones — 4 iconos compactos
        PlutoColumn(
            title: 'Acciones',
            field: 'acciones',
            type: PlutoColumnType.text(),
            width: 150,
            enableSorting: false,
            enableFilterMenuItem: false,
            renderer: (r) {
              final inc = _inc(r);
              if (inc == null) return const SizedBox.shrink();
              final igRechaza = esRechazoIA(inc);
              return Row(mainAxisSize: MainAxisSize.min, children: [
                // Ver caso
                _IconAction(
                  icon: Icons.article_outlined,
                  tooltip: 'Ver caso completo',
                  color: theme.primaryColor,
                  onTap: () => showDialog(
                      context: context,
                      builder: (_) => DetalleCasoDialog(
                          inc: inc,
                          theme: theme,
                          onAprobar: () => onConfirmAccion('aprobar', inc),
                          onRechazar: () => onConfirmAccion('rechazar', inc),
                          onVerMapa: () => showDialog(
                              context: context,
                              builder: (_) => MapaUbicacionDialog(
                                  inc: inc, theme: theme)))),
                ),
                const SizedBox(width: 4),
                // Ver mapa
                _IconAction(
                    icon: Icons.map_outlined,
                    tooltip: 'Ver en mapa',
                    color: theme.medium,
                    onTap: () => showDialog(
                        context: context,
                        builder: (_) =>
                            MapaUbicacionDialog(inc: inc, theme: theme))),
                const SizedBox(width: 4),
                // Aprobar
                _IconAction(
                    icon: Icons.check_circle_outline,
                    tooltip:
                        igRechaza ? 'IA recomienda rechazar' : 'Aprobar caso',
                    color: igRechaza ? theme.neutral : theme.low,
                    onTap: igRechaza
                        ? null
                        : () => onConfirmAccion('aprobar', inc)),
                const SizedBox(width: 4),
                // Rechazar
                _IconAction(
                    icon: Icons.cancel_outlined,
                    tooltip: 'Rechazar caso',
                    color: theme.critical,
                    onTap: () => onConfirmAccion('rechazar', inc)),
              ]);
            }),
      ];

  Incidencia? _inc(PlutoColumnRendererContext r) {
    final id = r.row.cells['id']?.value as String? ?? '';
    try {
      return items.firstWhere((i) => i.id == id);
    } catch (_) {
      return null;
    }
  }

  List<PlutoRow> _rows() => items
      .map((inc) => PlutoRow(cells: {
            'id': PlutoCell(value: inc.id),
            'img': PlutoCell(value: inc.imagenPath ?? ''),
            'categoria': PlutoCell(value: inc.categoria),
            'descripcion': PlutoCell(value: inc.descripcion),
            'confianza': PlutoCell(value: '${inc.iaConfianza ?? 0.0}'),
            'prio_ia': PlutoCell(value: inc.iaPrioridadSugerida ?? ''),
            'veredicto': PlutoCell(value: esRechazoIA(inc) ? '1' : '0'),
            'ubicacion':
                PlutoCell(value: approxDireccion(inc.latitud, inc.longitud)),
            'fecha': PlutoCell(value: formatFechaHoraCorta(inc.fechaReporte)),
            'acciones': PlutoCell(value: ''),
          }))
      .toList();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: theme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.border),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 4))
          ]),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: PlutoGrid(
          columns: _cols(context),
          rows: _rows(),
          onLoaded: (e) => e.stateManager.setPageSize(12, notify: false),
          createFooter: (s) => PlutoPagination(s),
          configuration: PlutoGridConfiguration(
            style: PlutoGridStyleConfig(
              gridBorderColor: theme.border,
              gridBackgroundColor: theme.surface,
              rowColor: theme.surface,
              activatedColor: theme.primaryColor.withOpacity(0.07),
              activatedBorderColor: theme.primaryColor,
              columnHeight: 44,
              rowHeight: 64,
              columnTextStyle: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: theme.textSecondary),
            ),
            columnSize: const PlutoGridColumnSizeConfig(
                autoSizeMode: PlutoAutoSizeMode.scale),
          ),
        ),
      ),
    );
  }
}

// ── Icono de acción mini ───────────────────────────────────────────────────────
class _IconAction extends StatelessWidget {
  const _IconAction(
      {required this.icon,
      required this.tooltip,
      required this.color,
      this.onTap});
  final IconData icon;
  final String tooltip;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = onTap == null ? Colors.grey.shade400 : color;
    return Tooltip(
      message: tooltip,
      child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(6),
          child: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                  color: c.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: c.withOpacity(0.3))),
              child: Icon(icon, size: 16, color: c))),
    );
  }
}
