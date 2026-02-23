import 'package:flutter/material.dart';
import 'package:nethive_neo/data/mock_data.dart';
import 'package:nethive_neo/helpers/formatters.dart';
import 'package:nethive_neo/models/models.dart';
import 'package:nethive_neo/theme/theme.dart';
import 'package:nethive_neo/widgets/shared/section_header.dart';

class AuditoriaPage extends StatefulWidget {
  const AuditoriaPage({super.key});
  @override
  State<AuditoriaPage> createState() => _AuditoriaPageState();
}

class _AuditoriaPageState extends State<AuditoriaPage> {
  String? _filterModulo;
  String? _filterNivel;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    List<EventoAuditoria> events = List.from(mockAuditoria);
    if (_filterModulo != null) events = events.where((e) => e.modulo == _filterModulo).toList();
    if (_filterNivel  != null) events = events.where((e) => e.nivel  == _filterNivel).toList();

    final modulos = mockAuditoria.map((e) => e.modulo).toSet().toList()..sort();
    const niveles = ['nacional', 'estatal', 'municipal'];

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SectionHeader(
          title: 'Log de Auditoría',
          subtitle: '${mockAuditoria.length} eventos registrados',
        ),
        const SizedBox(height: 12),
        Row(children: [
          DropdownButtonHideUnderline(child: DropdownButton<String?>(
            value: _filterModulo,
            hint: Text('Módulo', style: TextStyle(fontSize: 13, color: theme.textSecondary)),
            items: [
              const DropdownMenuItem(value: null, child: Text('Todos los módulos')),
              ...modulos.map((m) => DropdownMenuItem(value: m, child: Text(m))),
            ],
            onChanged: (v) => setState(() => _filterModulo = v),
            borderRadius: BorderRadius.circular(8),
          )),
          const SizedBox(width: 12),
          DropdownButtonHideUnderline(child: DropdownButton<String?>(
            value: _filterNivel,
            hint: Text('Nivel', style: TextStyle(fontSize: 13, color: theme.textSecondary)),
            items: [
              const DropdownMenuItem(value: null, child: Text('Todos los niveles')),
              ...niveles.map((n) => DropdownMenuItem(value: n, child: Text(_cap(n)))),
            ],
            onChanged: (v) => setState(() => _filterNivel = v),
            borderRadius: BorderRadius.circular(8),
          )),
          const Spacer(),
          Text('${events.length} resultados', style: TextStyle(fontSize: 12, color: theme.textSecondary)),
        ]),
        const SizedBox(height: 16),
        Expanded(child: Container(
          decoration: BoxDecoration(
            color: theme.surface, borderRadius: BorderRadius.circular(12),
            border: Border.all(color: theme.border),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)]),
          child: ListView.separated(
            itemCount: events.length,
            separatorBuilder: (_, __) => Divider(height: 0, color: theme.border.withOpacity(0.5)),
            itemBuilder: (_, i) {
              final e = events[i];
              const nivelColors = {
                'nacional': Color(0xFF7A1E3A), 'estatal': Color(0xFF1D4ED8), 'municipal': Color(0xFF2D7A4F),
              };
              final nivelColor = nivelColors[e.nivel] ?? const Color(0xFF64748B);
              return ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                leading: Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(color: nivelColor.withOpacity(0.12), borderRadius: BorderRadius.circular(8)),
                  child: Icon(_moduloIcon(e.modulo), size: 18, color: nivelColor)),
                title: Row(children: [
                  Expanded(child: Text('${e.accion} — ${e.modulo}',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: theme.textPrimary))),
                  Text(formatFechaHora(e.timestamp), style: TextStyle(fontSize: 11, color: theme.textSecondary)),
                ]),
                subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const SizedBox(height: 4),
                  Row(children: [
                    _Badge(text: _cap(e.nivel), color: nivelColor),
                    const SizedBox(width: 6),
                    _Badge(text: e.usuario, color: theme.neutral),
                  ]),
                  const SizedBox(height: 2),
                  Text(e.descripcion,
                    style: TextStyle(fontSize: 12, color: theme.textSecondary), overflow: TextOverflow.ellipsis),
                ]),
              );
            },
          ),
        )),
      ]),
    );
  }

  String _cap(String s) => s.isEmpty ? s : '${s[0].toUpperCase()}${s.substring(1)}';

  IconData _moduloIcon(String m) {
    const icons = <String, IconData>{
      'Bandeja IA':    Icons.smart_toy_outlined,
      'Técnicos':      Icons.engineering,
      'Aprobaciones':  Icons.approval,
      'Inventario':    Icons.inventory_2_outlined,
      'Configuración': Icons.settings_outlined,
      'Usuarios':      Icons.people_outline,
      'Reportes':      Icons.bar_chart,
      'Órdenes':       Icons.assignment_outlined,
      'SLA':           Icons.timer_outlined,
      'KPIs':          Icons.dashboard_outlined,
      'Supervisión':   Icons.monitor_heart_outlined,
      'Catálogos':     Icons.category_outlined,
    };
    return icons[m] ?? Icons.history;
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.text, required this.color});
  final String text; final Color color;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
    decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
    child: Text(text, style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w600)));
}
