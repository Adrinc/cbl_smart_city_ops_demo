// ignore_for_file: avoid_web_libraries_in_flutter
import 'dart:typed_data';
// ignore: deprecated_member_use_from_same_package
import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:nethive_neo/helpers/constants.dart';
import 'package:nethive_neo/helpers/formatters.dart';
import 'package:nethive_neo/models/models.dart';
import 'package:nethive_neo/pages/tecnicos/widgets/asignar_incidencia_dialog.dart';
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
    showDialog(
        context: ctx,
        builder: (_) => _CambiarEstatusDialog(tecnico: tec, theme: theme));
  }

  // ── Ver detalle ───────────────────────────────────────────────────────────
  void _verDetalle(BuildContext ctx, Tecnico tec) {
    final theme = AppTheme.of(ctx);
    final prov = ctx.read<TecnicoProvider>();
    showDialog(
        context: ctx,
        builder: (_) => _DetalleTecnicoDialog(
            tecnico: tec,
            theme: theme,
            avatarBytes: prov.getAvatarBytes(tec.id)));
  }

  // ── Nuevo técnico ─────────────────────────────────────────────────────────
  void _nuevoTecnico(BuildContext ctx) {
    final theme = AppTheme.of(ctx);
    showDialog(context: ctx, builder: (_) => _NuevoTecnicoDialog(theme: theme));
  }

  // ── Asignar incidencia a técnico ──────────────────────────────────────────
  void _asignarIncidencia(BuildContext ctx, Tecnico tec) {
    AsignarIncidenciaDialog.show(ctx, tec);
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final prov = context.watch<TecnicoProvider>();
    final cnts = prov.conteoEstatus;
    final items = prov.filtrados;
    final isMobile = MediaQuery.of(context).size.width < mobileSize;

    return Padding(
      padding: EdgeInsets.all(isMobile ? 16 : 24),
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
                  backgroundColor: theme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 10))),
        ),
        const SizedBox(height: 18),

        // ── KPI Cards ───────────────────────────────────────────────────────
        LayoutBuilder(builder: (_, box) {
          return GridView.count(
              crossAxisCount: box.maxWidth > 700 ? 4 : 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              // ratio más bajo en 2-col para evitar overflow texto+ícono
              childAspectRatio: box.maxWidth > 700 ? 3.2 : 2.4,
              children: [
                _StatCard(
                    label: 'Total',
                    value: '${prov.todos.length}',
                    icon: Icons.people_outline,
                    color: theme.primaryColor,
                    theme: theme),
                _StatCard(
                    label: 'Activos',
                    value: '${cnts["activo"] ?? 0}',
                    icon: Icons.check_circle_outline,
                    color: theme.low,
                    theme: theme),
                _StatCard(
                    label: 'En campo',
                    value: '${cnts["en_campo"] ?? 0}',
                    icon: Icons.directions_run,
                    color: theme.high,
                    theme: theme),
                _StatCard(
                    label: 'Descanso',
                    value: '${cnts["descanso"] ?? 0}',
                    icon: Icons.coffee_outlined,
                    color: theme.neutral,
                    theme: theme),
              ]);
        }),
        const SizedBox(height: 16),

        // ── Filtros ──────────────────────────────────────────────────────────
        LayoutBuilder(builder: (_, box) {
          final isMobileFilter = box.maxWidth < mobileSize;
          if (isMobileFilter) {
            return _FiltroTecnicosBtn(
              filtroActual: prov.filtroEstatus,
              theme: theme,
              onSelect: (opt) =>
                  context.read<TecnicoProvider>().setFiltroEstatus(opt),
              labelFiltro: _labelFiltro,
            );
          }
          return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(children: [
                for (final opt in [
                  'todos',
                  'activo',
                  'en_campo',
                  'descanso',
                  'inactivo'
                ])
                  Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                          label: Text(_labelFiltro(opt),
                              style: const TextStyle(fontSize: 12)),
                          selected: prov.filtroEstatus == opt,
                          selectedColor: theme.primaryColor.withOpacity(0.15),
                          onSelected: (_) => context
                              .read<TecnicoProvider>()
                              .setFiltroEstatus(opt))),
              ]));
        }),
        const SizedBox(height: 14),

        // ── Contenido principal ──────────────────────────────────────────────
        Expanded(child: LayoutBuilder(builder: (ctx, box) {
          if (box.maxWidth >= 820) {
            return _PlutoTecnicosView(
                items: items,
                theme: theme,
                onDetalle: (t) => _verDetalle(context, t),
                onCambiarEstatus: (t) => _cambiarEstatus(context, t),
                onAsignarIncidencia: (t) => _asignarIncidencia(context, t));
          }
          // Mobile: ListView sin altura fija → nunca overflow
          if (items.isEmpty) {
            return Center(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.engineering_outlined,
                    size: 48, color: theme.textDisabled),
                const SizedBox(height: 12),
                Text('Sin técnicos con este filtro',
                    style: TextStyle(fontSize: 14, color: theme.textSecondary)),
              ]),
            );
          }
          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (_, i) => _TecnicoListItem(
              tecnico: items[i],
              avatarBytes: prov.getAvatarBytes(items[i].id),
              theme: theme,
              onDetalle: () => _verDetalle(context, items[i]),
              onCambiarEstatus: () => _cambiarEstatus(context, items[i]),
              onAsignarIncidencia: () => _asignarIncidencia(context, items[i]),
            ),
          );
        })),
      ]),
    );
  }

  String _labelFiltro(String f) {
    const m = {
      'todos': 'Todos',
      'activo': 'Activos',
      'en_campo': 'En campo',
      'descanso': 'Descanso',
      'inactivo': 'Inactivos'
    };
    return m[f] ?? f;
  }
}

