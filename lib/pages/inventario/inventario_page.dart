import 'package:flutter/material.dart';
import 'package:nethive_neo/helpers/formatters.dart';
import 'package:nethive_neo/models/models.dart';
import 'package:nethive_neo/providers/providers.dart';
import 'package:nethive_neo/theme/theme.dart';
import 'package:nethive_neo/widgets/shared/responsive_layout.dart';
import 'package:nethive_neo/widgets/shared/section_header.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:provider/provider.dart';

class InventarioPage extends StatefulWidget {
  const InventarioPage({super.key});
  @override
  State<InventarioPage> createState() => _InventarioPageState();
}

class _InventarioPageState extends State<InventarioPage> {
  String? _filterCategoria;
  String? _filterEstatus;
  String _search = '';
  PlutoGridStateManager? _sm;

  static String _catLabel(String c) {
    const m = {
      'electrico': 'Eléctrico', 'pavimento': 'Pavimento', 'senales': 'Señales',
      'saneamiento': 'Saneamiento', 'herramientas': 'Herramientas', 'general': 'General'
    };
    return m[c] ?? c;
  }

  List<MaterialItem> _filter(List<MaterialItem> all) {
    var r = all;
    if (_filterCategoria != null) r = r.where((m) => m.categoria == _filterCategoria).toList();
    if (_filterEstatus   != null) r = r.where((m) => m.estatus   == _filterEstatus  ).toList();
    if (_search.isNotEmpty)
      r = r.where((m) => m.descripcion.toLowerCase().contains(_search.toLowerCase()) ||
                         m.clave.toLowerCase().contains(_search.toLowerCase())).toList();
    return r;
  }

  Color _statusColor(String s, AppTheme t) =>
      s == 'agotado' ? t.critical : s == 'bajo_stock' ? t.high : t.low;

  List<PlutoColumn> _cols(AppTheme t) => [
    PlutoColumn(title: 'Clave',       field: 'clave',       type: PlutoColumnType.text(), width: 110,
      renderer: (r) => Text(r.cell.value, style: TextStyle(fontWeight: FontWeight.w700, color: t.primaryColor, fontSize: 12))),
    PlutoColumn(title: 'Descripción', field: 'descripcion', type: PlutoColumnType.text(), width: 220,
      renderer: (r) => Tooltip(message: r.cell.value, child: Text(r.cell.value, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12, color: t.textPrimary)))),
    PlutoColumn(title: 'Categoría',   field: 'categoria',   type: PlutoColumnType.text(), width: 110,
      renderer: (r) => Text(_catLabel(r.cell.value), style: TextStyle(fontSize: 12, color: t.textSecondary))),
    PlutoColumn(title: 'Unidad',      field: 'unidad',      type: PlutoColumnType.text(), width: 80),
    PlutoColumn(title: 'Stock',       field: 'stock',       type: PlutoColumnType.number(), width: 80,
      renderer: (r) {
        final min = int.tryParse(r.row.cells['minimo']?.value.toString() ?? '0') ?? 0;
        final s = int.tryParse(r.cell.value.toString()) ?? 0;
        return Text('$s', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700,
          color: s <= min ? t.critical : t.textPrimary));
      }),
    PlutoColumn(title: 'Mínimo',      field: 'minimo',      type: PlutoColumnType.number(), width: 80),
    PlutoColumn(title: 'Reservado',   field: 'reservado',   type: PlutoColumnType.number(), width: 90),
    PlutoColumn(title: 'Estatus',     field: 'estatus',     type: PlutoColumnType.text(), width: 110,
      renderer: (r) {
        final s = r.cell.value as String;
        final c = _statusColor(s, t);
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(color: c.withOpacity(0.12), borderRadius: BorderRadius.circular(6)),
          child: Text(s == 'bajo_stock' ? 'Bajo Stock' : s == 'agotado' ? 'Agotado' : 'OK',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: c)));
      }),
  ];

  List<PlutoRow> _rows(List<MaterialItem> items) => items.map((m) => PlutoRow(cells: {
    'clave':       PlutoCell(value: m.clave),
    'descripcion': PlutoCell(value: m.descripcion),
    'categoria':   PlutoCell(value: m.categoria),
    'unidad':      PlutoCell(value: m.unidad),
    'stock':       PlutoCell(value: m.stockActual),
    'minimo':      PlutoCell(value: m.stockMinimo),
    'reservado':   PlutoCell(value: m.reservado),
    'estatus':     PlutoCell(value: m.estatus),
  })).toList();

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final prov  = context.watch<InventarioProvider>();
    final items = _filter(prov.todos);
    final cats  = prov.todos.map((m) => m.categoria).toSet().toList()..sort();
    final bajoStock = prov.bajoStock;
    final agotados  = prov.agotados;

    // KPI mini chips
    final kpiChips = Row(children: [
      _Chip('Total', '${prov.todos.length}', theme.medium, theme),
      const SizedBox(width: 8),
      _Chip('Bajo Stock', '${bajoStock.length}', theme.high, theme),
      const SizedBox(width: 8),
      _Chip('Agotados', '${agotados.length}', theme.critical, theme),
    ]);

    final alertBanner = (bajoStock.isNotEmpty || agotados.isNotEmpty)
      ? Container(margin: const EdgeInsets.only(bottom: 14), padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: theme.high.withOpacity(0.08), borderRadius: BorderRadius.circular(8),
            border: Border.all(color: theme.high.withOpacity(0.3))),
          child: Row(children: [
            Icon(Icons.inventory_2_outlined, color: theme.high, size: 18),
            const SizedBox(width: 8),
            Expanded(child: Text('${agotados.length} materiales AGOTADOS · ${bajoStock.length} bajo mínimo de stock',
              style: TextStyle(fontSize: 12, color: theme.high, fontWeight: FontWeight.w600))),
          ]))
      : const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SectionHeader(
          title: 'Inventario de Materiales',
          subtitle: '${prov.todos.length} materiales · ${bajoStock.length} bajo stock · ${agotados.length} agotados',
          trailing: kpiChips,
        ),
        const SizedBox(height: 12),
        alertBanner,

        // Search + Filters
        _FilterBar(
          search: _search, filterCategoria: _filterCategoria, filterEstatus: _filterEstatus,
          cats: cats, catLabel: _catLabel, theme: theme,
          onSearch: (v) => setState(() => _search = v),
          onCategoria: (v) => setState(() => _filterCategoria = v),
          onEstatus: (v) => setState(() => _filterEstatus = v),
        ),
        const SizedBox(height: 14),

        // Table or cards
        Expanded(child: TableOrCards(
          tableView: _PlutoView(cols: _cols(theme), rows: _rows(items), theme: theme, onLoaded: (sm) => _sm = sm),
          cardView: _CardList(items: items, catLabel: _catLabel, theme: theme),
        )),
      ]),
    );
  }
}

