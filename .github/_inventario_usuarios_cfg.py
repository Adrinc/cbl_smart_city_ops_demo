"""
Reescribe inventario_page.dart → PlutoGrid + mobile cards
Reescribe usuarios_page.dart  → PlutoGrid + mobile cards + full "Nuevo Usuario" dialog
Añade addRegla() a configuracion_provider.dart
Reescribe configuracion_page.dart → dialog completo "Nueva Regla"
"""
import pathlib
ROOT = pathlib.Path(r"g:\TRABAJO\FLUTTER\cbl_portal_demos\sistema_smart_sistem_demo")

# ─────────────────────────────────────── INVENTARIO PAGE ──────────────────────
inventario = r'''import 'package:flutter/material.dart';
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
'''

# ─────────────────────────────────────── USUARIOS PAGE ───────────────────────
usuarios = r'''import 'package:flutter/material.dart';
import 'package:nethive_neo/data/mock_data.dart';
import 'package:nethive_neo/helpers/formatters.dart';
import 'package:nethive_neo/models/models.dart';
import 'package:nethive_neo/theme/theme.dart';
import 'package:nethive_neo/widgets/shared/responsive_layout.dart';
import 'package:nethive_neo/widgets/shared/section_header.dart';
import 'package:pluto_grid/pluto_grid.dart';

class UsuariosPage extends StatefulWidget {
  const UsuariosPage({super.key});
  @override
  State<UsuariosPage> createState() => _UsuariosPageState();
}

class _UsuariosPageState extends State<UsuariosPage> {
  List<UsuarioSistema> _users = List.from(mockUsuarios);

  void _addUser(UsuarioSistema u) => setState(() => _users.add(u));

  List<PlutoColumn> _cols(AppTheme t) => [
    PlutoColumn(title: 'Usuario', field: 'nombre', type: PlutoColumnType.text(), width: 180,
      renderer: (r) {
        final u = _users.firstWhere((u) => u.nombre == r.cell.value, orElse: () => _users.first);
        return Row(children: [
          CircleAvatar(radius: 14, backgroundColor: t.primaryColor.withOpacity(0.12),
            backgroundImage: u.avatarPath != null ? AssetImage(u.avatarPath!) : null,
            child: u.avatarPath == null ? Text(u.iniciales, style: TextStyle(fontSize: 9, color: t.primaryColor, fontWeight: FontWeight.w700)) : null),
          const SizedBox(width: 8),
          Expanded(child: Text(u.nombre, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: t.textPrimary),
            overflow: TextOverflow.ellipsis)),
        ]);
      }),
    PlutoColumn(title: 'Email', field: 'email', type: PlutoColumnType.text(), width: 200,
      renderer: (r) => Text(r.cell.value, style: TextStyle(fontSize: 12, color: t.textSecondary))),
    PlutoColumn(title: 'Rol', field: 'rol', type: PlutoColumnType.text(), width: 140,
      renderer: (r) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(color: t.primarySoft, borderRadius: BorderRadius.circular(6)),
        child: Text((r.cell.value as String).replaceAll('_', ' '),
          style: TextStyle(fontSize: 11, color: t.primaryColor, fontWeight: FontWeight.w600)))),
    PlutoColumn(title: 'Nivel', field: 'nivel', type: PlutoColumnType.text(), width: 100,
      renderer: (r) => Text(_capitalizar(r.cell.value), style: TextStyle(fontSize: 12, color: t.textPrimary))),
    PlutoColumn(title: 'Estatus', field: 'estatus', type: PlutoColumnType.text(), width: 100,
      renderer: (r) {
        final active = r.cell.value == 'activo';
        final c = active ? t.low : t.neutral;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(color: c.withOpacity(0.12), borderRadius: BorderRadius.circular(6)),
          child: Text(active ? 'Activo' : 'Inactivo', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: c)));
      }),
    PlutoColumn(title: 'Último acceso', field: 'ultimo_acceso', type: PlutoColumnType.text(), width: 200,
      renderer: (r) => Text(r.cell.value, style: TextStyle(fontSize: 11, color: t.textSecondary))),
    PlutoColumn(title: 'Acciones', field: 'acciones', type: PlutoColumnType.text(), width: 100,
      enableSorting: false,
      renderer: (r) => Row(mainAxisSize: MainAxisSize.min, children: [
        IconButton(icon: Icon(Icons.edit_outlined, size: 16, color: t.textSecondary), onPressed: () {}, tooltip: 'Editar',
          padding: EdgeInsets.zero, constraints: const BoxConstraints(minWidth: 28, minHeight: 28)),
        IconButton(icon: Icon(Icons.block_outlined, size: 16, color: t.high), onPressed: () {}, tooltip: 'Desactivar',
          padding: EdgeInsets.zero, constraints: const BoxConstraints(minWidth: 28, minHeight: 28)),
      ])),
  ];

  List<PlutoRow> _rows() => _users.map((u) => PlutoRow(cells: {
    'nombre':        PlutoCell(value: u.nombre),
    'email':         PlutoCell(value: u.email),
    'rol':           PlutoCell(value: u.rol),
    'nivel':         PlutoCell(value: u.nivel),
    'estatus':       PlutoCell(value: u.estatus),
    'ultimo_acceso': PlutoCell(value: formatFechaHora(u.ultimoAcceso)),
    'acciones':      PlutoCell(value: ''),
  })).toList();

  static String _capitalizar(String s) => s.isEmpty ? s : '${s[0].toUpperCase()}${s.substring(1)}';

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SectionHeader(
          title: 'Usuarios del Sistema',
          subtitle: '${_users.length} usuarios registrados',
          trailing: FilledButton.icon(
            onPressed: () async {
              final result = await showDialog<UsuarioSistema>(
                context: context,
                builder: (_) => const _NuevoUsuarioDialog(),
              );
              if (result != null) _addUser(result);
            },
            icon: const Icon(Icons.person_add, size: 16),
            label: const Text('Nuevo Usuario'),
            style: FilledButton.styleFrom(backgroundColor: theme.primaryColor),
          ),
        ),
        const SizedBox(height: 20),
        Expanded(child: TableOrCards(
          tableView: _TableView(cols: _cols(theme), rows: _rows(), theme: theme),
          cardView: _MobileCardList(users: _users, theme: theme),
        )),
      ]),
    );
  }
}

// ── PlutoGrid Table ───────────────────────────────────────────────────────────
class _TableView extends StatelessWidget {
  const _TableView({required this.cols, required this.rows, required this.theme});
  final List<PlutoColumn> cols;
  final List<PlutoRow> rows;
  final AppTheme theme;
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: theme.surface, borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.border),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)]),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: PlutoGrid(
          columns: cols, rows: rows,
          onLoaded: (e) => e.stateManager.setPageSize(20, notify: false),
          createFooter: (s) => PlutoPagination(s),
          configuration: PlutoGridConfiguration(
            style: PlutoGridStyleConfig(
              gridBorderColor: theme.border, gridBackgroundColor: theme.surface,
              rowColor: theme.surface, activatedColor: theme.primaryColor.withOpacity(0.08),
              activatedBorderColor: theme.primaryColor, columnHeight: 40, rowHeight: 46,
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
class _MobileCardList extends StatelessWidget {
  const _MobileCardList({required this.users, required this.theme});
  final List<UsuarioSistema> users;
  final AppTheme theme;
  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: users.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, i) {
        final u = users[i];
        final isActive = u.estatus == 'activo';
        final sc = isActive ? theme.low : theme.neutral;
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: theme.surface, borderRadius: BorderRadius.circular(12),
            border: Border.all(color: theme.border),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)]),
          child: Row(children: [
            CircleAvatar(radius: 22, backgroundColor: theme.primaryColor.withOpacity(0.12),
              backgroundImage: u.avatarPath != null ? AssetImage(u.avatarPath!) : null,
              child: u.avatarPath == null ? Text(u.iniciales, style: TextStyle(fontSize: 12, color: theme.primaryColor, fontWeight: FontWeight.w700)) : null),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(u.nombre, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: theme.textPrimary)),
              Text(u.email, style: TextStyle(fontSize: 11, color: theme.textSecondary)),
              const SizedBox(height: 4),
              Row(children: [
                Container(padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(color: theme.primarySoft, borderRadius: BorderRadius.circular(5)),
                  child: Text(u.rol.replaceAll('_', ' '), style: TextStyle(fontSize: 10, color: theme.primaryColor, fontWeight: FontWeight.w600))),
                const SizedBox(width: 6),
                Container(padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(color: sc.withOpacity(0.12), borderRadius: BorderRadius.circular(5)),
                  child: Text(isActive ? 'Activo' : 'Inactivo', style: TextStyle(fontSize: 10, color: sc, fontWeight: FontWeight.w600))),
              ]),
            ])),
            IconButton(icon: Icon(Icons.edit_outlined, size: 18, color: theme.textSecondary), onPressed: () {}),
          ]),
        );
      },
    );
  }
}

// ─────────────────────── DIÁLOGO NUEVO USUARIO ───────────────────────────────
class _NuevoUsuarioDialog extends StatefulWidget {
  const _NuevoUsuarioDialog();
  @override
  State<_NuevoUsuarioDialog> createState() => _NuevoUsuarioDialogState();
}

class _NuevoUsuarioDialogState extends State<_NuevoUsuarioDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nombre  = TextEditingController();
  final _email   = TextEditingController();
  final _pass    = TextEditingController();
  String _rol     = 'operador_municipal';
  String _nivel   = 'municipal';
  bool  _obscure  = true;

  static const _roles   = ['admin', 'operador_municipal', 'operador_estatal', 'operador_nacional', 'supervisor'];
  static const _niveles = ['municipal', 'estatal', 'nacional'];

  @override
  void dispose() {
    _nombre.dispose(); _email.dispose(); _pass.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: isMobile ? double.infinity : 520),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Form(
            key: _formKey,
            child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
              // Header
              Row(children: [
                Container(width: 40, height: 40, decoration: BoxDecoration(
                  color: theme.primaryColor.withOpacity(0.12), shape: BoxShape.circle),
                  child: Icon(Icons.person_add_outlined, color: theme.primaryColor, size: 20)),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Nuevo Usuario', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: theme.textPrimary)),
                  Text('Los cambios son temporales en esta demo', style: TextStyle(fontSize: 11, color: theme.textSecondary)),
                ])),
                IconButton(icon: Icon(Icons.close, size: 18, color: theme.textSecondary), onPressed: () => Navigator.pop(context)),
              ]),
              const SizedBox(height: 22),
              Divider(color: theme.border),
              const SizedBox(height: 18),

              // Nombre
              _Label('Nombre completo', theme),
              const SizedBox(height: 6),
              _Field(controller: _nombre, hint: 'Ej. María García López',
                icon: Icons.person_outline, theme: theme,
                validator: (v) => (v == null || v.isEmpty) ? 'Requerido' : null),
              const SizedBox(height: 14),

              // Email
              _Label('Correo electrónico', theme),
              const SizedBox(height: 6),
              _Field(controller: _email, hint: 'Ej. m.garcia@ensenada.gob.mx',
                icon: Icons.email_outlined, theme: theme,
                keyboardType: TextInputType.emailAddress,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Requerido';
                  if (!v.contains('@')) return 'Email inválido';
                  return null;
                }),
              const SizedBox(height: 14),

              // Rol + Nivel (lado a lado en desktop)
              isMobile
                ? Column(children: [
                    _DropRow('Rol', _roles, _rol, theme, (v) => setState(() => _rol = v!), _rolLabel),
                    const SizedBox(height: 14),
                    _DropRow('Nivel de acceso', _niveles, _nivel, theme, (v) => setState(() => _nivel = v!), _nivelLabel),
                  ])
                : Row(children: [
                    Expanded(child: _DropRow('Rol', _roles, _rol, theme, (v) => setState(() => _rol = v!), _rolLabel)),
                    const SizedBox(width: 14),
                    Expanded(child: _DropRow('Nivel de acceso', _niveles, _nivel, theme, (v) => setState(() => _nivel = v!), _nivelLabel)),
                  ]),
              const SizedBox(height: 14),

              // Contraseña temporal
              _Label('Contraseña temporal', theme),
              const SizedBox(height: 6),
              TextFormField(
                controller: _pass,
                obscureText: _obscure,
                decoration: InputDecoration(
                  hintText: 'Mínimo 8 caracteres',
                  hintStyle: TextStyle(fontSize: 12, color: theme.textSecondary),
                  prefixIcon: Icon(Icons.lock_outline, size: 16, color: theme.textSecondary),
                  suffixIcon: IconButton(
                    icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined, size: 16, color: theme.textSecondary),
                    onPressed: () => setState(() => _obscure = !_obscure)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: theme.border)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: theme.border)),
                  filled: true, fillColor: theme.background,
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Requerida';
                  if (v.length < 8) return 'Mínimo 8 caracteres';
                  return null;
                },
              ),
              const SizedBox(height: 6),
              Text('El usuario deberá cambiarla en su primer inicio de sesión.',
                style: TextStyle(fontSize: 11, color: theme.textSecondary, fontStyle: FontStyle.italic)),
              const SizedBox(height: 24),
              Divider(color: theme.border),
              const SizedBox(height: 16),

              // Actions
              Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                  style: OutlinedButton.styleFrom(foregroundColor: theme.textSecondary, side: BorderSide(color: theme.border))),
                const SizedBox(width: 10),
                FilledButton.icon(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      Navigator.pop(context, UsuarioSistema(
                        id: 'u_${DateTime.now().millisecondsSinceEpoch}',
                        nombre: _nombre.text.trim(),
                        email: _email.text.trim(),
                        rol: _rol, nivel: _nivel,
                        estatus: 'activo',
                        ultimoAcceso: DateTime.now(),
                      ));
                    }
                  },
                  icon: const Icon(Icons.check, size: 16),
                  label: const Text('Crear Usuario'),
                  style: FilledButton.styleFrom(backgroundColor: theme.primaryColor)),
              ]),
            ]),
          ),
        ),
      ),
    );
  }

  static String _rolLabel(String r) {
    const m = {
      'admin': 'Administrador',
      'operador_municipal': 'Op. Municipal',
      'operador_estatal': 'Op. Estatal',
      'operador_nacional': 'Op. Nacional',
      'supervisor': 'Supervisor',
    };
    return m[r] ?? r;
  }
  static String _nivelLabel(String n) {
    const m = {'municipal': 'Municipal', 'estatal': 'Estatal', 'nacional': 'Nacional'};
    return m[n] ?? n;
  }
}

Widget _DropRow(String label, List<String> opts, String val, AppTheme theme,
    ValueChanged<String?> onChange, String Function(String) labelFn) {
  return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    _Label(label, theme),
    const SizedBox(height: 6),
    Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: theme.background, borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.border)),
      child: DropdownButtonHideUnderline(child: DropdownButton<String>(
        value: val, isExpanded: true,
        items: opts.map((o) => DropdownMenuItem(value: o, child: Text(labelFn(o), style: TextStyle(fontSize: 13)))).toList(),
        onChanged: onChange,
      )),
    ),
  ]);
}

class _Label extends StatelessWidget {
  const _Label(this.text, this.theme);
  final String text;
  final AppTheme theme;
  @override
  Widget build(BuildContext context) => Text(text,
    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: theme.textSecondary));
}

class _Field extends StatelessWidget {
  const _Field({required this.controller, required this.hint, required this.icon,
    required this.theme, this.validator, this.keyboardType});
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final AppTheme theme;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  @override
  Widget build(BuildContext context) => TextFormField(
    controller: controller,
    keyboardType: keyboardType,
    validator: validator,
    decoration: InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(fontSize: 12, color: theme.textSecondary),
      prefixIcon: Icon(icon, size: 16, color: theme.textSecondary),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: theme.border)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: theme.border)),
      filled: true, fillColor: theme.background,
    ),
  );
}
'''

