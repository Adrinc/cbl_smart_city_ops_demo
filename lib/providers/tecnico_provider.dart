import 'package:flutter/material.dart';
import 'package:nethive_neo/data/mock_data.dart';
import 'package:nethive_neo/models/models.dart';

class TecnicoProvider extends ChangeNotifier {
  late List<Tecnico> _tecnicos;

  TecnicoProvider() {
    _tecnicos = List.from(mockTecnicosEnsenada);
  }

  List<Tecnico> get todos => List.unmodifiable(_tecnicos);

  List<Tecnico> get activos =>
      _tecnicos.where((t) => t.estatus == 'activo' || t.estatus == 'en_campo').toList();

  List<Tecnico> get disponibles =>
      _tecnicos.where((t) => t.estatus == 'activo').toList();

  List<Tecnico> get enCampo =>
      _tecnicos.where((t) => t.estatus == 'en_campo').toList();

  Tecnico? byId(String id) =>
      _tecnicos.where((t) => t.id == id).firstOrNull;

  List<Tecnico> byEspecialidad(String especialidad) =>
      _tecnicos.where((t) => t.especialidad == especialidad || t.especialidad == 'general').toList();

  void actualizarEstatus(String id, String nuevoEstatus) {
    final idx = _tecnicos.indexWhere((t) => t.id == id);
    if (idx == -1) return;
    _tecnicos[idx] = _tecnicos[idx].copyWith(estatus: nuevoEstatus);
    notifyListeners();
  }

  Map<String, int> get conteoEstatus {
    final mapa = <String, int>{};
    for (final t in _tecnicos) {
      mapa[t.estatus] = (mapa[t.estatus] ?? 0) + 1;
    }
    return mapa;
  }
}
