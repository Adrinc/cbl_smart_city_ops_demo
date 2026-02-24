import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:nethive_neo/helpers/formatters.dart';
import 'package:nethive_neo/models/models.dart';
import 'package:nethive_neo/theme/theme.dart';
import 'helpers_bandeja.dart';

class MapaUbicacionDialog extends StatelessWidget {
  const MapaUbicacionDialog({super.key, required this.inc, required this.theme});
  final Incidencia inc;
  final AppTheme theme;

  @override
  Widget build(BuildContext context) {
    final latLng = LatLng(inc.latitud, inc.longitud);
    final color  = prioColor(inc.prioridad);
    final dir    = approxDireccion(inc.latitud, inc.longitud);
    final icon   = catIcon(inc.categoria);
    final total  = MediaQuery.of(context).size;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.all(20),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 560, maxHeight: total.height * 0.82),
        child: Column(children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 12, 14),
            child: Row(children: [
              Icon(Icons.location_on, color: theme.primaryColor, size: 20),
              const SizedBox(width: 10),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Ubicación del reporte',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: theme.textPrimary)),
                Text('${formatIdIncidencia(inc.id)} · $dir',
                  style: TextStyle(fontSize: 12, color: theme.textSecondary),
                  overflow: TextOverflow.ellipsis),
              ])),
              IconButton(icon: Icon(Icons.close, color: theme.textSecondary, size: 20),
                onPressed: () => Navigator.pop(context)),
            ]),
          ),
          Divider(height: 1, color: theme.border),

          // Mapa
          Expanded(child: Stack(children: [
            FlutterMap(
              options: MapOptions(initialCenter: latLng, initialZoom: 15),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.cbluna.terranex'),
                MarkerLayer(markers: [
                  Marker(
                    point: latLng, width: 48, height: 48,
                    child: Container(
                      decoration: BoxDecoration(
                        color: color, shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2.5),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.35),
                          blurRadius: 8, offset: const Offset(0, 3))]),
                      child: Icon(icon, color: Colors.white, size: 22))),
                ]),
              ],
            ),
            Positioned(top: 10, left: 10, child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.92),
                borderRadius: BorderRadius.circular(8),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 6)]),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(icon, size: 14, color: color),
                const SizedBox(width: 5),
                Text('${labelCategoria(inc.categoria)} · ${inc.entorno}',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: theme.textPrimary)),
              ]))),
          ])),

          // Footer coords
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            decoration: BoxDecoration(
              color: theme.background,
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16))),
            child: Row(children: [
              Icon(Icons.gps_fixed, size: 13, color: theme.textSecondary),
              const SizedBox(width: 6),
              Expanded(child: Text(
                '${inc.latitud.toStringAsFixed(5)}, ${inc.longitud.toStringAsFixed(5)}',
                style: TextStyle(fontSize: 12, color: theme.textSecondary),
                overflow: TextOverflow.ellipsis)),
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cerrar')),
            ]),
          ),
        ]),
      ),
    );
  }
}