// ════════════════════════════════════════════════════════════════════════════════
// PLUTOGRID DESKTOP
// ════════════════════════════════════════════════════════════════════════════════
class _PlutoTecnicosView extends StatelessWidget {
  const _PlutoTecnicosView(
      {required this.items,
      required this.theme,
      required this.onDetalle,
      required this.onCambiarEstatus,
      required this.onAsignarIncidencia});
  final List<Tecnico> items;
  final AppTheme theme;
  final ValueChanged<Tecnico> onDetalle, onCambiarEstatus, onAsignarIncidencia;

  Tecnico? _tec(PlutoColumnRendererContext r) {
    final id = r.row.cells['id']?.value as String? ?? '';
    try {
      return items.firstWhere((t) => t.id == id);
    } catch (_) {
      return null;
    }
  }

  List<PlutoColumn> _cols(BuildContext context) => [
        PlutoColumn(
            title: '',
            field: 'avatar',
            type: PlutoColumnType.text(),
            width: 60,
            enableSorting: false,
            enableFilterMenuItem: false,
            renderer: (r) {
              final tec = _tec(r);
              final prov = context.read<TecnicoProvider>();
              final bytes = tec != null ? prov.getAvatarBytes(tec.id) : null;
              final color = _estatusColor(tec?.estatus ?? '', theme);
              if (bytes != null)
                return Center(
                    child: CircleAvatar(
                        radius: 22, backgroundImage: MemoryImage(bytes)));
              return Center(
                  child: CircleAvatar(
                      radius: 22,
                      backgroundColor: color.withOpacity(0.2),
                      child: Text(tec?.iniciales ?? '?',
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: color))));
            }),
        PlutoColumn(
            title: 'ID',
            field: 'id',
            type: PlutoColumnType.text(),
            width: 72,
            renderer: (r) => Text(r.cell.value,
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: theme.textSecondary))),
        PlutoColumn(
            title: 'Nombre',
            field: 'nombre',
            type: PlutoColumnType.text(),
            width: 170,
            renderer: (r) => Text(r.cell.value,
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: theme.textPrimary),
                overflow: TextOverflow.ellipsis)),
        PlutoColumn(
            title: 'Rol',
            field: 'rol',
            type: PlutoColumnType.text(),
            width: 130,
            renderer: (r) => Text(labelRolTecnico(r.cell.value),
                style: TextStyle(fontSize: 12, color: theme.textSecondary))),
        PlutoColumn(
            title: 'Especialidad',
            field: 'especialidad',
            type: PlutoColumnType.text(),
            width: 130,
            renderer: (r) => Text(labelCategoria(r.cell.value),
                style: TextStyle(fontSize: 12, color: theme.textPrimary))),
        PlutoColumn(
            title: 'Estatus',
            field: 'estatus',
            type: PlutoColumnType.text(),
            width: 118,
            renderer: (r) {
              final c = _estatusColor(r.cell.value, theme);
              return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                      color: c.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: c.withOpacity(0.3))),
                  child: Text(labelEstatusTecnico(r.cell.value),
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: c)));
            }),
        PlutoColumn(
            title: 'Activas',
            field: 'activas',
            type: PlutoColumnType.number(),
            width: 82,
            renderer: (r) {
              final v = r.cell.value as int;
              final c = v > 3
                  ? theme.critical
                  : v > 1
                      ? theme.high
                      : theme.low;
              return Center(
                  child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                          color: c.withOpacity(0.1), shape: BoxShape.circle),
                      child: Center(
                          child: Text('$v',
                              style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: c)))));
            }),
        PlutoColumn(
            title: 'Cerradas/mes',
            field: 'cerradas',
            type: PlutoColumnType.number(),
            width: 110,
            renderer: (r) => Center(
                child: Text('${r.cell.value}',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: theme.low)))),
        PlutoColumn(
            title: 'Municipio',
            field: 'municipio',
            type: PlutoColumnType.text(),
            width: 110,
            renderer: (r) => Text(r.cell.value,
                style: TextStyle(fontSize: 11, color: theme.textSecondary),
                overflow: TextOverflow.ellipsis)),
        PlutoColumn(
            title: 'Acciones',
            field: 'acc',
            type: PlutoColumnType.text(),
            width: 180,
            enableSorting: false,
            enableFilterMenuItem: false,
            renderer: (r) {
              final tec = _tec(r);
              if (tec == null) return const SizedBox.shrink();
              return Row(mainAxisSize: MainAxisSize.min, children: [
                _IconBtn(
                    icon: Icons.person_outline,
                    tooltip: 'Ver detalle',
                    color: theme.primaryColor,
                    onTap: () => onDetalle(tec)),
                const SizedBox(width: 6),
                _IconBtn(
                    icon: Icons.swap_horiz,
                    tooltip: 'Cambiar estatus',
                    color: theme.medium,
                    onTap: () => onCambiarEstatus(tec)),
                const SizedBox(width: 6),
                Tooltip(
                  message: 'Asignar caso a este técnico',
                  child: InkWell(
                    onTap: () => onAsignarIncidencia(tec),
                    borderRadius: BorderRadius.circular(6),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 4),
                      decoration: BoxDecoration(
                          color: theme.low.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                          border:
                              Border.all(color: theme.low.withOpacity(0.3))),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        Icon(Icons.assignment_ind_outlined,
                            size: 13, color: theme.low),
                        const SizedBox(width: 4),
                        Text('Asignar',
                            style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: theme.low)),
                      ]),
                    ),
                  ),
                ),
              ]);
            }),
      ];

  List<PlutoRow> _rows() => items
      .map((t) => PlutoRow(cells: {
            'avatar': PlutoCell(value: ''),
            'id': PlutoCell(value: t.id),
            'nombre': PlutoCell(value: t.nombre),
            'rol': PlutoCell(value: t.rol),
            'especialidad': PlutoCell(value: t.especialidad),
            'estatus': PlutoCell(value: t.estatus),
            'activas': PlutoCell(value: t.incidenciasActivas),
            'cerradas': PlutoCell(value: t.incidenciasCerradasMes),
            'municipio': PlutoCell(value: t.municipioAsignado ?? 'Ensenada'),
            'acc': PlutoCell(value: ''),
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
              onLoaded: (e) => e.stateManager.setPageSize(15, notify: false),
              createFooter: (s) => PlutoPagination(s),
              configuration: PlutoGridConfiguration(
                  style: PlutoGridStyleConfig(
                      gridBorderColor: theme.border,
                      gridBackgroundColor: theme.surface,
                      rowColor: theme.surface,
                      activatedColor: theme.primaryColor.withOpacity(0.07),
                      activatedBorderColor: theme.primaryColor,
                      columnHeight: 44,
                      rowHeight: 60,
                      columnTextStyle: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: theme.textSecondary)),
                  columnSize: const PlutoGridColumnSizeConfig(
                      autoSizeMode: PlutoAutoSizeMode.scale)))),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════════
