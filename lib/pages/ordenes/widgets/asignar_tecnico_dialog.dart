import 'package:flutter/material.dart';
import 'package:nethive_neo/helpers/formatters.dart';
import 'package:nethive_neo/models/models.dart';
import 'package:nethive_neo/providers/providers.dart';
import 'package:nethive_neo/theme/theme.dart';
import 'package:provider/provider.dart';

class AsignarTecnicoDialog extends StatefulWidget {
  const AsignarTecnicoDialog({super.key, required this.incidencia});
  final Incidencia incidencia;

  static Future<void> show(BuildContext context, Incidencia inc) {
    return showDialog(
      context: context,
      builder: (_) => AsignarTecnicoDialog(incidencia: inc),
    );
  }

  @override
  State<AsignarTecnicoDialog> createState() => _AsignarTecnicoDialogState();
}

class _AsignarTecnicoDialogState extends State<AsignarTecnicoDialog> {
  String? _selectedId;
  String _filtroEsp = 'todos';

  // Mapeo categoría → especialidad
  static const _catToEsp = <String, String>{
    'alumbrado': 'alumbrado',
    'bacheo': 'bacheo',
    'basura': 'basura',
    'agua_drenaje': 'agua_drenaje',
    'señalizacion': 'general',
    'senalizacion': 'general',
    'seguridad': 'general',
  };

  @override
  void initState() {
    super.initState();
    // Pre-seleccionar filtro por especialidad según categoría
    _filtroEsp = _catToEsp[widget.incidencia.categoria] ?? 'todos';
  }

