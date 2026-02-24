import 'package:flutter/material.dart';
import 'package:nethive_neo/helpers/constants.dart';
import 'package:nethive_neo/helpers/formatters.dart';
import 'package:nethive_neo/models/models.dart';
import 'package:nethive_neo/pages/ordenes/widgets/asignar_tecnico_dialog.dart';
import 'package:nethive_neo/pages/ordenes/widgets/tecnico_chip_detalle.dart';
import 'package:nethive_neo/providers/providers.dart';
import 'package:nethive_neo/theme/theme.dart';
import 'package:nethive_neo/widgets/shared/estatus_badge.dart';
import 'package:nethive_neo/widgets/shared/priority_badge.dart';
import 'package:nethive_neo/widgets/shared/section_header.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:provider/provider.dart';

class OrdenesPage extends StatefulWidget {
  const OrdenesPage({super.key});
  @override
  State<OrdenesPage> createState() => _OrdenesPageState();
}

class _OrdenesPageState extends State<OrdenesPage> {
  PlutoGridStateManager? _stateManager;
  String? _filterPrioridad;
  String? _filterEstatus;
  String? _filterCategoria;

  static const _prioridades = ['critico', 'alto', 'medio', 'bajo'];
  static const _estatuses = [
    'recibido',
    'en_revision',
    'aprobado',
    'asignado',
    'en_proceso',
    'resuelto',
    'cerrado',
    'rechazado'
  ];
  static const _categorias = [
    'alumbrado',
    'bacheo',
    'basura',
    'agua_drenaje',
    'senalizacion',
    'seguridad'
  ];

  static const _catIcons = <String, IconData>{
    'alumbrado': Icons.lightbulb_outline,
    'bacheo': Icons.construction,
    'basura': Icons.delete_outline,
    'seguridad': Icons.security,
    'agua_drenaje': Icons.water_drop_outlined,
    'señalizacion': Icons.signpost_outlined,
    'senalizacion': Icons.signpost_outlined,
  };

  static IconData _catIcon(String cat) =>
      _catIcons[cat] ?? Icons.report_outlined;

  List<Incidencia> _applyFilters(List<Incidencia> source) {
    return source.where((i) {
      if (_filterPrioridad != null && i.prioridad != _filterPrioridad)
        return false;
      if (_filterEstatus != null && i.estatus != _filterEstatus) return false;
      if (_filterCategoria != null && i.categoria != _filterCategoria)
        return false;
      return true;
    }).toList();
  }

