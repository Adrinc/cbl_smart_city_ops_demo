import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:nethive_neo/helpers/formatters.dart';
import 'package:nethive_neo/models/models.dart';
import 'package:nethive_neo/providers/providers.dart';
import 'package:nethive_neo/theme/theme.dart';
import 'package:nethive_neo/widgets/shared/priority_badge.dart';
import 'package:provider/provider.dart';

class MapaPage extends StatefulWidget {
  const MapaPage({super.key});
  @override
  State<MapaPage> createState() => _MapaPageState();
}

class _MapaPageState extends State<MapaPage> {
  Incidencia? _selected;
  String? _filterPrioridad;
  String? _filterCategoria;
  bool _showTecnicos = false;
  final Set<String> _hoveredIds = {};

  static const Map<String, IconData> _catIcon = {
    'alumbrado': Icons.lightbulb_outline,
    'bacheo': Icons.construction,
    'basura': Icons.delete_outline,
    'agua_drenaje': Icons.water_drop_outlined,
    'senalizacion': Icons.traffic,
    'señalizacion': Icons.traffic,
    'seguridad': Icons.security,
  };

  // Ensenada center
  static const _center = LatLng(31.8667, -116.5963);

  Color _prioColor(String p) {
    switch (p) {
      case 'critico':
        return const Color(0xFFB91C1C);
      case 'alto':
        return const Color(0xFFD97706);
      case 'medio':
        return const Color(0xFF1D4ED8);
      default:
        return const Color(0xFF2D7A4F);
    }
  }

