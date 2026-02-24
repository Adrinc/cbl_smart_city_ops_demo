import 'package:flutter/material.dart';
import 'package:nethive_neo/helpers/constants.dart';
import 'package:nethive_neo/models/models.dart';
import 'package:nethive_neo/pages/configuracion/widgets/criterios_editor.dart';
import 'package:nethive_neo/pages/configuracion/widgets/ver_criterios_dialog.dart';
import 'package:nethive_neo/providers/providers.dart';
import 'package:nethive_neo/theme/theme.dart';
import 'package:nethive_neo/widgets/shared/section_header.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:provider/provider.dart';

class ConfiguracionPage extends StatelessWidget {
  const ConfiguracionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final prov = context.watch<ConfiguracionProvider>();
    final reglas = prov.reglas;
    final isMobile = MediaQuery.of(context).size.width < mobileSize;

    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 16 : 24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SectionHeader(
          title: 'Motor de Priorización',
          subtitle:
              'Reglas automáticas para clasificar y escalar incidencias según categoría y entorno',
          trailing: FilledButton.icon(
            onPressed: () => _showNuevaReglaDialog(context, prov, theme),
            icon: const Icon(Icons.add, size: 16),
            label: const Text('Nueva Regla'),
            style: FilledButton.styleFrom(backgroundColor: theme.primaryColor),
          ),
        ),
        const SizedBox(height: 8),

        // Demo calc panel
        _CalcPanel(prov: prov, theme: theme),
        const SizedBox(height: 20),

