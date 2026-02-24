import 'package:flutter/material.dart';
import 'package:nethive_neo/helpers/constants.dart';
import 'package:nethive_neo/models/models.dart';
import 'package:nethive_neo/providers/providers.dart';
import 'package:nethive_neo/theme/theme.dart';
import 'package:nethive_neo/widgets/shared/section_header.dart';
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

        // Reglas list — tabla desktop / cards mobile
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
          ReorderableListView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            onReorder: (oldIdx, newIdx) => prov.reorderRegla(oldIdx, newIdx),
            children: reglas
                .asMap()
                .entries
                .map((e) => _ReglaCard(
                    key: ValueKey(e.value.id),
                    regla: e.value,
                    idx: e.key,
                    prov: prov,
                    theme: theme))
                .toList(),
          )
        else
          Container(
            decoration: BoxDecoration(
                color: theme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: theme.border),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.04), blurRadius: 8)
                ]),
            child: Column(children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                    color: theme.border.withOpacity(0.3),
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(12))),
                child: Row(children: [
                  _ColH('Categoría', flex: 2),
                  _ColH('Entorno', flex: 2),
                  _ColH('Prioridad', flex: 2),
                  _ColH('SLA (h)', flex: 1),
                  _ColH('Auto-Aprobar', flex: 2),
                  _ColH('Escala Reinc.', flex: 2),
                  _ColH('Estado', flex: 1),
                ]),
              ),
              ...reglas.asMap().entries.map((e) {
                final idx = e.key;
                final r = e.value;
                return Container(
                  decoration: BoxDecoration(
                      border: Border(
                          top: BorderSide(color: theme.border, width: 0.5))),
                  child:
                      _ReglaRow(regla: r, idx: idx, prov: prov, theme: theme),
                );
              }),
            ]),
          ),
      ]),
    );
  }

  static void _showNuevaReglaDialog(
      BuildContext ctx, ConfiguracionProvider prov, AppTheme theme) {
    showDialog(context: ctx, builder: (_) => _NuevaReglaDialog(prov: prov));
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

// Keep the existing classes below this point

class _ColH extends StatelessWidget {
  const _ColH(this.label, {required this.flex});
  final String label;
  final int flex;
  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    return Expanded(
        flex: flex,
        child: Text(label,
            style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: theme.textSecondary)));
  }
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
