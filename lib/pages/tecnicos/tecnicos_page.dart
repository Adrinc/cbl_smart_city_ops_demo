import 'package:flutter/material.dart';
import 'package:nethive_neo/helpers/formatters.dart';
import 'package:nethive_neo/models/models.dart';
import 'package:nethive_neo/providers/providers.dart';
import 'package:nethive_neo/theme/theme.dart';
import 'package:nethive_neo/widgets/shared/section_header.dart';
import 'package:provider/provider.dart';

class TecnicosPage extends StatefulWidget {
  const TecnicosPage({super.key});
  @override
  State<TecnicosPage> createState() => _TecnicosPageState();
}

class _TecnicosPageState extends State<TecnicosPage> {
  String? _filterEstatus;
  String? _filterEspecialidad;

  @override
  Widget build(BuildContext context) {
    final theme  = AppTheme.of(context);
    final prov   = context.watch<TecnicoProvider>();
    var tecs = prov.todos;
    if (_filterEstatus     != null) tecs = tecs.where((t) => t.estatus     == _filterEstatus).toList();
    if (_filterEspecialidad != null) tecs = tecs.where((t) => t.especialidad == _filterEspecialidad).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            title: 'Técnicos y Cuadrillas — Ensenada',
            subtitle: '${prov.todos.length} en plantilla · ${prov.activos.length} activos · ${prov.enCampo.length} en campo',
          ),
          const SizedBox(height: 12),

          // KPI mini row
          Row(children: [
            _StatCard(value: '${prov.activos.length}',   label: 'Activos',    color: theme.low,    theme: theme),
            const SizedBox(width: 12),
            _StatCard(value: '${prov.enCampo.length}',   label: 'En Campo',   color: theme.medium, theme: theme),
            const SizedBox(width: 12),
            _StatCard(value: '${prov.todos.fold(0, (s, t) => s + t.incidenciasActivas)}',
              label: 'Asignadas', color: theme.high, theme: theme),
            const SizedBox(width: 12),
            _StatCard(value: '${prov.todos.fold(0, (s, t) => s + t.incidenciasCerradasMes)}',
              label: 'Cerradas/Mes', color: theme.primaryColor, theme: theme),
          ]),
          const SizedBox(height: 16),

          // Filters
          Wrap(spacing: 8, children: [
            for (final est in ['activo','en_campo','inactivo','descanso'])
              ChoiceChip(
                label: Text(labelEstatusTecnico(est), style: const TextStyle(fontSize: 12)),
                selected: _filterEstatus == est,
                onSelected: (sel) => setState(() => _filterEstatus = sel ? est : null),
                selectedColor: theme.primaryColor,
                labelStyle: TextStyle(color: _filterEstatus == est ? Colors.white : null),
                side: BorderSide(color: theme.border),
              ),
            const SizedBox.shrink(),
            for (final esp in ['alumbrado','bacheo','basura','agua_drenaje','general'])
              ChoiceChip(
                label: Text(labelCategoria(esp == 'general' ? 'general' : esp), style: const TextStyle(fontSize: 12)),
                selected: _filterEspecialidad == esp,
                onSelected: (sel) => setState(() => _filterEspecialidad = sel ? esp : null),
                selectedColor: theme.medium,
                labelStyle: TextStyle(color: _filterEspecialidad == esp ? Colors.white : null),
                side: BorderSide(color: theme.border),
              ),
            if (_filterEstatus != null || _filterEspecialidad != null)
              ActionChip(
                label: const Text('Limpiar'),
                avatar: const Icon(Icons.clear, size: 14),
                onPressed: () => setState(() { _filterEstatus = null; _filterEspecialidad = null; }),
                backgroundColor: theme.critical.withOpacity(0.1),
                labelStyle: TextStyle(fontSize: 12, color: theme.critical),
              ),
          ]),
          const SizedBox(height: 16),

          // Grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3, crossAxisSpacing: 16, mainAxisSpacing: 16, childAspectRatio: 1.6),
            itemCount: tecs.length,
            itemBuilder: (_, i) => _TecnicoCard(tecnico: tecs[i], theme: theme),
          ),
          if (tecs.isEmpty)
            Center(child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: Text('Sin técnicos para el filtro aplicado',
                style: TextStyle(color: theme.textSecondary, fontSize: 14)),
            )),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.value, required this.label, required this.color, required this.theme});
  final String value, label;
  final Color color;
  final AppTheme theme;
  @override
  Widget build(BuildContext context) {
    return Expanded(child: Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(children: [
        Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: color)),
        const SizedBox(width: 8),
        Text(label, style: TextStyle(fontSize: 12, color: theme.textSecondary)),
      ]),
    ));
  }
}

class _TecnicoCard extends StatelessWidget {
  const _TecnicoCard({required this.tecnico, required this.theme});
  final Tecnico tecnico;
  final AppTheme theme;

  Color _statusColor(String s) {
    switch (s) {
      case 'en_campo': return theme.low;
      case 'activo':   return theme.medium;
      case 'inactivo': return theme.neutral;
      case 'descanso': return theme.high;
      default:         return theme.neutral;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(tecnico.estatus);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.border),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Row(children: [
        Stack(children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: theme.primaryColor.withOpacity(0.12),
            backgroundImage: tecnico.avatarPath != null ? AssetImage(tecnico.avatarPath!) : null,
            child: tecnico.avatarPath == null
              ? Text(tecnico.iniciales, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: theme.primaryColor))
              : null,
          ),
          Positioned(bottom: 0, right: 0, child: Container(
            width: 12, height: 12,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)),
          )),
        ]),
        const SizedBox(width: 12),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(tecnico.nombre, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: theme.textPrimary),
              overflow: TextOverflow.ellipsis),
            Text(labelRolTecnico(tecnico.rol), style: TextStyle(fontSize: 11, color: theme.textSecondary)),
            const SizedBox(height: 4),
            Row(children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
                child: Text(labelEstatusTecnico(tecnico.estatus),
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: color)),
              ),
              const Spacer(),
              Icon(Icons.assignment_outlined, size: 12, color: theme.textSecondary),
              const SizedBox(width: 2),
              Text('${tecnico.incidenciasActivas}', style: TextStyle(fontSize: 11, color: theme.textSecondary, fontWeight: FontWeight.w600)),
            ]),
          ],
        )),
      ]),
    );
  }
}