        // Reglas list — PlutoGrid desktop / cards mobile
        if (reglas.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(40),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.tune_outlined, size: 48, color: theme.textDisabled),
                const SizedBox(height: 12),
                Text('Sin reglas configuradas',
                    style: TextStyle(color: theme.textSecondary, fontSize: 14)),
              ]),
            ),
          )
        else if (isMobile)
          _MobileCategoryGroups(reglas: reglas, prov: prov, theme: theme)
        else
          _ReglaPlutoGrid(
            key: ValueKey(reglas.map((r) => '${r.id}${r.activa}').join()),
            reglas: reglas,
            prov: prov,
            theme: theme,
            onNuevaRegla: () => _showNuevaReglaDialog(context, prov, theme),
          ),
      ]),
    );
  }

  static void _showNuevaReglaDialog(
      BuildContext ctx, ConfiguracionProvider prov, AppTheme theme) {
    showDialog(context: ctx, builder: (_) => _NuevaReglaDialog(prov: prov));
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// MOBILE — Agrupación por categoría (expandible)
// ═══════════════════════════════════════════════════════════════════════════
class _MobileCategoryGroups extends StatelessWidget {
  const _MobileCategoryGroups(
      {required this.reglas, required this.prov, required this.theme});
  final List<ReglaPriorizacion> reglas;
  final ConfiguracionProvider prov;
  final AppTheme theme;

  static const _catM = {
    'alumbrado': 'Alumbrado',
    'bacheo': 'Bacheo',
    'basura': 'Basura',
    'seguridad': 'Seguridad',
    'agua_drenaje': 'Agua/Drenaje',
    'señalizacion': 'Señalización',
  };
  static const _catIcons = <String, IconData>{
    'alumbrado': Icons.lightbulb_outline,
    'bacheo': Icons.construction,
    'basura': Icons.delete_outline,
    'agua_drenaje': Icons.water_drop_outlined,
    'señalizacion': Icons.traffic,
    'seguridad': Icons.security,
  };

  @override
  Widget build(BuildContext context) {
    // Agrupar por categoría manteniendo el orden de aparición
    final grouped = <String, List<ReglaPriorizacion>>{};
    for (final r in reglas) {
      (grouped[r.categoria] ??= []).add(r);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: grouped.entries.map((entry) {
        final cat = entry.key;
        final catReglas = entry.value;
        final icon = _catIcons[cat] ?? Icons.category_outlined;
        final label = _catM[cat] ?? cat;
        final activaCount = catReglas.where((r) => r.activa).length;
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
              color: theme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: theme.border),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)
              ]),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Theme(
              // quitar el borde divisor interno del ExpansionTile
              data:
                  Theme.of(context).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                leading: Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                      color: theme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8)),
                  child: Icon(icon, size: 18, color: theme.primaryColor),
                ),
                title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(label,
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: theme.textPrimary)),
                      Row(mainAxisSize: MainAxisSize.min, children: [
                        // badge total
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                              color: theme.primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10)),
                          child: Text(
                              '${catReglas.length} regla${catReglas.length == 1 ? '' : 's'}',
                              style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: theme.primaryColor)),
                        ),
                        if (activaCount < catReglas.length) ...[
                          const SizedBox(width: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 7, vertical: 3),
                            decoration: BoxDecoration(
                                color: theme.textDisabled.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(10)),
                            child: Text(
                                '${catReglas.length - activaCount} inactiva${catReglas.length - activaCount == 1 ? '' : 's'}',
                                style: TextStyle(
                                    fontSize: 10, color: theme.textDisabled)),
                          ),
                        ],
                      ]),
                    ]),
                subtitle: Text(
                  catReglas.map((r) => _entM(r.entorno)).join(' · '),
                  style: TextStyle(fontSize: 11, color: theme.textSecondary),
                ),
                initiallyExpanded: false,
                collapsedBackgroundColor: theme.surface,
                backgroundColor: theme.background,
                iconColor: theme.primaryColor,
                collapsedIconColor: theme.textSecondary,
                tilePadding: const EdgeInsets.fromLTRB(14, 6, 14, 6),
                childrenPadding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
                children: catReglas.asMap().entries.map((e) {
                  // Cabecera de entorno dentro del grupo
                  final entorno = e.value.entorno;
                  const entIcons = <String, IconData>{
                    'residencial': Icons.home_outlined,
                    'comercial': Icons.storefront_outlined,
                    'industrial': Icons.factory_outlined,
                    'institucional': Icons.account_balance_outlined,
                  };
                  const entColors = <String, Color>{
                    'residencial': Color(0xFF2D7A4F),
                    'comercial': Color(0xFF1D4ED8),
                    'industrial': Color(0xFFD97706),
                    'institucional': Color(0xFF7A1E3A),
                  };
                  final entColor =
                      entColors[entorno] ?? const Color(0xFF64748B);
                  final entIcon =
                      entIcons[entorno] ?? Icons.location_city_outlined;
                  return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding:
                              const EdgeInsets.only(left: 4, bottom: 6, top: 2),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 9, vertical: 4),
                            decoration: BoxDecoration(
                                color: entColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                    color: entColor.withOpacity(0.35))),
                            child:
                                Row(mainAxisSize: MainAxisSize.min, children: [
                              Icon(entIcon, size: 13, color: entColor),
                              const SizedBox(width: 5),
                              Text(_entM(entorno),
                                  style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: entColor)),
                            ]),
                          ),
                        ),
                        _ReglaCard(
                          key: ValueKey(e.value.id),
                          regla: e.value,
                          idx: reglas.indexOf(e.value),
                          prov: prov,
                          theme: theme,
                        ),
                        if (e.key < catReglas.length - 1)
                          const SizedBox(height: 10),
                      ]);
                }).toList(),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  static String _entM(String e) {
    const m = {
      'residencial': 'Residencial',
      'comercial': 'Comercial',
      'industrial': 'Industrial',
      'institucional': 'Institucional',
    };
    return m[e] ?? e;
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// PLUTOGRID DESKTOP — Reglas de priorización (agrupadas por Categoría → Entorno)
// ═══════════════════════════════════════════════════════════════════════════
class _ReglaPlutoGrid extends StatelessWidget {
  const _ReglaPlutoGrid({
    super.key,
    required this.reglas,
    required this.prov,
    required this.theme,
    required this.onNuevaRegla,
  });
  final List<ReglaPriorizacion> reglas;
  final ConfiguracionProvider prov;
  final AppTheme theme;
  final VoidCallback onNuevaRegla;

  static const _catM = {
    'alumbrado': 'Alumbrado',
    'bacheo': 'Bacheo',
    'basura': 'Basura',
    'seguridad': 'Seguridad',
    'agua_drenaje': 'Agua/Drenaje',
    'señalizacion': 'Señalización',
  };
  static const _entM = {
    'residencial': 'Residencial',
    'comercial': 'Comercial',
    'industrial': 'Industrial',
    'institucional': 'Institucional',
  };
  static const _prioColors = {
    'critico': Color(0xFFB91C1C),
    'alto': Color(0xFFD97706),
    'medio': Color(0xFF1D4ED8),
    'bajo': Color(0xFF2D7A4F),
  };

  List<PlutoColumn> _cols(BuildContext context) => [
        PlutoColumn(
          title: 'Categoría',
          field: 'categoria',
          width: 140,
          type: PlutoColumnType.text(),
          renderer: (r) {
            final cat = (r.cell.value as String? ?? '');
            if (cat.isEmpty) return const SizedBox.shrink();
            // Sub-grupo nivel-2 o filas hoja: no repetir la categoría
            if (!r.row.type.isGroup || r.row.parent != null) {
              return const SizedBox.shrink();
            }
            final label = _catM[cat] ?? cat;
            return Row(children: [
              Icon(_catIcon(cat), size: 16, color: theme.primaryColor),
              const SizedBox(width: 6),
              Text(label,
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: theme.textPrimary)),
            ]);
          },
        ),
        PlutoColumn(
          title: 'Entorno',
          field: 'entorno',
          width: 150,
          type: PlutoColumnType.text(),
          renderer: (r) {
            // Solo mostrar entorno en filas de sub-grupo nivel-2
            if (!r.row.type.isGroup || r.row.parent == null) {
              return const SizedBox.shrink();
            }
            final val = r.cell.value as String? ?? '';
            if (val.isEmpty) return const SizedBox.shrink();

            const icons = <String, IconData>{
              'residencial': Icons.home_outlined,
              'comercial': Icons.storefront_outlined,
              'industrial': Icons.factory_outlined,
              'institucional': Icons.account_balance_outlined,
            };
            const colors = <String, Color>{
              'residencial': Color(0xFF2D7A4F), // verde
              'comercial': Color(0xFF1D4ED8), // azul
              'industrial': Color(0xFFD97706), // ámbar
              'institucional': Color(0xFF7A1E3A), // vino
            };
            const labels = <String, String>{
              'residencial': 'Residencial',
              'comercial': 'Comercial',
              'industrial': 'Industrial',
              'institucional': 'Institucional',
            };

            final color = colors[val] ?? const Color(0xFF64748B);
            final icon = icons[val] ?? Icons.location_city_outlined;
            final label = labels[val] ?? val;

            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
              decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: color.withOpacity(0.35))),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(icon, size: 13, color: color),
                const SizedBox(width: 5),
                Text(label,
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: color)),
              ]),
            );
          },
        ),
        PlutoColumn(
          title: 'Prioridad',
          field: 'prioridad',
          width: 120,
          type: PlutoColumnType.text(),
          renderer: (r) {
            if (r.row.type.isGroup) return const SizedBox.shrink();
            final prio = (r.cell.value as String? ?? '');
            if (prio.isEmpty) return const SizedBox.shrink();
            final color = _prioColors[prio] ?? const Color(0xFF64748B);
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                  color: color.withOpacity(0.13),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: color.withOpacity(0.35))),
              child: Text(prio.toUpperCase(),
                  style: TextStyle(
                      fontSize: 10, fontWeight: FontWeight.w800, color: color)),
            );
          },
        ),
        PlutoColumn(
          title: 'SLA (h)',
          field: 'sla',
          width: 80,
          type: PlutoColumnType.text(),
          renderer: (r) {
            if (r.row.type.isGroup) return const SizedBox.shrink();
            return Text('${r.cell.value}h',
                style: TextStyle(
                    fontSize: 12,
                    color: theme.textPrimary,
                    fontWeight: FontWeight.w500));
          },
        ),
        PlutoColumn(
          title: 'Auto-Aprobar',
          field: 'autoAprobar',
          width: 120,
          type: PlutoColumnType.text(),
          renderer: (r) {
            if (r.row.type.isGroup) return const SizedBox.shrink();
            final v = r.cell.value == 'true';
            return Row(children: [
              Icon(v ? Icons.check_circle : Icons.radio_button_unchecked,
                  size: 18, color: v ? theme.low : theme.textDisabled),
              const SizedBox(width: 6),
              Text(v ? 'Sí' : 'No',
                  style: TextStyle(
                      fontSize: 12, color: v ? theme.low : theme.textDisabled)),
            ]);
          },
        ),
        PlutoColumn(
          title: 'Escala Reinc.',
          field: 'escalaReinc',
          width: 120,
          type: PlutoColumnType.text(),
          renderer: (r) {
            if (r.row.type.isGroup) return const SizedBox.shrink();
            final v = r.cell.value == 'true';
            return Row(children: [
              Icon(v ? Icons.trending_up : Icons.trending_flat,
                  size: 18, color: v ? theme.high : theme.textDisabled),
              const SizedBox(width: 6),
              Text(v ? 'Sí' : 'No',
                  style: TextStyle(
                      fontSize: 12,
                      color: v ? theme.high : theme.textDisabled)),
            ]);
          },
        ),
        PlutoColumn(
          title: 'Estado',
          field: 'activa',
          width: 100,
          type: PlutoColumnType.text(),
          renderer: (r) {
            if (r.row.type.isGroup) return const SizedBox.shrink();
            final id = r.row.cells['_id']?.value as String? ?? '';
            final v = r.cell.value == 'true';
            return Transform.scale(
              scale: 0.85,
              child: Switch(
                value: v,
                onChanged: (_) => prov.toggleActiva(id),
                activeColor: theme.primaryColor,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            );
          },
        ),
        PlutoColumn(
          title: 'Criterios',
          field: 'criterios',
          width: 90,
          type: PlutoColumnType.text(),
          enableSorting: false,
          enableFilterMenuItem: false,
          renderer: (r) {
            if (r.row.type.isGroup) return const SizedBox.shrink();
            final id = r.row.cells['_id']?.value as String? ?? '';
            final regla = prov.byId(id);
            final n = regla?.criterios.length ?? 0;
            return GestureDetector(
              onTap: () {
                if (regla == null) return;
                VerCriteriosDialog.show(context, regla);
              },
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.list_alt_outlined,
                    size: 14,
                    color: n > 0 ? theme.primaryColor : theme.textDisabled),
                const SizedBox(width: 4),
                Text(
                  n > 0 ? '$n' : '—',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: n > 0 ? theme.primaryColor : theme.textDisabled,
                      decoration: n > 0
                          ? TextDecoration.underline
                          : TextDecoration.none),
                ),
              ]),
            );
          },
        ),
        PlutoColumn(
          title: 'Acciones',
          field: 'acc',
          width: 100,
          type: PlutoColumnType.text(),
          enableSorting: false,
          enableFilterMenuItem: false,
          renderer: (r) {
            if (r.row.type.isGroup) return const SizedBox.shrink();
            final id = r.row.cells['_id']?.value as String? ?? '';
            final regla = prov.byId(id);
            if (regla == null) return const SizedBox();
            return Row(mainAxisSize: MainAxisSize.min, children: [
              Tooltip(
                message: 'Ver / Editar Criterios',
                child: InkWell(
                  onTap: () => VerCriteriosDialog.show(context, regla),
                  borderRadius: BorderRadius.circular(6),
                  child: Padding(
                    padding: const EdgeInsets.all(5),
                    child: Icon(Icons.list_alt_outlined,
                        size: 16, color: theme.primaryColor),
                  ),
                ),
              ),
              const SizedBox(width: 2),
              Tooltip(
                message: 'Eliminar regla',
                child: InkWell(
                  onTap: () => _confirmDelete(context, regla),
                  borderRadius: BorderRadius.circular(6),
                  child: Padding(
                    padding: const EdgeInsets.all(5),
                    child: Icon(Icons.delete_outline,
                        size: 16, color: theme.critical),
                  ),
                ),
              ),
            ]);
          },
        ),
        PlutoColumn(
          title: '',
          field: '_id',
          width: 0,
          hide: true,
          type: PlutoColumnType.text(),
        ),
      ];

  void _confirmDelete(BuildContext ctx, ReglaPriorizacion regla) {
    showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar regla'),
        content: Text(
            '¿Eliminar la regla ${regla.categoria} / ${regla.entorno} (${regla.nivelPrioridad.toUpperCase()})?\n'
            'Esta acción es temporal y se revertirá al recargar.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar')),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              prov.deleteRegla(regla.id);
              ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
                content: const Text(
                    'Regla eliminada (temporal — solo en esta sesión)'),
                backgroundColor: theme.neutral,
              ));
            },
            style: FilledButton.styleFrom(backgroundColor: theme.critical),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  List<PlutoRow> _rows() => reglas
      .map((r) => PlutoRow(cells: {
            'categoria': PlutoCell(value: r.categoria),
            'entorno': PlutoCell(value: r.entorno),
            'prioridad': PlutoCell(value: r.nivelPrioridad),
            'sla': PlutoCell(value: '${r.slaHoras}'),
            'autoAprobar': PlutoCell(value: '${r.autoAprobar}'),
            'escalaReinc': PlutoCell(value: '${r.esReincidenteEscala}'),
            'activa': PlutoCell(value: '${r.activa}'),
            'criterios': PlutoCell(value: '${r.criterios.length}'),
            'acc': PlutoCell(value: ''),
            '_id': PlutoCell(value: r.id),
          }))
      .toList();

  IconData _catIcon(String c) {
    const d = <String, IconData>{
      'alumbrado': Icons.lightbulb_outline,
      'bacheo': Icons.construction,
      'basura': Icons.delete_outline,
      'agua_drenaje': Icons.water_drop_outlined,
      'señalizacion': Icons.traffic,
      'seguridad': Icons.security,
    };
    return d[c] ?? Icons.category_outlined;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height:
          600, // altura fija; PlutoGrid scrollea internamente si se expanden todos los grupos
      child: Container(
        decoration: BoxDecoration(
            color: theme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: theme.border),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)
            ]),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: PlutoGrid(
            columns: _cols(context),
            rows: _rows(),
            onLoaded: (e) {
              e.stateManager.setPageSize(50, notify: false);
              // ─ Row grouping: Categoría → Entorno ────────────────────────────────────
              final catCol = e.stateManager.columns
                  .firstWhere((c) => c.field == 'categoria');
              final entCol = e.stateManager.columns
                  .firstWhere((c) => c.field == 'entorno');
              e.stateManager.setRowGroup(
                PlutoRowGroupByColumnDelegate(
                  columns: [catCol, entCol],
                  showFirstExpandableIcon: false,
                  showCount: true,
                  enableCompactCount: false,
                ),
              );
            },
            configuration: PlutoGridConfiguration(
              columnSize: const PlutoGridColumnSizeConfig(
                autoSizeMode: PlutoAutoSizeMode.scale,
              ),
              style: PlutoGridStyleConfig(
                gridBorderColor: theme.border,
                gridBackgroundColor: theme.surface,
                rowColor: theme.surface,
                activatedColor: theme.primaryColor.withOpacity(0.07),
                activatedBorderColor: theme.primaryColor,
                cellColorInEditState: theme.surface,
                columnTextStyle: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: theme.textSecondary),
                columnHeight: 44,
                rowHeight: 56,
              ),
            ),
          ),
        ),
      ),
    );
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
  String _categoria = 'alumbrado';
  String _entorno = 'residencial';
  String _prioridad = 'medio';
  int _slaHoras = 24;
  bool _autoAprobar = false;
  bool _escalaReinc = false;
  bool _activa = true;
  List<String> _criterios = [];

  static const _categorias = [
    'alumbrado',
    'bacheo',
    'basura',
    'seguridad',
    'agua_drenaje',
    'señalizacion'
  ];
  static const _entornos = [
    'residencial',
    'comercial',
    'industrial',
    'institucional'
  ];
  static const _prioridades = ['bajo', 'medio', 'alto', 'critico'];
  static const _slaOpts = [4, 8, 12, 16, 24, 48, 72, 96];

  static const _catLabels = {
    'alumbrado': 'Alumbrado',
    'bacheo': 'Bacheo',
    'basura': 'Basura',
    'seguridad': 'Seguridad',
    'agua_drenaje': 'Agua / Drenaje',
    'señalizacion': 'Señalización'
  };
  static const _entLabels = {
    'residencial': 'Residencial',
    'comercial': 'Comercial',
    'industrial': 'Industrial',
    'institucional': 'Institucional'
  };
  static const _prioLabels = {
    'bajo': 'Bajo',
    'medio': 'Medio',
    'alto': 'Alto',
    'critico': 'Crítico'
  };
  static const _prioColors = {
    'bajo': Color(0xFF2D7A4F),
    'medio': Color(0xFF1D4ED8),
    'alto': Color(0xFFD97706),
    'critico': Color(0xFFB91C1C)
  };

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
          child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(children: [
                  Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                          color: theme.primaryColor.withOpacity(0.12),
                          shape: BoxShape.circle),
                      child: Icon(Icons.tune,
                          color: theme.primaryColor, size: 20)),
                  const SizedBox(width: 12),
                  Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                        Text('Nueva Regla de Priorización',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: theme.textPrimary)),
                        Text('Cambios temporales — solo en esta sesión',
                            style: TextStyle(
                                fontSize: 11, color: theme.textSecondary)),
                      ])),
                  IconButton(
                      icon: Icon(Icons.close,
                          size: 18, color: theme.textSecondary),
                      onPressed: () => Navigator.pop(context)),
                ]),
                const SizedBox(height: 20),
                Divider(color: theme.border),
                const SizedBox(height: 18),

                // Categoría + Entorno
                isMobile
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                            _ReglaDroprow(
                                'Categoría',
                                _categorias,
                                _categoria,
                                _catLabels,
                                theme,
                                Icons.category_outlined,
                                (v) => setState(() => _categoria = v!)),
                            const SizedBox(height: 14),
                            _ReglaDroprow(
                                'Entorno urbano',
                                _entornos,
                                _entorno,
                                _entLabels,
                                theme,
                                Icons.location_city_outlined,
                                (v) => setState(() => _entorno = v!)),
                          ])
                    : Row(children: [
                        Expanded(
                            child: _ReglaDroprow(
                                'Categoría',
                                _categorias,
                                _categoria,
                                _catLabels,
                                theme,
                                Icons.category_outlined,
                                (v) => setState(() => _categoria = v!))),
                        const SizedBox(width: 14),
                        Expanded(
                            child: _ReglaDroprow(
                                'Entorno urbano',
                                _entornos,
                                _entorno,
                                _entLabels,
                                theme,
                                Icons.location_city_outlined,
                                (v) => setState(() => _entorno = v!))),
                      ]),
                const SizedBox(height: 16),

                // Prioridad
                Text('Nivel de prioridad',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: theme.textSecondary)),
                const SizedBox(height: 8),
                Wrap(
                    spacing: 8,
                    children: _prioridades.map((p) {
                      final c = _prioColors[p] ?? theme.textPrimary;
                      final sel = _prioridad == p;
                      return ChoiceChip(
                        label: Text(_prioLabels[p] ?? p,
                            style: TextStyle(
                                fontSize: 12,
                                color: sel ? Colors.white : c,
                                fontWeight: FontWeight.w600)),
                        selected: sel,
                        onSelected: (_) => setState(() => _prioridad = p),
                        selectedColor: c,
                        backgroundColor: c.withOpacity(0.1),
                        side: BorderSide(color: c.withOpacity(0.4)),
                        showCheckmark: false,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                      );
                    }).toList()),
                const SizedBox(height: 16),

                // SLA horas
                Text('SLA (horas)',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: theme.textSecondary)),
                const SizedBox(height: 8),
                Wrap(
                    spacing: 8,
                    children: _slaOpts.map((h) {
                      final sel = _slaHoras == h;
                      return ChoiceChip(
                        label: Text('${h}h',
                            style: TextStyle(
                                fontSize: 12, fontWeight: FontWeight.w600)),
                        selected: sel,
                        onSelected: (_) => setState(() => _slaHoras = h),
                        selectedColor: theme.primaryColor,
                        labelStyle: TextStyle(color: sel ? Colors.white : null),
                        side: BorderSide(color: theme.border),
                        showCheckmark: false,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                      );
                    }).toList()),
                const SizedBox(height: 16),
                Divider(color: theme.border),
                const SizedBox(height: 12),

                // Switches
                _SwitchRow('Auto-Aprobar esta categoría/entorno', _autoAprobar,
                    theme.low, theme, (v) => setState(() => _autoAprobar = v)),
                const SizedBox(height: 4),
                Text(
                    'Si está activo, los reportes que coincidan se aprueban sin revisión humana.',
                    style: TextStyle(
                        fontSize: 11,
                        color: theme.textSecondary,
                        fontStyle: FontStyle.italic)),
                const SizedBox(height: 10),
                _SwitchRow('Escalar prioridad si es reincidente', _escalaReinc,
                    theme.high, theme, (v) => setState(() => _escalaReinc = v)),
                const SizedBox(height: 4),
                Text(
                    'Si hay incidencias previas similares, sube la prioridad un nivel automáticamente.',
                    style: TextStyle(
                        fontSize: 11,
                        color: theme.textSecondary,
                        fontStyle: FontStyle.italic)),
                const SizedBox(height: 10),
                _SwitchRow('Regla activa', _activa, theme.primaryColor, theme,
                    (v) => setState(() => _activa = v)),
                const SizedBox(height: 20),

                // Criterios de clasificación
                Divider(color: theme.border),
                const SizedBox(height: 14),
                CriteriosEditor(
                  criterios: _criterios,
                  onChanged: (v) => setState(() => _criterios = v),
                  theme: theme,
                ),
                const SizedBox(height: 16),

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
                    Expanded(
                        child: Text(
                      '${_catLabels[_categoria]} en zona ${_entLabels[_entorno]?.toLowerCase()} → prioridad ${_prioLabels[_prioridad]?.toUpperCase()} · SLA ${_slaHoras}h',
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: prioColor),
                    )),
                  ]),
                ),
                const SizedBox(height: 20),
                Divider(color: theme.border),
                const SizedBox(height: 14),

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
                        widget.prov.addRegla(ReglaPriorizacion(
                          id: 'r_${DateTime.now().millisecondsSinceEpoch}',
                          categoria: _categoria,
                          entorno: _entorno,
                          nivelPrioridad: _prioridad,
                          slaHoras: _slaHoras,
                          autoAprobar: _autoAprobar,
                          esReincidenteEscala: _escalaReinc,
                          activa: _activa,
                          criterios: List.from(_criterios),
                        ));
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                            content: Text(
                                'Regla creada (temporal — solo en esta sesión)'),
                            backgroundColor: Color(0xFF2D7A4F)));
                      },
                      icon: const Icon(Icons.add, size: 16),
                      label: const Text('Guardar Regla'),
                      style: FilledButton.styleFrom(
                          backgroundColor: theme.primaryColor)),
                ]),
              ]),
        ),
      ),
    );
  }
}

