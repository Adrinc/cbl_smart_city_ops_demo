import 'package:flutter/material.dart';
import 'package:nethive_neo/helpers/formatters.dart';
import 'package:nethive_neo/models/models.dart';
import 'package:nethive_neo/pages/ordenes/widgets/asignar_tecnico_dialog.dart';
import 'package:nethive_neo/providers/providers.dart';
import 'package:nethive_neo/theme/theme.dart';
import 'package:provider/provider.dart';

/// Chip inline para la columna "Técnico" del PlutoGrid de Órdenes.
/// Si hay técnico asignado → chip clickeable que abre el dialog de detalle.
/// Si no hay técnico → botón "Asignar".
class TecnicoChipDetalle extends StatelessWidget {
  const TecnicoChipDetalle({
    super.key,
    required this.incId,
    required this.theme,
  });

  final String incId;
  final AppTheme theme;

  @override
  Widget build(BuildContext context) {
    final tecProv = context.watch<TecnicoProvider>();
    final incProv = context.watch<IncidenciaProvider>();
    final inc = incProv.byId(incId);
    if (inc == null) return const SizedBox();

    if (inc.tecnicoId != null) {
      final tec = tecProv.byId(inc.tecnicoId!);
      final nombre = tec?.nombre ?? inc.tecnicoId!;
      final estatus = tec?.estatus ?? '';
      return GestureDetector(
        onTap: () {
          if (tec == null) return;
          _showDetalle(context, tec, inc, tecProv);
        },
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          _AvatarMin(tecnico: tec, size: 22, theme: theme),
          const SizedBox(width: 6),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  nombre,
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: theme.primaryColor,
                      decoration: TextDecoration.underline),
                  overflow: TextOverflow.ellipsis,
                ),
                if (estatus.isNotEmpty)
                  Text(
                    labelEstatusT(estatus),
                    style: TextStyle(
                        fontSize: 10, color: _estatusColor(estatus, theme)),
                  ),
              ],
            ),
          ),
        ]),
      );
    }

    // Sin técnico
    const canAssignStatuses = {
      'aprobado',
      'asignado',
      'recibido',
      'en_revision'
    };
    if (!canAssignStatuses.contains(inc.estatus)) {
      return Text('—',
          style: TextStyle(fontSize: 12, color: theme.textDisabled));
    }

    return GestureDetector(
      onTap: () => AsignarTecnicoDialog.show(context, inc),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: theme.primaryColor.withOpacity(0.10),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: theme.primaryColor.withOpacity(0.35)),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.person_add_outlined, size: 12, color: theme.primaryColor),
          const SizedBox(width: 4),
          Text('Asignar',
              style: TextStyle(
                  fontSize: 11,
                  color: theme.primaryColor,
                  fontWeight: FontWeight.w600)),
        ]),
      ),
    );
  }

  static void _showDetalle(
      BuildContext ctx, Tecnico tec, Incidencia inc, TecnicoProvider tecProv) {
    final theme = AppTheme.of(ctx);
    showDialog(
      context: ctx,
      builder: (_) => _TecnicoDetalleDialog(
        tecnico: tec,
        incidencia: inc,
        theme: theme,
        avatarBytes: tecProv.getAvatarBytes(tec.id),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Dialog de detalle del técnico asignado
// ──────────────────────────────────────────────────────────────────────────────
class _TecnicoDetalleDialog extends StatelessWidget {
  const _TecnicoDetalleDialog({
    required this.tecnico,
    required this.incidencia,
    required this.theme,
    this.avatarBytes,
  });
  final Tecnico tecnico;
  final Incidencia incidencia;
  final AppTheme theme;
  final dynamic avatarBytes; // Uint8List?

  @override
  Widget build(BuildContext context) {
    final estatusColor = _estatusColor(tecnico.estatus, theme);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            // Header con avatar
            Row(children: [
              _AvatarBig(
                  tecnico: tecnico,
                  avatarBytes: avatarBytes,
                  size: 60,
                  theme: theme),
              const SizedBox(width: 14),
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Text(tecnico.nombre,
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: theme.textPrimary)),
                    const SizedBox(height: 2),
                    Text(labelRolTecnico(tecnico.rol),
                        style: TextStyle(
                            fontSize: 12, color: theme.textSecondary)),
                    const SizedBox(height: 5),
                    // Estatus badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 9, vertical: 3),
                      decoration: BoxDecoration(
                        color: estatusColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(6),
                        border:
                            Border.all(color: estatusColor.withOpacity(0.4)),
                      ),
                      child: Text(labelEstatusT(tecnico.estatus).toUpperCase(),
                          style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: estatusColor)),
                    ),
                  ])),
              IconButton(
                  icon: Icon(Icons.close, size: 18, color: theme.textSecondary),
                  onPressed: () => Navigator.pop(context)),
            ]),
            const SizedBox(height: 16),
            Divider(color: theme.border),
            const SizedBox(height: 12),

            // Datos del técnico
            _InfoRow2('ID', tecnico.id, theme),
            _InfoRow2(
                'Especialidad', labelCategoria(tecnico.especialidad), theme),
            _InfoRow2(
                'Municipio', tecnico.municipioAsignado ?? 'Sin asignar', theme),
            _InfoRow2(
                'Incidencias activas', '${tecnico.incidenciasActivas}', theme),
            _InfoRow2('Cerradas este mes', '${tecnico.incidenciasCerradasMes}',
                theme),
            const SizedBox(height: 12),

            // Incidencia asignada
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.primaryColor.withOpacity(0.06),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: theme.primaryColor.withOpacity(0.2)),
              ),
              child: Row(children: [
                Icon(Icons.assignment_outlined,
                    size: 16, color: theme.primaryColor),
                const SizedBox(width: 10),
                Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      Text('Incidencia asignada',
                          style: TextStyle(
                              fontSize: 11,
                              color: theme.textSecondary,
                              fontWeight: FontWeight.w600)),
                      const SizedBox(height: 2),
                      Text(
                        '${formatIdIncidencia(incidencia.id)} · ${labelCategoria(incidencia.categoria)}',
                        style: TextStyle(
                            fontSize: 12,
                            color: theme.textPrimary,
                            fontWeight: FontWeight.w600),
                      ),
                    ])),
              ]),
            ),
            const SizedBox(height: 16),

            // Botón Reasignar
            Row(mainAxisAlignment: MainAxisAlignment.end, children: [
              OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                    foregroundColor: theme.textSecondary,
                    side: BorderSide(color: theme.border)),
                child: const Text('Cerrar'),
              ),
              const SizedBox(width: 8),
              FilledButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  AsignarTecnicoDialog.show(context, incidencia);
                },
                icon: const Icon(Icons.swap_horiz, size: 15),
                label: const Text('Reasignar'),
                style:
                    FilledButton.styleFrom(backgroundColor: theme.primaryColor),
              ),
            ]),
          ]),
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Widgets internos reutilizables
// ──────────────────────────────────────────────────────────────────────────────
class _AvatarMin extends StatelessWidget {
  const _AvatarMin(
      {required this.tecnico, required this.size, required this.theme});
  final Tecnico? tecnico;
  final double size;
  final AppTheme theme;

