"""Reescribe bandeja_ia_page.dart con las 6 mejoras solicitadas."""
import pathlib

ROOT = pathlib.Path(r"g:\TRABAJO\FLUTTER\cbl_portal_demos\sistema_smart_sistem_demo")

PAGE = r'''import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:nethive_neo/helpers/formatters.dart';
import 'package:nethive_neo/models/models.dart';
import 'package:nethive_neo/providers/providers.dart';
import 'package:nethive_neo/theme/theme.dart';
import 'package:nethive_neo/widgets/shared/priority_badge.dart';
import 'package:nethive_neo/widgets/shared/section_header.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:provider/provider.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Helpers top-level
// ─────────────────────────────────────────────────────────────────────────────

bool _esRechazoIA(Incidencia inc) {
  final p = inc.imagenPath ?? '';
  return p.contains('rechazar') || p.contains('happyface') || p.contains('papelito');
}

String _approxDireccion(double lat, double lon) {
  if (lat > 31.876) return 'Col. Reforma Norte';
  if (lat > 31.872) return 'Col. El Sauzal';
  if (lat > 31.868) return 'Zona Centro Norte';
  if (lat > 31.864) return 'Centro Histórico';
  if (lat > 31.858) return 'Col. Miramar';
  if (lat > 31.854) return 'Col. Los Viñedos';
  return 'Col. Chapultepec';
}

// ─────────────────────────────────────────────────────────────────────────────
// Página principal
// ─────────────────────────────────────────────────────────────────────────────

class BandejaIAPage extends StatefulWidget {
  const BandejaIAPage({super.key});
  @override
  State<BandejaIAPage> createState() => _BandejaIAPageState();
}

class _BandejaIAPageState extends State<BandejaIAPage> {
  String? _filterCategoria;
  String  _filterVeredicto = 'todos';
  String  _search = '';

  List<Incidencia> _filter(List<Incidencia> all) {
    var r = all;
    if (_filterCategoria != null) r = r.where((i) => i.categoria == _filterCategoria).toList();
    if (_filterVeredicto == 'recomienda_aprobar')  r = r.where((i) => !_esRechazoIA(i)).toList();
    if (_filterVeredicto == 'recomienda_rechazar') r = r.where((i) =>  _esRechazoIA(i)).toList();
    if (_search.isNotEmpty)
      r = r.where((i) => i.descripcion.toLowerCase().contains(_search.toLowerCase()) ||
                         i.id.contains(_search)).toList();
    return r;
  }

  // ── PlutoGrid columns ──────────────────────────────────────────────────────
  List<PlutoColumn> _cols(AppTheme theme, List<Incidencia> items) => [
    PlutoColumn(title: 'ID',          field: 'id',          type: PlutoColumnType.text(), width: 90,
      renderer: (r) => Text(formatIdIncidencia(r.cell.value),
        style: TextStyle(fontWeight: FontWeight.w800, color: theme.primaryColor, fontSize: 12))),
    PlutoColumn(title: 'Categoría',   field: 'categoria',   type: PlutoColumnType.text(), width: 120,
      renderer: (r) => Text(labelCategoria(r.cell.value),
        style: TextStyle(fontSize: 12, color: theme.textPrimary))),
    PlutoColumn(title: 'Descripción', field: 'descripcion', type: PlutoColumnType.text(), width: 230,
      renderer: (r) => Tooltip(message: r.cell.value,
        child: Text(r.cell.value, maxLines: 2, overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: 12, color: theme.textPrimary)))),
    PlutoColumn(title: 'Confianza IA',field: 'confianza',   type: PlutoColumnType.text(), width: 110,
      renderer: (r) {
        final conf = double.tryParse(r.cell.value) ?? 0.0;
        final c = conf >= 0.90 ? theme.low : conf >= 0.70 ? theme.high : theme.critical;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(color: c.withOpacity(0.12), borderRadius: BorderRadius.circular(20)),
          child: Text('${(conf * 100).toStringAsFixed(1)}%',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: c)));
      }),
    PlutoColumn(title: 'Prioridad IA',field: 'prio_ia',     type: PlutoColumnType.text(), width: 115,
      renderer: (r) => r.cell.value.isEmpty
        ? Text('—', style: TextStyle(color: theme.textDisabled))
        : PriorityBadge(prioridad: r.cell.value)),
    PlutoColumn(title: 'Veredicto IA',field: 'veredicto',   type: PlutoColumnType.text(), width: 145,
      renderer: (r) {
        final rechaza = r.cell.value == '1';
        final c = rechaza ? theme.neutral : theme.low;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(color: c.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(rechaza ? Icons.report_off : Icons.check_circle_outline, size: 12, color: c),
            const SizedBox(width: 4),
            Flexible(child: Text(rechaza ? 'Rec. rechazar' : 'Rec. aprobar',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: c))),
          ]));
      }),
    PlutoColumn(title: 'Ubicación',   field: 'ubicacion',   type: PlutoColumnType.text(), width: 145,
      renderer: (r) => Text(r.cell.value,
        style: TextStyle(fontSize: 11, color: theme.textSecondary))),
    PlutoColumn(title: 'Fecha',        field: 'fecha',       type: PlutoColumnType.text(), width: 110,
      renderer: (r) => Text(r.cell.value, style: TextStyle(fontSize: 11, color: theme.textSecondary))),
    PlutoColumn(title: 'Acciones',     field: 'acciones',    type: PlutoColumnType.text(), width: 220,
      enableSorting: false,
      renderer: (r) {
        final inc = items.firstWhere((i) => i.id == r.row.cells['id']!.value,
          orElse: () => items.first);
        final iaRechaza = _esRechazoIA(inc);
        return Row(mainAxisSize: MainAxisSize.min, children: [
          _ActionBtn(label: 'Mapa',     icon: Icons.map_outlined,    color: theme.medium,
            onTap: () => _showMapaDialog(context, inc, theme)),
          const SizedBox(width: 4),
          _ActionBtn(label: 'Rechazar', icon: Icons.close,           color: theme.critical,
            onTap: () => _confirmAccion(context, 'rechazar', inc, iaRechaza)),
          const SizedBox(width: 4),
          _ActionBtn(label: 'Aprobar',  icon: Icons.check,           color: theme.low,
            onTap: iaRechaza ? null : () => _confirmAccion(context, 'aprobar', inc, iaRechaza)),
        ]);
      }),
  ];

  List<PlutoRow> _rows(List<Incidencia> items) => items.map((inc) => PlutoRow(cells: {
    'id':          PlutoCell(value: inc.id),
    'categoria':   PlutoCell(value: inc.categoria),
    'descripcion': PlutoCell(value: inc.descripcion),
    'confianza':   PlutoCell(value: '${inc.iaConfianza ?? 0.0}'),
    'prio_ia':     PlutoCell(value: inc.iaPrioridadSugerida ?? ''),
    'veredicto':   PlutoCell(value: _esRechazoIA(inc) ? '1' : '0'),
    'ubicacion':   PlutoCell(value: _approxDireccion(inc.latitud, inc.longitud)),
    'fecha':       PlutoCell(value: formatFechaHoraCorta(inc.fechaReporte)),
    'acciones':    PlutoCell(value: ''),
  })).toList();

  // ── Acciones ───────────────────────────────────────────────────────────────
  void _confirmAccion(BuildContext ctx, String tipo, Incidencia inc, bool iaRechaza) {
    showDialog(
      context: ctx,
      barrierDismissible: false,
      builder: (_) => _ConfirmarAccionDialog(
        tipo: tipo, inc: inc, iaRechaza: iaRechaza,
        onConfirm: (motivo) {
          final bIa  = ctx.read<BandejaIAProvider>();
          final bInc = ctx.read<IncidenciaProvider>();
          if (tipo == 'aprobar') {
            bIa.aprobar(inc.id, prioridadOverride: inc.iaPrioridadSugerida);
            bInc.actualizarEstatus(inc.id, 'aprobado');
            ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
              content: Text('${formatIdIncidencia(inc.id)} aprobado — enviado a Órdenes'),
              backgroundColor: const Color(0xFF2D7A4F)));
          } else {
            bIa.rechazar(inc.id);
            bInc.actualizarEstatus(inc.id, 'rechazado');
            ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
              content: Text('${formatIdIncidencia(inc.id)} rechazado${motivo.isNotEmpty ? " · $motivo" : ""}'),
              backgroundColor: const Color(0xFF64748B)));
          }
        },
      ),
    );
  }

  void _showMapaDialog(BuildContext ctx, Incidencia inc, AppTheme theme) {
    showDialog(context: ctx, builder: (_) => _MapaUbicacionDialog(inc: inc, theme: theme));
  }

  @override
  Widget build(BuildContext context) {
    final theme   = AppTheme.of(context);
    final bandeja = context.watch<BandejaIAProvider>();
    final all     = bandeja.pendientes;
    final pending = _filter(all);
    final cats    = all.map((i) => i.categoria).toSet().toList()..sort();

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // ── Header ──────────────────────────────────────────────────────────
        SectionHeader(
          title: 'Bandeja de Revisión IA',
          subtitle: 'Reportes ciudadanos clasificados por IA — requieren validación humana',
          trailing: all.isNotEmpty
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: theme.high.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: theme.high.withOpacity(0.3))),
                child: Text('${all.length} pendientes',
                  style: TextStyle(color: theme.high, fontSize: 12, fontWeight: FontWeight.w700)))
            : null,
        ),
        const SizedBox(height: 10),

        // ── Info banner ──────────────────────────────────────────────────────
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
            Expanded(child: Text(
              'La IA valida coherencia texto-imagen y sugiere categoría y prioridad. '
              'El operador revisa y aprueba o rechaza antes de generar la orden.',
              style: TextStyle(fontSize: 12, color: theme.textSecondary))),
          ]),
        ),

        // ── Filtros ──────────────────────────────────────────────────────────
        _FilterBar(
          search: _search, filterCategoria: _filterCategoria, filterVeredicto: _filterVeredicto,
          cats: cats, theme: theme,
          onSearch:    (v) => setState(() => _search = v),
          onCategoria: (v) => setState(() => _filterCategoria = v),
          onVeredicto: (v) => setState(() => _filterVeredicto = v ?? 'todos'),
        ),
        const SizedBox(height: 10),

        if (pending.length != all.length)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text('${pending.length} de ${all.length} registros',
              style: TextStyle(fontSize: 12, color: theme.textSecondary, fontStyle: FontStyle.italic))),

        // ── Contenido ────────────────────────────────────────────────────────
        if (pending.isEmpty)
          Expanded(child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.check_circle_outline, size: 56, color: theme.low),
            const SizedBox(height: 12),
            Text('Sin resultados para la selección actual',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: theme.textPrimary)),
          ])))
        else
          Expanded(child: LayoutBuilder(builder: (ctx, box) {
            if (box.maxWidth >= 800) {
              return _PlutoDesktopView(cols: _cols(theme, pending), rows: _rows(pending), theme: theme);
            }
            return ListView.separated(
              itemCount: pending.length,
              separatorBuilder: (_, __) => const SizedBox(height: 14),
              itemBuilder: (_, i) => _BandejaCard(
                inc: pending[i],
                onAprobar:  (inc) => _confirmAccion(context, 'aprobar',  inc, _esRechazoIA(inc)),
                onRechazar: (inc) => _confirmAccion(context, 'rechazar', inc, _esRechazoIA(inc)),
                onVerMapa:  (inc) => _showMapaDialog(context, inc, theme),
              ),
            );
          })),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// FilterBar
// ─────────────────────────────────────────────────────────────────────────────

class _FilterBar extends StatelessWidget {
  const _FilterBar({
    required this.search, required this.filterCategoria, required this.filterVeredicto,
    required this.cats, required this.theme, required this.onSearch,
    required this.onCategoria, required this.onVeredicto,
  });
  final String search, filterVeredicto;
  final String? filterCategoria;
  final List<String> cats;
  final AppTheme theme;
  final ValueChanged<String> onSearch;
  final ValueChanged<String?> onCategoria, onVeredicto;

  @override
  Widget build(BuildContext context) {
    return Wrap(spacing: 10, runSpacing: 8, crossAxisAlignment: WrapCrossAlignment.center, children: [
      SizedBox(width: 200, child: TextField(
        onChanged: onSearch,
        decoration: InputDecoration(
          hintText: 'Buscar ID o descripción…',
          hintStyle: TextStyle(fontSize: 12, color: theme.textSecondary),
          prefixIcon: Icon(Icons.search, size: 16, color: theme.textSecondary),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: theme.border)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: theme.border)),
          filled: true, fillColor: theme.surface,
        ),
      )),
      DropdownButtonHideUnderline(child: DropdownButton<String>(
        value: filterVeredicto,
        items: const [
          DropdownMenuItem(value: 'todos',               child: Text('Todos los veredictos')),
          DropdownMenuItem(value: 'recomienda_aprobar',  child: Text('IA: Recomienda Aprobar')),
          DropdownMenuItem(value: 'recomienda_rechazar', child: Text('IA: Recomienda Rechazar')),
        ],
        onChanged: onVeredicto, borderRadius: BorderRadius.circular(8),
      )),
      DropdownButtonHideUnderline(child: DropdownButton<String?>(
        value: filterCategoria,
        hint: Text('Todas las categorías', style: TextStyle(fontSize: 12, color: theme.textSecondary)),
        items: [
          const DropdownMenuItem<String?>(value: null, child: Text('Todas las categorías')),
          ...cats.map((c) => DropdownMenuItem<String?>(value: c, child: Text(labelCategoria(c)))),
        ],
        onChanged: onCategoria, borderRadius: BorderRadius.circular(8),
      )),
    ]);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Desktop PlutoGrid
// ─────────────────────────────────────────────────────────────────────────────

class _PlutoDesktopView extends StatelessWidget {
  const _PlutoDesktopView({required this.cols, required this.rows, required this.theme});
  final List<PlutoColumn> cols;
  final List<PlutoRow> rows;
  final AppTheme theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: theme.surface, borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.border),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))]),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: PlutoGrid(
          columns: cols, rows: rows,
          onLoaded: (e) => e.stateManager.setPageSize(12, notify: false),
          createFooter: (s) => PlutoPagination(s),
          configuration: PlutoGridConfiguration(
            style: PlutoGridStyleConfig(
              gridBorderColor: theme.border, gridBackgroundColor: theme.surface,
              rowColor: theme.surface, activatedColor: theme.primaryColor.withOpacity(0.07),
              activatedBorderColor: theme.primaryColor, columnHeight: 42, rowHeight: 56,
              columnTextStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: theme.textSecondary),
            ),
            columnSize: const PlutoGridColumnSizeConfig(autoSizeMode: PlutoAutoSizeMode.scale),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Mobile: _BandejaCard
// ─────────────────────────────────────────────────────────────────────────────

class _BandejaCard extends StatefulWidget {
  const _BandejaCard({required this.inc, required this.onAprobar, required this.onRechazar, required this.onVerMapa});
  final Incidencia inc;
  final ValueChanged<Incidencia> onAprobar, onRechazar, onVerMapa;
  @override
  State<_BandejaCard> createState() => _BandejaCardState();
}

class _BandejaCardState extends State<_BandejaCard> {
  bool _expanded = true;

  static const _catIcons = <String, IconData>{
    'alumbrado': Icons.lightbulb_outline, 'bacheo': Icons.construction,
    'basura': Icons.delete_outline, 'agua_drenaje': Icons.water_drop_outlined,
    'señalizacion': Icons.traffic, 'senalizacion': Icons.traffic,
    'seguridad': Icons.security,
  };

  @override
  Widget build(BuildContext context) {
    final theme     = AppTheme.of(context);
    final inc       = widget.inc;
    final conf      = inc.iaConfianza ?? 0.0;
    final confColor = conf >= 0.90 ? theme.low : conf >= 0.70 ? theme.high : theme.critical;
    final iaRechaza = _esRechazoIA(inc);

    return Container(
      decoration: BoxDecoration(
        color: theme.surface, borderRadius: BorderRadius.circular(14),
        border: Border.all(color: iaRechaza ? theme.neutral.withOpacity(0.35) : theme.border),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 3))]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

        // ── Header ────────────────────────────────────────────────────────────
        InkWell(
          onTap: () => setState(() => _expanded = !_expanded),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
            child: Row(children: [
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                  color: (iaRechaza ? theme.neutral : theme.primaryColor).withOpacity(0.1),
                  shape: BoxShape.circle),
                child: Icon(_catIcons[inc.categoria] ?? Icons.help_outline,
                  color: iaRechaza ? theme.neutral : theme.primaryColor, size: 19)),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Text(formatIdIncidencia(inc.id),
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800,
                      color: iaRechaza ? theme.textSecondary : theme.primaryColor)),
                  const SizedBox(width: 6),
                  Flexible(child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: theme.border.withOpacity(0.5), borderRadius: BorderRadius.circular(5)),
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

        // ── Expanded body ─────────────────────────────────────────────────────
        if (_expanded) ...[
          Divider(height: 1, color: theme.border.withOpacity(0.5)),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

              // Imagen con tap para ver grande
              if (inc.imagenPath != null)
                _ImageThumbnail(imagenPath: inc.imagenPath!, iaRechaza: iaRechaza, theme: theme),

              const SizedBox(height: 12),

              // Ubicación + botón mapa
              _UbicacionRow(inc: inc, theme: theme, onVerMapa: () => widget.onVerMapa(inc)),

              const SizedBox(height: 12),

              // IA panel
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.medium.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: theme.medium.withOpacity(0.2))),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Icon(Icons.psychology_outlined, size: 14, color: theme.medium),
                    const SizedBox(width: 5),
                    Text('ANÁLISIS IA', style: TextStyle(
                      fontSize: 10, fontWeight: FontWeight.w700, color: theme.medium, letterSpacing: 0.8)),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: confColor.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                      child: Text('${(conf * 100).toStringAsFixed(1)}% confianza',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: confColor))),
                  ]),
                  const SizedBox(height: 8),
                  Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('Categoría sugerida',
                        style: TextStyle(fontSize: 10, color: theme.textSecondary, fontWeight: FontWeight.w600)),
                      Text(labelCategoria(inc.iaCategoriaSugerida ?? inc.categoria),
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: theme.textPrimary)),
                    ])),
                    const SizedBox(width: 12),
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('Prioridad sugerida',
                        style: TextStyle(fontSize: 10, color: theme.textSecondary, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 2),
                      PriorityBadge(prioridad: inc.iaPrioridadSugerida ?? inc.prioridad),
                    ]),
                  ]),
                  if (inc.iaCoherenciaNota != null) ...[
                    const SizedBox(height: 8),
                    Text(inc.iaCoherenciaNota!,
                      style: TextStyle(fontSize: 11, color: theme.textSecondary, fontStyle: FontStyle.italic),
                      maxLines: 4, overflow: TextOverflow.ellipsis),
                  ],
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                    decoration: BoxDecoration(
                      color: (iaRechaza ? theme.neutral : theme.low).withOpacity(0.08),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: (iaRechaza ? theme.neutral : theme.low).withOpacity(0.25))),
                    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 1),
                        child: Icon(iaRechaza ? Icons.report_off : Icons.check_circle_outline,
                          size: 14, color: iaRechaza ? theme.neutral : theme.low)),
                      const SizedBox(width: 6),
                      Expanded(child: Text(
                        iaRechaza
                          ? 'IA recomienda RECHAZAR — imagen no relevante para infraestructura pública.'
                          : 'IA recomienda APROBAR — descripción e imagen son coherentes con la categoría.',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
                          color: iaRechaza ? theme.neutral : theme.low))),
                    ]),
                  ),
                ]),
              ),
            ]),
          ),
        ],

        // ── Actions ───────────────────────────────────────────────────────────
        Container(
          padding: const EdgeInsets.fromLTRB(14, 8, 14, 12),
          decoration: BoxDecoration(
            color: theme.background,
            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(14))),
          child: Row(children: [
            if (inc.esReincidente)
              Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: theme.high.withOpacity(0.1), borderRadius: BorderRadius.circular(5)),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.repeat, size: 12, color: theme.high),
                  const SizedBox(width: 3),
                  Text('Reincidente',
                    style: TextStyle(fontSize: 10, color: theme.high, fontWeight: FontWeight.w600)),
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
              style: OutlinedButton.styleFrom(
                foregroundColor: theme.critical,
                side: BorderSide(color: theme.critical.withOpacity(0.45)),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6))),
            const SizedBox(width: 6),
            ElevatedButton.icon(
              onPressed: iaRechaza ? null : () => widget.onAprobar(inc),
              icon: const Icon(Icons.check, size: 14),
              label: const Text('Aprobar', overflow: TextOverflow.ellipsis),
              style: ElevatedButton.styleFrom(
                backgroundColor: iaRechaza ? theme.neutral : theme.low,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6))),
          ]),
        ),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Image thumbnail con tap → fullscreen
// ─────────────────────────────────────────────────────────────────────────────

class _ImageThumbnail extends StatelessWidget {
  const _ImageThumbnail({required this.imagenPath, required this.iaRechaza, required this.theme});
  final String imagenPath;
  final bool iaRechaza;
  final AppTheme theme;

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Icon(Icons.camera_alt_outlined, size: 13, color: theme.textSecondary),
        const SizedBox(width: 4),
        Text('IMAGEN DEL CIUDADANO', style: TextStyle(
          fontSize: 10, fontWeight: FontWeight.w700, color: theme.textSecondary, letterSpacing: 0.7)),
        const Spacer(),
        TextButton.icon(
          onPressed: () => showDialog(context: context,
            builder: (_) => _ImageViewerDialog(imagenPath: imagenPath, theme: theme)),
          icon: Icon(Icons.open_in_full, size: 13, color: theme.medium),
          label: Text('Ver grande', style: TextStyle(fontSize: 11, color: theme.medium)),
          style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2))),
      ]),
      const SizedBox(height: 6),
      GestureDetector(
        onTap: () => showDialog(context: context,
          builder: (_) => _ImageViewerDialog(imagenPath: imagenPath, theme: theme)),
        child: Container(
          height: 160,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: iaRechaza ? theme.neutral.withOpacity(0.3) : theme.border),
            color: theme.background),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(9),
            child: Stack(fit: StackFit.expand, children: [
              Image.asset(imagenPath, fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Center(child: Column(
                  mainAxisAlignment: MainAxisAlignment.center, children: [
                    Icon(Icons.broken_image_outlined, color: theme.textDisabled, size: 28),
                    const SizedBox(height: 4),
                    Text('Sin imagen', style: TextStyle(fontSize: 11, color: theme.textDisabled)),
                  ]))),
              if (iaRechaza)
                Positioned(top: 8, right: 8, child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.65), borderRadius: BorderRadius.circular(5)),
                  child: const Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.not_interested, size: 11, color: Colors.white),
                    SizedBox(width: 3),
                    Text('No relevante', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w600)),
                  ]))),
              Positioned(bottom: 6, left: 6, child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5), borderRadius: BorderRadius.circular(4)),
                child: const Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.zoom_in, size: 11, color: Colors.white),
                  SizedBox(width: 3),
                  Text('Toca para ampliar', style: TextStyle(color: Colors.white, fontSize: 9)),
                ]))),
            ]),
          ),
        ),
      ),
    ]);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Fila de ubicación
// ─────────────────────────────────────────────────────────────────────────────

class _UbicacionRow extends StatelessWidget {
  const _UbicacionRow({required this.inc, required this.theme, required this.onVerMapa});
  final Incidencia inc;
  final AppTheme theme;
  final VoidCallback onVerMapa;

  @override
  Widget build(BuildContext context) {
    final dir = _approxDireccion(inc.latitud, inc.longitud);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: theme.background, borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.border.withOpacity(0.6))),
      child: Row(children: [
        Icon(Icons.location_on_outlined, size: 15, color: theme.primaryColor),
        const SizedBox(width: 8),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(dir, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: theme.textPrimary),
            overflow: TextOverflow.ellipsis),
          Text('${inc.latitud.toStringAsFixed(4)}, ${inc.longitud.toStringAsFixed(4)}',
            style: TextStyle(fontSize: 10, color: theme.textSecondary)),
        ])),
        const SizedBox(width: 8),
        TextButton.icon(
          onPressed: onVerMapa,
          icon: Icon(Icons.map_outlined, size: 14, color: theme.medium),
          label: Text('Ver en mapa', style: TextStyle(fontSize: 11, color: theme.medium), overflow: TextOverflow.ellipsis),
          style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4))),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Dialog: Imagen fullscreen
// ─────────────────────────────────────────────────────────────────────────────

class _ImageViewerDialog extends StatelessWidget {
  const _ImageViewerDialog({required this.imagenPath, required this.theme});
  final String imagenPath;
  final AppTheme theme;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: size.width * 0.92, maxHeight: size.height * 0.88),
        child: Stack(children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.asset(imagenPath,
              fit: BoxFit.contain, width: double.infinity, height: double.infinity,
              errorBuilder: (_, __, ___) => Container(
                color: theme.surface, padding: const EdgeInsets.all(40),
                child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(Icons.broken_image_outlined, size: 64, color: theme.textDisabled),
                  const SizedBox(height: 8),
                  Text('Imagen no disponible', style: TextStyle(color: theme.textDisabled)),
                ])))),
          ),
          Positioned(top: 10, right: 10, child: Material(
            color: Colors.black.withOpacity(0.55),
            shape: const CircleBorder(),
            child: InkWell(
              onTap: () => Navigator.pop(context),
              customBorder: const CircleBorder(),
              child: const Padding(padding: EdgeInsets.all(8),
                child: Icon(Icons.close, color: Colors.white, size: 22))),
          )),
        ]),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Dialog: Mapa de ubicación
// ─────────────────────────────────────────────────────────────────────────────

class _MapaUbicacionDialog extends StatelessWidget {
  const _MapaUbicacionDialog({required this.inc, required this.theme});
  final Incidencia inc;
  final AppTheme theme;

  Color _prioColor() {
    switch (inc.prioridad) {
      case 'critico': return const Color(0xFFB91C1C);
      case 'alto':    return const Color(0xFFD97706);
      case 'medio':   return const Color(0xFF1D4ED8);
      default:        return const Color(0xFF2D7A4F);
    }
  }

  @override
  Widget build(BuildContext context) {
    final latLng = LatLng(inc.latitud, inc.longitud);
    final color  = _prioColor();
    final dir    = _approxDireccion(inc.latitud, inc.longitud);
    final total  = MediaQuery.of(context).size;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.all(20),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 560, maxHeight: total.height * 0.82),
        child: Column(children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 12, 14),
            child: Row(children: [
              Icon(Icons.location_on, color: theme.primaryColor, size: 20),
              const SizedBox(width: 10),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Ubicación del reporte',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: theme.textPrimary)),
                Text('${formatIdIncidencia(inc.id)} · $dir',
                  style: TextStyle(fontSize: 12, color: theme.textSecondary),
                  overflow: TextOverflow.ellipsis),
              ])),
              IconButton(icon: Icon(Icons.close, color: theme.textSecondary, size: 20),
                onPressed: () => Navigator.pop(context)),
            ]),
          ),
          Divider(height: 1, color: theme.border),

          // Mapa
          Expanded(child: Stack(children: [
            FlutterMap(
              options: MapOptions(initialCenter: latLng, initialZoom: 15),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.cbluna.terranex'),
                MarkerLayer(markers: [
                  Marker(
                    point: latLng, width: 44, height: 44,
                    child: Container(
                      decoration: BoxDecoration(
                        color: color, shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2.5),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.35),
                          blurRadius: 8, offset: const Offset(0, 3))]),
                      child: const Icon(Icons.report_problem_outlined, color: Colors.white, size: 20))),
                ]),
              ],
            ),
            Positioned(top: 10, left: 10, child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.92),
                borderRadius: BorderRadius.circular(8),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 6)]),
              child: Text('${labelCategoria(inc.categoria)} · ${inc.entorno}',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: theme.textPrimary)))),
          ])),

          // Footer
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            decoration: BoxDecoration(
              color: theme.background,
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16))),
            child: Row(children: [
              Icon(Icons.gps_fixed, size: 13, color: theme.textSecondary),
              const SizedBox(width: 6),
              Expanded(child: Text(
                '${inc.latitud.toStringAsFixed(5)}, ${inc.longitud.toStringAsFixed(5)}',
                style: TextStyle(fontSize: 12, color: theme.textSecondary),
                overflow: TextOverflow.ellipsis)),
              TextButton(onPressed: () => Navigator.pop(context),
                child: const Text('Cerrar')),
            ]),
          ),
        ]),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Dialog: Confirmar Aprobar / Rechazar
// ─────────────────────────────────────────────────────────────────────────────

class _ConfirmarAccionDialog extends StatefulWidget {
  const _ConfirmarAccionDialog({
    required this.tipo, required this.inc, required this.iaRechaza, required this.onConfirm});
  final String tipo;
  final Incidencia inc;
  final bool iaRechaza;
  final void Function(String motivo) onConfirm;
  @override
  State<_ConfirmarAccionDialog> createState() => _ConfirmarAccionDialogState();
}

class _ConfirmarAccionDialogState extends State<_ConfirmarAccionDialog> {
  final _motivoCtrl = TextEditingController();
  final _formKey    = GlobalKey<FormState>();

  bool get _motivoObligatorio => widget.tipo == 'rechazar' && !widget.iaRechaza;

  @override
  void dispose() { _motivoCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final theme     = AppTheme.of(context);
    final esAprobar = widget.tipo == 'aprobar';
    final acColor   = esAprobar ? theme.low : theme.critical;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Padding(
          padding: const EdgeInsets.all(26),
          child: Form(
            key: _formKey,
            child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(color: acColor.withOpacity(0.12), shape: BoxShape.circle),
                  child: Icon(esAprobar ? Icons.check_circle_outline : Icons.cancel_outlined,
                    color: acColor, size: 22)),
                const SizedBox(width: 14),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(esAprobar ? 'Confirmar aprobación' : 'Confirmar rechazo',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: theme.textPrimary)),
                  Text(formatIdIncidencia(widget.inc.id),
                    style: TextStyle(fontSize: 13, color: theme.textSecondary)),
                ])),
                IconButton(icon: Icon(Icons.close, size: 18, color: theme.textSecondary),
                  onPressed: () => Navigator.pop(context)),
              ]),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.background, borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: theme.border)),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(labelCategoria(widget.inc.categoria),
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: theme.textSecondary)),
                  const SizedBox(height: 4),
                  Text(widget.inc.descripcion,
                    style: TextStyle(fontSize: 13, color: theme.textPrimary),
                    maxLines: 3, overflow: TextOverflow.ellipsis),
                ])),
              const SizedBox(height: 14),
              if (_motivoObligatorio)
                Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: theme.high.withOpacity(0.08), borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: theme.high.withOpacity(0.3))),
                  child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Padding(padding: const EdgeInsets.only(top: 1),
                      child: Icon(Icons.warning_amber_outlined, size: 16, color: theme.high)),
                    const SizedBox(width: 8),
                    Expanded(child: Text(
                      'La IA recomendó APROBAR este reporte. Si lo rechazas, indica el motivo.',
                      style: TextStyle(fontSize: 12, color: theme.high, fontWeight: FontWeight.w500))),
                  ])),
              if (widget.tipo == 'rechazar') ...[
                Text(_motivoObligatorio ? 'Motivo de rechazo *' : 'Motivo (opcional)',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: theme.textSecondary)),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _motivoCtrl,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: _motivoObligatorio
                      ? 'Explica por qué rechazas a pesar de la recomendación de la IA…'
                      : 'Ej. Imagen borrosa, fuera de jurisdicción, descripción insuficiente…',
                    hintStyle: TextStyle(fontSize: 12, color: theme.textDisabled),
                    contentPadding: const EdgeInsets.all(12),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: theme.border)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: theme.border)),
                    filled: true, fillColor: theme.background),
                  validator: _motivoObligatorio
                    ? (v) => (v == null || v.trim().isEmpty) ? 'El motivo es obligatorio' : null
                    : null,
                ),
                const SizedBox(height: 16),
              ] else
                const SizedBox(height: 4),
              Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: theme.textSecondary,
                    side: BorderSide(color: theme.border)),
                  child: const Text('Cancelar')),
                const SizedBox(width: 10),
                FilledButton.icon(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      Navigator.pop(context);
                      widget.onConfirm(_motivoCtrl.text.trim());
                    }
                  },
                  icon: Icon(esAprobar ? Icons.check : Icons.close, size: 16),
                  label: Text(esAprobar ? 'Sí, aprobar' : 'Sí, rechazar'),
                  style: FilledButton.styleFrom(backgroundColor: acColor)),
              ]),
            ]),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Mini botón de acción para PlutoGrid renderer
// ─────────────────────────────────────────────────────────────────────────────

class _ActionBtn extends StatelessWidget {
  const _ActionBtn({required this.label, required this.icon, required this.color, this.onTap});
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = onTap == null ? Colors.grey : color;
    return Tooltip(
      message: label,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
          decoration: BoxDecoration(
            color: c.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: c.withOpacity(0.3))),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(icon, size: 12, color: c),
            const SizedBox(width: 3),
            Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: c)),
          ])),
      ),
    );
  }
}
'''

target = ROOT / 'lib' / 'pages' / 'bandeja_ia' / 'bandeja_ia_page.dart'
target.write_text(PAGE, encoding='utf-8')
print(f"✅ bandeja_ia_page.dart reescrito ({len(PAGE.splitlines())} líneas)")