  List<PlutoColumn> _buildColumns(AppTheme theme) => [
        PlutoColumn(
            title: 'ID',
            field: 'id',
            width: 80,
            type: PlutoColumnType.text(),
            renderer: (r) => Text(r.cell.value,
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: theme.primaryColor))),
        PlutoColumn(
            title: 'Categoría',
            field: 'categoria',
            width: 130,
            type: PlutoColumnType.text(),
            renderer: (r) {
              final cat = r.cell.value as String;
              return Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(_catIcon(cat), size: 14, color: theme.primaryColor),
                const SizedBox(width: 5),
                Flexible(
                    child: Text(labelCategoria(cat),
                        style:
                            TextStyle(fontSize: 12, color: theme.textPrimary),
                        overflow: TextOverflow.ellipsis)),
              ]);
            }),
        PlutoColumn(
            title: 'Descripción',
            field: 'descripcion',
            width: 260,
            type: PlutoColumnType.text(),
            renderer: (r) => Text(r.cell.value,
                style: TextStyle(fontSize: 12, color: theme.textPrimary),
                maxLines: 1,
                overflow: TextOverflow.ellipsis)),
        PlutoColumn(
            title: 'Prioridad',
            field: 'prioridad',
            width: 90,
            type: PlutoColumnType.text(),
            renderer: (r) => PriorityBadge(prioridad: r.cell.value)),
        PlutoColumn(
            title: 'Estatus',
            field: 'estatus',
            width: 110,
            type: PlutoColumnType.text(),
            renderer: (r) => EstatusBadge(estatus: r.cell.value)),
        PlutoColumn(
            title: 'SLA',
            field: 'sla',
            width: 100,
            type: PlutoColumnType.text(),
            renderer: (r) {
              final vencido = r.cell.value.toString().startsWith('Vencido');
              return Text(r.cell.value,
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: vencido ? theme.critical : theme.textPrimary));
            }),
        PlutoColumn(
            title: 'Técnico',
            field: 'tecnico',
            width: 160,
            type: PlutoColumnType.text(),
            renderer: (r) {
              final incId = r.row.cells['_obj']?.value as String? ?? '';
              return TecnicoChipDetalle(incId: incId, theme: theme);
            }),
        PlutoColumn(
            title: 'Reportado',
            field: 'fecha',
            width: 100,
            type: PlutoColumnType.text(),
            renderer: (r) => Text(r.cell.value,
                style: TextStyle(fontSize: 11, color: theme.textSecondary))),
      ];

  List<PlutoRow> _buildRows(
      List<Incidencia> incs, IncidenciaProvider prov, TecnicoProvider tecProv) {
    return incs.map((i) {
      final tecNombre = i.tecnicoId != null
          ? (tecProv.byId(i.tecnicoId!)?.nombre ?? i.tecnicoId!)
          : '';
      return PlutoRow(cells: {
        'id': PlutoCell(value: formatIdIncidencia(i.id)),
        'categoria': PlutoCell(value: i.categoria),
        'descripcion': PlutoCell(value: i.descripcion),
        'prioridad': PlutoCell(value: i.prioridad),
        'estatus': PlutoCell(value: i.estatus),
        'sla': PlutoCell(value: formatSla(i.fechaLimite)),
        'tecnico': PlutoCell(value: tecNombre),
        'fecha': PlutoCell(value: formatFechaCorta(i.fechaReporte)),
        '_obj': PlutoCell(value: i.id),
      });
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final prov = context.watch<IncidenciaProvider>();
    final tecProv = context.watch<TecnicoProvider>();
    final source = _applyFilters(prov.todas);
    final isMobile = MediaQuery.of(context).size.width < mobileSize;

    return Padding(
      padding: EdgeInsets.all(isMobile ? 16 : 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            title: 'Órdenes / Incidencias',
            subtitle:
                '${source.length} registros · ${prov.criticas.length} críticas · ${prov.vencidas.length} vencidas',
            trailing: Text('Ensenada',
                style: TextStyle(fontSize: 12, color: theme.textSecondary)),
          ),
          const SizedBox(height: 12),

          // Filter bar
          _FilterBar(
            filterPrioridad: _filterPrioridad,
            filterEstatus: _filterEstatus,
            filterCategoria: _filterCategoria,
            prioridades: _prioridades,
            estatuses: _estatuses,
            categorias: _categorias,
            theme: theme,
            onPrioridad: (v) {
              setState(() {
                _filterPrioridad = v;
              });
            },
            onEstatus: (v) {
              setState(() {
                _filterEstatus = v;
              });
            },
            onCategoria: (v) {
              setState(() {
                _filterCategoria = v;
              });
            },
            onClear: () {
              setState(() {
                _filterPrioridad = null;
                _filterEstatus = null;
                _filterCategoria = null;
              });
            },
          ),
          const SizedBox(height: 12),

          // Grid desktop / Cards mobile
          Expanded(
            child: source.isEmpty
                ? Center(
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.inbox_outlined,
                        size: 48, color: theme.textSecondary),
                    const SizedBox(height: 12),
                    Text('Sin resultados para el filtro aplicado',
                        style: TextStyle(
                            color: theme.textSecondary, fontSize: 14)),
                  ]))
                : isMobile
                    ? ListView.builder(
                        padding: const EdgeInsets.only(top: 4, bottom: 16),
                        itemCount: source.length,
                        itemBuilder: (_, i) => _IncidenciaCard(
                          inc: source[i],
                          theme: theme,
                          onTap: () =>
                              _showDetail(context, source[i], prov, theme),
                        ),
                      )
                    : Container(
                        decoration: BoxDecoration(
                          color: theme.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: theme.border, width: 1),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 4))
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: PlutoGrid(
                            columns: _buildColumns(theme) +
                                [
                                  PlutoColumn(
                                      title: '',
                                      field: '_obj',
                                      hide: true,
                                      width: 0,
                                      type: PlutoColumnType.text())
                                ],
                            rows: _buildRows(source, prov, tecProv),
                            onLoaded: (e) {
                              _stateManager = e.stateManager;
                              e.stateManager.setPageSize(25, notify: false);
                            },
                            onRowDoubleTap: (e) {
                              final id = e.row.cells['_obj']?.value as String?;
                              if (id != null) {
                                final inc = prov.byId(id);
                                if (inc != null)
                                  _showDetail(context, inc, prov, theme);
                              }
                            },
                            createFooter: (s) => PlutoPagination(s),
                            configuration: PlutoGridConfiguration(
                              columnSize: const PlutoGridColumnSizeConfig(
                                autoSizeMode: PlutoAutoSizeMode.scale,
                              ),
                              style: PlutoGridStyleConfig(
                                gridBorderColor: theme.border,
                                gridBackgroundColor: theme.surface,
                                rowColor: theme.surface,
                                activatedColor:
                                    theme.primaryColor.withOpacity(0.08),
                                activatedBorderColor: theme.primaryColor,
                                cellColorInEditState: theme.surface,
                                columnTextStyle: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: theme.textSecondary),
                                columnHeight: 40,
                                rowHeight: 44,
                              ),
                            ),
                          ),
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  void _showDetail(BuildContext context, Incidencia inc,
      IncidenciaProvider prov, AppTheme theme) {
    final tecProv = context.read<TecnicoProvider>();
    final audProv = context.read<AuditoriaProvider>();
    final tec = inc.tecnicoId != null ? tecProv.byId(inc.tecnicoId!) : null;

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(children: [
                  Text(formatIdIncidencia(inc.id),
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: theme.primaryColor)),
                  const Spacer(),
                  IconButton(
                      onPressed: () => Navigator.pop(ctx),
                      icon: const Icon(Icons.close)),
                ]),
                const SizedBox(height: 4),
                Text(inc.descripcion,
                    style: TextStyle(fontSize: 15, color: theme.textPrimary)),
                const SizedBox(height: 16),
                Wrap(spacing: 8, runSpacing: 8, children: [
                  PriorityBadge(prioridad: inc.prioridad),
                  EstatusBadge(estatus: inc.estatus),
                  _DetailChip(
                      label: labelCategoria(inc.categoria),
                      icon: Icons.category_outlined,
                      theme: theme),
                  _DetailChip(
                      label: labelEntorno(inc.entorno),
                      icon: Icons.location_on_outlined,
                      theme: theme),
                ]),
                const SizedBox(height: 16),
                _DetailRow(
                    label: 'SLA',
                    value: formatSla(inc.fechaLimite),
                    valueColor: inc.estaVencida ? theme.critical : null,
                    theme: theme),
                _DetailRow(
                    label: 'Reportado',
                    value: formatFechaHora(inc.fechaReporte),
                    theme: theme),
                _DetailRow(
                    label: 'Municipio', value: inc.municipio, theme: theme),
                // Técnico asignado
                if (tec != null)
                  _TecnicoInfoRow(tec: tec, theme: theme, tecProv: tecProv)
                else if (inc.tecnicoId != null)
                  _DetailRow(
                      label: 'Técnico', value: inc.tecnicoId!, theme: theme),
                // Reincidente
                if (inc.esReincidente) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                        color: theme.high.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6)),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(Icons.repeat, size: 14, color: theme.high),
                      const SizedBox(width: 6),
                      Text('Incidencia reincidente',
                          style: TextStyle(
                              fontSize: 12,
                              color: theme.high,
                              fontWeight: FontWeight.w600)),
                    ]),
                  ),
                ],
                const SizedBox(height: 20),
                Divider(color: theme.border),
                const SizedBox(height: 14),
                // Acciones
                Wrap(spacing: 8, runSpacing: 8, children: [
                  // Sin técnico asignado: mostrar botón asignar
                  if (inc.tecnicoId == null &&
                      (inc.estatus == 'aprobado' ||
                          inc.estatus == 'recibido' ||
                          inc.estatus == 'en_revision'))
                    FilledButton.icon(
                      onPressed: () {
                        Navigator.pop(ctx);
                        AsignarTecnicoDialog.show(context, inc);
                      },
                      icon: const Icon(Icons.person_add_outlined, size: 16),
                      label: const Text('Asignar Técnico'),
                      style: FilledButton.styleFrom(
                          backgroundColor: theme.primaryColor),
                    ),
                  if (inc.estatus == 'aprobado' || inc.estatus == 'asignado')
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(ctx);
                        prov.actualizarEstatus(inc.id, 'en_proceso');
                        audProv.registrar(
                          modulo: 'Órdenes',
                          accion: 'INICIAR',
                          descripcion:
                              'Inició orden ${formatIdIncidencia(inc.id)} — ${labelCategoria(inc.categoria)}',
                          referenciaId: inc.id,
                        );
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text(
                                '${formatIdIncidencia(inc.id)} marcada En Proceso'),
                            backgroundColor: theme.medium));
                      },
                      icon: const Icon(Icons.play_arrow_outlined, size: 16),
                      label: const Text('Iniciar'),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: theme.medium,
                          foregroundColor: Colors.white),
                    ),
                  if (inc.estatus == 'en_proceso')
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(ctx);
                        prov.actualizarEstatus(inc.id, 'resuelto');
                        if (inc.tecnicoId != null)
                          tecProv.decrementarActivas(inc.tecnicoId!);
                        audProv.registrar(
                          modulo: 'Órdenes',
                          accion: 'RESOLVER',
                          descripcion:
                              'Marcó como resuelta la orden ${formatIdIncidencia(inc.id)} — ${labelCategoria(inc.categoria)}',
                          referenciaId: inc.id,
                        );
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text(
                                '${formatIdIncidencia(inc.id)} marcada como Resuelta'),
                            backgroundColor: theme.low));
                      },
                      icon: const Icon(Icons.check_circle_outline, size: 16),
                      label: const Text('Marcar Resuelta'),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: theme.low,
                          foregroundColor: Colors.white),
                    ),
                  OutlinedButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Cerrar'),
                  ),
                ]),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Widget interno: fila de técnico asignado