// ── PlutoGrid View ────────────────────────────────────────────────────────────
class _PlutoView extends StatelessWidget {
  const _PlutoView({required this.cols, required this.rows, required this.theme, required this.onLoaded});
  final List<PlutoColumn> cols;
  final List<PlutoRow> rows;
  final AppTheme theme;
  final Function(PlutoGridStateManager) onLoaded;

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
          onLoaded: (e) { onLoaded(e.stateManager); e.stateManager.setPageSize(25, notify: false); },
          createFooter: (s) => PlutoPagination(s),
          configuration: PlutoGridConfiguration(
            style: PlutoGridStyleConfig(
              gridBorderColor: theme.border, gridBackgroundColor: theme.surface,
              rowColor: theme.surface, activatedColor: theme.primaryColor.withOpacity(0.08),
              activatedBorderColor: theme.primaryColor, columnHeight: 40, rowHeight: 44,
              columnTextStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: theme.textSecondary),
            ),
            columnSize: const PlutoGridColumnSizeConfig(autoSizeMode: PlutoAutoSizeMode.scale),
          ),
        ),
      ),
    );
  }
}

// ── Mobile Card List ──────────────────────────────────────────────────────────
class _CardList extends StatelessWidget {
  const _CardList({required this.items, required this.catLabel, required this.theme});
  final List<MaterialItem> items;
  final String Function(String) catLabel;
  final AppTheme theme;

