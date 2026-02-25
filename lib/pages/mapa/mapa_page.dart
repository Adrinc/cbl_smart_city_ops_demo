import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';
import 'package:latlong2/latlong.dart';
import 'package:nethive_neo/helpers/constants.dart';
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
  Tecnico? _selectedTecnico;
  String? _filterPrioridad;
  String? _filterCategoria;
  bool _showTecnicos = false;
  final Set<String> _hoveredIds = {};
  final Set<String> _hoveredTecIds = {};
  late final MapController _mapController;
  NivelTerritorial? _prevNivel;

  static const Map<String, IconData> _catIcon = {
    'alumbrado': Icons.lightbulb_outline,
    'bacheo': Icons.construction,
    'basura': Icons.delete_outline,
    'agua_drenaje': Icons.water_drop_outlined,
    'senalizacion': Icons.traffic,
    'señalizacion': Icons.traffic,
    'seguridad': Icons.security,
  };

  // ── Centros por nivel ───────────────────────────────────────────────────
  static const _centerNacional = LatLng(23.6, -102.5);
  static const _centerEstatal = LatLng(30.7, -115.8);
  static const _centerMunicipal = LatLng(32.5027, -117.0037);

  // ── Clusters Estatal (municipios de BC) ─────────────────────────────────
  static const _municipiosClusters = [
    (name: 'Tijuana', lat: 32.5027, lng: -117.0037, count: 142, sev: 'critico'),
    (name: 'Mexicali', lat: 32.6245, lng: -115.4523, count: 87, sev: 'alto'),
    (name: 'Ensenada', lat: 31.8667, lng: -116.5963, count: 56, sev: 'alto'),
    (name: 'Tecate', lat: 32.5732, lng: -116.6279, count: 28, sev: 'medio'),
    (name: 'Rosarito', lat: 32.3710, lng: -117.0640, count: 16, sev: 'bajo'),
  ];

  // ── Clusters Nacional (estados) ──────────────────────────────────────────
  static const _estadosClusters = [
    (name: 'CDMX', lat: 19.432, lng: -99.133, count: 312, sev: 'critico'),
    (name: 'Jalisco', lat: 20.660, lng: -103.350, count: 187, sev: 'critico'),
    (
      name: 'Baja California',
      lat: 30.730,
      lng: -115.800,
      count: 143,
      sev: 'alto'
    ),
    (name: 'Nuevo León', lat: 25.592, lng: -99.996, count: 201, sev: 'critico'),
    (name: 'Veracruz', lat: 19.173, lng: -96.134, count: 98, sev: 'alto'),
    (name: 'Puebla', lat: 19.043, lng: -98.198, count: 134, sev: 'alto'),
    (name: 'Guanajuato', lat: 21.019, lng: -101.258, count: 112, sev: 'medio'),
    (name: 'Chihuahua', lat: 28.635, lng: -106.089, count: 76, sev: 'medio'),
    (name: 'Oaxaca', lat: 17.060, lng: -96.722, count: 45, sev: 'bajo'),
    (name: 'Yucatán', lat: 20.968, lng: -89.623, count: 58, sev: 'medio'),
    (name: 'Sonora', lat: 29.073, lng: -110.955, count: 67, sev: 'medio'),
    (name: 'Tamaulipas', lat: 24.266, lng: -98.836, count: 89, sev: 'alto'),
    (name: 'Michoacán', lat: 19.566, lng: -101.707, count: 54, sev: 'medio'),
    (name: 'Querétaro', lat: 20.593, lng: -100.389, count: 41, sev: 'bajo'),
    (name: 'Quintana Roo', lat: 19.181, lng: -88.479, count: 30, sev: 'bajo'),
  ];

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final nivel = context.read<AppLevelProvider>().nivel;
    if (_prevNivel != null && _prevNivel != nivel) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _animateToNivel(nivel),
      );
    }
    _prevNivel = nivel;
  }

  void _animateToNivel(NivelTerritorial nivel) {
    setState(() {
      _selected = null;
      _selectedTecnico = null;
    });
    final target = switch (nivel) {
      NivelTerritorial.nacional => _centerNacional,
      NivelTerritorial.estatal => _centerEstatal,
      NivelTerritorial.municipal => _centerMunicipal,
    };
    final zoom = switch (nivel) {
      NivelTerritorial.nacional => 5.2,
      NivelTerritorial.estatal => 7.6,
      NivelTerritorial.municipal => 11.5,
    };
    _mapController.move(target, zoom);
  }

  List<Marker> _buildClusterMarkers(
    List<({String name, double lat, double lng, int count, String sev})> items,
  ) {
    return items.map((item) {
      final color = _prioColor(item.sev);
      return Marker(
        point: LatLng(item.lat, item.lng),
        width: 64,
        height: 64,
        child: Tooltip(
          message: '${item.name}: ${item.count} incidencias',
          child: Container(
            decoration: BoxDecoration(
              color: color.withOpacity(0.88),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2.5),
              boxShadow: [
                BoxShadow(
                    color: color.withOpacity(0.45),
                    blurRadius: 12,
                    spreadRadius: 2),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${item.count}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  item.name.length > 9
                      ? '${item.name.substring(0, 8)}.'
                      : item.name,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 7,
                    height: 1.1,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }).toList();
  }

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
            onTap: () => setState(() {
              _selected = i;
              _selectedTecnico = null;
            }),
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
    const tecColor = Color(0xFF7A1E3A);
    return tecs.map((t) {
      final isHovered = _hoveredTecIds.contains(t.id);
      return Marker(
        point: LatLng(t.latitud, t.longitud),
        width: isHovered ? 44 : 34,
        height: isHovered ? 44 : 34,
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          onEnter: (_) => setState(() => _hoveredTecIds.add(t.id)),
          onExit: (_) => setState(() => _hoveredTecIds.remove(t.id)),
          child: GestureDetector(
            onTap: () => setState(() {
              _selectedTecnico = t;
              _selected = null;
            }),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              decoration: BoxDecoration(
                color: tecColor,
                shape: BoxShape.circle,
                border:
                    Border.all(color: Colors.white, width: isHovered ? 3 : 2),
                boxShadow: [
                  BoxShadow(
                    color: tecColor.withOpacity(isHovered ? 0.7 : 0.4),
                    blurRadius: isHovered ? 14 : 6,
                    spreadRadius: isHovered ? 2 : 0,
                  ),
                ],
              ),
              child: Icon(Icons.engineering,
                  color: Colors.white, size: isHovered ? 22 : 16),
            ),
          ),
        ),
      );
    }).toList();
  }

  void _mostrarFiltrosMobile(BuildContext context, AppTheme theme) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => StatefulBuilder(
        builder: (ctx, setLocalState) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: theme.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text('Filtros del Mapa',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: theme.textPrimary)),
                const SizedBox(height: 16),
                // Prioridad
                Text('Prioridad',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: theme.textSecondary)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [null, 'critico', 'alto', 'medio', 'bajo']
                      .map((p) => ChoiceChip(
                            label: Text(p == null ? 'Todas' : labelPrioridad(p),
                                style: const TextStyle(fontSize: 12)),
                            selected: _filterPrioridad == p,
                            onSelected: (_) {
                              setLocalState(() {});
                              setState(() => _filterPrioridad = p);
                            },
                            selectedColor:
                                p == null ? theme.primaryColor : _prioColor(p),
                            labelStyle: TextStyle(
                                color: _filterPrioridad == p
                                    ? Colors.white
                                    : null),
                            side: BorderSide.none,
                          ))
                      .toList(),
                ),
                const SizedBox(height: 16),
                // Categoría
                Text('Categoría',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: theme.textSecondary)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    null,
                    'alumbrado',
                    'bacheo',
                    'basura',
                    'agua_drenaje',
                    'señalizacion',
                    'seguridad'
                  ]
                      .map((cat) => ChoiceChip(
                            avatar: cat != null
                                ? Icon(_catIcon[cat] ?? Icons.report_problem,
                                    size: 14,
                                    color: _filterCategoria == cat
                                        ? Colors.white
                                        : theme.textSecondary)
                                : null,
                            label: Text(
                                cat == null ? 'Todas' : labelCategoria(cat),
                                style: const TextStyle(fontSize: 12)),
                            selected: _filterCategoria == cat,
                            onSelected: (_) {
                              setLocalState(() {});
                              setState(() => _filterCategoria = cat);
                            },
                            selectedColor: theme.primaryColor,
                            labelStyle: TextStyle(
                                color: _filterCategoria == cat
                                    ? Colors.white
                                    : null),
                            side: BorderSide.none,
                          ))
                      .toList(),
                ),
                const SizedBox(height: 16),
                // Técnicos toggle
                Row(children: [
                  Text('Mostrar técnicos',
                      style: TextStyle(fontSize: 13, color: theme.textPrimary)),
                  const Spacer(),
                  Switch(
                    value: _showTecnicos,
                    onChanged: (v) {
                      setLocalState(() {});
                      setState(() => _showTecnicos = v);
                    },
                    activeColor: theme.primaryColor,
                  ),
                ]),
                const SizedBox(height: 8),
                // Limpiar
                OutlinedButton.icon(
                  onPressed: () {
                    setLocalState(() {});
                    setState(() {
                      _filterPrioridad = null;
                      _filterCategoria = null;
                    });
                    Navigator.of(context).pop();
                  },
                  icon: const Icon(Icons.clear_all, size: 16),
                  label: const Text('Limpiar filtros'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: theme.textSecondary,
                    minimumSize: const Size(double.infinity, 40),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final nivel = context.watch<AppLevelProvider>().nivel;
    final incProv = context.watch<IncidenciaProvider>();
    final tecProv = context.watch<TecnicoProvider>();
    final incs = incProv.activas;
    final tecs = tecProv.activos;
    final isMobile = MediaQuery.of(context).size.width < mobileSize;
    final esMunicipal = nivel == NivelTerritorial.municipal;

    final filtrosActivos =
        _filterPrioridad != null || _filterCategoria != null || _showTecnicos;

    // Centro e zoom iniciales según nivel
    final initialCenter = switch (nivel) {
      NivelTerritorial.nacional => _centerNacional,
      NivelTerritorial.estatal => _centerEstatal,
      NivelTerritorial.municipal => _centerMunicipal,
    };
    final initialZoom = switch (nivel) {
      NivelTerritorial.nacional => 5.2,
      NivelTerritorial.estatal => 7.6,
      NivelTerritorial.municipal => 11.5,
    };

    return Stack(
      children: [
        // Mapa principal
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: initialCenter,
            initialZoom: initialZoom,
            onTap: (_, __) => setState(() {
              _selected = null;
              _selectedTecnico = null;
            }),
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.cbluna.terranex',
              tileProvider: CancellableNetworkTileProvider(),
            ),
            // Markers según nivel
            if (nivel == NivelTerritorial.nacional)
              MarkerLayer(
                  markers: _buildClusterMarkers(_estadosClusters.toList()))
            else if (nivel == NivelTerritorial.estatal)
              MarkerLayer(
                  markers: _buildClusterMarkers(_municipiosClusters.toList()))
            else ...[
              MarkerLayer(markers: _buildIncidenciaMarkers(incs)),
              MarkerLayer(markers: _buildTecnicoMarkers(tecs)),
            ],
          ],
        ),

        // ── Banner de contexto para Nacional/Estatal ──────────────────────
        if (!esMunicipal)
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.93),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.12), blurRadius: 10),
                  ],
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(
                    nivel == NivelTerritorial.nacional
                        ? Icons.public
                        : Icons.account_balance,
                    size: 16,
                    color: const Color(0xFF7A1E3A),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    nivel == NivelTerritorial.nacional
                        ? 'Vista Nacional — Incidencias agrupadas por estado'
                        : 'Vista Estatal — Baja California Norte · Incidencias por municipio',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ]),
              ),
            ),
          ),

        // ── Controles (solo en nivel municipal) ───────────────────────────
        // MOBILE: botón flotante de filtros
        if (esMunicipal && isMobile)
          Positioned(
            top: 16,
            right: 16,
            child: GestureDetector(
              onTap: () => _mostrarFiltrosMobile(context, theme),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.95),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.15), blurRadius: 8)
                  ],
                  border: filtrosActivos
                      ? Border.all(
                          color: theme.primaryColor.withOpacity(0.6),
                          width: 1.5)
                      : null,
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.tune,
                      size: 18,
                      color:
                          filtrosActivos ? theme.primaryColor : Colors.black87),
                  const SizedBox(width: 6),
                  Text('Filtros',
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: filtrosActivos
                              ? theme.primaryColor
                              : Colors.black87)),
                  if (filtrosActivos) ...[
                    const SizedBox(width: 4),
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                          color: theme.primaryColor, shape: BoxShape.circle),
                    ),
                  ],
                ]),
              ),
            ),
          ),
        // DESKTOP: barras de filtros originales
        if (esMunicipal && !isMobile)
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
                              color:
                                  _filterPrioridad == p ? Colors.white : null,
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
                                  _catIcon[cat] ??
                                      Icons.report_problem_outlined,
                                  size: 12,
                                  color:
                                      sel ? Colors.white : theme.textSecondary)
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

        // Leyenda (solo nivel municipal)
        if (esMunicipal)
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
                              color: Color(0xFF7A1E3A),
                              shape: BoxShape.circle)),
                      const SizedBox(width: 6),
                      const Text('Técnico', style: TextStyle(fontSize: 11)),
                    ]),
                  ],
                ],
              ),
            ),
          ),

        // Counter badge (solo nivel municipal)
        if (esMunicipal)
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

        // Panel lateral derecho (desktop) / modal inferior (mobile)
        if (!isMobile)
          AnimatedPositioned(
            duration: const Duration(milliseconds: 280),
            curve: Curves.easeOutCubic,
            top: 0,
            bottom: 0,
            right: (_selected != null || _selectedTecnico != null) ? 0 : -370,
            width: 360,
            child: _selected != null
                ? _MapaSidePanel(
                    inc: _selected!,
                    theme: theme,
                    tecProv: tecProv,
                    onClose: () => setState(() => _selected = null))
                : _selectedTecnico != null
                    ? _TecnicoSidePanel(
                        tecnico: _selectedTecnico!,
                        tecProv: tecProv,
                        theme: theme,
                        onClose: () => setState(() => _selectedTecnico = null))
                    : const SizedBox.shrink(),
          ),
        if (isMobile && (_selected != null || _selectedTecnico != null)) ...[
          // Fondo semitransparente
          Positioned.fill(
            child: GestureDetector(
              onTap: () => setState(() {
                _selected = null;
                _selectedTecnico = null;
              }),
              child: Container(color: Colors.black.withOpacity(0.35)),
            ),
          ),
          // Panel inferior
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: MediaQuery.of(context).size.height * 0.68,
            child: ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(18)),
              child: _selected != null
                  ? _MapaSidePanel(
                      inc: _selected!,
                      theme: theme,
                      tecProv: tecProv,
                      onClose: () => setState(() => _selected = null),
                    )
                  : _TecnicoSidePanel(
                      tecnico: _selectedTecnico!,
                      tecProv: tecProv,
                      theme: theme,
                      onClose: () => setState(() => _selectedTecnico = null),
                    ),
            ),
          ),
        ],
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