class _TecnicoInfoRow extends StatelessWidget {
  const _TecnicoInfoRow(
      {required this.tec, required this.theme, required this.tecProv});
  final Tecnico tec;
  final AppTheme theme;
  final TecnicoProvider tecProv;

  @override
  Widget build(BuildContext context) {
    final bytes = tecProv.getAvatarBytes(tec.id);
    final hasPath = tec.avatarPath?.isNotEmpty ?? false;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(children: [
        SizedBox(
            width: 120,
            child: Text('Técnico asignado',
                style: TextStyle(fontSize: 12, color: theme.textSecondary))),
        CircleAvatar(
            radius: 14,
            backgroundColor: const Color(0xFF7A1E3A),
            backgroundImage: bytes != null
                ? MemoryImage(bytes) as ImageProvider
                : hasPath
                    ? AssetImage(tec.avatarPath!)
                    : null,
            child: (bytes == null && !hasPath)
                ? Text(_initials(tec.nombre),
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w700))
                : null),
        const SizedBox(width: 8),
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(tec.nombre,
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: theme.textPrimary)),
          Text(labelEspecialidad(tec.especialidad),
              style: TextStyle(fontSize: 11, color: theme.textSecondary)),
        ])),
      ]),
    );
  }

  String _initials(String n) {
    final p = n.trim().split(' ');
    return p.length >= 2
        ? '${p[0][0]}${p[1][0]}'.toUpperCase()
        : n.substring(0, n.length.clamp(0, 2)).toUpperCase();
  }
}

