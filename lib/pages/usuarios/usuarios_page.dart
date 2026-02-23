import 'package:flutter/material.dart';
import 'package:nethive_neo/data/mock_data.dart';
import 'package:nethive_neo/helpers/formatters.dart';
import 'package:nethive_neo/models/models.dart';
import 'package:nethive_neo/theme/theme.dart';
import 'package:nethive_neo/widgets/shared/section_header.dart';

class UsuariosPage extends StatelessWidget {
  const UsuariosPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final List<UsuarioSistema> users = mockUsuarios;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SectionHeader(
          title: 'Usuarios del Sistema',
          subtitle: '${users.length} usuarios registrados',
          trailing: FilledButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.person_add, size: 16),
            label: const Text('Nuevo Usuario'),
            style: FilledButton.styleFrom(backgroundColor: theme.primaryColor),
          ),
        ),
        const SizedBox(height: 20),
        Expanded(child: Container(
          decoration: BoxDecoration(
            color: theme.surface, borderRadius: BorderRadius.circular(12),
            border: Border.all(color: theme.border),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)]),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SingleChildScrollView(
              child: DataTable(
                headingRowColor: WidgetStatePropertyAll(theme.border.withOpacity(0.3)),
                headingTextStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: theme.textSecondary),
                dataTextStyle: TextStyle(fontSize: 12, color: theme.textPrimary),
                columnSpacing: 20,
                columns: const [
                  DataColumn(label: Text('Usuario')),
                  DataColumn(label: Text('Email')),
                  DataColumn(label: Text('Rol')),
                  DataColumn(label: Text('Nivel')),
                  DataColumn(label: Text('Estatus')),
                  DataColumn(label: Text('Último acceso')),
                  DataColumn(label: Text('Acciones')),
                ],
                rows: users.map((u) {
                  final isActive = u.estatus == 'activo';
                  return DataRow(cells: [
                    DataCell(Row(children: [
                      CircleAvatar(
                        radius: 14,
                        backgroundColor: theme.primaryColor.withOpacity(0.12),
                        backgroundImage: u.avatarPath != null ? AssetImage(u.avatarPath!) : null,
                        child: u.avatarPath == null
                          ? Text(u.iniciales, style: TextStyle(fontSize: 9, color: theme.primaryColor, fontWeight: FontWeight.w700))
                          : null,
                      ),
                      const SizedBox(width: 8),
                      Text(u.nombre, style: const TextStyle(fontWeight: FontWeight.w600)),
                    ])),
                    DataCell(Text(u.email)),
                    DataCell(Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(color: theme.primarySoft, borderRadius: BorderRadius.circular(6)),
                      child: Text(u.rol.replaceAll('_', ' '), style: TextStyle(fontSize: 11, color: theme.primaryColor, fontWeight: FontWeight.w600)))),
                    DataCell(Text(_capitalizar(u.nivel))),
                    DataCell(Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: isActive ? theme.low.withOpacity(0.12) : theme.neutral.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(6)),
                      child: Text(isActive ? 'Activo' : 'Inactivo',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: isActive ? theme.low : theme.neutral)))),
                    DataCell(Text(formatFechaHora(u.ultimoAcceso))),
                    DataCell(Row(children: [
                      IconButton(icon: Icon(Icons.edit_outlined, size: 16, color: theme.textSecondary), onPressed: () {}, tooltip: 'Editar'),
                      IconButton(icon: Icon(isActive ? Icons.block : Icons.check_circle_outline, size: 16,
                        color: isActive ? theme.high : theme.low), onPressed: () {}, tooltip: isActive ? 'Desactivar' : 'Activar'),
                    ])),
                  ]);
                }).toList(),
              ),
            ),
          ),
        )),
      ]),
    );
  }

  String _capitalizar(String s) => s.isEmpty ? s : '${s[0].toUpperCase()}${s.substring(1)}';
}
