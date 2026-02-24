import 'package:flutter/material.dart';
import 'package:nethive_neo/models/models.dart';
import 'package:nethive_neo/providers/providers.dart';
import 'package:nethive_neo/theme/theme.dart';
import 'package:provider/provider.dart';

/// Diálogo para crear o editar una [CategoriaConfig].
///
/// Si [existente] es null → modo creación.
/// Si [existente] no es null → modo edición (el id no es editable).
class CategoriaDialog extends StatefulWidget {
  const CategoriaDialog({super.key, this.existente});
  final CategoriaConfig? existente;

  static Future<void> show(BuildContext context, {CategoriaConfig? existente}) {
    return showDialog(
      context: context,
      builder: (_) => CategoriaDialog(existente: existente),
    );
  }

  @override
  State<CategoriaDialog> createState() => _CategoriaDialogState();
}

class _CategoriaDialogState extends State<CategoriaDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _labelCtrl;
  late IconData _selectedIcon;

  bool get _esEdicion => widget.existente != null;

  @override
  void initState() {
    super.initState();
    final cat = widget.existente;
    _labelCtrl = TextEditingController(text: cat?.label ?? '');
    _selectedIcon = cat?.icon ?? kCityIcons.first.icon;
  }

  @override
  void dispose() {
    _labelCtrl.dispose();
    super.dispose();
  }

  /// Auto-genera un ID único a partir del nombre visible:
  /// normaliza acentos, convierte a snake_case y añade
  /// sufijo numérico si ya existe en el provider.
  String _generateId(String label, ConfiguracionProvider prov) {
    final base = label
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[áàäâ]'), 'a')
        .replaceAll(RegExp(r'[éèëê]'), 'e')
        .replaceAll(RegExp(r'[íìïî]'), 'i')
        .replaceAll(RegExp(r'[óòöô]'), 'o')
        .replaceAll(RegExp(r'[úùüû]'), 'u')
        .replaceAll('ñ', 'n')
        .replaceAll(RegExp(r'[^a-z0-9]'), '_')
        .replaceAll(RegExp(r'_+'), '_')
        .replaceAll(RegExp(r'^_|_$'), '');
    String id = base.isEmpty ? 'categoria' : base;
    int i = 2;
    while (prov.categoriaById(id) != null) {
      id = '${base}_$i';
      i++;
    }
    return id;
  }

  void _guardar() {
    if (!_formKey.currentState!.validate()) return;
    final prov = context.read<ConfiguracionProvider>();

    if (_esEdicion) {
      prov.updateCategoria(
        widget.existente!.id,
        label: _labelCtrl.text.trim(),
        iconCodePoint: _selectedIcon.codePoint,
      );
      _feedback('Categoría actualizada');
    } else {
      final id = _generateId(_labelCtrl.text, prov);
      prov.addCategoria(CategoriaConfig(
        id: id,
        label: _labelCtrl.text.trim(),
        iconCodePoint: _selectedIcon.codePoint,
        activa: true,
        esNativa: false,
      ));
      _feedback('Categoría "${_labelCtrl.text.trim()}" creada');
    }
    Navigator.of(context).pop();
  }

  void _feedback(String msg) {
    ScaffoldMessenger.maybeOf(context)
        ?.showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: isMobile ? double.infinity : 540),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Cabecera ──
                Row(children: [
                  Icon(
                    _esEdicion ? Icons.edit_outlined : Icons.add_circle_outline,
                    size: 22,
                    color: theme.primaryColor,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    _esEdicion ? 'Editar categoría' : 'Nueva categoría',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: theme.textPrimary),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: Icon(Icons.close, color: theme.textSecondary),
                    splashRadius: 18,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ]),
                const SizedBox(height: 20),

                // ── Nombre visible ──
                _FieldLabel('Nombre visible', theme),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _labelCtrl,
                  decoration: _inputDec(
                    theme,
                    hint: 'ej: Bacheo Especial',
                    icon: Icons.label_outline,
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Escribe un nombre'
                      : null,
                ),
                const SizedBox(height: 20),

                // ── Selector de ícono ──
                _FieldLabel('Ícono', theme),
                const SizedBox(height: 10),
                _IconPicker(
                  selected: _selectedIcon,
                  theme: theme,
                  onSelect: (icon) => setState(() => _selectedIcon = icon),
                ),
                const SizedBox(height: 24),

                // ── Preview ──
                _Preview(
                  label: _labelCtrl.text.trim().isEmpty
                      ? 'Vista previa'
                      : _labelCtrl.text.trim(),
                  icon: _selectedIcon,
                  theme: theme,
                ),
                const SizedBox(height: 24),

                // ── Botones ──
                Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text('Cancelar',
                        style: TextStyle(color: theme.textSecondary)),
                  ),
                  const SizedBox(width: 8),
                  FilledButton.icon(
                    onPressed: _guardar,
                    icon: Icon(_esEdicion ? Icons.save_outlined : Icons.add),
                    label: Text(
                        _esEdicion ? 'Guardar cambios' : 'Crear categoría'),
                    style: FilledButton.styleFrom(
                        backgroundColor: theme.primaryColor),
                  ),
                ]),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDec(AppTheme theme,
      {required String hint, String? helper, required IconData icon}) {
    return InputDecoration(
      hintText: hint,
      helperText: helper,
      helperMaxLines: 2,
      prefixIcon: Icon(icon, size: 18, color: theme.textSecondary),
      filled: true,
      fillColor: theme.background,
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: theme.border)),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: theme.border)),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: theme.primaryColor, width: 1.5)),
      errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFB91C1C), width: 1.5)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    );
  }
}

