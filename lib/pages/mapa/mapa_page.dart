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
  bool _showTecnicos = false;

  // Ensenada center
  static const _center = LatLng(31.8667, -116.5963);

  Color _prioColor(String p) {
    switch (p) {
      case 'critico': return const Color(0xFFB91C1C);
      case 'alto':    return const Color(0xFFD97706);
      case 'medio':   return const Color(0xFF1D4ED8);
      default:        return const Color(0xFF2D7A4F);
    }
  }

  List<Marker> _buildIncidenciaMarkers(List<Incidencia> incs) {
    return incs
      .where((i) => _filterPrioridad == null || i.prioridad == _filterPrioridad)
      .where((i) => i.estaActiva)
      .map((i) {
        final color = _prioColor(i.prioridad);
        return Marker(
          point: LatLng(i.latitud, i.longitud),
          width: 32, height: 32,
          child: GestureDetector(
            onTap: () => setState(() => _selected = i),
            child: Container(
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: [BoxShadow(color: color.withOpacity(0.5), blurRadius: 6)],
              ),
              child: const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 16),
            ),
          ),
        );
      }).toList();
  }

  List<Marker> _buildTecnicoMarkers(List<Tecnico> tecs) {
    if (!_showTecnicos) return [];
    return tecs.map((t) => Marker(
      point: LatLng(t.latitud, t.longitud),
      width: 30, height: 30,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF7A1E3A),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2),
        ),
        child: const Icon(Icons.engineering, color: Colors.white, size: 14),
      ),
    )).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme  = AppTheme.of(context);
    final incProv = context.watch<IncidenciaProvider>();
    final tecProv = context.watch<TecnicoProvider>();
    final incs    = incProv.activas;
    final tecs    = tecProv.activos;

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
          top: 16, left: 16, right: 16,
          child: Row(children: [
            _MapControl(
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                const Text('Prioridad: ', style: TextStyle(fontSize: 12)),
                ...[null, 'critico', 'alto', 'medio', 'bajo'].map((p) => Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: ChoiceChip(
                    label: Text(p == null ? 'Todas' : labelPrioridad(p), style: const TextStyle(fontSize: 11)),
                    selected: _filterPrioridad == p,
                    onSelected: (_) => setState(() => _filterPrioridad = p),
                    selectedColor: p == null ? theme.primaryColor : _prioColor(p),
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
        ),

        // Leyenda
        Positioned(
          bottom: 16, left: 16,
          child: _MapControl(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Leyenda', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                const SizedBox(height: 6),
                ...[
                  ('critico', 'Crítico'),
                  ('alto',    'Alto'),
                  ('medio',   'Medio'),
                  ('bajo',    'Bajo'),
                ].map((e) => Padding(
                  padding: const EdgeInsets.only(bottom: 3),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Container(width: 12, height: 12, decoration: BoxDecoration(color: _prioColor(e.$1), shape: BoxShape.circle)),
                    const SizedBox(width: 6),
                    Text(e.$2, style: const TextStyle(fontSize: 11)),
                  ]),
                )),
                if (_showTecnicos) ...[
                  const SizedBox(height: 2),
                  Row(mainAxisSize: MainAxisSize.min, children: [
                    Container(width: 12, height: 12, decoration: const BoxDecoration(color: Color(0xFF7A1E3A), shape: BoxShape.circle)),
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
          bottom: 16, right: 16,
          child: _MapControl(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Text('${incs.length}', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: theme.primaryColor)),
              const Text('activas', style: TextStyle(fontSize: 11)),
            ]),
          ),
        ),

        // Detail panel
        if (_selected != null)
          Positioned(
            bottom: 16, left: 50, right: 100,
            child: _IncidenciaDetailPanel(inc: _selected!, theme: theme, onClose: () => setState(() => _selected = null)),
          ),
      ],
    );
  }
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
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8)],
      ),
      child: child,
    );
  }
}

class _IncidenciaDetailPanel extends StatelessWidget {
  const _IncidenciaDetailPanel({required this.inc, required this.theme, required this.onClose});
  final Incidencia inc;
  final AppTheme theme;
  final VoidCallback onClose;

  Color _prioColor(String p) {
    switch (p) {
      case 'critico': return const Color(0xFFB91C1C);
      case 'alto':    return const Color(0xFFD97706);
      case 'medio':   return const Color(0xFF1D4ED8);
      default:        return const Color(0xFF2D7A4F);
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _prioColor(inc.prioridad);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.4), width: 2),
        boxShadow: [BoxShadow(color: color.withOpacity(0.2), blurRadius: 12)],
      ),
      child: Row(children: [
        Container(
          width: 6, height: 60,
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3)),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
          Row(children: [
            Text(formatIdIncidencia(inc.id), style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: theme.primaryColor)),
            const SizedBox(width: 8),
            PriorityBadge(prioridad: inc.prioridad),
            const Spacer(),
            Text(labelCategoria(inc.categoria), style: TextStyle(fontSize: 12, color: theme.textSecondary)),
          ]),
          const SizedBox(height: 4),
          Text(inc.descripcion, style: TextStyle(fontSize: 12, color: theme.textPrimary),
            maxLines: 1, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 4),
          Row(children: [
            Icon(Icons.timer_outlined, size: 13, color: inc.estaVencida ? theme.critical : theme.textSecondary),
            const SizedBox(width: 3),
            Text(formatSla(inc.fechaLimite),
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
                color: inc.estaVencida ? theme.critical : theme.textSecondary)),
            const SizedBox(width: 12),
            Icon(Icons.location_on_outlined, size: 13, color: theme.textSecondary),
            const SizedBox(width: 3),
            Text('${inc.latitud.toStringAsFixed(4)}, ${inc.longitud.toStringAsFixed(4)}',
              style: TextStyle(fontSize: 11, color: theme.textSecondary)),
          ]),
        ])),
        const SizedBox(width: 8),
        IconButton(onPressed: onClose, icon: const Icon(Icons.close, size: 18)),
      ]),
    );
  }
}