// TECNICO LIST ITEM (mobile — sin altura fija, estilo Usuarios)
// ════════════════════════════════════════════════════════════════════════════════
class _TecnicoListItem extends StatelessWidget {
  const _TecnicoListItem({
    required this.tecnico,
    required this.avatarBytes,
    required this.theme,
    required this.onDetalle,
    required this.onCambiarEstatus,
    required this.onAsignarIncidencia,
  });
  final Tecnico tecnico;
  final Uint8List? avatarBytes;
  final AppTheme theme;
  final VoidCallback onDetalle, onCambiarEstatus, onAsignarIncidencia;

  @override
  Widget build(BuildContext context) {
    final color = _estatusColor(tecnico.estatus, theme);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
          color: theme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.border),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 6,
                offset: const Offset(0, 2))
          ]),
      child: InkWell(
        onTap: onDetalle,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // ─ Fila principal ───────────────────────────────────
            Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
              Stack(children: [
                CircleAvatar(
                    radius: 24,
                    backgroundImage:
                        avatarBytes != null ? MemoryImage(avatarBytes!) : null,
                    backgroundColor: color.withOpacity(0.18),
                    child: avatarBytes == null
                        ? Text(tecnico.iniciales,
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: color))
                        : null),
                Positioned(
                    bottom: 1,
                    right: 1,
                    child: Container(
                        width: 11,
                        height: 11,
                        decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border:
                                Border.all(color: theme.surface, width: 2)))),
              ]),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(tecnico.nombre,
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: theme.textPrimary),
                          overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 2),
                      Text(labelRolTecnico(tecnico.rol),
                          style: TextStyle(
                              fontSize: 12, color: theme.textSecondary)),
                    ]),
              ),
              const SizedBox(width: 8),
              // Status badge
              Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                      color: color.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: color.withOpacity(0.3))),
                  child: Text(labelEstatusTecnico(tecnico.estatus),
                      style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: color))),
              const SizedBox(width: 4),
              // Menú de acciones
              PopupMenuButton<String>(
                icon:
                    Icon(Icons.more_vert, size: 18, color: theme.textSecondary),
                padding: EdgeInsets.zero,
                onSelected: (v) {
                  if (v == 'estatus') onCambiarEstatus();
                  if (v == 'asignar') onAsignarIncidencia();
                },
                itemBuilder: (_) => [
                  PopupMenuItem(
                      value: 'estatus',
                      child: Row(children: [
                        Icon(Icons.swap_horiz, size: 16, color: theme.medium),
                        const SizedBox(width: 8),
                        const Text('Cambiar estatus'),
                      ])),
                  PopupMenuItem(
                      value: 'asignar',
                      child: Row(children: [
                        Icon(Icons.assignment_ind_outlined,
                            size: 16, color: theme.low),
                        const SizedBox(width: 8),
                        const Text('Asignar caso'),
                      ])),
                ],
              ),
            ]),
            const SizedBox(height: 8),
            // ─ Chips especialidad + municipio ──────────────────
            Wrap(spacing: 6, runSpacing: 4, children: [
              _Chip(
                  label: labelCategoria(tecnico.especialidad),
                  icon: Icons.build_outlined,
                  theme: theme),
              if (tecnico.municipioAsignado != null)
                _Chip(
                    label: tecnico.municipioAsignado!,
                    icon: Icons.location_city_outlined,
                    theme: theme),
            ]),
            const SizedBox(height: 8),
            // ─ Métricas ───────────────────────────────────
            Row(children: [
              _MetricaTile(
                  label: 'Activas',
                  value: '${tecnico.incidenciasActivas}',
                  color: tecnico.incidenciasActivas > 3
                      ? theme.critical
                      : theme.high,
                  theme: theme),
              const SizedBox(width: 16),
              _MetricaTile(
                  label: 'Cerradas/mes',
                  value: '${tecnico.incidenciasCerradasMes}',
                  color: theme.low,
                  theme: theme),
            ]),
          ]),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════════