// ─────────────────────────── Icon Picker ─────────────────────────────────────

class _IconPicker extends StatelessWidget {
  const _IconPicker({
    required this.selected,
    required this.theme,
    required this.onSelect,
  });
  final IconData selected;
  final AppTheme theme;
  final void Function(IconData) onSelect;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: theme.background,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: theme.border),
      ),
      child: GridView.builder(
        padding: const EdgeInsets.all(10),
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 56,
          mainAxisSpacing: 6,
          crossAxisSpacing: 6,
        ),
        itemCount: kCityIcons.length,
        itemBuilder: (_, i) {
          final opt = kCityIcons[i];
          final isSelected = opt.icon.codePoint == selected.codePoint;
          return Tooltip(
            message: opt.label,
            child: GestureDetector(
              onTap: () => onSelect(opt.icon),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                decoration: BoxDecoration(
                  color: isSelected
                      ? theme.primaryColor.withOpacity(0.12)
                      : theme.surface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected ? theme.primaryColor : theme.border,
                    width: isSelected ? 1.5 : 1,
                  ),
                ),
                child: Icon(
                  opt.icon,
                  size: 22,
                  color: isSelected ? theme.primaryColor : theme.textSecondary,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ─────────────────────────── Preview chip ────────────────────────────────────

class _Preview extends StatelessWidget {
  const _Preview(
      {required this.label, required this.icon, required this.theme});
  final String label;
  final IconData icon;
  final AppTheme theme;

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Text('Vista previa:',
          style: TextStyle(fontSize: 12, color: theme.textSecondary)),
      const SizedBox(width: 12),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
            color: theme.primarySoft,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: theme.primaryColor.withOpacity(0.3))),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 16, color: theme.primaryColor),
          const SizedBox(width: 7),
          Text(label,
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: theme.primaryColor)),
        ]),
      ),
    ]);
  }
}

// ─────────────────────────── Helpers ─────────────────────────────────────────

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text, this.theme);
  final String text;
  final AppTheme theme;

  @override
  Widget build(BuildContext context) {
    return Text(text,
        style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: theme.textSecondary));
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// GESTIONAR CATEGORÍAS — Dialog principal
// ══════════════════════════════════════════════════════════════════════════════