# ─────────────────────── CONFIGURACION PROVIDER addRegla ─────────────────────
add_regla_method = '''
  void addRegla(ReglaPriorizacion r) {
    _reglas.insert(0, r);
    notifyListeners();
  }
'''

# ─────────────────────── CONFIGURACION PAGE — dialog completo ─────────────────
# Sólo reescribimos la función _showNuevaReglaDialog
nueva_regla_dialog = r'''  static void _showNuevaReglaDialog(
      BuildContext ctx, ConfiguracionProvider prov, AppTheme theme) {
    showDialog(
        context: ctx,
        builder: (_) => _NuevaReglaDialog(prov: prov));
  }
}

// ─────────────────────────── DIÁLOGO NUEVA REGLA ─────────────────────────────
class _NuevaReglaDialog extends StatefulWidget {
  const _NuevaReglaDialog({required this.prov});
  final ConfiguracionProvider prov;
  @override
  State<_NuevaReglaDialog> createState() => _NuevaReglaDialogState();
}

class _NuevaReglaDialogState extends State<_NuevaReglaDialog> {
  String _categoria    = 'alumbrado';
  String _entorno      = 'residencial';
  String _prioridad    = 'medio';
  int    _slaHoras     = 24;
  bool   _autoAprobar  = false;
  bool   _escalaReinc  = false;
  bool   _activa       = true;

  static const _categorias = ['alumbrado','bacheo','basura','seguridad','agua_drenaje','señalizacion'];
  static const _entornos   = ['residencial','comercial','industrial','institucional'];
  static const _prioridades= ['bajo','medio','alto','critico'];
  static const _slaOpts    = [4, 8, 12, 16, 24, 48, 72, 96];

  static const _catLabels  = {'alumbrado':'Alumbrado','bacheo':'Bacheo','basura':'Basura','seguridad':'Seguridad','agua_drenaje':'Agua / Drenaje','señalizacion':'Señalización'};
  static const _entLabels  = {'residencial':'Residencial','comercial':'Comercial','industrial':'Industrial','institucional':'Institucional'};
  static const _prioLabels = {'bajo':'Bajo','medio':'Medio','alto':'Alto','critico':'Crítico'};
  static const _prioColors = {'bajo': Color(0xFF2D7A4F),'medio': Color(0xFF1D4ED8),'alto': Color(0xFFD97706),'critico': Color(0xFFB91C1C)};

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final isMobile = MediaQuery.of(context).size.width < 600;
    final prioColor = _prioColors[_prioridad] ?? theme.textPrimary;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: isMobile ? double.infinity : 560),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(28),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Header
            Row(children: [
              Container(width: 40, height: 40,
                decoration: BoxDecoration(color: theme.primaryColor.withOpacity(0.12), shape: BoxShape.circle),
                child: Icon(Icons.tune, color: theme.primaryColor, size: 20)),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Nueva Regla de Priorización', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: theme.textPrimary)),
                Text('Cambios temporales — solo en esta sesión', style: TextStyle(fontSize: 11, color: theme.textSecondary)),
              ])),
              IconButton(icon: Icon(Icons.close, size: 18, color: theme.textSecondary), onPressed: () => Navigator.pop(context)),
            ]),
            const SizedBox(height: 20),
            Divider(color: theme.border),
            const SizedBox(height: 18),

            // Categoría + Entorno
            isMobile
              ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  _ReglaDroprow('Categoría', _categorias, _categoria, _catLabels, theme, Icons.category_outlined, (v) => setState(() => _categoria = v!)),
                  const SizedBox(height: 14),
                  _ReglaDroprow('Entorno urbano', _entornos, _entorno, _entLabels, theme, Icons.location_city_outlined, (v) => setState(() => _entorno = v!)),
                ])
              : Row(children: [
                  Expanded(child: _ReglaDroprow('Categoría', _categorias, _categoria, _catLabels, theme, Icons.category_outlined, (v) => setState(() => _categoria = v!))),
                  const SizedBox(width: 14),
                  Expanded(child: _ReglaDroprow('Entorno urbano', _entornos, _entorno, _entLabels, theme, Icons.location_city_outlined, (v) => setState(() => _entorno = v!))),
                ]),
            const SizedBox(height: 16),

            // Prioridad
            Text('Nivel de prioridad', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: theme.textSecondary)),
            const SizedBox(height: 8),
            Wrap(spacing: 8, children: _prioridades.map((p) {
              final c = _prioColors[p] ?? theme.textPrimary;
              final sel = _prioridad == p;
              return ChoiceChip(
                label: Text(_prioLabels[p] ?? p, style: TextStyle(fontSize: 12, color: sel ? Colors.white : c, fontWeight: FontWeight.w600)),
                selected: sel,
                onSelected: (_) => setState(() => _prioridad = p),
                selectedColor: c,
                backgroundColor: c.withOpacity(0.1),
                side: BorderSide(color: c.withOpacity(0.4)),
                showCheckmark: false,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              );
            }).toList()),
            const SizedBox(height: 16),

            // SLA horas
            Text('SLA (horas)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: theme.textSecondary)),
            const SizedBox(height: 8),
            Wrap(spacing: 8, children: _slaOpts.map((h) {
              final sel = _slaHoras == h;
              return ChoiceChip(
                label: Text('${h}h', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                selected: sel,
                onSelected: (_) => setState(() => _slaHoras = h),
                selectedColor: theme.primaryColor,
                labelStyle: TextStyle(color: sel ? Colors.white : null),
                side: BorderSide(color: theme.border),
                showCheckmark: false,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              );
            }).toList()),
            const SizedBox(height: 16),
            Divider(color: theme.border),
            const SizedBox(height: 12),

            // Switches
            _SwitchRow('Auto-Aprobar esta categoría/entorno', _autoAprobar, theme.low, theme, (v) => setState(() => _autoAprobar = v)),
            const SizedBox(height: 4),
            Text('Si está activo, los reportes que coincidan se aprueban sin revisión humana.',
              style: TextStyle(fontSize: 11, color: theme.textSecondary, fontStyle: FontStyle.italic)),
            const SizedBox(height: 10),
            _SwitchRow('Escalar prioridad si es reincidente', _escalaReinc, theme.high, theme, (v) => setState(() => _escalaReinc = v)),
            const SizedBox(height: 4),
            Text('Si hay incidencias previas similares, sube la prioridad un nivel automáticamente.',
              style: TextStyle(fontSize: 11, color: theme.textSecondary, fontStyle: FontStyle.italic)),
            const SizedBox(height: 10),
            _SwitchRow('Regla activa', _activa, theme.primaryColor, theme, (v) => setState(() => _activa = v)),
            const SizedBox(height: 20),

            // Preview chip
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: prioColor.withOpacity(0.07),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: prioColor.withOpacity(0.25))),
              child: Row(children: [
                Icon(Icons.preview, size: 18, color: prioColor),
                const SizedBox(width: 10),
                Expanded(child: Text(
                  '${_catLabels[_categoria]} en zona ${_entLabels[_entorno]?.toLowerCase()} → prioridad ${_prioLabels[_prioridad]?.toUpperCase()} · SLA ${_slaHoras}h',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: prioColor),
                )),
              ]),
            ),
            const SizedBox(height: 20),
            Divider(color: theme.border),
            const SizedBox(height: 14),

            Row(mainAxisAlignment: MainAxisAlignment.end, children: [
              OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(foregroundColor: theme.textSecondary, side: BorderSide(color: theme.border)),
                child: const Text('Cancelar')),
              const SizedBox(width: 10),
              FilledButton.icon(
                onPressed: () {
                  widget.prov.addRegla(ReglaPriorizacion(
                    id: 'r_${DateTime.now().millisecondsSinceEpoch}',
                    categoria: _categoria, entorno: _entorno,
                    nivelPrioridad: _prioridad, slaHoras: _slaHoras,
                    autoAprobar: _autoAprobar, esReincidenteEscala: _escalaReinc,
                    activa: _activa,
                  ));
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Regla creada (temporal — solo en esta sesión)'),
                    backgroundColor: Color(0xFF2D7A4F)));
                },
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Guardar Regla'),
                style: FilledButton.styleFrom(backgroundColor: theme.primaryColor)),
            ]),
          ]),
        ),
      ),
    );
  }
}

Widget _ReglaDroprow(String label, List<String> opts, String val,
    Map<String,String> labelMap, AppTheme theme, IconData icon, ValueChanged<String?> onChange) {
  return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: theme.textSecondary)),
    const SizedBox(height: 6),
    Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(color: theme.background, borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.border)),
      child: DropdownButtonHideUnderline(child: DropdownButton<String>(
        value: val, isExpanded: true,
        items: opts.map((o) => DropdownMenuItem(value: o, child: Row(children: [
          const SizedBox(width: 4),
          Text(labelMap[o] ?? o, style: const TextStyle(fontSize: 13)),
        ]))).toList(),
        onChanged: onChange,
      )),
    ),
  ]);
}

Widget _SwitchRow(String label, bool val, Color color, AppTheme theme, ValueChanged<bool> onChange) {
  return Row(children: [
    Expanded(child: Text(label, style: TextStyle(fontSize: 13, color: theme.textPrimary, fontWeight: FontWeight.w500))),
    Switch(value: val, onChanged: onChange, activeColor: color, materialTapTargetSize: MaterialTapTargetSize.shrinkWrap),
  ]);
}

// Keep the existing classes below this point
'''