Widget _ReglaDroprow(
    String label,
    List<String> opts,
    String val,
    Map<String, String> labelMap,
    AppTheme theme,
    IconData icon,
    ValueChanged<String?> onChange) {
  return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(label,
        style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: theme.textSecondary)),
    const SizedBox(height: 6),
    Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
          color: theme.background,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: theme.border)),
      child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
        value: val,
        isExpanded: true,
        items: opts
            .map((o) => DropdownMenuItem(
                value: o,
                child: Row(children: [
                  const SizedBox(width: 4),
                  Text(labelMap[o] ?? o, style: const TextStyle(fontSize: 13)),
                ])))
            .toList(),
        onChanged: onChange,
      )),
    ),
  ]);
}

Widget _SwitchRow(String label, bool val, Color color, AppTheme theme,
    ValueChanged<bool> onChange) {
  return Row(children: [
    Expanded(
        child: Text(label,
            style: TextStyle(
                fontSize: 13,
                color: theme.textPrimary,
                fontWeight: FontWeight.w500))),
    Switch(
        value: val,
        onChanged: onChange,
        activeColor: color,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap),
  ]);
}

class _ReglaRow extends StatelessWidget {
  const _ReglaRow(
      {required this.regla,
      required this.idx,
      required this.prov,
      required this.theme});
  final ReglaPriorizacion regla;
  final int idx;
  final ConfiguracionProvider prov;
  final AppTheme theme;
  @override
  Widget build(BuildContext context) {
    const catM = {
      'alumbrado': 'Alumbrado',
      'bacheo': 'Bacheo',
      'basura': 'Basura',
      'seguridad': 'Seguridad',
      'agua_drenaje': 'Agua/Drenaje',
      'señalizacion': 'Señalización'
    };
    const prioColors = {
      'critico': Color(0xFFB91C1C),
      'alto': Color(0xFFD97706),
      'medio': Color(0xFF1D4ED8),
      'bajo': Color(0xFF2D7A4F)
    };
    final prioColor =
        prioColors[regla.nivelPrioridad] ?? const Color(0xFF64748B);
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(children: [
          Expanded(
              flex: 2,
              child: Text(catM[regla.categoria] ?? regla.categoria,
                  style: TextStyle(fontSize: 12, color: theme.textPrimary))),
          Expanded(
              flex: 2,
              child: Text(regla.entorno,
                  style: TextStyle(fontSize: 12, color: theme.textPrimary))),
          Expanded(
              flex: 2,
              child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                      color: prioColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(6)),
                  child: Text(regla.nivelPrioridad.toUpperCase(),
                      style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: prioColor)))),
          Expanded(
              flex: 1,
              child: Text('${regla.slaHoras}h',
                  style: TextStyle(fontSize: 12, color: theme.textPrimary))),
          Expanded(
              flex: 2,
              child: Icon(
                  regla.autoAprobar
                      ? Icons.check_circle
                      : Icons.radio_button_unchecked,
                  size: 16,
                  color: regla.autoAprobar ? theme.low : theme.textDisabled)),
          Expanded(
              flex: 2,
              child: Icon(
                  regla.esReincidenteEscala
                      ? Icons.check_circle
                      : Icons.radio_button_unchecked,
                  size: 16,
                  color: regla.esReincidenteEscala
                      ? theme.high
                      : theme.textDisabled)),
          Expanded(
              flex: 1,
              child: Switch(
                  value: regla.activa,
                  onChanged: (_) => prov.toggleActiva(regla.id),
                  activeColor: theme.primaryColor,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap)),
        ]));
  }
}