// TECNICO CARD (conservado para referencia — ya no se usa en mobile)
// ════════════════════════════════════════════════════════════════════════════════
class _TecnicoCard extends StatelessWidget {
  const _TecnicoCard(
      {required this.tecnico,
      required this.avatarBytes,
      required this.theme,
      required this.onDetalle,
      required this.onCambiarEstatus,
      required this.onAsignarIncidencia});
  final Tecnico tecnico;
  final Uint8List? avatarBytes;
  final AppTheme theme;
  final VoidCallback onDetalle, onCambiarEstatus, onAsignarIncidencia;

  @override
  Widget build(BuildContext context) {
    final color = _estatusColor(tecnico.estatus, theme);
    return Container(
      decoration: BoxDecoration(
          color: theme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: theme.border),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 3))
          ]),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            CircleAvatar(
                radius: 26,
                backgroundImage:
                    avatarBytes != null ? MemoryImage(avatarBytes!) : null,
                backgroundColor: color.withOpacity(0.18),
                child: avatarBytes == null
                    ? Text(tecnico.iniciales,
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: color))
                    : null),
            const SizedBox(width: 12),
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text(tecnico.nombre,
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: theme.textPrimary),
                      overflow: TextOverflow.ellipsis),
                  Text(labelRolTecnico(tecnico.rol),
                      style:
                          TextStyle(fontSize: 11, color: theme.textSecondary)),
                ])),
            Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: color.withOpacity(0.3))),
                child: Text(labelEstatusTecnico(tecnico.estatus),
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: color))),
          ]),
          const SizedBox(height: 12),

          // Especialidad + municipio
          Wrap(spacing: 6, runSpacing: 4, children: [
            _Chip(
                label: labelCategoria(tecnico.especialidad),
                icon: Icons.build_outlined,
                theme: theme),
            if (tecnico.municipioAsignado != null)
              _Chip(
                  label: tecnico.municipioAsignado!,
                  icon: Icons.location_city_outlined,
                  theme: theme),
          ]),
          const SizedBox(height: 10),

          // Métricas
          Row(children: [
            _MetricaTile(
                label: 'Activas',
                value: '${tecnico.incidenciasActivas}',
                color: tecnico.incidenciasActivas > 3
                    ? theme.critical
                    : theme.high,
                theme: theme),
            const SizedBox(width: 8),
            _MetricaTile(
                label: 'Cerradas/mes',
                value: '${tecnico.incidenciasCerradasMes}',
                color: theme.low,
                theme: theme),
          ]),
          const Spacer(),

          // Acciones
          Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Row(children: [
              Expanded(
                  child: OutlinedButton.icon(
                      onPressed: onDetalle,
                      icon: Icon(Icons.person_outline,
                          size: 13, color: theme.primaryColor),
                      label: Text('Detalle',
                          style: TextStyle(
                              fontSize: 12, color: theme.primaryColor)),
                      style: OutlinedButton.styleFrom(
                          side: BorderSide(
                              color: theme.primaryColor.withOpacity(0.4)),
                          padding: const EdgeInsets.symmetric(vertical: 8)))),
              const SizedBox(width: 8),
              Expanded(
                  child: OutlinedButton.icon(
                      onPressed: onCambiarEstatus,
                      icon:
                          Icon(Icons.swap_horiz, size: 13, color: theme.medium),
                      label: Text('Estatus',
                          style: TextStyle(fontSize: 12, color: theme.medium)),
                      style: OutlinedButton.styleFrom(
                          side:
                              BorderSide(color: theme.medium.withOpacity(0.4)),
                          padding: const EdgeInsets.symmetric(vertical: 8)))),
            ]),
            const SizedBox(height: 6),
            OutlinedButton.icon(
                onPressed: onAsignarIncidencia,
                icon: Icon(Icons.assignment_ind_outlined,
                    size: 13, color: theme.low),
                label: Text('Asignar caso',
                    style: TextStyle(fontSize: 12, color: theme.low)),
                style: OutlinedButton.styleFrom(
                    side: BorderSide(color: theme.low.withOpacity(0.4)),
                    padding: const EdgeInsets.symmetric(vertical: 8))),
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
  const _DetalleTecnicoDialog(
      {required this.tecnico, required this.theme, this.avatarBytes});
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
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 24, 16, 20),
              decoration: BoxDecoration(
                  color: theme.primaryColor.withOpacity(0.08),
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(18))),
              child: Row(children: [
                CircleAvatar(
                    radius: 30,
                    backgroundImage:
                        avatarBytes != null ? MemoryImage(avatarBytes!) : null,
                    backgroundColor: color.withOpacity(0.2),
                    child: avatarBytes == null
                        ? Text(tecnico.iniciales,
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                                color: color))
                        : null),
                const SizedBox(width: 16),
                Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      Text(tecnico.nombre,
                          style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              color: theme.textPrimary)),
                      Text(labelRolTecnico(tecnico.rol),
                          style: TextStyle(
                              fontSize: 12, color: theme.textSecondary)),
                      const SizedBox(height: 4),
                      Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                              color: color.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(20)),
                          child: Text(labelEstatusTecnico(tecnico.estatus),
                              style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: color))),
                    ])),
                IconButton(
                    icon: Icon(Icons.close, color: theme.textSecondary),
                    onPressed: () => Navigator.pop(context)),
              ])),
          // Info
          Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _InfoRow2('Especialidad',
                        labelCategoria(tecnico.especialidad), theme),
                    _InfoRow2('Municipio',
                        tecnico.municipioAsignado ?? 'Ensenada', theme),
                    _InfoRow2('ID', tecnico.id, theme),
                    _InfoRow2('Incidencias activas',
                        '${tecnico.incidenciasActivas}', theme),
                    _InfoRow2('Cerradas este mes',
                        '${tecnico.incidenciasCerradasMes}', theme),
                    _InfoRow2(
                        'Ubicación',
                        '${tecnico.latitud.toStringAsFixed(4)}, ${tecnico.longitud.toStringAsFixed(4)}',
                        theme),
                  ])),
          Padding(
              padding: const EdgeInsets.fromLTRB(22, 0, 22, 18),
              child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: theme.primaryColor,
                        foregroundColor: Colors.white),
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
  @override
  void initState() {
    super.initState();
    _estatus = widget.tecnico.estatus;
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme;
    return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 380),
            child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Row(children: [
                    Icon(Icons.swap_horiz, color: theme.medium),
                    const SizedBox(width: 10),
                    Expanded(
                        child: Text(
                            'Cambiar estatus — ${widget.tecnico.nombre}',
                            style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: theme.textPrimary))),
                    IconButton(
                        icon: Icon(Icons.close,
                            color: theme.textSecondary, size: 18),
                        onPressed: () => Navigator.pop(context)),
                  ]),
                  const SizedBox(height: 18),
                  for (final op in [
                    'activo',
                    'en_campo',
                    'descanso',
                    'inactivo'
                  ])
                    RadioListTile<String>(
                        value: op,
                        groupValue: _estatus,
                        title: Text(labelEstatusTecnico(op),
                            style: const TextStyle(fontSize: 13)),
                        activeColor: _estatusColor(op, theme),
                        onChanged: (v) => setState(() => _estatus = v!),
                        dense: true,
                        contentPadding: EdgeInsets.zero),
                  const SizedBox(height: 14),
                  Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                    TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancelar')),
                    const SizedBox(width: 8),
                    ElevatedButton(
                        onPressed: () {
                          context
                              .read<TecnicoProvider>()
                              .actualizarEstatus(widget.tecnico.id, _estatus);
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text(
                                  '${widget.tecnico.nombre}: estatus actualizado a ${labelEstatusTecnico(_estatus)}'),
                              backgroundColor: theme.low));
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: theme.primaryColor,
                            foregroundColor: Colors.white),
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
  @override
  State<_NuevoTecnicoDialog> createState() => _NuevoTecnicoDialogState();
}