/// Diálogo que lista todas las categorías con acciones inline:
/// editar nombre/ícono, desactivar/reactivar, eliminar (si aplica).
/// Incluye botón para crear nueva categoría.
class GestionarCategoriasDialog extends StatelessWidget {
  const GestionarCategoriasDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      builder: (_) => const GestionarCategoriasDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final prov = context.watch<ConfiguracionProvider>();
    final categorias = prov.categorias;
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: isMobile ? double.infinity : 540,
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Cabecera ──
              Row(children: [
                Icon(Icons.category_outlined,
                    size: 22, color: theme.primaryColor),
                const SizedBox(width: 10),
                Expanded(
                  child: Text('Gestionar Categorías',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: theme.textPrimary)),
                ),
                FilledButton.icon(
                  onPressed: () => CategoriaDialog.show(context),
                  icon: const Icon(Icons.add, size: 15),
                  label: const Text('Nueva'),
                  style: FilledButton.styleFrom(
                      backgroundColor: theme.primaryColor,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      textStyle: const TextStyle(fontSize: 13)),
                ),
                const SizedBox(width: 6),
                IconButton(
                  icon: Icon(Icons.close, color: theme.textSecondary),
                  splashRadius: 18,
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ]),
              const SizedBox(height: 4),
              Text(
                '${categorias.length} categorías · ${categorias.where((c) => c.activa).length} activas',
                style: TextStyle(fontSize: 12, color: theme.textSecondary),
              ),
              const SizedBox(height: 16),
              // ── Lista ──
              Flexible(
                child: Container(
                  decoration: BoxDecoration(
                      border: Border.all(color: theme.border),
                      borderRadius: BorderRadius.circular(10)),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: categorias.length,
                      separatorBuilder: (_, __) =>
                          Divider(height: 1, color: theme.border),
                      itemBuilder: (_, i) => _CatRow(
                        cat: categorias[i],
                        reglaCount: prov.reglasPorCategoria(categorias[i].id),
                        prov: prov,
                        theme: theme,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // ── Nota info ──
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Icon(Icons.info_outline, size: 14, color: theme.textDisabled),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Las categorías del sistema no se pueden eliminar; solo desactivar. '
                    'Una categoría custom solo puede eliminarse si no tiene reglas asociadas.',
                    style: TextStyle(fontSize: 11, color: theme.textDisabled),
                  ),
                ),
              ]),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Fila de categoría ─────────────────────────────────────────────────────────

class _CatRow extends StatelessWidget {
  const _CatRow({
    required this.cat,
    required this.reglaCount,
    required this.prov,
    required this.theme,
  });
  final CategoriaConfig cat;
  final int reglaCount;
  final ConfiguracionProvider prov;
  final AppTheme theme;

  bool get _inactiva => !cat.activa;
  bool get _puedeEliminar => !cat.esNativa && reglaCount == 0;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: _inactiva ? 0.5 : 1.0,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(children: [
          // Ícono
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
                color: theme.primaryColor.withOpacity(_inactiva ? 0.05 : 0.1),
                borderRadius: BorderRadius.circular(8)),
            child: Icon(cat.icon,
                size: 18,
                color: _inactiva ? theme.textDisabled : theme.primaryColor),
          ),
          const SizedBox(width: 12),
          // Nombre + ID
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Text(cat.label,
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: _inactiva
                            ? theme.textDisabled
                            : theme.textPrimary)),
                const SizedBox(width: 6),
                if (cat.esNativa)
                  _MiniChip(label: 'Sistema', color: theme.neutral),
                if (!cat.esNativa)
                  _MiniChip(label: 'Custom', color: const Color(0xFF1D4ED8)),
                if (_inactiva)
                  _MiniChip(label: 'Inactiva', color: theme.neutral),
              ]),
              Row(children: [
                Text(cat.id,
                    style: TextStyle(
                        fontSize: 11,
                        color: theme.textDisabled,
                        fontFamily: 'monospace')),
                const SizedBox(width: 8),
                Icon(Icons.tune_outlined, size: 11, color: theme.textDisabled),
                const SizedBox(width: 3),
                Text('$reglaCount regla${reglaCount != 1 ? 's' : ''}',
                    style: TextStyle(fontSize: 11, color: theme.textSecondary)),
              ]),
            ]),
          ),
          // Acciones
          Tooltip(
            message: 'Editar nombre e ícono',
            child: IconButton(
              icon: Icon(Icons.edit_outlined,
                  size: 18, color: theme.primaryColor),
              splashRadius: 16,
              onPressed: () => CategoriaDialog.show(context, existente: cat),
            ),
          ),
          if (_inactiva)
            Tooltip(
              message: 'Reactivar categoría',
              child: IconButton(
                icon: const Icon(Icons.visibility_outlined,
                    size: 18, color: Color(0xFF2D7A4F)),
                splashRadius: 16,
                onPressed: () {
                  prov.reactivarCategoria(cat.id);
                  ScaffoldMessenger.maybeOf(context)?.showSnackBar(
                      SnackBar(content: Text('"${cat.label}" reactivada')));
                },
              ),
            )
          else
            Tooltip(
              message: _puedeEliminar
                  ? 'Desactivar o eliminar'
                  : cat.esNativa
                      ? 'Desactivar (categoría del sistema)'
                      : 'Desactivar (tiene reglas activas)',
              child: IconButton(
                icon: Icon(
                  _puedeEliminar ? Icons.delete_outline : Icons.block_outlined,
                  size: 18,
                  color: const Color(0xFFD97706),
                ),
                splashRadius: 16,
                onPressed: () => _showAccionDialog(context),
              ),
            ),
        ]),
      ),
    );
  }

  void _showAccionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => _CatAccionDialog(
        cat: cat,
        reglaCount: reglaCount,
        prov: prov,
      ),
    );
  }
}

