import 'package:flutter/material.dart';
import 'package:nethive_neo/models/models.dart';
import 'package:nethive_neo/providers/providers.dart';
import 'package:nethive_neo/theme/theme.dart';
import 'package:provider/provider.dart';
import 'criterios_editor.dart';

/// Dialog para ver y editar los criterios de una regla de priorización.
class VerCriteriosDialog extends StatefulWidget {
  const VerCriteriosDialog({
    super.key,
    required this.regla,
  });
  final ReglaPriorizacion regla;

  static Future<void> show(BuildContext ctx, ReglaPriorizacion regla) {
    return showDialog(
      context: ctx,
      builder: (_) => VerCriteriosDialog(regla: regla),
    );
  }

  @override
  State<VerCriteriosDialog> createState() => _VerCriteriosDialogState();
}

class _VerCriteriosDialogState extends State<VerCriteriosDialog> {
  bool _editMode = false;
  late List<String> _criterios;

  static const _catLabels = {
    'alumbrado': 'Alumbrado',
    'bacheo': 'Bacheo',
    'basura': 'Basura',
    'seguridad': 'Seguridad',
    'agua_drenaje': 'Agua / Drenaje',
    'señalizacion': 'Señalización',
    'senalizacion': 'Señalización',
  };
  static const _entLabels = {
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

  @override
  void initState() {
    super.initState();
    _criterios = List.from(widget.regla.criterios);
  }

  void _guardar() {
    context
        .read<ConfiguracionProvider>()
        .updateCriterios(widget.regla.id, _criterios);
    setState(() => _editMode = false);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Criterios actualizados (temporal — solo en esta sesión)'),
      backgroundColor: Color(0xFF2D7A4F),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final prioColor =
        _prioColors[widget.regla.nivelPrioridad] ?? theme.textPrimary;
    final catLabel =
        _catLabels[widget.regla.categoria] ?? widget.regla.categoria;
    final entLabel = _entLabels[widget.regla.entorno] ?? widget.regla.entorno;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520, maxHeight: 620),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: prioColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child:
                      Icon(Icons.list_alt_outlined, size: 20, color: prioColor),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Criterios · $catLabel / $entLabel',
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: theme.textPrimary),
                        ),
                        Row(children: [
                          Container(
                            margin: const EdgeInsets.only(top: 3),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                                color: prioColor.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                    color: prioColor.withOpacity(0.35))),
                            child: Text(
                              widget.regla.nivelPrioridad.toUpperCase(),
                              style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: prioColor),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'SLA ${widget.regla.slaHoras}h',
                            style: TextStyle(
                                fontSize: 11, color: theme.textSecondary),
                          ),
                        ]),
                      ]),
                ),
                IconButton(
                  icon: Icon(Icons.close, size: 18, color: theme.textSecondary),
                  onPressed: () => Navigator.pop(context),
                ),
              ]),
              const SizedBox(height: 16),
              Divider(color: theme.border),
              const SizedBox(height: 12),

              // Contenido: vista o editor
              Expanded(
                child: _editMode
                    ? SingleChildScrollView(
                        child: CriteriosEditor(
                          criterios: _criterios,
                          onChanged: (v) => setState(() => _criterios = v),
                          theme: theme,
                        ),
                      )
                    : _criterios.isEmpty
                        ? Center(
                            child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                Icon(Icons.notes_outlined,
                                    size: 40, color: theme.textDisabled),
                                const SizedBox(height: 10),
                                Text(
                                  'Sin criterios definidos.',
                                  style: TextStyle(
                                      fontSize: 13, color: theme.textSecondary),
                                ),
                                const SizedBox(height: 6),
                                TextButton.icon(
                                  onPressed: () =>
                                      setState(() => _editMode = true),
                                  icon:
                                      const Icon(Icons.edit_outlined, size: 14),
                                  label: const Text('Añadir criterios'),
                                ),
                              ]))
                        : ListView.separated(
                            shrinkWrap: true,
                            itemCount: _criterios.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 6),
                            itemBuilder: (_, i) => Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(top: 5),
                                    child: Container(
                                      width: 7,
                                      height: 7,
                                      decoration: BoxDecoration(
                                        color: prioColor.withOpacity(0.7),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      _criterios[i],
                                      style: TextStyle(
                                          fontSize: 13,
                                          color: theme.textPrimary,
                                          height: 1.45),
                                    ),
                                  ),
                                ]),
                          ),
              ),

              const SizedBox(height: 14),
              Divider(color: theme.border),
              const SizedBox(height: 10),

              // Footer
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (!_editMode) ...[
                    OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                          foregroundColor: theme.textSecondary,
                          side: BorderSide(color: theme.border)),
                      child: const Text('Cerrar'),
                    ),
                    const SizedBox(width: 8),
                    FilledButton.icon(
                      onPressed: () => setState(() {
                        _editMode = true;
                      }),
                      icon: const Icon(Icons.edit_outlined, size: 15),
                      label: const Text('Editar Criterios'),
                      style: FilledButton.styleFrom(
                          backgroundColor: theme.primaryColor),
                    ),
                  ] else ...[
                    OutlinedButton(
                      onPressed: () {
                        setState(() {
                          _criterios = List.from(widget.regla.criterios);
                          _editMode = false;
                        });
                      },
                      style: OutlinedButton.styleFrom(
                          foregroundColor: theme.textSecondary,
                          side: BorderSide(color: theme.border)),
                      child: const Text('Cancelar'),
                    ),
                    const SizedBox(width: 8),
                    FilledButton.icon(
                      onPressed: _guardar,
                      icon: const Icon(Icons.save_outlined, size: 15),
                      label: const Text('Guardar Criterios'),
                      style: FilledButton.styleFrom(
                          backgroundColor: theme.primaryColor),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