# ── Ejecutar ─────────────────────────────────────────────────────────────────-

# 1. inventario_page.dart
(ROOT / 'lib' / 'pages' / 'inventario' / 'inventario_page.dart').write_text(inventario, encoding='utf-8')
print(f"✅ inventario_page.dart ({len(inventario.splitlines())} líneas)")

# 2. usuarios_page.dart
(ROOT / 'lib' / 'pages' / 'usuarios' / 'usuarios_page.dart').write_text(usuarios, encoding='utf-8')
print(f"✅ usuarios_page.dart ({len(usuarios.splitlines())} líneas)")

# 3. configuracion_provider.dart — insertar addRegla antes del cierre de clase
cfg_prov_path = ROOT / 'lib' / 'providers' / 'configuracion_provider.dart'
cfg_prov_text = cfg_prov_path.read_text(encoding='utf-8')

# Añadir addRegla() antes del último método (calcPrioridad)
if 'addRegla' not in cfg_prov_text:
    cfg_prov_text = cfg_prov_text.replace(
        '  String calcPrioridad(',
        add_regla_method + '  String calcPrioridad('
    )
    cfg_prov_path.write_text(cfg_prov_text, encoding='utf-8')
    print("✅ ConfiguracionProvider.addRegla() añadido")
else:
    print("⚠️ addRegla ya existe, saltando")