// ── Diálogo de acción (desactivar / eliminar) ─────────────────────────────────

class _CatAccionDialog extends StatelessWidget {
  const _CatAccionDialog({
    required this.cat,
    required this.reglaCount,
    required this.prov,
  });
  final CategoriaConfig cat;
  final int reglaCount;
  final ConfiguracionProvider prov;

  bool get _puedeEliminar => !cat.esNativa && reglaCount == 0;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      title: Row(children: [
        const Icon(Icons.warning_amber_outlined,
            color: Color(0xFFD97706), size: 20),
        const SizedBox(width: 8),
        Text('Gestionar "${cat.label}"'),
      ]),
      content: SizedBox(
        width: 380,
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          // Info contextual
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
                color: const Color(0xFFFEF3C7),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                    color: const Color(0xFFD97706).withOpacity(0.4))),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              if (cat.esNativa)
                _InfoBullet(
                  icon: Icons.lock_outlined,
                  text:
                      'Categoría nativa del sistema: no puede eliminarse físicamente. Solo puede desactivarse.',
                ),
              if (!cat.esNativa && reglaCount > 0)
                _InfoBullet(
                  icon: Icons.tune_outlined,
                  text:
                      'Tiene $reglaCount regla${reglaCount != 1 ? 's' : ''} asociada${reglaCount != 1 ? 's' : ''}. Elimínalas primero para poder borrarla permanentemente.',
                ),
              if (_puedeEliminar)
                _InfoBullet(
                  icon: Icons.delete_outline,
                  text:
                      'Sin reglas asociadas. Puedes eliminarla permanentemente o solo desactivarla.',
                ),
            ]),
          ),
        ]),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Cancelar', style: TextStyle(color: theme.textSecondary)),
        ),
        OutlinedButton.icon(
          onPressed: () {
            prov.desactivarCategoria(cat.id);
            Navigator.of(context).pop();
            ScaffoldMessenger.maybeOf(context)?.showSnackBar(SnackBar(
                content: Text(
                    '"${cat.label}" desactivada. Datos históricos conservados.')));
          },
          icon: const Icon(Icons.visibility_off_outlined, size: 16),
          label: const Text('Desactivar'),
          style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFFD97706),
              side: const BorderSide(color: Color(0xFFD97706))),
        ),
        if (_puedeEliminar)
          FilledButton.icon(
            onPressed: () {
              prov.eliminarCategoria(cat.id);
              Navigator.of(context).pop();
              ScaffoldMessenger.maybeOf(context)?.showSnackBar(SnackBar(
                  content: Text('"${cat.label}" eliminada permanentemente.'),
                  backgroundColor: const Color(0xFFB91C1C)));
            },
            icon: const Icon(Icons.delete_forever, size: 16),
            label: const Text('Eliminar'),
            style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFB91C1C)),
          ),
      ],
    );
  }
}

// ── Helpers locales ───────────────────────────────────────────────────────────

class _MiniChip extends StatelessWidget {
  const _MiniChip({required this.label, required this.color});
  final String label;
  final Color color;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
      margin: const EdgeInsets.only(right: 4),
      decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: color.withOpacity(0.35))),
      child: Text(label,
          style: TextStyle(
              fontSize: 10, fontWeight: FontWeight.w600, color: color)),
    );
  }
}

class _InfoBullet extends StatelessWidget {
  const _InfoBullet({required this.icon, required this.text});
  final IconData icon;
  final String text;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, size: 14, color: const Color(0xFF92400E)),
        const SizedBox(width: 6),
        Expanded(
            child: Text(text,
                style:
                    const TextStyle(fontSize: 12, color: Color(0xFF78350F)))),
      ]),
    );
  }
}
