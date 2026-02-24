import 'package:flutter/material.dart';
import 'package:nethive_neo/helpers/formatters.dart';
import 'package:nethive_neo/models/models.dart';
import 'package:nethive_neo/providers/providers.dart';
import 'package:nethive_neo/theme/theme.dart';
import 'package:nethive_neo/widgets/shared/estatus_badge.dart';
import 'package:nethive_neo/widgets/shared/priority_badge.dart';
import 'package:provider/provider.dart';

/// Dialog para asignar una incidencia disponible al técnico indicado.
/// Se invoca desde la pantalla de Técnicos con el icono "Asignar caso".
class AsignarIncidenciaDialog extends StatefulWidget {
  const AsignarIncidenciaDialog({super.key, required this.tecnico});
  final Tecnico tecnico;

  static Future<void> show(BuildContext context, Tecnico tec) {
    return showDialog(
      context: context,
      builder: (_) => AsignarIncidenciaDialog(tecnico: tec),
    );
  }

  @override
  State<AsignarIncidenciaDialog> createState() =>
      _AsignarIncidenciaDialogState();
}

class _AsignarIncidenciaDialogState extends State<AsignarIncidenciaDialog> {
  String? _selectedId;
  String _filtroPrioridad = 'todos';

  static const _catToEsp = <String, String>{
    'alumbrado': 'alumbrado',
    'bacheo': 'bacheo',
    'basura': 'basura',
    'agua_drenaje': 'agua_drenaje',
    'señalizacion': 'general',
    'senalizacion': 'general',
    'seguridad': 'general',
  };

  static const _catIcons = <String, IconData>{
    'alumbrado': Icons.lightbulb_outline,
    'bacheo': Icons.construction,
    'basura': Icons.delete_outline,
    'seguridad': Icons.security,
    'agua_drenaje': Icons.water_drop_outlined,
    'señalizacion': Icons.signpost_outlined,
    'senalizacion': Icons.signpost_outlined,
  };
  static const _prioColors = {
    'critico': Color(0xFFB91C1C),
    'alto': Color(0xFFD97706),
    'medio': Color(0xFF1D4ED8),
    'bajo': Color(0xFF2D7A4F),
  };

  List<Incidencia> _getDisponibles(IncidenciaProvider incProv) {
    final esp = widget.tecnico.especialidad;
    var lista = incProv.todas
        .where((i) => const {'aprobado', 'recibido'}.contains(i.estatus))
        .where((i) => i.tecnicoId == null)
        .toList();

    // Sugerir primero las de la misma especialidad
    if (esp != 'general') {
      final espKey = _catToEsp[esp] ?? esp;
      lista.sort((a, b) {
        final aMatch =
            (_catToEsp[a.categoria] ?? a.categoria) == espKey ? 0 : 1;
        final bMatch =
            (_catToEsp[b.categoria] ?? b.categoria) == espKey ? 0 : 1;
        return aMatch.compareTo(bMatch);
      });
    }

    if (_filtroPrioridad != 'todos') {
      lista = lista.where((i) => i.prioridad == _filtroPrioridad).toList();
    }
    return lista;
  }