  List<Marker> _buildIncidenciaMarkers(List<Incidencia> incs) {
    const _estadosOperativos = {'aprobado', 'asignado', 'en_proceso'};
    return incs
        .where((i) => _estadosOperativos.contains(i.estatus))
        .where(
            (i) => _filterPrioridad == null || i.prioridad == _filterPrioridad)
        .where(
            (i) => _filterCategoria == null || i.categoria == _filterCategoria)
        .map((i) {
      final color = _prioColor(i.prioridad);
      final isHovered = _hoveredIds.contains(i.id);
      final icon = _catIcon[i.categoria] ?? Icons.report_problem_outlined;
      return Marker(
        point: LatLng(i.latitud, i.longitud),
        width: isHovered ? 44 : 36,
        height: isHovered ? 44 : 36,
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          onEnter: (_) => setState(() => _hoveredIds.add(i.id)),
          onExit: (_) => setState(() => _hoveredIds.remove(i.id)),
          child: GestureDetector(
            onTap: () => setState(() => _selected = i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border:
                    Border.all(color: Colors.white, width: isHovered ? 3 : 2),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(isHovered ? 0.7 : 0.4),
                    blurRadius: isHovered ? 14 : 6,
                    spreadRadius: isHovered ? 2 : 0,
                  )
                ],
              ),
              child: Icon(icon, color: Colors.white, size: isHovered ? 22 : 17),
            ),
          ),
        ),
      );
    }).toList();
  }

  List<Marker> _buildTecnicoMarkers(List<Tecnico> tecs) {
    if (!_showTecnicos) return [];
    return tecs
        .map((t) => Marker(
              point: LatLng(t.latitud, t.longitud),
              width: 30,
              height: 30,
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF7A1E3A),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: const Icon(Icons.engineering,
                    color: Colors.white, size: 14),
              ),
            ))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final incProv = context.watch<IncidenciaProvider>();
    final tecProv = context.watch<TecnicoProvider>();
    final incs = incProv.activas;
    final tecs = tecProv.activos;

    return Stack(
      children: [
        // Mapa principal
        FlutterMap(
          options: MapOptions(
            initialCenter: _center,
            initialZoom: 11,
            onTap: (_, __) => setState(() => _selected = null),
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.cbluna.terranex',
            ),
            MarkerLayer(markers: _buildIncidenciaMarkers(incs)),
            MarkerLayer(markers: _buildTecnicoMarkers(tecs)),
          ],
        ),

        // Barra superior de controles
        Positioned(
          top: 16,
          left: 16,
          right: 16,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            // Fila 1: Prioridad + Técnicos toggle
            Row(children: [
              _MapControl(
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  const Text('Prioridad: ', style: TextStyle(fontSize: 12)),
                  ...[
                    null,
                    'critico',
                    'alto',
                    'medio',
                    'bajo'
                  ].map((p) => Padding(
                        padding: const EdgeInsets.only(left: 4),
                        child: ChoiceChip(
                          label: Text(p == null ? 'Todas' : labelPrioridad(p),
                              style: const TextStyle(fontSize: 11)),
                          selected: _filterPrioridad == p,
                          onSelected: (_) =>
                              setState(() => _filterPrioridad = p),
                          selectedColor:
                              p == null ? theme.primaryColor : _prioColor(p),
                          labelStyle: TextStyle(
                            color: _filterPrioridad == p ? Colors.white : null,
                            fontSize: 11,
                          ),
                          side: BorderSide.none,
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          visualDensity: VisualDensity.compact,
                        ),
                      )),
                ]),
              ),
              const SizedBox(width: 8),
              _MapControl(
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Switch(
                    value: _showTecnicos,
                    onChanged: (v) => setState(() => _showTecnicos = v),
                    activeColor: theme.primaryColor,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  const SizedBox(width: 4),
                  const Text('Técnicos', style: TextStyle(fontSize: 12)),
                ]),
              ),
            ]),
            const SizedBox(height: 8),
            // Fila 2: Categoría
            Row(children: [
              _MapControl(
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  const Text('Categoría: ', style: TextStyle(fontSize: 12)),
                  ...[
                    null,
                    'alumbrado',
                    'bacheo',
                    'basura',
                    'agua_drenaje',
                    'señalizacion',
                    'seguridad',
                  ].map((cat) {
                    final sel = _filterCategoria == cat;
                    return Padding(
                      padding: const EdgeInsets.only(left: 4),
                      child: ChoiceChip(
                        label: Text(
                          cat == null ? 'Todas' : labelCategoria(cat),
                          style: const TextStyle(fontSize: 11),
                        ),
                        selected: sel,
                        onSelected: (_) =>
                            setState(() => _filterCategoria = cat),
                        selectedColor: theme.primaryColor,
                        labelStyle: TextStyle(
                            color: sel ? Colors.white : null, fontSize: 11),
                        avatar: cat != null
                            ? Icon(
                                _catIcon[cat] ?? Icons.report_problem_outlined,
                                size: 12,
                                color: sel ? Colors.white : theme.textSecondary)
                            : null,
                        side: BorderSide.none,
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        visualDensity: VisualDensity.compact,
                      ),
                    );
                  }),
                ]),
              ),
            ]),
          ]),
        ),

        // Leyenda
        Positioned(
          bottom: 16,
          left: 16,
          child: _MapControl(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Leyenda',
                    style:
                        TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                const SizedBox(height: 6),
                ...[
                  ('critico', 'Crítico'),
                  ('alto', 'Alto'),
                  ('medio', 'Medio'),
                  ('bajo', 'Bajo'),
                ].map((e) => Padding(
                      padding: const EdgeInsets.only(bottom: 3),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                                color: _prioColor(e.$1),
                                shape: BoxShape.circle)),
                        const SizedBox(width: 6),
                        Text(e.$2, style: const TextStyle(fontSize: 11)),
                      ]),
                    )),
                if (_showTecnicos) ...[
                  const SizedBox(height: 2),
                  Row(mainAxisSize: MainAxisSize.min, children: [
                    Container(
                        width: 12,
                        height: 12,
                        decoration: const BoxDecoration(
                            color: Color(0xFF7A1E3A), shape: BoxShape.circle)),
                    const SizedBox(width: 6),
                    const Text('Técnico', style: TextStyle(fontSize: 11)),
                  ]),
                ],
              ],
            ),
          ),
        ),

        // Counter badge
        Positioned(
          bottom: 16,
          right: 16,
          child: _MapControl(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Text(
                  '${incs.where((i) => const {
                        'aprobado',
                        'asignado',
                        'en_proceso'
                      }.contains(i.estatus)).length}',
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: theme.primaryColor)),
              const Text('en operación', style: TextStyle(fontSize: 11)),
            ]),
          ),
        ),

        // Panel lateral derecho
        AnimatedPositioned(
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeOutCubic,
          top: 0,
          bottom: 0,
          right: _selected != null ? 0 : -370,
          width: 360,
          child: _selected != null
              ? _MapaSidePanel(
                  inc: _selected!,
                  theme: theme,
                  tecProv: tecProv,
                  onClose: () => setState(() => _selected = null))
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}

