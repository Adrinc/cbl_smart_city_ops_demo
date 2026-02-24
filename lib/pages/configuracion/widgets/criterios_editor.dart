import 'package:flutter/material.dart';
import 'package:nethive_neo/theme/theme.dart';

/// Editor de criterios en lenguaje natural para una regla de priorización.
/// Permite añadir, editar, reordenar y eliminar bullets de criterio.
class CriteriosEditor extends StatefulWidget {
  const CriteriosEditor({
    super.key,
    required this.criterios,
    required this.onChanged,
    required this.theme,
  });

  final List<String> criterios;
  final ValueChanged<List<String>> onChanged;
  final AppTheme theme;

  @override
  State<CriteriosEditor> createState() => _CriteriosEditorState();
}

class _CriteriosEditorState extends State<CriteriosEditor> {
  late List<String> _items;
  final _addCtrl = TextEditingController();
  final _addFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _items = List.from(widget.criterios);
  }

  @override
  void dispose() {
    _addCtrl.dispose();
    _addFocus.dispose();
    super.dispose();
  }

  void _addItem() {
    final text = _addCtrl.text.trim();
    if (text.isEmpty) return;
    setState(() => _items.add(text));
    _addCtrl.clear();
    _addFocus.requestFocus();
    widget.onChanged(List.from(_items));
  }

  void _removeItem(int idx) {
    setState(() => _items.removeAt(idx));
    widget.onChanged(List.from(_items));
  }

  void _reorder(int oldIdx, int newIdx) {
    if (newIdx > oldIdx) newIdx -= 1;
    setState(() {
      final item = _items.removeAt(oldIdx);
      _items.insert(newIdx, item);
    });
    widget.onChanged(List.from(_items));
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // Label
      Row(children: [
        Icon(Icons.list_alt_outlined, size: 14, color: theme.textSecondary),
        const SizedBox(width: 6),
        Text(
          'Criterios de clasificación',
          style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: theme.textSecondary),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
          decoration: BoxDecoration(
            color: theme.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            '${_items.length}',
            style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: theme.primaryColor),
          ),
        ),
      ]),
      const SizedBox(height: 6),
      Text(
        'Define situaciones concretas que corresponden a esta regla. '
        'El operador y la IA los usan como referencia para clasificar.',
        style: TextStyle(fontSize: 11, color: theme.textSecondary, height: 1.4),
      ),
      const SizedBox(height: 10),

      // Lista reordenable
      if (_items.isNotEmpty)
        Container(
          constraints: const BoxConstraints(maxHeight: 180),
          decoration: BoxDecoration(
            color: theme.background,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: theme.border),
          ),
          child: ReorderableListView.builder(
            shrinkWrap: true,
            buildDefaultDragHandles: false,
            onReorder: _reorder,
            itemCount: _items.length,
            itemBuilder: (_, i) => _CriterioItem(
              key: ValueKey('crit_$i'),
              index: i,
              text: _items[i],
              theme: theme,
              onDelete: () => _removeItem(i),
            ),
          ),
        ),

      if (_items.isNotEmpty) const SizedBox(height: 8),

      // Campo para añadir
      Row(children: [
        Expanded(
          child: TextField(
            controller: _addCtrl,
            focusNode: _addFocus,
            style: const TextStyle(fontSize: 12),
            decoration: InputDecoration(
              hintText: 'Escribe un criterio y presiona +',
              hintStyle: TextStyle(fontSize: 12, color: theme.textDisabled),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              isDense: true,
              fillColor: theme.surface,
              filled: true,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: theme.border)),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: theme.border)),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide:
                      BorderSide(color: theme.primaryColor, width: 1.5)),
            ),
            onSubmitted: (_) => _addItem(),
          ),
        ),
        const SizedBox(width: 8),
        FilledButton(
          onPressed: _addItem,
          style: FilledButton.styleFrom(
            backgroundColor: theme.primaryColor,
            minimumSize: const Size(40, 40),
            padding: EdgeInsets.zero,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: const Icon(Icons.add, size: 18),
        ),
      ]),
    ]);
  }
}

// ──────────────────────── Item ──────────────────────────────────────────────
class _CriterioItem extends StatelessWidget {
  const _CriterioItem({
    super.key,
    required this.index,
    required this.text,
    required this.theme,
    required this.onDelete,
  });
  final int index;
  final String text;
  final AppTheme theme;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: theme.border, width: 0.5)),
      ),
      child: Row(children: [
        // Drag handle
        ReorderableDragStartListener(
          index: index,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
            child: Icon(Icons.drag_handle, size: 16, color: theme.textDisabled),
          ),
        ),
        // Bullet
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: theme.primaryColor.withOpacity(0.6),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        // Text
        Expanded(
          child: Text(
            text,
            style:
                TextStyle(fontSize: 12, color: theme.textPrimary, height: 1.4),
          ),
        ),
        // Delete
        IconButton(
          icon: Icon(Icons.close, size: 14, color: theme.textDisabled),
          padding: const EdgeInsets.all(8),
          constraints: const BoxConstraints(),
          tooltip: 'Eliminar criterio',
          onPressed: onDelete,
        ),
        const SizedBox(width: 4),
      ]),
    );
  }
}
