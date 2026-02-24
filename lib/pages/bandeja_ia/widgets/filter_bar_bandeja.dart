import 'package:flutter/material.dart';
import 'package:nethive_neo/helpers/formatters.dart';
import 'package:nethive_neo/theme/theme.dart';

class FilterBarBandeja extends StatelessWidget {
  const FilterBarBandeja({
    super.key,
    required this.search,
    required this.filterCategoria,
    required this.filterVeredicto,
    required this.cats,
    required this.theme,
    required this.onSearch,
    required this.onCategoria,
    required this.onVeredicto,
  });
  final String search, filterVeredicto;
  final String? filterCategoria;
  final List<String> cats;
  final AppTheme theme;
  final ValueChanged<String> onSearch;
  final ValueChanged<String?> onCategoria, onVeredicto;

  @override
  Widget build(BuildContext context) {
    return Wrap(spacing: 10, runSpacing: 8, crossAxisAlignment: WrapCrossAlignment.center, children: [
      SizedBox(width: 200, child: TextField(
        onChanged: onSearch,
        decoration: InputDecoration(
          hintText: 'Buscar ID o descripción…',
          hintStyle: TextStyle(fontSize: 12, color: theme.textSecondary),
          prefixIcon: Icon(Icons.search, size: 16, color: theme.textSecondary),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: theme.border)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: theme.border)),
          filled: true, fillColor: theme.surface,
        ),
      )),
      DropdownButtonHideUnderline(child: DropdownButton<String>(
        value: filterVeredicto,
        items: const [
          DropdownMenuItem(value: 'todos',               child: Text('Todos los veredictos')),
          DropdownMenuItem(value: 'recomienda_aprobar',  child: Text('IA: Recomienda Aprobar')),
          DropdownMenuItem(value: 'recomienda_rechazar', child: Text('IA: Recomienda Rechazar')),
        ],
        onChanged: onVeredicto, borderRadius: BorderRadius.circular(8),
      )),
      DropdownButtonHideUnderline(child: DropdownButton<String?>(
        value: filterCategoria,
        hint: Text('Todas las categorías', style: TextStyle(fontSize: 12, color: theme.textSecondary)),
        items: [
          const DropdownMenuItem<String?>(value: null, child: Text('Todas las categorías')),
          ...cats.map((c) => DropdownMenuItem<String?>(value: c, child: Text(labelCategoria(c)))),
        ],
        onChanged: onCategoria, borderRadius: BorderRadius.circular(8),
      )),
    ]);
  }
}