// ════════════════════════════════════════════════════════════════════════════
// PANEL LATERAL — Técnico
// ════════════════════════════════════════════════════════════════════════════
class _TecnicoSidePanel extends StatelessWidget {
  const _TecnicoSidePanel({
    required this.tecnico,
    required this.tecProv,
    required this.theme,
    required this.onClose,
  });
  final Tecnico tecnico;
  final TecnicoProvider tecProv;
  final AppTheme theme;
  final VoidCallback onClose;

  Color _estatusColor(String estatus) {
    switch (estatus) {
      case 'activo':
        return const Color(0xFF2D7A4F);
      case 'en_campo':
        return const Color(0xFFD97706);
      case 'descanso':
        return const Color(0xFF64748B);
      default:
        return const Color(0xFF94A3B8);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bytes = tecProv.getAvatarBytes(tecnico.id);
    final ImageProvider? avatarImg = bytes != null
        ? MemoryImage(bytes)
        : tecnico.avatarPath != null
            ? AssetImage(tecnico.avatarPath!) as ImageProvider
            : null;
    final statusColor = _estatusColor(tecnico.estatus);
    const vinoPrimary = Color(0xFF7A1E3A);

    return Container(
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.18),
              blurRadius: 24,
              offset: const Offset(-4, 0)),
        ],
      ),
      child: Column(children: [
        // ── Header ───────────────────────────────────────────────────────
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF5C1528), Color(0xFF7A1E3A)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
            ),
          ),
          child: Column(children: [
            // Fila superior: stripe decorativa + botón cerrar
            Row(mainAxisAlignment: MainAxisAlignment.end, children: [
              Material(
                color: Colors.white.withOpacity(0.15),
                shape: const CircleBorder(),
                child: InkWell(
                    onTap: onClose,
                    customBorder: const CircleBorder(),
                    child: const Padding(
                        padding: EdgeInsets.all(6),
                        child:
                            Icon(Icons.close, color: Colors.white, size: 16))),
              ),
            ]),
            const SizedBox(height: 8),
            // Avatar circular con borde
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipOval(
                child: avatarImg != null
                    ? Image(
                        image: avatarImg,
                        fit: BoxFit.cover,
                        width: 100,
                        height: 100,
                      )
                    : Container(
                        color: const Color(0xFF9B2C4E),
                        child: Center(
                          child: Text(
                            tecnico.iniciales,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 12),
            // Nombre
            Text(
              tecnico.nombre,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            // Rol + badge estatus en la misma fila
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text(
                labelRolTecnico(tecnico.rol),
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: Colors.white.withOpacity(0.4), width: 1)),
                child: Text(labelEstatusTecnico(tecnico.estatus),
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 10)),
              ),
            ]),
          ]),
        ),

        // ── Cuerpo scrollable ─────────────────────────────────────────────
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              // ID + municipio
              Row(children: [
                Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                        color: theme.border.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(6)),
                    child: Text(tecnico.id,
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: theme.textSecondary))),
                const SizedBox(width: 6),
                Icon(Icons.location_city_outlined,
                    size: 12, color: theme.textDisabled),
                const SizedBox(width: 3),
                Text(tecnico.municipioAsignado ?? 'Tijuana',
                    style: TextStyle(fontSize: 12, color: theme.textSecondary)),
              ]),
              const SizedBox(height: 14),
              Divider(color: theme.border),
              const SizedBox(height: 10),

              // Especialidad
              _TecRow(
                Icons.build_outlined,
                'Especialidad',
                labelCategoria(tecnico.especialidad),
                theme,
              ),
              _TecRow(
                Icons.work_outline,
                'Rol',
                labelRolTecnico(tecnico.rol),
                theme,
              ),
              _TecRow(
                Icons.location_on_outlined,
                'Coordenadas',
                '${tecnico.latitud.toStringAsFixed(4)}, ${tecnico.longitud.toStringAsFixed(4)}',
                theme,
              ),

              const SizedBox(height: 14),
              Divider(color: theme.border),
              const SizedBox(height: 10),

              // KPIs
              Text('ACTIVIDAD DEL MES',
                  style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: vinoPrimary,
                      letterSpacing: 0.8)),
              const SizedBox(height: 10),
              Row(children: [
                Expanded(
                  child: _KpiTile(
                    label: 'Activas',
                    value: '${tecnico.incidenciasActivas}',
                    color: tecnico.incidenciasActivas > 0
                        ? const Color(0xFFD97706)
                        : theme.low,
                    theme: theme,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _KpiTile(
                    label: 'Cerradas /mes',
                    value: '${tecnico.incidenciasCerradasMes}',
                    color: theme.low,
                    theme: theme,
                  ),
                ),
              ]),
              const SizedBox(height: 12),
            ]),
          ),
        ),

        // ── Footer ────────────────────────────────────────────────────────
        Container(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          decoration: BoxDecoration(
              color: theme.background,
              border: Border(top: BorderSide(color: theme.border))),
          child: SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onClose,
              icon: const Icon(Icons.close, size: 15),
              label: const Text('Cerrar'),
              style: OutlinedButton.styleFrom(
                foregroundColor: theme.textSecondary,
              ),
            ),
          ),
        ),
      ]),
    );
  }
}

class _KpiTile extends StatelessWidget {
  const _KpiTile(
      {required this.label,
      required this.value,
      required this.color,
      required this.theme});
  final String label, value;
  final Color color;
  final AppTheme theme;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
            color: color.withOpacity(0.08),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: color.withOpacity(0.25))),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(value,
              style: TextStyle(
                  fontSize: 20, fontWeight: FontWeight.w800, color: color)),
          const SizedBox(height: 2),
          Text(label,
              style: TextStyle(fontSize: 10, color: theme.textSecondary)),
        ]),
      );
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
