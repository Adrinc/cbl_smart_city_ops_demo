import 'package:flutter/material.dart';
import 'package:nethive_neo/models/models.dart';
import 'package:nethive_neo/providers/providers.dart';
import 'package:nethive_neo/theme/theme.dart';
import 'package:nethive_neo/widgets/shared/section_header.dart';
import 'package:provider/provider.dart';

class InventarioPage extends StatefulWidget {
  const InventarioPage({super.key});
  @override
  State<InventarioPage> createState() => _InventarioPageState();
}

class _InventarioPageState extends State<InventarioPage> {
  String? _filterCategoria;
  String? _filterEstatus;
  String _search = '';

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final prov = context.watch<InventarioProvider>();
    var items = prov.todos;

    if (_filterCategoria != null)
      items = items.where((m) => m.categoria == _filterCategoria).toList();
    if (_filterEstatus != null)
      items = items.where((m) => m.estatus == _filterEstatus).toList();
    if (_search.isNotEmpty)
      items = items
          .where((m) =>
              m.descripcion.toLowerCase().contains(_search.toLowerCase()) ||
              m.clave.toLowerCase().contains(_search.toLowerCase()))
          .toList();

    final cats = prov.todos.map((m) => m.categoria).toSet().toList()..sort();
    final bajoStock = prov.bajoStock;
    final agotados = prov.agotados;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            title: 'Inventario de Materiales',
            subtitle:
                '${prov.todos.length} materiales · ${bajoStock.length} bajo stock · ${agotados.length} agotados',
          ),
          const SizedBox(height: 12),

          // Alert if low stock
          if (bajoStock.isNotEmpty || agotados.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                  color: theme.high.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: theme.high.withOpacity(0.3))),
              child: Row(children: [
                Icon(Icons.inventory_2_outlined, color: theme.high, size: 18),
                const SizedBox(width: 8),
                Text(
                    '${agotados.length} materiales AGOTADOS · ${bajoStock.length} bajo mínimo de stock',
                    style: TextStyle(
                        fontSize: 12,
                        color: theme.high,
                        fontWeight: FontWeight.w600)),
              ]),
            ),

          // Search + Filters
          Row(children: [
            Expanded(
                child: TextField(
              onChanged: (v) => setState(() => _search = v),
              decoration: InputDecoration(
                hintText: 'Buscar por clave o descripción...',
                hintStyle: TextStyle(fontSize: 13, color: theme.textSecondary),
                prefixIcon:
                    Icon(Icons.search, size: 18, color: theme.textSecondary),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: theme.border)),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: theme.border)),
                filled: true,
                fillColor: theme.surface,
              ),
            )),
            const SizedBox(width: 12),
            DropdownButtonHideUnderline(
                child: DropdownButton<String?>(
              value: _filterCategoria,
              hint: Text('Categoría',
                  style: TextStyle(fontSize: 13, color: theme.textSecondary)),
              items: [
                DropdownMenuItem(
                    value: null, child: const Text('Todas las categorías')),
                ...cats.map((c) =>
                    DropdownMenuItem(value: c, child: Text(_catLabel(c)))),
              ],
              onChanged: (v) => setState(() => _filterCategoria = v),
              borderRadius: BorderRadius.circular(8),
            )),
            const SizedBox(width: 12),
            DropdownButtonHideUnderline(
                child: DropdownButton<String?>(
              value: _filterEstatus,
              hint: Text('Estatus',
                  style: TextStyle(fontSize: 13, color: theme.textSecondary)),
              items: const [
                DropdownMenuItem(value: null, child: Text('Todos')),
                DropdownMenuItem(
                    value: 'disponible', child: Text('Disponible')),
                DropdownMenuItem(
                    value: 'bajo_stock', child: Text('Bajo Stock')),
                DropdownMenuItem(value: 'agotado', child: Text('Agotado')),
              ],
              onChanged: (v) => setState(() => _filterEstatus = v),
              borderRadius: BorderRadius.circular(8),
            )),
          ]),
          const SizedBox(height: 16),

          // Table
          Expanded(
              child: Container(
            decoration: BoxDecoration(
              color: theme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: theme.border),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SingleChildScrollView(
                child: DataTable(
                  headingRowColor:
                      WidgetStatePropertyAll(theme.border.withOpacity(0.3)),
                  headingTextStyle: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: theme.textSecondary),
                  dataTextStyle:
                      TextStyle(fontSize: 12, color: theme.textPrimary),
                  columnSpacing: 24,
                  columns: const [
                    DataColumn(label: Text('Clave')),
                    DataColumn(label: Text('Descripción')),
                    DataColumn(label: Text('Categoría')),
                    DataColumn(label: Text('Unidad')),
                    DataColumn(label: Text('Stock'), numeric: true),
                    DataColumn(label: Text('Mínimo'), numeric: true),
                    DataColumn(label: Text('Reservado'), numeric: true),
                    DataColumn(label: Text('Estatus')),
                  ],
                  rows: items.map((m) {
                    final statusColor = m.estatus == 'agotado'
                        ? theme.critical
                        : m.estatus == 'bajo_stock'
                            ? theme.high
                            : theme.low;
                    return DataRow(cells: [
                      DataCell(Text(m.clave,
                          style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: theme.primaryColor))),
                      DataCell(SizedBox(
                          width: 200,
                          child: Text(m.descripcion,
                              overflow: TextOverflow.ellipsis))),
                      DataCell(Text(_catLabel(m.categoria))),
                      DataCell(Text(m.unidad)),
                      DataCell(Text('${m.stockActual}',
                          style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: m.stockActual <= m.stockMinimo
                                  ? theme.critical
                                  : theme.textPrimary))),
                      DataCell(Text('${m.stockMinimo}')),
                      DataCell(Text('${m.reservado}')),
                      DataCell(Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(6)),
                        child: Text(
                            m.estatus == 'bajo_stock'
                                ? 'Bajo Stock'
                                : m.estatus == 'agotado'
                                    ? 'Agotado'
                                    : 'OK',
                            style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: statusColor)),
                      )),
                    ]);
                  }).toList(),
                ),
              ),
            ),
          )),
        ],
      ),
    );
  }

  String _catLabel(String c) {
    const m = {
      'electrico': 'Eléctrico',
      'pavimento': 'Pavimento',
      'senales': 'Señales',
      'saneamiento': 'Saneamiento',
      'herramientas': 'Herramientas',
      'general': 'General'
    };
    return m[c] ?? c;
  }
}