class _FilterBar extends StatelessWidget {
  final String? filterPrioridad, filterEstatus, filterCategoria;
  final List<String> prioridades, estatuses, categorias;
  final AppTheme theme;
  final Function(String?) onPrioridad, onEstatus, onCategoria;
  final VoidCallback onClear;

  const _FilterBar({
    required this.filterPrioridad,
    required this.filterEstatus,
    required this.filterCategoria,
    required this.prioridades,
    required this.estatuses,
    required this.categorias,
    required this.theme,
    required this.onPrioridad,
    required this.onEstatus,
    required this.onCategoria,
    required this.onClear,
  });

  bool get _hasFilter =>
      filterPrioridad != null ||
      filterEstatus != null ||
      filterCategoria != null;

  @override
  Widget build(BuildContext context) {
    return Wrap(
        spacing: 8,
        runSpacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          // Prioridad dropdown
          _ChipDropdown(
            label: filterPrioridad != null
                ? labelPrioridad(filterPrioridad!)
                : 'Prioridad',
            active: filterPrioridad != null,
            theme: theme,
            items: [null, ...prioridades],
            itemLabel: (v) => v == null ? 'Todas' : labelPrioridad(v),
            onSelected: onPrioridad,
          ),
          _ChipDropdown(
            label: filterEstatus != null
                ? labelEstatus(filterEstatus!)
                : 'Estatus',
            active: filterEstatus != null,
            theme: theme,
            items: [null, ...estatuses],
            itemLabel: (v) => v == null ? 'Todos' : labelEstatus(v),
            onSelected: onEstatus,
          ),
          _ChipDropdown(
            label: filterCategoria != null
                ? labelCategoria(filterCategoria!)
                : 'Categoría',
            active: filterCategoria != null,
            theme: theme,
            items: [null, ...categorias],
            itemLabel: (v) => v == null ? 'Todas' : labelCategoria(v),
            onSelected: onCategoria,
          ),
          if (_hasFilter)
            ActionChip(
              label: const Text('Limpiar filtros'),
              avatar: const Icon(Icons.clear, size: 14),
              onPressed: onClear,
              backgroundColor: theme.critical.withOpacity(0.1),
              labelStyle: TextStyle(fontSize: 12, color: theme.critical),
            ),
        ]);
  }
}