  void _confirmar(BuildContext ctx) {
    if (_selectedId == null) return;
    final incProv = ctx.read<IncidenciaProvider>();
    final tecProv = ctx.read<TecnicoProvider>();
    final aud = ctx.read<AuditoriaProvider>();
    final inc = incProv.byId(_selectedId!);
    if (inc == null) return;

    incProv.asignarTecnico(_selectedId!, widget.tecnico.id);
    tecProv.incrementarActivas(widget.tecnico.id);
    aud.registrar(
      modulo: 'Técnicos',
      accion: 'ASIGNAR',
      descripcion:
          'Asignó ${widget.tecnico.nombre} a incidencia ${formatIdIncidencia(_selectedId!)} '
          '· ${labelCategoria(inc.categoria)} (${inc.prioridad})',
      referenciaId: _selectedId,
    );
    Navigator.pop(ctx);
    ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
      content: Text(
          '${widget.tecnico.nombre} asignado a ${formatIdIncidencia(_selectedId!)}'),
      backgroundColor: const Color(0xFF2D7A4F),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final incProv = context.watch<IncidenciaProvider>();
    final disponibles = _getDisponibles(incProv);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560, maxHeight: 640),
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
                    color: theme.primaryColor.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.assignment_ind_outlined,
                      color: theme.primaryColor, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Asignar Caso a ${widget.tecnico.nombre}',
                            style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: theme.textPrimary)),
                        Text(
                            '${labelRolTecnico(widget.tecnico.rol)} · '
                            'Esp: ${labelCategoria(widget.tecnico.especialidad)} · '
                            '${widget.tecnico.incidenciasActivas} activos',
                            style: TextStyle(
                                fontSize: 11, color: theme.textSecondary)),
                      ]),
                ),
                IconButton(
                    icon:
                        Icon(Icons.close, size: 18, color: theme.textSecondary),
                    onPressed: () => Navigator.pop(context)),
              ]),
              const SizedBox(height: 14),
              Divider(color: theme.border),
              const SizedBox(height: 10),

              // Filtro por prioridad
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(children: [
                  Text('Prioridad:',
                      style:
                          TextStyle(fontSize: 11, color: theme.textSecondary)),
                  const SizedBox(width: 8),
                  for (final p in ['todos', 'critico', 'alto', 'medio', 'bajo'])
                    Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: ChoiceChip(
                        label: Text(
                            p == 'todos'
                                ? 'Todos'
                                : p[0].toUpperCase() + p.substring(1),
                            style: TextStyle(fontSize: 11)),
                        selected: _filtroPrioridad == p,
                        onSelected: (_) => setState(() => _filtroPrioridad = p),
                        selectedColor: p == 'todos'
                            ? theme.primaryColor
                            : (_prioColors[p] ?? theme.primaryColor),
                        labelStyle: TextStyle(
                            color: _filtroPrioridad == p
                                ? Colors.white
                                : theme.textSecondary),
                        side: BorderSide(color: theme.border),
                        showCheckmark: false,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 0),
                      ),
                    ),
                ]),
              ),
              const SizedBox(height: 10),

              // Contador
              Text(
                '${disponibles.length} incidencias sin asignar',
                style: TextStyle(fontSize: 11, color: theme.textSecondary),
              ),
              const SizedBox(height: 8),

              // Lista
              Expanded(
                child: disponibles.isEmpty
                    ? Center(
                        child:
                            Column(mainAxisSize: MainAxisSize.min, children: [
                          Icon(Icons.check_circle_outline,
                              size: 40, color: theme.low),
                          const SizedBox(height: 10),
                          Text('Sin incidencias disponibles',
                              style: TextStyle(
                                  fontSize: 13, color: theme.textSecondary)),
                        ]),
                      )
                    : ListView.separated(
                        itemCount: disponibles.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 6),
                        itemBuilder: (_, i) {
                          final inc = disponibles[i];
                          final selected = _selectedId == inc.id;
                          final prioColor =
                              _prioColors[inc.prioridad] ?? theme.neutral;
                          final isEspMatch =
                              widget.tecnico.especialidad == 'general' ||
                                  (_catToEsp[inc.categoria] ?? inc.categoria) ==
                                      widget.tecnico.especialidad;

                          return GestureDetector(
                            onTap: () => setState(() => _selectedId = inc.id),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 140),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: selected
                                    ? theme.primaryColor.withOpacity(0.08)
                                    : theme.surface,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                    color: selected
                                        ? theme.primaryColor
                                        : theme.border,
                                    width: selected ? 1.5 : 1),
                              ),
                              child: Row(children: [
                                // Icono categoría
                                Container(
                                  padding: const EdgeInsets.all(7),
                                  decoration: BoxDecoration(
                                      color: prioColor.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8)),
                                  child: Icon(
                                      _catIcons[inc.categoria] ??
                                          Icons.report_outlined,
                                      size: 16,
                                      color: prioColor),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(children: [
                                          Text(
                                            formatIdIncidencia(inc.id),
                                            style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w700,
                                                color: theme.primaryColor),
                                          ),
                                          const SizedBox(width: 8),
                                          PriorityBadge(
                                              prioridad: inc.prioridad),
                                          const SizedBox(width: 6),
                                          EstatusBadge(estatus: inc.estatus),
                                          if (isEspMatch) ...[
                                            const SizedBox(width: 6),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 5,
                                                      vertical: 2),
                                              decoration: BoxDecoration(
                                                  color: theme.low
                                                      .withOpacity(0.12),
                                                  borderRadius:
                                                      BorderRadius.circular(4)),
                                              child: Text('Recomendado',
                                                  style: TextStyle(
                                                      fontSize: 9,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      color: theme.low)),
                                            ),
                                          ],
                                        ]),
                                        const SizedBox(height: 3),
                                        Text(
                                          inc.descripcion,
                                          style: TextStyle(
                                              fontSize: 11,
                                              color: theme.textSecondary),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 2),
                                        Row(children: [
                                          Icon(Icons.access_time,
                                              size: 11,
                                              color: theme.textDisabled),
                                          const SizedBox(width: 3),
                                          Text(
                                            'SLA: ${formatSla(inc.fechaLimite)}',
                                            style: TextStyle(
                                                fontSize: 10,
                                                color: inc.fechaLimite !=
                                                            null &&
                                                        inc.fechaLimite!
                                                            .isBefore(
                                                                DateTime.now())
                                                    ? theme.critical
                                                    : theme.textDisabled),
                                          ),
                                        ]),
                                      ]),
                                ),
                                // Radio
                                Radio<String>(
                                  value: inc.id,
                                  groupValue: _selectedId,
                                  onChanged: (v) =>
                                      setState(() => _selectedId = v),
                                  activeColor: theme.primaryColor,
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                              ]),
                            ),
                          );
                        },
                      ),
              ),

              const SizedBox(height: 12),
              Divider(color: theme.border),
              const SizedBox(height: 10),

              // Footer
              Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                      foregroundColor: theme.textSecondary,
                      side: BorderSide(color: theme.border)),
                  child: const Text('Cancelar'),
                ),
                const SizedBox(width: 10),
                FilledButton.icon(
                  onPressed:
                      _selectedId == null ? null : () => _confirmar(context),
                  icon: const Icon(Icons.assignment_ind_outlined, size: 16),
                  label: const Text('Asignar Caso'),
                  style: FilledButton.styleFrom(
                      backgroundColor: theme.primaryColor),
                ),
              ]),
            ],
          ),
        ),
      ),
    );
  }
}