class _CalcPanel extends StatefulWidget {
  const _CalcPanel({required this.prov, required this.theme});
  final ConfiguracionProvider prov;
  final AppTheme theme;
  @override
  State<_CalcPanel> createState() => _CalcPanelState();
}

class _CalcPanelState extends State<_CalcPanel> {
  String _cat = 'bacheo';
  String _ent = 'residencial';
  bool _reinc = false;
  static const _cats = [
    'alumbrado',
    'bacheo',
    'basura',
    'seguridad',
    'agua_drenaje',
    'señalizacion'
  ];
  static const _ents = [
    'residencial',
    'comercial',
    'industrial',
    'institucional'
  ];

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme;
    final result = widget.prov.calcPrioridad(_cat, _ent, _reinc);
    const prioColors = {
      'critico': Color(0xFFB91C1C),
      'alto': Color(0xFFD97706),
      'medio': Color(0xFF1D4ED8),
      'bajo': Color(0xFF2D7A4F)
    };
    final prioColor = prioColors[result] ?? theme.neutral;
    final isMobile = MediaQuery.of(context).size.width < mobileSize;

    Widget resultBadge = Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
          color: prioColor.withOpacity(0.15),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: prioColor.withOpacity(0.4))),
      child: Text(result.toUpperCase(),
          style: TextStyle(
              fontSize: 13, fontWeight: FontWeight.w800, color: prioColor)),
    );

    Widget catDrop = DropdownButtonHideUnderline(
        child: DropdownButton<String>(
      value: _cat,
      isDense: true,
      items: _cats
          .map((c) => DropdownMenuItem(
              value: c, child: Text(c, style: const TextStyle(fontSize: 12))))
          .toList(),
      onChanged: (v) {
        if (v != null) setState(() => _cat = v);
      },
      borderRadius: BorderRadius.circular(8),
    ));

    Widget entDrop = DropdownButtonHideUnderline(
        child: DropdownButton<String>(
      value: _ent,
      isDense: true,
      items: _ents
          .map((e) => DropdownMenuItem(
              value: e, child: Text(e, style: const TextStyle(fontSize: 12))))
          .toList(),
      onChanged: (v) {
        if (v != null) setState(() => _ent = v);
      },
      borderRadius: BorderRadius.circular(8),
    ));

    Widget reincRow = Row(mainAxisSize: MainAxisSize.min, children: [
      Checkbox(
          value: _reinc,
          onChanged: (v) => setState(() => _reinc = v ?? false),
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap),
      Text('Reincidente',
          style: TextStyle(fontSize: 12, color: theme.textSecondary)),
    ]);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: theme.primarySoft,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: theme.primaryColor.withOpacity(0.2))),
      child: isMobile
          ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Icon(Icons.science_outlined,
                    color: theme.primaryColor, size: 18),
                const SizedBox(width: 8),
                Text('Simulador de prioridad',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: theme.primaryColor)),
                const Spacer(),
                resultBadge,
              ]),
              const SizedBox(height: 10),
              Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    catDrop,
                    entDrop,
                    reincRow,
                  ]),
            ])
          : Row(children: [
              Icon(Icons.science_outlined, color: theme.primaryColor, size: 18),
              const SizedBox(width: 10),
              Text('Simulador:',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: theme.primaryColor)),
              const SizedBox(width: 8),
              catDrop,
              const SizedBox(width: 8),
              entDrop,
              const SizedBox(width: 8),
              reincRow,
              const SizedBox(width: 12),
              Text('→', style: TextStyle(color: theme.textSecondary)),
              const SizedBox(width: 8),
              resultBadge,
            ]),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Card mobile de regla