  Color _statusColor(String s) =>
    s == 'agotado' ? theme.critical : s == 'bajo_stock' ? theme.high : theme.low;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return Center(child: Text('Sin resultados', style: TextStyle(color: theme.textSecondary)));
    return ListView.separated(
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, i) {
        final m = items[i];
        final sc = _statusColor(m.estatus);
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: theme.surface, borderRadius: BorderRadius.circular(12),
            border: Border.all(color: theme.border),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)]),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Text(m.clave, style: TextStyle(fontWeight: FontWeight.w800, color: theme.primaryColor, fontSize: 13)),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: sc.withOpacity(0.12), borderRadius: BorderRadius.circular(6)),
                child: Text(m.estatus == 'bajo_stock' ? 'Bajo Stock' : m.estatus == 'agotado' ? 'Agotado' : 'OK',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: sc))),
              const Spacer(),
              Text(catLabel(m.categoria), style: TextStyle(fontSize: 11, color: theme.textSecondary)),
            ]),
            const SizedBox(height: 6),
            Text(m.descripcion, style: TextStyle(fontSize: 13, color: theme.textPrimary)),
            const SizedBox(height: 8),
            Row(children: [
              _InfoBit('Stock', '${m.stockActual} ${m.unidad}', m.stockActual <= m.stockMinimo ? theme.critical : theme.textPrimary, theme),
              const SizedBox(width: 16),
              _InfoBit('Mín.', '${m.stockMinimo}', theme.textSecondary, theme),
              const SizedBox(width: 16),
              _InfoBit('Reservado', '${m.reservado}', theme.textSecondary, theme),
            ]),
          ]),
        );
      },
    );
  }
}

class _InfoBit extends StatelessWidget {
  const _InfoBit(this.label, this.value, this.color, this.theme);
  final String label, value;
  final Color color;
  final AppTheme theme;
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(label, style: TextStyle(fontSize: 10, color: theme.textSecondary, fontWeight: FontWeight.w600)),
    Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: color)),
  ]);
}

// ── Filter Bar ────────────────────────────────────────────────────────────────
class _FilterBar extends StatelessWidget {
  const _FilterBar({
    required this.search, required this.filterCategoria, required this.filterEstatus,
    required this.cats, required this.catLabel, required this.theme,
    required this.onSearch, required this.onCategoria, required this.onEstatus,
  });
  final String search;
  final String? filterCategoria, filterEstatus;
  final List<String> cats;
  final String Function(String) catLabel;
  final AppTheme theme;
  final ValueChanged<String> onSearch;
  final ValueChanged<String?> onCategoria, onEstatus;

  @override
  Widget build(BuildContext context) {
    return Wrap(spacing: 10, runSpacing: 8, crossAxisAlignment: WrapCrossAlignment.center, children: [
      SizedBox(width: 220, child: TextField(
        onChanged: onSearch,
        decoration: InputDecoration(
          hintText: 'Buscar clave o descripción…',
          hintStyle: TextStyle(fontSize: 12, color: theme.textSecondary),
          prefixIcon: Icon(Icons.search, size: 16, color: theme.textSecondary),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: theme.border)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: theme.border)),
          filled: true, fillColor: theme.surface,
        ),
      )),
      DropdownButtonHideUnderline(child: DropdownButton<String?>(
        value: filterCategoria,
        hint: Text('Categoría', style: TextStyle(fontSize: 12, color: theme.textSecondary)),
        items: [
          const DropdownMenuItem(value: null, child: Text('Todas')),
          ...cats.map((c) => DropdownMenuItem(value: c, child: Text(catLabel(c)))),
        ],
        onChanged: onCategoria, borderRadius: BorderRadius.circular(8),
      )),
      DropdownButtonHideUnderline(child: DropdownButton<String?>(
        value: filterEstatus,
        hint: Text('Estatus', style: TextStyle(fontSize: 12, color: theme.textSecondary)),
        items: const [
          DropdownMenuItem(value: null, child: Text('Todos')),
          DropdownMenuItem(value: 'disponible', child: Text('Disponible')),
          DropdownMenuItem(value: 'bajo_stock', child: Text('Bajo Stock')),
          DropdownMenuItem(value: 'agotado', child: Text('Agotado')),
        ],
        onChanged: onEstatus, borderRadius: BorderRadius.circular(8),
      )),
    ]);
  }
}

// ── Mini KPI chip ─────────────────────────────────────────────────────────────
class _Chip extends StatelessWidget {
  const _Chip(this.label, this.value, this.color, this.theme);
  final String label, value;
  final Color color;
  final AppTheme theme;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(20),
      border: Border.all(color: color.withOpacity(0.3))),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: color)),
      const SizedBox(width: 4),
      Text(label, style: TextStyle(fontSize: 11, color: theme.textSecondary)),
    ]),
  );
}