class _NuevoTecnicoDialogState extends State<_NuevoTecnicoDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nombreCtrl = TextEditingController();
  String _rol = 'tecnico_campo';
  String _especialidad = 'general';
  String _estatus = 'activo';
  Uint8List? _avatarBytes;
  bool _loadingImg = false;

  @override
  void dispose() {
    _nombreCtrl.dispose();
    super.dispose();
  }

  // Abrir file picker web
  Future<void> _pickImage() async {
    setState(() => _loadingImg = true);
    final input = html.FileUploadInputElement()..accept = 'image/*';
    input.click();
    await input.onChange.first;
    final file = input.files?.first;
    if (file == null) {
      setState(() => _loadingImg = false);
      return;
    }
    final reader = html.FileReader();
    reader.readAsArrayBuffer(file);
    await reader.onLoad.first;
    final result = reader.result;
    if (result is List<int>) {
      setState(() {
        _avatarBytes = Uint8List.fromList(result);
        _loadingImg = false;
      });
    } else {
      setState(() => _loadingImg = false);
    }
  }

  void _guardar() {
    if (!_formKey.currentState!.validate()) return;
    final prov = context.read<TecnicoProvider>();
    final id = 'TEC-${(prov.todos.length + 1).toString().padLeft(3, "0")}';
    final tec = Tecnico(
        id: id,
        nombre: _nombreCtrl.text.trim(),
        rol: _rol,
        especialidad: _especialidad,
        estatus: _estatus,
        incidenciasActivas: 0,
        incidenciasCerradasMes: 0,
        latitud: 31.8667,
        longitud: -116.5963,
        municipioAsignado: 'Ensenada');
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
        child: Form(
            key: _formKey,
            child: Column(children: [
              // Header
              Container(
                  padding: const EdgeInsets.fromLTRB(24, 22, 16, 18),
                  decoration: BoxDecoration(
                      color: theme.primaryColor.withOpacity(0.08),
                      borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(18))),
                  child: Row(children: [
                    Icon(Icons.person_add_outlined,
                        color: theme.primaryColor, size: 22),
                    const SizedBox(width: 12),
                    Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                          Text('Nuevo Técnico',
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: theme.textPrimary)),
                          Text('Registrar nuevo miembro de cuadrilla',
                              style: TextStyle(
                                  fontSize: 12, color: theme.textSecondary)),
                        ])),
                    IconButton(
                        icon: Icon(Icons.close, color: theme.textSecondary),
                        onPressed: () => Navigator.pop(context)),
                  ])),

              // Body
              Expanded(
                  child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Avatar upload
                            Center(
                                child: Column(children: [
                              GestureDetector(
                                  onTap: _pickImage,
                                  child: Stack(
                                      alignment: Alignment.bottomRight,
                                      children: [
                                        CircleAvatar(
                                            radius: 46,
                                            backgroundImage: _avatarBytes !=
                                                    null
                                                ? MemoryImage(_avatarBytes!)
                                                : null,
                                            backgroundColor: theme
                                                .primaryColor
                                                .withOpacity(0.12),
                                            child: _loadingImg
                                                ? SizedBox(
                                                    width: 22,
                                                    height: 22,
                                                    child:
                                                        CircularProgressIndicator(
                                                            color: theme
                                                                .primaryColor,
                                                            strokeWidth: 2))
                                                : _avatarBytes == null
                                                    ? Icon(Icons.person_outline,
                                                        size: 36,
                                                        color:
                                                            theme.primaryColor)
                                                    : null),
                                        Container(
                                            width: 28,
                                            height: 28,
                                            decoration: BoxDecoration(
                                                color: theme.primaryColor,
                                                shape: BoxShape.circle,
                                                border: Border.all(
                                                    color: Colors.white,
                                                    width: 2)),
                                            child: const Icon(Icons.camera_alt,
                                                size: 14, color: Colors.white)),
                                      ])),
                              const SizedBox(height: 8),
                              TextButton.icon(
                                  onPressed: _pickImage,
                                  icon: const Icon(Icons.upload_file, size: 14),
                                  label: Text(
                                      _avatarBytes != null
                                          ? 'Cambiar foto'
                                          : 'Subir foto (opcional)',
                                      style: const TextStyle(fontSize: 12))),
                            ])),
                            const SizedBox(height: 20),

                            // Nombre
                            Text('Nombre completo *',
                                style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: theme.textSecondary)),
                            const SizedBox(height: 6),
                            TextFormField(
                                controller: _nombreCtrl,
                                decoration: InputDecoration(
                                    hintText: 'Ej. Carlos Mendoza López',
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8)),
                                    contentPadding: const EdgeInsets.all(12)),
                                validator: (v) => v == null || v.trim().isEmpty
                                    ? 'El nombre es requerido'
                                    : null),
                            const SizedBox(height: 14),

                            // Rol
                            Text('Rol *',
                                style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: theme.textSecondary)),
                            const SizedBox(height: 6),
                            DropdownButtonFormField<String>(
                                value: _rol,
                                decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8)),
                                    contentPadding: const EdgeInsets.all(12)),
                                items: const [
                                  DropdownMenuItem(
                                      value: 'tecnico_campo',
                                      child: Text('Técnico de campo')),
                                  DropdownMenuItem(
                                      value: 'jefe_cuadrilla',
                                      child: Text('Jefe de cuadrilla')),
                                  DropdownMenuItem(
                                      value: 'supervisor',
                                      child: Text('Supervisor')),
                                ],
                                onChanged: (v) => setState(() => _rol = v!)),
                            const SizedBox(height: 14),

                            // Especialidad
                            Text('Especialidad *',
                                style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: theme.textSecondary)),
                            const SizedBox(height: 6),
                            DropdownButtonFormField<String>(
                                value: _especialidad,
                                decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8)),
                                    contentPadding: const EdgeInsets.all(12)),
                                items: const [
                                  DropdownMenuItem(
                                      value: 'alumbrado',
                                      child: Text('Alumbrado público')),
                                  DropdownMenuItem(
                                      value: 'bacheo',
                                      child: Text('Bacheo y pavimentación')),
                                  DropdownMenuItem(
                                      value: 'basura',
                                      child: Text('Recolección de basura')),
                                  DropdownMenuItem(
                                      value: 'agua_drenaje',
                                      child: Text('Agua y drenaje')),
                                  DropdownMenuItem(
                                      value: 'señalizacion',
                                      child: Text('Señalización vial')),
                                  DropdownMenuItem(
                                      value: 'general', child: Text('General')),
                                ],
                                onChanged: (v) =>
                                    setState(() => _especialidad = v!)),
                            const SizedBox(height: 14),

                            // Estatus inicial
                            Text('Estatus inicial',
                                style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: theme.textSecondary)),
                            const SizedBox(height: 6),
                            DropdownButtonFormField<String>(
                                value: _estatus,
                                decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8)),
                                    contentPadding: const EdgeInsets.all(12)),
                                items: const [
                                  DropdownMenuItem(
                                      value: 'activo', child: Text('Activo')),
                                  DropdownMenuItem(
                                      value: 'descanso',
                                      child: Text('Descanso')),
                                  DropdownMenuItem(
                                      value: 'inactivo',
                                      child: Text('Inactivo')),
                                ],
                                onChanged: (v) =>
                                    setState(() => _estatus = v!)),
                          ]))),

              // Footer
              Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
                  child:
                      Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                    OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancelar'),
                        style: OutlinedButton.styleFrom(
                            foregroundColor: theme.textSecondary,
                            side: BorderSide(color: theme.border))),
                    const SizedBox(width: 12),
                    FilledButton.icon(
                        onPressed: _guardar,
                        icon: const Icon(Icons.check, size: 16),
                        label: const Text('Registrar técnico'),
                        style: FilledButton.styleFrom(
                            backgroundColor: theme.primaryColor,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 12))),
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
    case 'activo':
      return theme.low;
    case 'en_campo':
      return theme.high;
    case 'descanso':
      return theme.neutral;
    default:
      return theme.textDisabled;
  }
}