class _ChipDropdown extends StatelessWidget {
  final String label;
  final bool active;
  final AppTheme theme;
  final List<String?> items;
  final String Function(String?) itemLabel;
  final Function(String?) onSelected;

  const _ChipDropdown({
    required this.label,
    required this.active,
    required this.theme,
    required this.items,
    required this.itemLabel,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String?>(
      tooltip: '',
      child: Chip(
        label: Text(label,
            style: TextStyle(
                fontSize: 12,
                color: active ? theme.primaryColor : theme.textSecondary,
                fontWeight: active ? FontWeight.w600 : FontWeight.w400)),
        avatar: Icon(Icons.filter_list,
            size: 14, color: active ? theme.primaryColor : theme.textSecondary),
        backgroundColor:
            active ? theme.primaryColor.withOpacity(0.1) : theme.surface,
        side: BorderSide(
            color: active ? theme.primaryColor.withOpacity(0.4) : theme.border),
      ),
      itemBuilder: (_) => items
          .map((v) => PopupMenuItem<String?>(
                value: v,
                child: Text(itemLabel(v), style: const TextStyle(fontSize: 13)),
              ))
          .toList(),
      onSelected: onSelected,
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow(
      {required this.label,
      required this.value,
      required this.theme,
      this.valueColor});
  final String label, value;
  final AppTheme theme;
  final Color? valueColor;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(children: [
        SizedBox(
            width: 120,
            child: Text(label,
                style: TextStyle(fontSize: 12, color: theme.textSecondary))),
        Expanded(
            child: Text(value,
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: valueColor ?? theme.textPrimary))),
      ]),
    );
  }
}

class _DetailChip extends StatelessWidget {
  const _DetailChip(
      {required this.label, required this.icon, required this.theme});
  final String label;
  final IconData icon;
  final AppTheme theme;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
          color: theme.border.withOpacity(0.5),
          borderRadius: BorderRadius.circular(6)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 13, color: theme.textSecondary),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(fontSize: 12, color: theme.textPrimary)),
      ]),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Card mobile — Incidencia
// ══════════════════════════════════════════════════════════════════════════════
class _IncidenciaCard extends StatelessWidget {
  const _IncidenciaCard({
    required this.inc,
    required this.theme,
    required this.onTap,
  });
  final Incidencia inc;
  final AppTheme theme;
  final VoidCallback onTap;

