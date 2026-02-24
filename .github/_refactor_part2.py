"""
Parte 2: Técnicos page (PlutoGrid desktop + NuevoTécnico dialog) +
         TecnicoProvider (agregarTecnico + avatar bytes cache) +
         Tecnico model (copyWith ampliado) +
         Plan_de_mejoras.md
"""
import pathlib

ROOT = pathlib.Path(r"g:\TRABAJO\FLUTTER\cbl_portal_demos\sistema_smart_sistem_demo")
LIB  = ROOT / "lib"

# ═══════════════════════════════════════════════════════════════════════════════
# 1. TecnicoProvider — agrega agregarTecnico + avatar bytes cache
# ═══════════════════════════════════════════════════════════════════════════════
(LIB / "providers" / "tecnico_provider.dart").write_text(r"""
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:nethive_neo/data/mock_data.dart';
import 'package:nethive_neo/models/models.dart';

class TecnicoProvider extends ChangeNotifier {
  final List<Tecnico> _tecnicos = List.from(MockData.tecnicos);
  final Map<String, Uint8List> _avatarBytesCache = {};
  String _filtroEstatus = 'todos';

  // ── Getters ───────────────────────────────────────────────────────────────
  List<Tecnico> get todos   => List.unmodifiable(_tecnicos);
  List<Tecnico> get activos => _tecnicos.where((t) => t.estatus != 'inactivo').toList();
  List<Tecnico> get disponibles => _tecnicos.where((t) => t.estatus == 'activo').toList();
  List<Tecnico> get enCampo    => _tecnicos.where((t) => t.estatus == 'en_campo').toList();
  String get filtroEstatus => _filtroEstatus;

  Tecnico? byId(String id) {
    try { return _tecnicos.firstWhere((t) => t.id == id); } catch (_) { return null; }
  }

  List<Tecnico> byEspecialidad(String esp) =>
      _tecnicos.where((t) => t.especialidad == esp).toList();

  // ── Filtro ────────────────────────────────────────────────────────────────
  void setFiltroEstatus(String estatus) {
    _filtroEstatus = estatus;
    notifyListeners();
  }

  List<Tecnico> get filtrados {
    if (_filtroEstatus == 'todos') return todos;
    return _tecnicos.where((t) => t.estatus == _filtroEstatus).toList();
  }

  // ── Conteos ───────────────────────────────────────────────────────────────
  Map<String, int> get conteoEstatus => {
    'activo':    _tecnicos.where((t) => t.estatus == 'activo').length,
    'en_campo':  _tecnicos.where((t) => t.estatus == 'en_campo').length,
    'descanso':  _tecnicos.where((t) => t.estatus == 'descanso').length,
    'inactivo':  _tecnicos.where((t) => t.estatus == 'inactivo').length,
  };

  // ── Acciones ──────────────────────────────────────────────────────────────
  void actualizarEstatus(String id, String nuevoEstatus) {
    final idx = _tecnicos.indexWhere((t) => t.id == id);
    if (idx == -1) return;
    _tecnicos[idx] = _tecnicos[idx].copyWith(estatus: nuevoEstatus);
    notifyListeners();
  }

  void agregarTecnico(Tecnico tecnico) {
    _tecnicos.add(tecnico);
    notifyListeners();
  }

  // ── Avatar bytes (Flutter Web upload) ────────────────────────────────────
  void setAvatarBytes(String id, Uint8List bytes) {
    _avatarBytesCache[id] = bytes;
    notifyListeners();
  }

  Uint8List? getAvatarBytes(String id) => _avatarBytesCache[id];
}
""".strip(), encoding='utf-8')
print("✅ tecnico_provider.dart actualizado")