  @override
  Widget build(BuildContext context) {
    if (tecnico == null) {
      return CircleAvatar(
        radius: size / 2,
        backgroundColor: theme.primaryColor.withOpacity(0.15),
        child: Icon(Icons.person, size: size * 0.55, color: theme.primaryColor),
      );
    }
    final path = tecnico!.avatarPath;
    if (path != null && path.isNotEmpty) {
      return CircleAvatar(
        radius: size / 2,
        backgroundImage: AssetImage(path),
      );
    }
    final initials = tecnico!.nombre.split(' ').take(2).map((w) => w[0]).join();
    return CircleAvatar(
      radius: size / 2,
      backgroundColor: theme.primaryColor.withOpacity(0.15),
      child: Text(initials,
          style: TextStyle(
              fontSize: size * 0.35,
              fontWeight: FontWeight.w700,
              color: theme.primaryColor)),
    );
  }
}

class _AvatarBig extends StatelessWidget {
  const _AvatarBig({
    required this.tecnico,
    required this.size,
    required this.theme,
    this.avatarBytes,
  });
  final Tecnico tecnico;
  final double size;
  final AppTheme theme;
  final dynamic avatarBytes;

  @override
  Widget build(BuildContext context) {
    if (avatarBytes != null) {
      return CircleAvatar(
        radius: size / 2,
        backgroundImage: MemoryImage(avatarBytes),
      );
    }
    final path = tecnico.avatarPath;
    if (path != null && path.isNotEmpty) {
      return CircleAvatar(
        radius: size / 2,
        backgroundImage: AssetImage(path),
      );
    }
    final initials = tecnico.nombre.split(' ').take(2).map((w) => w[0]).join();
    return CircleAvatar(
      radius: size / 2,
      backgroundColor: theme.primaryColor.withOpacity(0.15),
      child: Text(initials,
          style: TextStyle(
              fontSize: size * 0.35,
              fontWeight: FontWeight.w700,
              color: theme.primaryColor)),
    );
  }
}

class _InfoRow2 extends StatelessWidget {
  const _InfoRow2(this.label, this.value, this.theme);
  final String label, value;
  final AppTheme theme;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Row(children: [
        SizedBox(
          width: 130,
          child: Text(label,
              style: TextStyle(fontSize: 12, color: theme.textSecondary)),
        ),
        Expanded(
            child: Text(value,
                style: TextStyle(
                    fontSize: 12,
                    color: theme.textPrimary,
                    fontWeight: FontWeight.w500))),
      ]),
    );
  }
}

Color _estatusColor(String estatus, AppTheme theme) {
  switch (estatus) {
    case 'activo':
      return theme.low;
    case 'en_campo':
      return theme.high;
    case 'descanso':
      return theme.neutral;
    default:
      return theme.critical;
  }
}

String labelEstatusT(String e) {
  const m = {
    'activo': 'Activo',
    'en_campo': 'En campo',
    'descanso': 'Descanso',
    'inactivo': 'Inactivo',
  };
  return m[e] ?? e;
}