  static const _catIcons = <String, IconData>{
    'alumbrado': Icons.lightbulb_outline,
    'bacheo': Icons.construction,
    'basura': Icons.delete_outline,
    'seguridad': Icons.security,
    'agua_drenaje': Icons.water_drop_outlined,
    'señalizacion': Icons.signpost_outlined,
    'senalizacion': Icons.signpost_outlined,
  };

  @override
  Widget build(BuildContext context) {
    final isVencida = inc.estaVencida;
    final catIcon = _catIcons[inc.categoria] ?? Icons.report_outlined;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: theme.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
              color:
                  isVencida ? theme.critical.withOpacity(0.35) : theme.border),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // ── Fila 1: ID + prioridad + estatus ──────────────────────
            Row(children: [
              Text(
                formatIdIncidencia(inc.id),
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: theme.primaryColor),
              ),
              const Spacer(),
              PriorityBadge(prioridad: inc.prioridad),
              const SizedBox(width: 6),
              EstatusBadge(estatus: inc.estatus),
            ]),
            const SizedBox(height: 8),

            // ── Fila 2: categoría + entorno ────────────────────────────
            Row(children: [
              Icon(catIcon, size: 14, color: theme.textSecondary),
              const SizedBox(width: 4),
              Text(labelCategoria(inc.categoria),
                  style: TextStyle(fontSize: 12, color: theme.textSecondary)),
              const SizedBox(width: 8),
              Text('·',
                  style: TextStyle(color: theme.textDisabled, fontSize: 12)),
              const SizedBox(width: 8),
              Text(labelEntorno(inc.entorno),
                  style: TextStyle(fontSize: 12, color: theme.textSecondary)),
            ]),
            const SizedBox(height: 6),

            // ── Descripción ────────────────────────────────────────────
            Text(
              inc.descripcion,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 13, color: theme.textPrimary),
            ),
            const SizedBox(height: 8),

            // ── SLA + fecha ────────────────────────────────────────────
            Row(children: [
              Icon(Icons.timer_outlined,
                  size: 13,
                  color: isVencida ? theme.critical : theme.textSecondary),
              const SizedBox(width: 4),
              Text(
                formatSla(inc.fechaLimite),
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isVencida ? theme.critical : theme.textSecondary),
              ),
              const Spacer(),
              Text(formatFechaCorta(inc.fechaReporte),
                  style: TextStyle(fontSize: 11, color: theme.textDisabled)),
            ]),

            // ── Técnico asignado o botón Asignar ──────────────────────
            if (inc.tecnicoId != null) ...[
              const SizedBox(height: 6),
              Consumer<TecnicoProvider>(builder: (ctx, tecProv, _) {
                final nombre =
                    tecProv.byId(inc.tecnicoId!)?.nombre ?? inc.tecnicoId!;
                return Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.person_outline,
                      size: 13, color: theme.textSecondary),
                  const SizedBox(width: 4),
                  Text(nombre,
                      style:
                          TextStyle(fontSize: 11, color: theme.textSecondary)),
                ]);
              }),
            ] else if (const {'aprobado', 'asignado', 'recibido', 'en_revision'}
                .contains(inc.estatus)) ...[
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () => AsignarTecnicoDialog.show(context, inc),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: theme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border:
                        Border.all(color: theme.primaryColor.withOpacity(0.35)),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.person_add_outlined,
                        size: 14, color: theme.primaryColor),
                    const SizedBox(width: 6),
                    Text('Asignar técnico',
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: theme.primaryColor)),
                  ]),
                ),
              ),
            ],

            // ── Reincidente ────────────────────────────────────────────
            if (inc.esReincidente) ...[
              const SizedBox(height: 6),
              Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.repeat, size: 12, color: theme.high),
                const SizedBox(width: 4),
                Text('Reincidente',
                    style: TextStyle(
                        fontSize: 11,
                        color: theme.high,
                        fontWeight: FontWeight.w600)),
              ]),
            ],
          ]),
        ),
      ),
    );
  }
}