class _IconBtn extends StatelessWidget {
  const _IconBtn(
      {required this.icon,
      required this.tooltip,
      required this.color,
      required this.onTap});
  final IconData icon;
  final String tooltip;
  final Color color;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Tooltip(
      message: tooltip,
      child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(6),
          child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: color.withOpacity(0.3))),
              child: Icon(icon, size: 16, color: color))));
}

class _StatCard extends StatelessWidget {
  const _StatCard(
      {required this.label,
      required this.value,
      required this.icon,
      required this.color,
      required this.theme});
  final String label, value;
  final IconData icon;
  final Color color;
  final AppTheme theme;
  @override
  Widget build(BuildContext context) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
          color: theme.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: theme.border),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)
          ]),
      child: Row(children: [
        Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
                color: color.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(icon, size: 17, color: color)),
        const SizedBox(width: 10),
        Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(value,
                  style: TextStyle(
                      fontSize: 20, fontWeight: FontWeight.w900, color: color)),
              Text(label,
                  style: TextStyle(fontSize: 10, color: theme.textSecondary)),
            ]),
      ]));
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.icon, required this.theme});
  final String label;
  final IconData icon;
  final AppTheme theme;
  @override
  Widget build(BuildContext context) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
          color: theme.background,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: theme.border)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 11, color: theme.textSecondary),
        const SizedBox(width: 3),
        Text(label, style: TextStyle(fontSize: 10, color: theme.textSecondary)),
      ]));
}