# ═══════════════════════════════════════════════════════════════════════════════
# 2. tecnicos_page.dart — reescritura completa
# ═══════════════════════════════════════════════════════════════════════════════
(LIB / "pages" / "tecnicos" / "tecnicos_page.dart").write_text(r"""
// ignore_for_file: avoid_web_libraries_in_flutter
import 'dart:typed_data';
// ignore: deprecated_member_use_from_same_package
import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:nethive_neo/helpers/formatters.dart';
import 'package:nethive_neo/models/models.dart';
import 'package:nethive_neo/providers/providers.dart';
import 'package:nethive_neo/theme/theme.dart';
import 'package:nethive_neo/widgets/shared/section_header.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:provider/provider.dart';

class TecnicosPage extends StatefulWidget {
  const TecnicosPage({super.key});
  @override
  State<TecnicosPage> createState() => _TecnicosPageState();
}

class _TecnicosPageState extends State<TecnicosPage> {
  // ── Cambiar estatus inline ─────────────────────────────────────────────────
  void _cambiarEstatus(BuildContext ctx, Tecnico tec) {
    final theme = AppTheme.of(ctx);
    showDialog(context: ctx, builder: (_) => _CambiarEstatusDialog(tecnico: tec, theme: theme));
  }

  // ── Ver detalle ───────────────────────────────────────────────────────────
  void _verDetalle(BuildContext ctx, Tecnico tec) {
    final theme = AppTheme.of(ctx);
    final prov  = ctx.read<TecnicoProvider>();
    showDialog(context: ctx, builder: (_) => _DetalleTecnicoDialog(
      tecnico: tec, theme: theme, avatarBytes: prov.getAvatarBytes(tec.id)));
  }

  // ── Nuevo técnico ─────────────────────────────────────────────────────────
  void _nuevoTecnico(BuildContext ctx) {
    final theme = AppTheme.of(ctx);
    showDialog(context: ctx, builder: (_) => _NuevoTecnicoDialog(theme: theme));
  }

  @override
  Widget build(BuildContext context) {
    final theme   = AppTheme.of(context);
    final prov    = context.watch<TecnicoProvider>();
    final cnts    = prov.conteoEstatus;
    final items   = prov.filtrados;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

        // ── Header ──────────────────────────────────────────────────────────
        SectionHeader(
          title: 'Gestión de Técnicos',
          subtitle: 'Cuadrillas · Asignaciones · Disponibilidad — Ensenada',
          trailing: ElevatedButton.icon(
            onPressed: () => _nuevoTecnico(context),
            icon: const Icon(Icons.person_add_outlined, size: 16),
            label: const Text('Nuevo Técnico'),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.primaryColor, foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10))),
        ),
        const SizedBox(height: 18),

        // ── KPI Cards ───────────────────────────────────────────────────────
        LayoutBuilder(builder: (_, box) {
          return GridView.count(
            crossAxisCount: box.maxWidth > 700 ? 4 : 2,
            shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 14, mainAxisSpacing: 14, childAspectRatio: 3.2,
            children: [
              _StatCard(label: 'Total',    value: '${prov.todos.length}', icon: Icons.people_outline, color: theme.primaryColor, theme: theme),
              _StatCard(label: 'Activos',  value: '${cnts["activo"] ?? 0}', icon: Icons.check_circle_outline, color: theme.low, theme: theme),
              _StatCard(label: 'En campo', value: '${cnts["en_campo"] ?? 0}', icon: Icons.directions_run, color: theme.high, theme: theme),
              _StatCard(label: 'Descanso', value: '${cnts["descanso"] ?? 0}', icon: Icons.coffee_outlined, color: theme.neutral, theme: theme),
            ]);
        }),
        const SizedBox(height: 16),

        // ── Filtros ──────────────────────────────────────────────────────────
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(children: [
            for (final opt in ['todos', 'activo', 'en_campo', 'descanso', 'inactivo'])
              Padding(padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(_labelFiltro(opt), style: const TextStyle(fontSize: 12)),
                  selected: prov.filtroEstatus == opt,
                  selectedColor: theme.primaryColor.withOpacity(0.15),
                  onSelected: (_) => context.read<TecnicoProvider>().setFiltroEstatus(opt))),
          ])),
        const SizedBox(height: 14),

        // ── Contenido principal ──────────────────────────────────────────────
        Expanded(child: LayoutBuilder(builder: (ctx, box) {
          if (box.maxWidth >= 820) {
            return _PlutoTecnicosView(
              items: items, theme: theme,
              onDetalle:       (t) => _verDetalle(context, t),
              onCambiarEstatus: (t) => _cambiarEstatus(context, t));
          }
          return GridView.builder(
            gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: box.maxWidth > 500 ? 320 : 400,
              crossAxisSpacing: 14, mainAxisSpacing: 14, childAspectRatio: 1.18),
            itemCount: items.length,
            itemBuilder: (_, i) => _TecnicoCard(
              tecnico: items[i],
              avatarBytes: prov.getAvatarBytes(items[i].id),
              theme: theme,
              onDetalle:       () => _verDetalle(context, items[i]),
              onCambiarEstatus: () => _cambiarEstatus(context, items[i])));
        })),
      ]),
    );
  }

  String _labelFiltro(String f) {
    const m = {'todos': 'Todos', 'activo': 'Activos', 'en_campo': 'En campo',
               'descanso': 'Descanso', 'inactivo': 'Inactivos'};
    return m[f] ?? f;
  }
}

// ════════════════════════════════════════════════════════════════════════════════
// PLUTOGRID DESKTOP
// ════════════════════════════════════════════════════════════════════════════════
class _PlutoTecnicosView extends StatelessWidget {
  const _PlutoTecnicosView({required this.items, required this.theme,
    required this.onDetalle, required this.onCambiarEstatus});
  final List<Tecnico> items;
  final AppTheme theme;
  final ValueChanged<Tecnico> onDetalle, onCambiarEstatus;

  Tecnico? _tec(PlutoColumnRendererContext r) {
    final id = r.row.cells['id']?.value as String? ?? '';
    try { return items.firstWhere((t) => t.id == id); } catch (_) { return null; }
  }

  List<PlutoColumn> _cols(BuildContext context) => [
    PlutoColumn(title: '', field: 'avatar', type: PlutoColumnType.text(), width: 60,
      enableSorting: false, enableFilterMenuItem: false,
      renderer: (r) {
        final tec  = _tec(r);
        final prov = context.read<TecnicoProvider>();
        final bytes = tec != null ? prov.getAvatarBytes(tec.id) : null;
        final color = _estatusColor(tec?.estatus ?? '', theme);
        if (bytes != null) return Center(child: CircleAvatar(radius: 22, backgroundImage: MemoryImage(bytes)));
        return Center(child: CircleAvatar(radius: 22,
          backgroundColor: color.withOpacity(0.2),
          child: Text(tec?.iniciales ?? '?',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: color))));
      }),

    PlutoColumn(title: 'ID', field: 'id', type: PlutoColumnType.text(), width: 72,
      renderer: (r) => Text(r.cell.value,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: theme.textSecondary))),

    PlutoColumn(title: 'Nombre', field: 'nombre', type: PlutoColumnType.text(), width: 170,
      renderer: (r) => Text(r.cell.value,
        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: theme.textPrimary),
        overflow: TextOverflow.ellipsis)),

    PlutoColumn(title: 'Rol', field: 'rol', type: PlutoColumnType.text(), width: 130,
      renderer: (r) => Text(labelRolTecnico(r.cell.value),
        style: TextStyle(fontSize: 12, color: theme.textSecondary))),

    PlutoColumn(title: 'Especialidad', field: 'especialidad', type: PlutoColumnType.text(), width: 130,
      renderer: (r) => Text(labelCategoria(r.cell.value),
        style: TextStyle(fontSize: 12, color: theme.textPrimary))),

    PlutoColumn(title: 'Estatus', field: 'estatus', type: PlutoColumnType.text(), width: 118,
      renderer: (r) {
        final c = _estatusColor(r.cell.value, theme);
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(color: c.withOpacity(0.12), borderRadius: BorderRadius.circular(20),
            border: Border.all(color: c.withOpacity(0.3))),
          child: Text(labelEstatusTecnico(r.cell.value),
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: c)));
      }),

    PlutoColumn(title: 'Activas', field: 'activas', type: PlutoColumnType.number(), width: 82,
      renderer: (r) {
        final v = r.cell.value as int;
        final c = v > 3 ? theme.critical : v > 1 ? theme.high : theme.low;
        return Center(child: Container(
          width: 32, height: 32, decoration: BoxDecoration(color: c.withOpacity(0.1), shape: BoxShape.circle),
          child: Center(child: Text('$v',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: c)))));
      }),

    PlutoColumn(title: 'Cerradas/mes', field: 'cerradas', type: PlutoColumnType.number(), width: 110,
      renderer: (r) => Center(child: Text('${r.cell.value}',
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: theme.low)))),

    PlutoColumn(title: 'Municipio', field: 'municipio', type: PlutoColumnType.text(), width: 110,
      renderer: (r) => Text(r.cell.value,
        style: TextStyle(fontSize: 11, color: theme.textSecondary), overflow: TextOverflow.ellipsis)),

    PlutoColumn(title: 'Acciones', field: 'acc', type: PlutoColumnType.text(), width: 140,
      enableSorting: false, enableFilterMenuItem: false,
      renderer: (r) {
        final tec = _tec(r);
        if (tec == null) return const SizedBox.shrink();
        return Row(mainAxisSize: MainAxisSize.min, children: [
          _IconBtn(icon: Icons.person_outline, tooltip: 'Ver detalle', color: theme.primaryColor,
            onTap: () => onDetalle(tec)),
          const SizedBox(width: 6),
          _IconBtn(icon: Icons.swap_horiz, tooltip: 'Cambiar estatus', color: theme.medium,
            onTap: () => onCambiarEstatus(tec)),
        ]);
      }),
  ];

  List<PlutoRow> _rows() => items.map((t) => PlutoRow(cells: {
    'avatar':      PlutoCell(value: ''),
    'id':          PlutoCell(value: t.id),
    'nombre':      PlutoCell(value: t.nombre),
    'rol':         PlutoCell(value: t.rol),
    'especialidad':PlutoCell(value: t.especialidad),
    'estatus':     PlutoCell(value: t.estatus),
    'activas':     PlutoCell(value: t.incidenciasActivas),
    'cerradas':    PlutoCell(value: t.incidenciasCerradasMes),
    'municipio':   PlutoCell(value: t.municipioAsignado ?? 'Ensenada'),
    'acc':         PlutoCell(value: ''),
  })).toList();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: theme.surface, borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.border),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))]),
      child: ClipRRect(borderRadius: BorderRadius.circular(12),
        child: PlutoGrid(
          columns: _cols(context),
          rows: _rows(),
          onLoaded: (e) => e.stateManager.setPageSize(15, notify: false),
          createFooter: (s) => PlutoPagination(s),
          configuration: PlutoGridConfiguration(
            style: PlutoGridStyleConfig(
              gridBorderColor: theme.border, gridBackgroundColor: theme.surface,
              rowColor: theme.surface, activatedColor: theme.primaryColor.withOpacity(0.07),
              activatedBorderColor: theme.primaryColor,
              columnHeight: 44, rowHeight: 60,
              columnTextStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: theme.textSecondary)),
            columnSize: const PlutoGridColumnSizeConfig(autoSizeMode: PlutoAutoSizeMode.none)))),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════════
// TECNICO CARD (mobile)
// ════════════════════════════════════════════════════════════════════════════════
class _TecnicoCard extends StatelessWidget {
  const _TecnicoCard({required this.tecnico, required this.avatarBytes, required this.theme,
    required this.onDetalle, required this.onCambiarEstatus});
  final Tecnico tecnico;
  final Uint8List? avatarBytes;
  final AppTheme theme;
  final VoidCallback onDetalle, onCambiarEstatus;

  @override
  Widget build(BuildContext context) {
    final color = _estatusColor(tecnico.estatus, theme);
    return Container(
      decoration: BoxDecoration(
        color: theme.surface, borderRadius: BorderRadius.circular(14),
        border: Border.all(color: theme.border),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 3))]),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            CircleAvatar(
              radius: 26,
              backgroundImage: avatarBytes != null ? MemoryImage(avatarBytes!) : null,
              backgroundColor: color.withOpacity(0.18),
              child: avatarBytes == null
                ? Text(tecnico.iniciales, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: color))
                : null),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(tecnico.nombre, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: theme.textPrimary),
                overflow: TextOverflow.ellipsis),
              Text(labelRolTecnico(tecnico.rol), style: TextStyle(fontSize: 11, color: theme.textSecondary)),
            ])),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(20),
                border: Border.all(color: color.withOpacity(0.3))),
              child: Text(labelEstatusTecnico(tecnico.estatus),
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: color))),
          ]),
          const SizedBox(height: 12),

          // Especialidad + municipio
          Wrap(spacing: 6, runSpacing: 4, children: [
            _Chip(label: labelCategoria(tecnico.especialidad), icon: Icons.build_outlined, theme: theme),
            if (tecnico.municipioAsignado != null)
              _Chip(label: tecnico.municipioAsignado!, icon: Icons.location_city_outlined, theme: theme),
          ]),
          const SizedBox(height: 10),

          // Métricas
          Row(children: [
            _MetricaTile(label: 'Activas', value: '${tecnico.incidenciasActivas}',
              color: tecnico.incidenciasActivas > 3 ? theme.critical : theme.high, theme: theme),
            const SizedBox(width: 8),
            _MetricaTile(label: 'Cerradas/mes', value: '${tecnico.incidenciasCerradasMes}',
              color: theme.low, theme: theme),
          ]),
          const Spacer(),

          // Acciones
          Row(children: [
            Expanded(child: OutlinedButton.icon(
              onPressed: onDetalle,
              icon: Icon(Icons.person_outline, size: 13, color: theme.primaryColor),
              label: Text('Detalle', style: TextStyle(fontSize: 12, color: theme.primaryColor)),
              style: OutlinedButton.styleFrom(side: BorderSide(color: theme.primaryColor.withOpacity(0.4)),
                padding: const EdgeInsets.symmetric(vertical: 8)))),
            const SizedBox(width: 8),
            Expanded(child: OutlinedButton.icon(
              onPressed: onCambiarEstatus,
              icon: Icon(Icons.swap_horiz, size: 13, color: theme.medium),
              label: Text('Estatus', style: TextStyle(fontSize: 12, color: theme.medium)),
              style: OutlinedButton.styleFrom(side: BorderSide(color: theme.medium.withOpacity(0.4)),
                padding: const EdgeInsets.symmetric(vertical: 8)))),
          ]),
        ]),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════════
// DIALOG — Detalle del técnico
// ════════════════════════════════════════════════════════════════════════════════
class _DetalleTecnicoDialog extends StatelessWidget {
  const _DetalleTecnicoDialog({required this.tecnico, required this.theme, this.avatarBytes});
  final Tecnico tecnico;
  final AppTheme theme;
  final Uint8List? avatarBytes;

  @override
  Widget build(BuildContext context) {
    final color = _estatusColor(tecnico.estatus, theme);
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          // Header vino
          Container(
            width: double.infinity, padding: const EdgeInsets.fromLTRB(24, 24, 16, 20),
            decoration: BoxDecoration(
              color: theme.primaryColor.withOpacity(0.08),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(18))),
            child: Row(children: [
              CircleAvatar(radius: 30,
                backgroundImage: avatarBytes != null ? MemoryImage(avatarBytes!) : null,
                backgroundColor: color.withOpacity(0.2),
                child: avatarBytes == null
                  ? Text(tecnico.iniciales, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: color))
                  : null),
              const SizedBox(width: 16),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(tecnico.nombre, style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: theme.textPrimary)),
                Text(labelRolTecnico(tecnico.rol), style: TextStyle(fontSize: 12, color: theme.textSecondary)),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(20)),
                  child: Text(labelEstatusTecnico(tecnico.estatus),
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: color))),
              ])),
              IconButton(icon: Icon(Icons.close, color: theme.textSecondary), onPressed: () => Navigator.pop(context)),
            ])),
          // Info
          Padding(
            padding: const EdgeInsets.all(22),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _InfoRow2('Especialidad', labelCategoria(tecnico.especialidad), theme),
              _InfoRow2('Municipio', tecnico.municipioAsignado ?? 'Ensenada', theme),
              _InfoRow2('ID', tecnico.id, theme),
              _InfoRow2('Incidencias activas', '${tecnico.incidenciasActivas}', theme),
              _InfoRow2('Cerradas este mes', '${tecnico.incidenciasCerradasMes}', theme),
              _InfoRow2('Ubicación', '${tecnico.latitud.toStringAsFixed(4)}, ${tecnico.longitud.toStringAsFixed(4)}', theme),
            ])),
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 0, 22, 18),
            child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(backgroundColor: theme.primaryColor, foregroundColor: Colors.white),
                child: const Text('Cerrar')),
            ])),
        ]),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════════
// DIALOG — Cambiar estatus
// ════════════════════════════════════════════════════════════════════════════════
class _CambiarEstatusDialog extends StatefulWidget {
  const _CambiarEstatusDialog({required this.tecnico, required this.theme});
  final Tecnico tecnico;
  final AppTheme theme;
  @override
  State<_CambiarEstatusDialog> createState() => _CambiarEstatusDialogState();
}

class _CambiarEstatusDialogState extends State<_CambiarEstatusDialog> {
  late String _estatus;
  @override void initState() { super.initState(); _estatus = widget.tecnico.estatus; }

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme;
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 380),
        child: Padding(padding: const EdgeInsets.all(24), child: Column(mainAxisSize: MainAxisSize.min, children: [
          Row(children: [
            Icon(Icons.swap_horiz, color: theme.medium),
            const SizedBox(width: 10),
            Expanded(child: Text('Cambiar estatus — ${widget.tecnico.nombre}',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: theme.textPrimary))),
            IconButton(icon: Icon(Icons.close, color: theme.textSecondary, size: 18),
              onPressed: () => Navigator.pop(context)),
          ]),
          const SizedBox(height: 18),
          for (final op in ['activo', 'en_campo', 'descanso', 'inactivo'])
            RadioListTile<String>(
              value: op, groupValue: _estatus,
              title: Text(labelEstatusTecnico(op), style: const TextStyle(fontSize: 13)),
              activeColor: _estatusColor(op, theme),
              onChanged: (v) => setState(() => _estatus = v!),
              dense: true, contentPadding: EdgeInsets.zero),
          const SizedBox(height: 14),
          Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () {
                context.read<TecnicoProvider>().actualizarEstatus(widget.tecnico.id, _estatus);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('${widget.tecnico.nombre}: estatus actualizado a ${labelEstatusTecnico(_estatus)}'),
                  backgroundColor: theme.low));
              },
              style: ElevatedButton.styleFrom(backgroundColor: theme.primaryColor, foregroundColor: Colors.white),
              child: const Text('Guardar')),
          ]),
        ]))));
  }
}

// ════════════════════════════════════════════════════════════════════════════════
// DIALOG — Nuevo Técnico con upload de avatar (Flutter Web)
// ════════════════════════════════════════════════════════════════════════════════
class _NuevoTecnicoDialog extends StatefulWidget {
  const _NuevoTecnicoDialog({required this.theme});
  final AppTheme theme;
  @override State<_NuevoTecnicoDialog> createState() => _NuevoTecnicoDialogState();
}

class _NuevoTecnicoDialogState extends State<_NuevoTecnicoDialog> {
  final _formKey      = GlobalKey<FormState>();
  final _nombreCtrl   = TextEditingController();
  String _rol         = 'tecnico_campo';
  String _especialidad = 'general';
  String _estatus     = 'activo';
  Uint8List? _avatarBytes;
  bool _loadingImg    = false;

  @override void dispose() { _nombreCtrl.dispose(); super.dispose(); }

  // Abrir file picker web
  Future<void> _pickImage() async {
    setState(() => _loadingImg = true);
    final input = html.FileUploadInputElement()..accept = 'image/*';
    input.click();
    await input.onChange.first;
    final file = input.files?.first;
    if (file == null) { setState(() => _loadingImg = false); return; }
    final reader = html.FileReader();
    reader.readAsArrayBuffer(file);
    await reader.onLoad.first;
    final result = reader.result;
    if (result is List<int>) {
      setState(() { _avatarBytes = Uint8List.fromList(result); _loadingImg = false; });
    } else {
      setState(() => _loadingImg = false);
    }
  }

  void _guardar() {
    if (!_formKey.currentState!.validate()) return;
    final prov = context.read<TecnicoProvider>();
    final id   = 'TEC-${(prov.todos.length + 1).toString().padLeft(3, "0")}';
    final tec  = Tecnico(
      id: id, nombre: _nombreCtrl.text.trim(), rol: _rol, especialidad: _especialidad,
      estatus: _estatus, incidenciasActivas: 0, incidenciasCerradasMes: 0,
      latitud: 31.8667, longitud: -116.5963, municipioAsignado: 'Ensenada');
    prov.agregarTecnico(tec);
    if (_avatarBytes != null) prov.setAvatarBytes(id, _avatarBytes!);
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Técnico $id agregado correctamente'),
      backgroundColor: widget.theme.low));
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme;
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520, maxHeight: 680),
        child: Form(key: _formKey, child: Column(children: [
          // Header
          Container(
            padding: const EdgeInsets.fromLTRB(24, 22, 16, 18),
            decoration: BoxDecoration(color: theme.primaryColor.withOpacity(0.08),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(18))),
            child: Row(children: [
              Icon(Icons.person_add_outlined, color: theme.primaryColor, size: 22),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Nuevo Técnico', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: theme.textPrimary)),
                Text('Registrar nuevo miembro de cuadrilla', style: TextStyle(fontSize: 12, color: theme.textSecondary)),
              ])),
              IconButton(icon: Icon(Icons.close, color: theme.textSecondary), onPressed: () => Navigator.pop(context)),
            ])),

          // Body
          Expanded(child: SingleChildScrollView(padding: const EdgeInsets.all(24),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

              // Avatar upload
              Center(child: Column(children: [
                GestureDetector(
                  onTap: _pickImage,
                  child: Stack(alignment: Alignment.bottomRight, children: [
                    CircleAvatar(radius: 46,
                      backgroundImage: _avatarBytes != null ? MemoryImage(_avatarBytes!) : null,
                      backgroundColor: theme.primaryColor.withOpacity(0.12),
                      child: _loadingImg
                        ? SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: theme.primaryColor, strokeWidth: 2))
                        : _avatarBytes == null
                          ? Icon(Icons.person_outline, size: 36, color: theme.primaryColor)
                          : null),
                    Container(
                      width: 28, height: 28,
                      decoration: BoxDecoration(color: theme.primaryColor, shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2)),
                      child: const Icon(Icons.camera_alt, size: 14, color: Colors.white)),
                  ])),
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: _pickImage,
                  icon: const Icon(Icons.upload_file, size: 14),
                  label: Text(_avatarBytes != null ? 'Cambiar foto' : 'Subir foto (opcional)',
                    style: const TextStyle(fontSize: 12))),
              ])),
              const SizedBox(height: 20),

              // Nombre
              Text('Nombre completo *', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: theme.textSecondary)),
              const SizedBox(height: 6),
              TextFormField(
                controller: _nombreCtrl,
                decoration: InputDecoration(
                  hintText: 'Ej. Carlos Mendoza López',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  contentPadding: const EdgeInsets.all(12)),
                validator: (v) => v == null || v.trim().isEmpty ? 'El nombre es requerido' : null),
              const SizedBox(height: 14),

              // Rol
              Text('Rol *', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: theme.textSecondary)),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                value: _rol,
                decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  contentPadding: const EdgeInsets.all(12)),
                items: const [
                  DropdownMenuItem(value: 'tecnico_campo',   child: Text('Técnico de campo')),
                  DropdownMenuItem(value: 'jefe_cuadrilla',  child: Text('Jefe de cuadrilla')),
                  DropdownMenuItem(value: 'supervisor',      child: Text('Supervisor')),
                ],
                onChanged: (v) => setState(() => _rol = v!)),
              const SizedBox(height: 14),

              // Especialidad
              Text('Especialidad *', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: theme.textSecondary)),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                value: _especialidad,
                decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  contentPadding: const EdgeInsets.all(12)),
                items: const [
                  DropdownMenuItem(value: 'alumbrado',    child: Text('Alumbrado público')),
                  DropdownMenuItem(value: 'bacheo',       child: Text('Bacheo y pavimentación')),
                  DropdownMenuItem(value: 'basura',       child: Text('Recolección de basura')),
                  DropdownMenuItem(value: 'agua_drenaje', child: Text('Agua y drenaje')),
                  DropdownMenuItem(value: 'señalizacion', child: Text('Señalización vial')),
                  DropdownMenuItem(value: 'general',      child: Text('General')),
                ],
                onChanged: (v) => setState(() => _especialidad = v!)),
              const SizedBox(height: 14),

              // Estatus inicial
              Text('Estatus inicial', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: theme.textSecondary)),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                value: _estatus,
                decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  contentPadding: const EdgeInsets.all(12)),
                items: const [
                  DropdownMenuItem(value: 'activo',   child: Text('Activo')),
                  DropdownMenuItem(value: 'descanso', child: Text('Descanso')),
                  DropdownMenuItem(value: 'inactivo', child: Text('Inactivo')),
                ],
                onChanged: (v) => setState(() => _estatus = v!)),
            ]))),

          // Footer
          Padding(padding: const EdgeInsets.fromLTRB(24, 0, 24, 20), child: Row(
            mainAxisAlignment: MainAxisAlignment.end, children: [
              OutlinedButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar'),
                style: OutlinedButton.styleFrom(foregroundColor: theme.textSecondary, side: BorderSide(color: theme.border))),
              const SizedBox(width: 12),
              FilledButton.icon(onPressed: _guardar,
                icon: const Icon(Icons.check, size: 16), label: const Text('Registrar técnico'),
                style: FilledButton.styleFrom(backgroundColor: theme.primaryColor, padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12))),
            ])),
        ])),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════════
// HELPERS LOCALES
// ════════════════════════════════════════════════════════════════════════════════
Color _estatusColor(String estatus, AppTheme theme) {
  switch (estatus) {
    case 'activo':   return theme.low;
    case 'en_campo': return theme.high;
    case 'descanso': return theme.neutral;
    default:         return theme.textDisabled;
  }
}

class _IconBtn extends StatelessWidget {
  const _IconBtn({required this.icon, required this.tooltip, required this.color, required this.onTap});
  final IconData icon;
  final String tooltip;
  final Color color;
  final VoidCallback onTap;
  @override Widget build(BuildContext context) => Tooltip(message: tooltip, child: InkWell(
    onTap: onTap, borderRadius: BorderRadius.circular(6),
    child: Container(
      width: 32, height: 32,
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.3))),
      child: Icon(icon, size: 16, color: color))));
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.value, required this.icon, required this.color, required this.theme});
  final String label, value;
  final IconData icon;
  final Color color;
  final AppTheme theme;
  @override Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
    decoration: BoxDecoration(color: theme.surface, borderRadius: BorderRadius.circular(10),
      border: Border.all(color: theme.border),
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)]),
    child: Row(children: [
      Container(width: 34, height: 34,
        decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
        child: Icon(icon, size: 17, color: color)),
      const SizedBox(width: 10),
      Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
        Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: color)),
        Text(label, style: TextStyle(fontSize: 10, color: theme.textSecondary)),
      ]),
    ]));
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.icon, required this.theme});
  final String label;
  final IconData icon;
  final AppTheme theme;
  @override Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(color: theme.background, borderRadius: BorderRadius.circular(20), border: Border.all(color: theme.border)),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 11, color: theme.textSecondary),
      const SizedBox(width: 3),
      Text(label, style: TextStyle(fontSize: 10, color: theme.textSecondary)),
    ]));
}

class _MetricaTile extends StatelessWidget {
  const _MetricaTile({required this.label, required this.value, required this.color, required this.theme});
  final String label, value;
  final Color color;
  final AppTheme theme;
  @override Widget build(BuildContext context) => Expanded(child: Container(
    padding: const EdgeInsets.symmetric(vertical: 8),
    decoration: BoxDecoration(color: color.withOpacity(0.08), borderRadius: BorderRadius.circular(8)),
    child: Column(children: [
      Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: color)),
      Text(label, style: TextStyle(fontSize: 9, color: theme.textSecondary)),
    ])));
}

class _InfoRow2 extends StatelessWidget {
  const _InfoRow2(this.label, this.value, this.theme);
  final String label, value;
  final AppTheme theme;
  @override Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SizedBox(width: 120, child: Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: theme.textSecondary))),
      Expanded(child: Text(value, style: TextStyle(fontSize: 13, color: theme.textPrimary))),
    ]));
}
""".strip(), encoding='utf-8')
print("✅ tecnicos_page.dart reescrito")