# 4. configuracion_page.dart — reescribir solo la sección del dialog + añadir nueva clase
cfg_page_path = ROOT / 'lib' / 'pages' / 'configuracion' / 'configuracion_page.dart'
cfg_page_text = cfg_page_path.read_text(encoding='utf-8')

# We need to add the missing imports at top and replace the stub dialog + add new classes
new_imports = '''import 'package:flutter/material.dart';
import 'package:nethive_neo/models/models.dart';
import 'package:nethive_neo/providers/providers.dart';
import 'package:nethive_neo/theme/theme.dart';
import 'package:nethive_neo/widgets/shared/section_header.dart';
import 'package:provider/provider.dart';
'''

old_stub = '''  static void _showNuevaReglaDialog(
      BuildContext ctx, ConfiguracionProvider prov, AppTheme theme) {
    showDialog(
        context: ctx,
        builder: (_) => AlertDialog(
              title: Text('Nueva Regla de Priorización',
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: theme.textPrimary)),
              content: Text(
                  'En la versión final, aquí se mostrará un formulario para crear nuevas reglas de priorización automática.',
                  style: TextStyle(fontSize: 13, color: theme.textSecondary)),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(_),
                    child: const Text('Cerrar')),
              ],
            ));
  }
}'''

if old_stub in cfg_page_text:
    cfg_page_text = cfg_page_text.replace(old_stub, nueva_regla_dialog)
    cfg_page_path.write_text(cfg_page_text, encoding='utf-8')
    print("✅ configuracion_page.dart — dialog Nueva Regla completo insertado")
else:
    print(f"⚠️ No se encontró el stub exacto. Reemplazando manualmente.")
    # Try a partial match
    marker = '  static void _showNuevaReglaDialog('
    if marker in cfg_page_text:
        # Find the end of the enclosing class (the } that closes ConfiguracionPage)
        idx = cfg_page_text.index(marker)
        # Find next '}' that closes the class after the function
        end = cfg_page_text.find('\n}\n', idx)
        if end != -1:
            cfg_page_text = cfg_page_text[:idx] + nueva_regla_dialog + cfg_page_text[end+3:]
            cfg_page_path.write_text(cfg_page_text, encoding='utf-8')
            print("✅ configuracion_page.dart — dialog reemplazado (modo fallback)")
        else:
            print("❌ No se pudo insertar el dialog — revisar manualmente")
    else:
        print("❌ Marcador no encontrado — revisar el archivo configuracion_page.dart")