// ══════════════════════════════════════════════════════════════════════════════
class _ReglaCard extends StatelessWidget {
  const _ReglaCard(
      {super.key,
      required this.regla,
      required this.idx,
      required this.prov,
      required this.theme});
  final ReglaPriorizacion regla;
  final int idx;
  final ConfiguracionProvider prov;
  final AppTheme theme;

  static const _catM = {
    'alumbrado': 'Alumbrado',
    'bacheo': 'Bacheo',
    'basura': 'Basura',
    'seguridad': 'Seguridad',
    'agua_drenaje': 'Agua/Drenaje',
    'señalizacion': 'Señalización'
  };
  static const _entM = {
    'residencial': 'Residencial',
    'comercial': 'Comercial',
    'industrial': 'Industrial',
    'institucional': 'Institucional'
  };
  static const _prioColors = {
    'critico': Color(0xFFB91C1C),
    'alto': Color(0xFFD97706),
    'medio': Color(0xFF1D4ED8),
    'bajo': Color(0xFF2D7A4F)
  };

  @override
  Widget build(BuildContext context) {
    final prioColor = _prioColors[regla.nivelPrioridad] ?? theme.neutral;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
            color: regla.activa ? prioColor.withOpacity(0.35) : theme.border),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // ── Fila 1: categoría + entorno + toggle ────────────────────────
          Row(children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
              decoration: BoxDecoration(
                  color: theme.border.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(6)),
              child: Text(_catM[regla.categoria] ?? regla.categoria,
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: theme.textPrimary)),
            ),
            const SizedBox(width: 8),
            Text(_entM[regla.entorno] ?? regla.entorno,
                style: TextStyle(fontSize: 12, color: theme.textSecondary)),
            const Spacer(),
            Switch(
                value: regla.activa,
                onChanged: (_) => prov.toggleActiva(regla.id),
                activeColor: theme.primaryColor,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap),
          ]),
          const SizedBox(height: 10),

          // ── Fila 2: prioridad + SLA ───────────────────────────────────
          Row(children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                  color: prioColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: prioColor.withOpacity(0.4))),
              child: Text(regla.nivelPrioridad.toUpperCase(),
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: prioColor)),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                  color: theme.border.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(6)),
              child: Text('SLA ${regla.slaHoras}h',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: theme.textSecondary)),
            ),
          ]),
          const SizedBox(height: 10),

          // ── Descripción natural ────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: prioColor.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: prioColor.withOpacity(0.15))),
            child: Text(
              '${_catM[regla.categoria] ?? regla.categoria} en zona '
              '${(_entM[regla.entorno] ?? regla.entorno).toLowerCase()} → '
              'prioridad ${regla.nivelPrioridad.toUpperCase()} · SLA ${regla.slaHoras}h',
              style: TextStyle(
                  fontSize: 12, color: prioColor, fontWeight: FontWeight.w500),
            ),
          ),
          const SizedBox(height: 10),

          // ── Flags ─────────────────────────────────────────────────────
          Wrap(spacing: 12, runSpacing: 6, children: [
            _Flag(
                icon: regla.autoAprobar
                    ? Icons.check_circle
                    : Icons.radio_button_unchecked,
                label: 'Auto-aprobar',
                active: regla.autoAprobar,
                activeColor: theme.low,
                theme: theme),
            _Flag(
                icon: regla.esReincidenteEscala
                    ? Icons.check_circle
                    : Icons.radio_button_unchecked,
                label: 'Escala reincidente',
                active: regla.esReincidenteEscala,
                activeColor: theme.high,
                theme: theme),
            if (!regla.activa)
              Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.pause_circle_outline,
                    size: 13, color: theme.neutral),
                const SizedBox(width: 4),
                Text('Inactiva',
                    style: TextStyle(
                        fontSize: 11,
                        color: theme.neutral,
                        fontWeight: FontWeight.w600)),
              ]),
          ]),
        ]),
      ),
    );
  }
}

class _Flag extends StatelessWidget {
  const _Flag(
      {required this.icon,
      required this.label,
      required this.active,
      required this.activeColor,
      required this.theme});
  final IconData icon;
  final String label;
  final bool active;
  final Color activeColor;
  final AppTheme theme;

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 14, color: active ? activeColor : theme.textDisabled),
      const SizedBox(width: 4),
      Text(label,
          style: TextStyle(
              fontSize: 11,
              color: active ? theme.textPrimary : theme.textDisabled)),
    ]);
  }
}