class _MetricaTile extends StatelessWidget {
  const _MetricaTile(
      {required this.label,
      required this.value,
      required this.color,
      required this.theme});
  final String label, value;
  final Color color;
  final AppTheme theme;
  @override
  Widget build(BuildContext context) => Expanded(
      child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
              color: color.withOpacity(0.08),
              borderRadius: BorderRadius.circular(8)),
          child: Column(children: [
            Text(value,
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.w900, color: color)),
            Text(label,
                style: TextStyle(fontSize: 9, color: theme.textSecondary)),
          ])));
}

class _InfoRow2 extends StatelessWidget {
  const _InfoRow2(this.label, this.value, this.theme);
  final String label, value;
  final AppTheme theme;
  @override
  Widget build(BuildContext context) => Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(
            width: 120,
            child: Text(label,
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: theme.textSecondary))),
        Expanded(
            child: Text(value,
                style: TextStyle(fontSize: 13, color: theme.textPrimary))),
      ]));
}

// ── Botón de filtros mobile para Técnicos ─────────────────────────────────────
class _FiltroTecnicosBtn extends StatelessWidget {
  const _FiltroTecnicosBtn({
    required this.filtroActual,
    required this.theme,
    required this.onSelect,
    required this.labelFiltro,
  });
  final String filtroActual;
  final AppTheme theme;
  final ValueChanged<String> onSelect;
  final String Function(String) labelFiltro;