  List<Tecnico> _getDisponibles(TecnicoProvider prov) {
    var lista = prov.todos
        .where((t) => t.estatus == 'activo' || t.estatus == 'en_campo')
        .toList();
    if (_filtroEsp != 'todos') {
      lista = lista
          .where((t) =>
              t.especialidad == _filtroEsp || t.especialidad == 'general')
          .toList();
    }
    lista.sort((a, b) => a.incidenciasActivas.compareTo(b.incidenciasActivas));
    return lista;
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final tecProv = context.watch<TecnicoProvider>();
    final disponibles = _getDisponibles(tecProv);
    final inc = widget.incidencia;
    final espSugerida = _catToEsp[inc.categoria] ?? 'general';

    const especialidades = [
      'todos',
      'alumbrado',
      'bacheo',
      'basura',
      'agua_drenaje',
      'general'
    ];

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520, maxHeight: 640),
        child: Column(children: [
          // ── Header ────────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.fromLTRB(20, 18, 14, 14),
            decoration: BoxDecoration(
              color: const Color(0xFF7A1E3A).withOpacity(0.06),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(children: [
              Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                      color: const Color(0xFF7A1E3A).withOpacity(0.12),
                      shape: BoxShape.circle),
                  child: const Icon(Icons.person_add_outlined,
                      color: Color(0xFF7A1E3A), size: 18)),
              const SizedBox(width: 12),
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Text('Asignar Técnico',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: theme.textPrimary)),
                    Text(
                        '${formatIdIncidencia(inc.id)} · ${labelCategoria(inc.categoria)}',
                        style: TextStyle(
                            fontSize: 12, color: theme.textSecondary)),
                  ])),
              IconButton(
                  icon: Icon(Icons.close, size: 18, color: theme.textSecondary),
                  onPressed: () => Navigator.pop(context)),
            ]),
          ),

          // ── Filtro especialidad ────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Filtrar por especialidad',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: theme.textSecondary)),
              const SizedBox(height: 6),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                    children: especialidades.map((esp) {
                  final sel = _filtroEsp == esp;
                  final suggested = esp == espSugerida;
                  return Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: FilterChip(
                      label: Text(
                          esp == 'todos' ? 'Todos' : labelEspecialidad(esp),
                          style: TextStyle(
                              fontSize: 11,
                              color: sel ? Colors.white : theme.textSecondary,
                              fontWeight:
                                  sel ? FontWeight.w700 : FontWeight.normal)),
                      selected: sel,
                      onSelected: (_) => setState(() => _filtroEsp = esp),
                      selectedColor: const Color(0xFF7A1E3A),
                      backgroundColor: suggested && !sel
                          ? const Color(0xFF7A1E3A).withOpacity(0.08)
                          : theme.background,
                      side: BorderSide(
                          color: suggested
                              ? const Color(0xFF7A1E3A).withOpacity(0.4)
                              : theme.border),
                      showCheckmark: false,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                    ),
                  );
                }).toList()),
              ),
            ]),
          ),
          const SizedBox(height: 8),

          // ── Lista técnicos ────────────────────────────────────────────
          Expanded(
              child: disponibles.isEmpty
                  ? Center(
                      child: Column(mainAxisSize: MainAxisSize.min, children: [
                      Icon(Icons.engineering,
                          size: 40, color: theme.textDisabled),
                      const SizedBox(height: 10),
                      Text('Sin técnicos disponibles\ncon esta especialidad',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: theme.textSecondary, fontSize: 13)),
                    ]))
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      itemCount: disponibles.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 6),
                      itemBuilder: (_, i) {
                        final tec = disponibles[i];
                        final isSelected = _selectedId == tec.id;
                        final bytes = tecProv.getAvatarBytes(tec.id);
                        final hasAvatar = bytes != null ||
                            (tec.avatarPath?.isNotEmpty ?? false);
                        return GestureDetector(
                          onTap: () => setState(
                              () => _selectedId = isSelected ? null : tec.id),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFF7A1E3A).withOpacity(0.08)
                                  : theme.surface,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: isSelected
                                    ? const Color(0xFF7A1E3A)
                                    : theme.border,
                                width: isSelected ? 1.5 : 1,
                              ),
                            ),
                            child: Row(children: [
                              // Avatar
                              CircleAvatar(
                                  radius: 20,
                                  backgroundColor: const Color(0xFF7A1E3A),
                                  backgroundImage: bytes != null
                                      ? MemoryImage(bytes) as ImageProvider
                                      : (tec.avatarPath?.isNotEmpty ?? false)
                                          ? AssetImage(tec.avatarPath!)
                                          : null,
                                  child: hasAvatar
                                      ? null
                                      : Text(_initials(tec.nombre),
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 13,
                                              fontWeight: FontWeight.w700))),
                              const SizedBox(width: 12),
                              // Info
                              Expanded(
                                  child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                    Text(tec.nombre,
                                        style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w700,
                                            color: theme.textPrimary)),
                                    Row(children: [
                                      Text(labelRolTecnico(tec.rol),
                                          style: TextStyle(
                                              fontSize: 11,
                                              color: theme.textSecondary)),
                                      Text(' · ',
                                          style: TextStyle(
                                              color: theme.textDisabled)),
                                      Text(labelEspecialidad(tec.especialidad),
                                          style: TextStyle(
                                              fontSize: 11,
                                              color: theme.textSecondary)),
                                    ]),
                                  ])),
                              const SizedBox(width: 8),
                              // Carga + estatus
                              Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    _EstatusChip(
                                        estatus: tec.estatus, theme: theme),
                                    const SizedBox(height: 4),
                                    Text('${tec.incidenciasActivas} activas',
                                        style: TextStyle(
                                            fontSize: 10,
                                            color: theme.textSecondary,
                                            fontWeight: FontWeight.w600)),
                                  ]),
                              if (isSelected) ...[
                                const SizedBox(width: 8),
                                Icon(Icons.check_circle,
                                    color: const Color(0xFF7A1E3A), size: 20),
                              ],
                            ]),
                          ),
                        );
                      },
                    )),

          // ── Footer ────────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            decoration: BoxDecoration(
                border: Border(top: BorderSide(color: theme.border))),
            child: Row(children: [
              if (_selectedId != null)
                Expanded(
                    child: Text(
                        'Técnico seleccionado: ${disponibles.firstWhere((t) => t.id == _selectedId).nombre}',
                        style:
                            TextStyle(fontSize: 12, color: theme.textSecondary),
                        overflow: TextOverflow.ellipsis)),
              const Spacer(),
              OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                      foregroundColor: theme.textSecondary,
                      side: BorderSide(color: theme.border)),
                  child: const Text('Cancelar')),
              const SizedBox(width: 10),
              FilledButton.icon(
                onPressed:
                    _selectedId == null ? null : () => _confirmar(context),
                icon: const Icon(Icons.check, size: 16),
                label: const Text('Asignar'),
                style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF7A1E3A)),
              ),
            ]),
          ),
        ]),
      ),
    );
  }

  void _confirmar(BuildContext context) {
    final tecId = _selectedId!;
    final incId = widget.incidencia.id;
    final incProv = context.read<IncidenciaProvider>();
    final tecProv = context.read<TecnicoProvider>();
    final audProv = context.read<AuditoriaProvider>();
    final tec = tecProv.byId(tecId);

    incProv.asignarTecnico(incId, tecId);
    tecProv.incrementarActivas(tecId);
    audProv.registrar(
      modulo: 'Órdenes',
      accion: 'ASIGNAR',
      descripcion: 'Asignó técnico ${tec?.nombre ?? tecId} a incidencia '
          '${formatIdIncidencia(incId)} — ${labelCategoria(widget.incidencia.categoria)}',
      referenciaId: incId,
    );

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Técnico ${tec?.nombre ?? tecId} asignado a '
          '${formatIdIncidencia(incId)}'),
      backgroundColor: const Color(0xFF2D7A4F),
    ));
  }

  String _initials(String nombre) {
    final parts = nombre.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return nombre.substring(0, nombre.length.clamp(0, 2)).toUpperCase();
  }
}

class _EstatusChip extends StatelessWidget {
  const _EstatusChip({required this.estatus, required this.theme});
  final String estatus;
  final AppTheme theme;

  @override
  Widget build(BuildContext context) {
    final color = switch (estatus) {
      'activo' => const Color(0xFF2D7A4F),
      'en_campo' => const Color(0xFF1D4ED8),
      'descanso' => const Color(0xFFD97706),
      _ => const Color(0xFF64748B),
    };
    final label = switch (estatus) {
      'activo' => 'Activo',
      'en_campo' => 'En campo',
      'descanso' => 'Descanso',
      _ => 'Inactivo',
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(4)),
      child: Text(label,
          style: TextStyle(
              fontSize: 10, color: color, fontWeight: FontWeight.w700)),
    );
  }
}
