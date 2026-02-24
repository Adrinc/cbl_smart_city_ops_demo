import 'package:flutter/material.dart';
import 'package:nethive_neo/data/mock_data.dart';
import 'package:nethive_neo/models/models.dart';

class SlaProvider extends ChangeNotifier {
  late List<Incidencia> _incidencias;

  SlaProvider() {
    _incidencias = List.from(mockIncidenciasTijuana);
  }

  List<Incidencia> get enRiesgo {
    final ahora = DateTime.now();
    return _incidencias.where((i) {
      if (!i.estaActiva || i.fechaLimite == null) return false;
      final diff = i.fechaLimite!.difference(ahora);
      return diff.inHours <= 4 && !diff.isNegative;
    }).toList();
  }

  List<Incidencia> get vencidas =>
      _incidencias.where((i) => i.estaVencida).toList();

  double get porcentajeCumplimiento {
    final conSla = _incidencias
        .where((i) => !i.estaActiva && i.fechaLimite != null && i.fechaResolucion != null)
        .toList();
    if (conSla.isEmpty) return 89.0;
    final cumplidos = conSla.where((i) {
      return i.fechaResolucion!.isBefore(i.fechaLimite!);
    }).length;
    return (cumplidos / conSla.length) * 100;
  }

  int get totalVencidas => vencidas.length;
  int get totalEnRiesgo => enRiesgo.length;
}
