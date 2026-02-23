import 'package:flutter/material.dart';
import 'package:nethive_neo/data/mock_data.dart';
import 'package:nethive_neo/models/models.dart';

class BandejaIAProvider extends ChangeNotifier {
  late List<Incidencia> _pendientes;

  BandejaIAProvider() {
    _pendientes = mockIncidenciasEnsenada
        .where((i) => i.estatus == 'en_revision')
        .toList();
  }

  List<Incidencia> get pendientes => List.unmodifiable(_pendientes);
  int get totalPendientes => _pendientes.length;

  Incidencia? byId(String id) =>
      _pendientes.where((i) => i.id == id).firstOrNull;

  void aprobar(String id, {String? prioridadOverride}) {
    final idx = _pendientes.indexWhere((i) => i.id == id);
    if (idx == -1) return;
    final updated = _pendientes[idx].copyWith(
      estatus: 'aprobado',
      prioridad: prioridadOverride,
    );
    _pendientes.removeAt(idx);
    _pendientes.insert(idx, updated);
    // La incidencia aprobada se retira de la bandeja
    _pendientes.removeWhere((i) => i.id == id && i.estatus == 'aprobado');
    notifyListeners();
  }

  void rechazar(String id) {
    _pendientes.removeWhere((i) => i.id == id);
    notifyListeners();
  }
}
