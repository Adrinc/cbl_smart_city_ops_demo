import 'package:flutter/material.dart';
import 'package:nethive_neo/data/mock_data.dart';
import 'package:nethive_neo/models/models.dart';

class IncidenciaProvider extends ChangeNotifier {
  late List<Incidencia> _incidencias;

  IncidenciaProvider() {
    _incidencias = List.from(mockIncidenciasTijuana);
  }

  List<Incidencia> get todas => List.unmodifiable(_incidencias);

  List<Incidencia> get activas =>
      _incidencias.where((i) => i.estaActiva).toList();

  List<Incidencia> get criticas =>
      _incidencias.where((i) => i.prioridad == 'critico' && i.estaActiva).toList();

  List<Incidencia> get vencidas =>
      _incidencias.where((i) => i.estaVencida).toList();

  List<Incidencia> get pendientesAprobacion =>
      _incidencias.where((i) => i.estatus == 'aprobado' && i.tecnicoId == null).toList();

  List<Incidencia> byEstatus(String estatus) =>
      _incidencias.where((i) => i.estatus == estatus).toList();

  List<Incidencia> byCategoria(String categoria) =>
      _incidencias.where((i) => i.categoria == categoria).toList();

  Incidencia? byId(String id) =>
      _incidencias.where((i) => i.id == id).firstOrNull;

  void actualizarEstatus(String id, String nuevoEstatus) {
    final idx = _incidencias.indexWhere((i) => i.id == id);
    if (idx == -1) return;
    DateTime? fechaRes;
    if (nuevoEstatus == 'resuelto' || nuevoEstatus == 'cerrado') {
      fechaRes = DateTime.now();
    }
    _incidencias[idx] = _incidencias[idx].copyWith(
      estatus: nuevoEstatus,
      fechaResolucion: fechaRes,
    );
    notifyListeners();
  }

  void asignarTecnico(String id, String tecnicoId) {
    final idx = _incidencias.indexWhere((i) => i.id == id);
    if (idx == -1) return;
    _incidencias[idx] = _incidencias[idx].copyWith(
      estatus: 'asignado',
      tecnicoId: tecnicoId,
    );
    notifyListeners();
  }

  void aprobar(String id) => actualizarEstatus(id, 'aprobado');
  void rechazar(String id) => actualizarEstatus(id, 'rechazado');
  void cerrar(String id) => actualizarEstatus(id, 'cerrado');

  Map<String, int> get conteoEstatus {
    final mapa = <String, int>{};
    for (final i in _incidencias) {
      mapa[i.estatus] = (mapa[i.estatus] ?? 0) + 1;
    }
    return mapa;
  }

  Map<String, int> get conteoCategoria {
    final mapa = <String, int>{};
    for (final i in _incidencias.where((i) => i.estaActiva)) {
      mapa[i.categoria] = (mapa[i.categoria] ?? 0) + 1;
    }
    return mapa;
  }
}