  bool get _hayFiltro => filtroActual != 'todos';

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _mostrarDialog(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color:
              _hayFiltro ? theme.primaryColor.withOpacity(0.12) : theme.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
              color: _hayFiltro
                  ? theme.primaryColor.withOpacity(0.5)
                  : theme.border),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.tune,
              size: 16,
              color: _hayFiltro ? theme.primaryColor : theme.textSecondary),
          const SizedBox(width: 6),
          Text(
            'Filtrar: ${labelFiltro(filtroActual)}',
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: _hayFiltro ? theme.primaryColor : theme.textSecondary),
          ),
          const SizedBox(width: 4),
          Icon(Icons.keyboard_arrow_down,
              size: 14,
              color: _hayFiltro ? theme.primaryColor : theme.textSecondary),
        ]),
      ),
    );
  }

  void _mostrarDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Filtrar Técnicos'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final opt in [
              'todos',
              'activo',
              'en_campo',
              'descanso',
              'inactivo'
            ])
              RadioListTile<String>(
                value: opt,
                groupValue: filtroActual,
                title: Text(labelFiltro(opt),
                    style: const TextStyle(fontSize: 13)),
                activeColor: theme.primaryColor,
                onChanged: (v) {
                  if (v != null) onSelect(v);
                  Navigator.pop(context);
                },
                dense: true,
                contentPadding: EdgeInsets.zero,
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
        ],
      ),
    );
  }
}