class _MapaSidePanel extends StatelessWidget {
  const _MapaSidePanel({
    required this.inc,
    required this.theme,
    required this.tecProv,
    required this.onClose,
  });
  final Incidencia inc;
  final AppTheme theme;
  final TecnicoProvider tecProv;
  final VoidCallback onClose;

  Color _prioColor(String p) {
    switch (p) {
      case 'critico':
        return const Color(0xFFB91C1C);
      case 'alto':
        return const Color(0xFFD97706);
      case 'medio':
        return const Color(0xFF1D4ED8);
      default:
        return const Color(0xFF2D7A4F);
    }
  }

  // Materiales simulados por categoría
  List<String> _materialesPor(String cat) {
    switch (cat) {
      case 'alumbrado':
        return [
          'Luminaria LED 150W',
          'Cable GTO 10mm',
          'Cintillo plástico x10'
        ];
      case 'bacheo':
        return [
          'Asfalto asfáltico 50kg',
          'Compactador manual',
          'Señal de obra vial'
        ];
      case 'basura':
        return [
          'Bolsas industriales x20',
          'Guantes resistentes',
          'Contenedor temporal'
        ];
      case 'agua_drenaje':
        return ['Tubo PVC 4"', 'Sellador hidráulico', 'Coladera de acero'];
      case 'señalizacion':
      case 'senalizacion':
        return [
          'Señal vial reflexiva',
          'Poste galvanizado',
          'Pintura para pavimento'
        ];
      case 'seguridad':
        return ['Placa de acero', 'Tornillería inox', 'Pintura anticorrosiva'];
      default:
        return ['Material general', 'Herramientas básicas'];
    }
  }

  // Tiempo estimado simulado
  String _tiempoEstimado(String cat, String prioridad) {
    final base = {
      'alumbrado': 45,
      'bacheo': 120,
      'basura': 30,
      'agua_drenaje': 90,
      'señalizacion': 60,
      'senalizacion': 60,
      'seguridad': 75
    };
    final mins = base[cat] ?? 60;
    final factor = prioridad == 'critico'
        ? 0.7
        : prioridad == 'alto'
            ? 0.85
            : 1.0;
    final total = (mins * factor).round();
    return total >= 60 ? '${total ~/ 60}h ${total % 60}min' : '${total}min';
  }

  // Hora de llegada simulada
  String _horaLlegada(String prioridad) {
    final now = DateTime.now();
    final delta = prioridad == 'critico'
        ? 15
        : prioridad == 'alto'
            ? 25
            : 40;
    final llegada = now.add(Duration(minutes: delta));
    return '${llegada.hour.toString().padLeft(2, '0')}:${llegada.minute.toString().padLeft(2, '0')} (est. $delta min)';
  }

