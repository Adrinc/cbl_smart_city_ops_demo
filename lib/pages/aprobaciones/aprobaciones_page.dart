import 'package:flutter/material.dart';
import 'package:nethive_neo/helpers/formatters.dart';
import 'package:nethive_neo/models/models.dart';
import 'package:nethive_neo/providers/providers.dart';
import 'package:nethive_neo/theme/theme.dart';
import 'package:nethive_neo/widgets/shared/priority_badge.dart';
import 'package:nethive_neo/widgets/shared/section_header.dart';
import 'package:provider/provider.dart';

class AprobacionesPage extends StatelessWidget {
  const AprobacionesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme   = AppTheme.of(context);
    final incProv = context.watch<IncidenciaProvider>();
    final tecProv = context.watch<TecnicoProvider>();
    final pending = incProv.pendientesAprobacion;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            title: 'Aprobaciones Pendientes',
            subtitle: 'Órdenes aprobadas que requieren asignación de técnico antes de iniciar',
            trailing: pending.isNotEmpty
              ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: theme.high.withOpacity(0.15), borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: theme.high.withOpacity(0.3))),
                child: Text('${pending.length} pendientes',
                  style: TextStyle(color: theme.high, fontSize: 12, fontWeight: FontWeight.w700)),
              ) : null,
          ),
          const SizedBox(height: 20),

          if (pending.isEmpty)
            Center(child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 48),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.check_circle_outline, size: 56, color: theme.low),
                const SizedBox(height: 12),
                Text('Sin aprobaciones pendientes', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: theme.textPrimary)),
                const SizedBox(height: 4),
                Text('Todas las órdenes han sido asignadas', style: TextStyle(fontSize: 13, color: theme.textSecondary)),
              ]),
            ))
          else
            ...pending.map((inc) => _AprobacionCard(inc: inc, tecProv: tecProv, incProv: incProv, theme: theme)),
        ],
      ),
    );
  }
}

class _AprobacionCard extends StatelessWidget {
  const _AprobacionCard({required this.inc, required this.tecProv, required this.incProv, required this.theme});
  final Incidencia inc;
  final TecnicoProvider tecProv;
  final IncidenciaProvider incProv;
  final AppTheme theme;

  @override
  Widget build(BuildContext context) {
    final disponibles = tecProv.byEspecialidad(inc.categoria);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.border),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Text(formatIdIncidencia(inc.id), style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: theme.primaryColor)),
          const SizedBox(width: 10),
          PriorityBadge(prioridad: inc.prioridad),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(color: theme.medium.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
            child: Text(labelCategoria(inc.categoria), style: TextStyle(fontSize: 11, color: theme.medium, fontWeight: FontWeight.w600)),
          ),
          const Spacer(),
          Text('SLA: ${formatSla(inc.fechaLimite)}',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
              color: inc.estaVencida ? theme.critical : theme.high)),
        ]),
        const SizedBox(height: 8),
        Text(inc.descripcion, style: TextStyle(fontSize: 13, color: theme.textPrimary)),
        const SizedBox(height: 16),
        Text('Asignar técnico:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: theme.textSecondary)),
        const SizedBox(height: 8),
        if (disponibles.isEmpty)
          Text('No hay técnicos disponibles con la especialidad requerida',
            style: TextStyle(fontSize: 12, color: theme.critical, fontStyle: FontStyle.italic))
        else
          Wrap(spacing: 8, runSpacing: 8, children: disponibles.map((t) => _TecnicoChip(
            tecnico: t, theme: theme,
            onAsignar: () {
              incProv.asignarTecnico(inc.id, t.id);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text('${t.nombre} asignado a ${formatIdIncidencia(inc.id)}'),
                backgroundColor: theme.low));
            },
          )).toList()),
      ]),
    );
  }
}

class _TecnicoChip extends StatelessWidget {
  const _TecnicoChip({required this.tecnico, required this.theme, required this.onAsignar});
  final Tecnico tecnico;
  final AppTheme theme;
  final VoidCallback onAsignar;

  @override
  Widget build(BuildContext context) {
    final isEnCampo = tecnico.estatus == 'en_campo';
    return InkWell(
      onTap: onAsignar,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: theme.low.withOpacity(0.08),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: theme.low.withOpacity(0.3)),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          CircleAvatar(
            radius: 14,
            backgroundColor: theme.primaryColor.withOpacity(0.12),
            backgroundImage: tecnico.avatarPath != null ? AssetImage(tecnico.avatarPath!) : null,
            child: tecnico.avatarPath == null
              ? Text(tecnico.iniciales, style: TextStyle(fontSize: 9, color: theme.primaryColor, fontWeight: FontWeight.w700))
              : null,
          ),
          const SizedBox(width: 8),
          Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
            Text(tecnico.nombre, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: theme.textPrimary)),
            Text(isEnCampo ? 'En campo · ${tecnico.incidenciasActivas} activas' : 'Disponible',
              style: TextStyle(fontSize: 10, color: isEnCampo ? theme.high : theme.low)),
          ]),
          const SizedBox(width: 8),
          Icon(Icons.add_task, size: 16, color: theme.low),
        ]),
      ),
    );
  }
}
