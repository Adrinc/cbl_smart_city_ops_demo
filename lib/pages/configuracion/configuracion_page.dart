import 'package:flutter/material.dart';
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

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
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

        // Reglas list
        Container(
          decoration: BoxDecoration(
              color: theme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: theme.border),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)
              ]),
          child: Column(children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                child: _ReglaRow(regla: r, idx: idx, prov: prov, theme: theme),
              );
            }),
          ]),
        ),
      ]),
    );
  }

  static void _showNuevaReglaDialog(
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
}

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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: theme.primarySoft,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: theme.primaryColor.withOpacity(0.2))),
      child: Row(children: [
        Icon(Icons.science_outlined, color: theme.primaryColor, size: 18),
        const SizedBox(width: 10),
        Text('Simulador:',
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: theme.primaryColor)),
        const SizedBox(width: 8),
        DropdownButtonHideUnderline(
            child: DropdownButton<String>(
          value: _cat,
          isDense: true,
          items: _cats
              .map((c) => DropdownMenuItem(
                  value: c,
                  child: Text(c, style: const TextStyle(fontSize: 12))))
              .toList(),
          onChanged: (v) {
            if (v != null) setState(() => _cat = v);
          },
          borderRadius: BorderRadius.circular(8),
        )),
        const SizedBox(width: 8),
        DropdownButtonHideUnderline(
            child: DropdownButton<String>(
          value: _ent,
          isDense: true,
          items: _ents
              .map((e) => DropdownMenuItem(
                  value: e,
                  child: Text(e, style: const TextStyle(fontSize: 12))))
              .toList(),
          onChanged: (v) {
            if (v != null) setState(() => _ent = v);
          },
          borderRadius: BorderRadius.circular(8),
        )),
        const SizedBox(width: 8),
        Row(mainAxisSize: MainAxisSize.min, children: [
          Checkbox(
              value: _reinc,
              onChanged: (v) => setState(() => _reinc = v ?? false),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap),
          Text('Reincidente',
              style: TextStyle(fontSize: 12, color: theme.textSecondary)),
        ]),
        const SizedBox(width: 12),
        Text('→', style: TextStyle(color: theme.textSecondary)),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
              color: prioColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: prioColor.withOpacity(0.4))),
          child: Text(result.toUpperCase(),
              style: TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w800, color: prioColor)),
        ),
      ]),
    );
  }
}