  @override
  Widget build(BuildContext context) {
    final tec = inc.tecnicoId != null ? tecProv.byId(inc.tecnicoId!) : null;
    final color = _prioColor(inc.prioridad);
    final mats = _materialesPor(inc.categoria);
    final bytes = tec != null ? tecProv.getAvatarBytes(tec.id) : null;

    return Container(
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.18),
              blurRadius: 24,
              offset: const Offset(-4, 0))
        ],
      ),
      child: Column(children: [
        // ── Imagen del incidente ──────────────────────────────────────────
        Stack(children: [
          Container(
            height: 180,
            color: theme.background,
            child: inc.imagenPath != null
                ? Image.asset(inc.imagenPath!,
                    width: double.infinity,
                    height: 180,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Center(
                        child: Icon(Icons.image_not_supported_outlined,
                            size: 40, color: theme.textDisabled)))
                : Center(
                    child: Icon(Icons.image_not_supported_outlined,
                        size: 40, color: theme.textDisabled)),
          ),
          // Color stripe top
          Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(height: 5, color: color)),
          // Close button
          Positioned(
              top: 10,
              right: 10,
              child: Material(
                  color: Colors.black.withOpacity(0.5),
                  shape: const CircleBorder(),
                  child: InkWell(
                      onTap: onClose,
                      customBorder: const CircleBorder(),
                      child: const Padding(
                          padding: EdgeInsets.all(6),
                          child: Icon(Icons.close,
                              color: Colors.white, size: 18))))),
          // Priority badge overlay bottom left
          Positioned(
              bottom: 8,
              left: 10,
              child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                  decoration: BoxDecoration(
                      color: color, borderRadius: BorderRadius.circular(20)),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.flag_outlined, size: 11, color: Colors.white),
                    const SizedBox(width: 4),
                    Text(labelPrioridad(inc.prioridad).toUpperCase(),
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 10)),
                  ]))),
          // ID overlay bottom right
          Positioned(
              bottom: 8,
              right: 10,
              child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(6)),
                  child: Text(formatIdIncidencia(inc.id),
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 12)))),
        ]),

        // ── Cuerpo scrollable ─────────────────────────────────────────────
        Expanded(
            child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Categoría + descripción
            Row(children: [
              Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                      color: theme.border.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(6)),
                  child: Text(labelCategoria(inc.categoria),
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: theme.textSecondary))),
              const SizedBox(width: 6),
              Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6)),
                  child: Text(labelEstatus(inc.estatus),
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: color))),
            ]),
            const SizedBox(height: 8),
            Text(inc.descripcion,
                style: TextStyle(
                    fontSize: 13,
                    color: theme.textPrimary,
                    fontWeight: FontWeight.w500)),
            const SizedBox(height: 6),
            // Coordenadas + SLA
            Row(children: [
              Icon(Icons.location_on_outlined,
                  size: 12, color: theme.textDisabled),
              const SizedBox(width: 3),
              Text(
                  '${inc.latitud.toStringAsFixed(4)}, ${inc.longitud.toStringAsFixed(4)}',
                  style: TextStyle(fontSize: 11, color: theme.textSecondary)),
              const Spacer(),
              Icon(Icons.timer_outlined,
                  size: 12,
                  color:
                      inc.estaVencida ? theme.critical : theme.textSecondary),
              const SizedBox(width: 3),
              Text(formatSla(inc.fechaLimite),
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: inc.estaVencida
                          ? theme.critical
                          : theme.textSecondary)),
            ]),

            const SizedBox(height: 16),
            Divider(color: theme.border),
            const SizedBox(height: 10),

            // ── Técnico asignado ────────────────────────────────────────
            Row(children: [
              Icon(Icons.engineering, size: 14, color: theme.primaryColor),
              const SizedBox(width: 6),
              Text('TÉCNICO ASIGNADO',
                  style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: theme.primaryColor,
                      letterSpacing: 0.8)),
            ]),
            const SizedBox(height: 10),

            if (tec == null)
              Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                      color: theme.high.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: theme.high.withOpacity(0.3))),
                  child: Row(children: [
                    Icon(Icons.person_off_outlined,
                        size: 16, color: theme.high),
                    const SizedBox(width: 8),
                    Text('Sin asignar',
                        style: TextStyle(
                            fontSize: 13,
                            color: theme.high,
                            fontWeight: FontWeight.w600)),
                  ]))
            else ...[
              // Card técnico con avatar
              Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                      color: theme.primaryColor.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: theme.primaryColor.withOpacity(0.2))),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          // Avatar
                          tec.avatarPath != null
                              ? CircleAvatar(
                                  radius: 22,
                                  backgroundImage: AssetImage(tec.avatarPath!))
                              : bytes != null
                                  ? CircleAvatar(
                                      radius: 22,
                                      backgroundImage: MemoryImage(bytes))
                                  : CircleAvatar(
                                      radius: 22,
                                      backgroundColor:
                                          theme.primaryColor.withOpacity(0.2),
                                      child: Text(tec.iniciales,
                                          style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w800,
                                              color: theme.primaryColor))),
                          const SizedBox(width: 12),
                          Expanded(
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                Text(tec.nombre,
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w800,
                                        color: theme.textPrimary)),
                                Text(labelRolTecnico(tec.rol),
                                    style: TextStyle(
                                        fontSize: 11,
                                        color: theme.textSecondary)),
                                const SizedBox(height: 3),
                                Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 7, vertical: 2),
                                    decoration: BoxDecoration(
                                        color:
                                            _tecStatusColor(tec.estatus, theme)
                                                .withOpacity(0.12),
                                        borderRadius:
                                            BorderRadius.circular(12)),
                                    child: Text(
                                        labelEstatusTecnico(tec.estatus),
                                        style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w700,
                                            color: _tecStatusColor(
                                                tec.estatus, theme)))),
                              ])),
                        ]),
                        const SizedBox(height: 12),
                        // Especialidad
                        _TecRow(Icons.build_outlined, 'Especialidad',
                            labelCategoria(tec.especialidad), theme),
                        _TecRow(Icons.schedule_outlined, 'Llegada est.',
                            _horaLlegada(inc.prioridad), theme),
                        _TecRow(
                            Icons.timer_outlined,
                            'Tiempo reparación',
                            _tiempoEstimado(inc.categoria, inc.prioridad),
                            theme),
                        _TecRow(Icons.assignment_outlined, 'Activas',
                            '${tec.incidenciasActivas} incidencias', theme),
                      ])),
            ],

            const SizedBox(height: 16),

            // ── Materiales ──────────────────────────────────────────────
            Row(children: [
              Icon(Icons.inventory_2_outlined, size: 14, color: theme.medium),
              const SizedBox(width: 6),
              Text('MATERIALES ESTIMADOS',
                  style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: theme.medium,
                      letterSpacing: 0.8)),
            ]),
            const SizedBox(height: 8),
            ...mats.map((m) => Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child: Row(children: [
                  Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                          color: theme.medium.withOpacity(0.6),
                          shape: BoxShape.circle)),
                  const SizedBox(width: 8),
                  Expanded(
                      child: Text(m,
                          style: TextStyle(
                              fontSize: 12, color: theme.textPrimary))),
                ]))),

            const SizedBox(height: 12),
          ]),
        )),

        // ── Footer ────────────────────────────────────────────────────────
        Container(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          decoration: BoxDecoration(
              color: theme.background,
              border: Border(top: BorderSide(color: theme.border))),
          child: Row(children: [
            if (inc.esReincidente)
              Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                      color: theme.high.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(5)),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.repeat, size: 11, color: theme.high),
                    const SizedBox(width: 3),
                    Text('Reincidente',
                        style: TextStyle(
                            fontSize: 10,
                            color: theme.high,
                            fontWeight: FontWeight.w600)),
                  ])),
            const Spacer(),
            Text('Ver orden completa',
                style: TextStyle(
                    fontSize: 11,
                    color: theme.primaryColor,
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.underline,
                    decorationColor: theme.primaryColor)),
          ]),
        ),
      ]),
    );
  }

  Color _tecStatusColor(String estatus, AppTheme theme) {
    switch (estatus) {
      case 'activo':
        return theme.low;
      case 'en_campo':
        return theme.high;
      case 'descanso':
        return theme.neutral;
      default:
        return theme.textDisabled;
    }
  }
}

// ── Fila de dato del técnico ────────────────────────────────────────────────
class _TecRow extends StatelessWidget {
  const _TecRow(this.icon, this.label, this.value, this.theme);
  final IconData icon;
  final String label, value;
  final AppTheme theme;
  @override
  Widget build(BuildContext context) => Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(children: [
        Icon(icon, size: 13, color: theme.textSecondary),
        const SizedBox(width: 6),
        SizedBox(
            width: 100,
            child: Text(label,
                style: TextStyle(
                    fontSize: 11,
                    color: theme.textSecondary,
                    fontWeight: FontWeight.w500))),
        Expanded(
            child: Text(value,
                style: TextStyle(
                    fontSize: 11,
                    color: theme.textPrimary,
                    fontWeight: FontWeight.w600),
                overflow: TextOverflow.ellipsis)),
      ]));
}

class _MapControl extends StatelessWidget {
  const _MapControl({required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8)
        ],
      ),
      child: child,
    );
  }
}