# ═══════════════════════════════════════════════════════════════════════════════
# 3. Plan_de_mejoras.md
# ═══════════════════════════════════════════════════════════════════════════════
(ROOT / ".github" / "Plan_de_mejoras.md").write_text("""# Plan de Mejoras — Terranex Smart City Operations

**Fecha:** Junio 2025 · **Versión:** 2.3 · **Plataforma:** Flutter Web

---

## Estado Actual (v2.2 — baseline)

| Módulo | Estado | Notas |
|--------|--------|-------|
| Dashboard Nacional | ✅ Completo | KPIs, mapa calor, alertas |
| Dashboard Estatal | ✅ Completo | BC Norte, municipios |
| Dashboard Municipal | ✅ Completo | Ensenada, gráficas fl_chart |
| Bandeja IA | ✅ Completo v2 | Modularizado en widgets/ |
| Órdenes / Incidencias | ✅ Completo | PlutoGrid + cards |
| Mapa Operativo | ✅ Completo | flutter_map, marcadores |
| Técnicos | ✅ Mejorado v2 | PlutoGrid + NuevoTécnico + avatar upload |
| Inventario | ✅ Completo | PlutoGrid + alertas stock |
| Aprobaciones | ✅ Completo | Flujo pendientes |
| SLA Monitor | ✅ Completo | Alertas por vencer |
| Reportes | ✅ Completo | fl_chart analítica |
| Configuración | ✅ Completo | Motor de priorización |
| Usuarios | ✅ Completo | PlutoGrid + NuevoUsuario |
| Auditoría | ✅ Completo | Log de eventos |
| Catálogos | ✅ Completo | Categorías, zonas |

---

## Mejoras Implementadas en v2.3

### BandejaIA (Modularización completa)
- **Widgets extraídos** a `lib/pages/bandeja_ia/widgets/`:
  - `helpers_bandeja.dart` — constantes `kCatIcons`, helpers `esRechazoIA`, `approxDireccion`
  - `filter_bar_bandeja.dart` — barra de filtros (search + dropdowns)
  - `imagen_viewer_dialog.dart` — visor pantalla completa
  - `mapa_ubicacion_dialog.dart` — mapa FlutterMap con icono de categoría en marcador
  - `confirmar_accion_dialog.dart` — confirmación con motivo obligatorio cuando IA aprueba pero operador rechaza
  - `detalle_caso_dialog.dart` — vista completa del caso (imagen grande, análisis IA, coordenadas, acciones)
  - `bandeja_card.dart` — tarjeta mobile mejorada
  - `pluto_bandeja_view.dart` — PlutoGrid desktop con columna de thumbnail y 4 acciones icono-solo
- **PlutoGrid mejorado**: columna de imagen (thumbnail 52×52), columna categoría con ícono, acciones compactas
- **Marcadores de mapa**: ícono específico por categoría (no genérico)
- `bandeja_ia_page.dart` reducido a ~120 líneas (orquestación pura)

### Técnicos (Reescritura v2)
- **PlutoGrid en desktop** (≥ 820px): columnas avatar, ID, nombre, rol, especialidad, estatus badge, activas, cerradas/mes, municipio, acciones
- **Cards mejoradas mobile**: avatar, badges de especialidad, métricas visuales, 2 botones de acción
- **"Nuevo Técnico"** dialog completo:
  - Upload de foto avatar desde dispositivo (dart:html FileReader → Uint8List)
  - Preview circular en tiempo real
  - Campos: nombre, rol, especialidad, estatus inicial
  - Genera ID auto (`TEC-014`, etc.)
- **Dialog "Ver detalle"**: avatar grande, todos los campos, estatus badge
- **Dialog "Cambiar estatus"**: RadioListTile con colores semánticos
- **TecnicoProvider**: `agregarTecnico()`, `setAvatarBytes()`, `getAvatarBytes()`, `setFiltroEstatus()`, `filtrados`
- **Filtros ChoiceChips**: todos, activos, en campo, descanso, inactivos

---

## Roadmap Próximas Mejoras

### Prioridad Alta

#### 1. Coherencia Mapa ↔ Órdenes
- [ ] Al hacer clic en marcador del mapa → abrir `DetalleCasoDialog` directamente
- [ ] Filtrar marcadores por categoría/prioridad desde el mapa
- [ ] Mostrar técnicos en campo como marcadores diferenciados (azul oscuro)
- [ ] Panel lateral derecho en el mapa con lista de incidencias visibles en pantalla

#### 2. Órdenes — columna Técnico asignado
- [ ] Agregar columna "Técnico" en PlutoGrid de órdenes (con avatar pequeño + nombre)
- [ ] Si no asignado: badge "Sin asignar" + botón de asignación rápida
- [ ] Dialog "Asignar técnico": dropdown con disponibles filtrados por especialidad
- [ ] Al asignar → cambiar estatus a `asignado` + incrementar `incidenciasActivas` del técnico
- [ ] Link "Ver técnico" → navegar a `/tecnicos` con técnico resaltado

#### 3. Bandeja IA — mejoras menores
- [ ] Contador de "recomienda aprobar" vs "recomienda rechazar" en header
- [ ] Acción "Aprobar todos los recomendados" (bulk action)
- [ ] Animación de salida cuando se aprueba/rechaza un ítem (AnimatedList)

### Prioridad Media

#### 4. Auditoría — Historial real de acciones
- [ ] Registrar en `AuditoriaProvider` cada acción: aprobaciones, rechazos, asignaciones
- [ ] PlutoGrid con filtro por módulo, fecha, usuario, nivel
- [ ] Export CSV (dart:html blob)
- [ ] Timeline view alternativa (VerticalTimeline)

#### 5. Reportes — Coherencia con datos reales
- [ ] Conectar gráficas de `ReporteProvider` con datos de `IncidenciaProvider`
- [ ] Gráfica de tendencia 30 días (simulated time series)
- [ ] Comparativa municipios (BarChart) usando datos de `KpiEstatal`
- [ ] Descargar reporte PDF simulado (mostrar dialog de "generando…" → snackbar éxito)

#### 6. Configuración — Descripción de reglas
- [ ] En cada `ReglaPriorizacion`, agregar descripción en lenguaje natural:
  - "Bacheo en zona industrial → Prioridad Alta → SLA 48 horas → Auto-aprobar: Sí"
- [ ] Vista expandida por regla con chips de parámetros visuales
- [ ] Simular activación/desactivación con toggle + snackbar
- [ ] Reordenar reglas por drag-and-drop (ReorderableListView)

### Prioridad Baja

#### 7. Modo Oscuro
- [ ] Toggle en topbar (switch Claro/Oscuro)
- [ ] `AppTheme` ya tiene constantes `*Dark` — implementar `ThemeMode` en `AppLevelProvider`
- [ ] Verificar contraste en sidebar, PlutoGrid, badges

#### 8. Responsivo Mobile
- [ ] Breakpoint `< 768px`: drawer en lugar de sidebar fijo
- [ ] Cards apiladas en todos los dashboards
- [ ] Topbar colapsable (solo logo + hamburger)

#### 9. Mapa — Enriquecimiento
- [ ] Polígonos de zonas/colonias (GeoJSON hardcodeado)
- [ ] Heatmap de densidad de incidencias (flutter_map plugin)
- [ ] Clustering de marcadores cuando zoom < 12

---

## Convenciones de Desarrollo

### Archivos
- `snake_case.dart` para archivos
- `PascalCase` para clases
- `_` prefijo para widgets privados dentro de la misma página
- Widgets reutilizables → `lib/widgets/shared/`

### PlutoGrid — Reglas de oro
1. **NUNCA** `PlutoLazyPagination` con datos hardcodeados
2. Siempre `setPageSize(N, notify: false)` en `onLoaded`
3. `rowHeight: 60-64` si hay imágenes o badges
4. `autoSizeMode: PlutoAutoSizeMode.none` con widths fijos
5. ID en celda oculta o usar `row.cells['id']?.value` para lookup

### State Management
- **Nunca mutar listas/objetos directamente** → `copyWith` + nueva lista + `notifyListeners()`
- Un provider por dominio, todos registrados en `main.dart` via `MultiProvider`
- Snackbar para cada acción operativa

### Colores semánticos
```
Crítico:  #B91C1C   (SLA vencido, prioridad crítica)
Alto:     #D97706   (por vencer, prioridad alta)
Medio:    #1D4ED8   (en proceso, prioridad media)
Bajo:     #2D7A4F   (resuelto, cumplido, activo)
Neutral:  #64748B   (inactivo, cancelado)
Primario: #7A1E3A   (vino — identidad, sidebar activo, CTAs)
```

---

## Checklist de Calidad antes de Demo

- [ ] `flutter build web --no-tree-shake-icons` sin errores
- [ ] Todas las rutas navegan sin error
- [ ] Sidebar adaptativo (nacional/estatal/municipal) funciona
- [ ] PlutoGrid paginado en: Órdenes, BandejaIA, Inventario, Usuarios, Técnicos
- [ ] Dialogs: NuevoTécnico, NuevoUsuario, NuevaRegla, Confirmar acción
- [ ] Mapa carga tiles OSM sin API key
- [ ] Botón "Salir de la Demo" → https://cbluna.com/ en misma ventana (`_self`)
- [ ] No hay strings en inglés expuestos al usuario
- [ ] Favicon cargado correctamente
""".strip(), encoding='utf-8')
print("✅ Plan_de_mejoras.md creado")

print("\n✅✅ TODOS LOS ARCHIVOS ESCRITOS — listo para build")
