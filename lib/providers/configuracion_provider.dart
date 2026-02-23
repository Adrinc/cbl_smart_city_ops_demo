import 'package:flutter/material.dart';
import 'package:nethive_neo/data/mock_data.dart';
import 'package:nethive_neo/models/models.dart';

class ConfiguracionProvider extends ChangeNotifier {
  late List<ReglaPriorizacion> _reglas;

  ConfiguracionProvider() {
    _reglas = List.from(mockReglaPriorizacion);
  }

  List<ReglaPriorizacion> get reglas => List.unmodifiable(_reglas);

  List<ReglaPriorizacion> get activas =>
      _reglas.where((r) => r.activa).toList();

  void toggleActiva(String id) {
    final idx = _reglas.indexWhere((r) => r.id == id);
    if (idx == -1) return;
    _reglas[idx] = _reglas[idx].copyWith(activa: !_reglas[idx].activa);
    notifyListeners();
  }

  void actualizarSla(String id, int nuevoSla) {
    final idx = _reglas.indexWhere((r) => r.id == id);
    if (idx == -1) return;
    _reglas[idx] = _reglas[idx].copyWith(slaHoras: nuevoSla);
    notifyListeners();
  }

  ReglaPriorizacion? byId(String id) =>
      _reglas.where((r) => r.id == id).firstOrNull;


  void addRegla(ReglaPriorizacion r) {
    _reglas.insert(0, r);
    notifyListeners();
  }
  String calcPrioridad(String categoria, String entorno, bool esReincidente) {
    try {
      final regla = _reglas.firstWhere((r) =>
          r.activa && r.categoria == categoria && r.entorno == entorno);
      if (esReincidente && regla.esReincidenteEscala) {
        const escalas = ['bajo', 'medio', 'alto', 'critico'];
        final idx = escalas.indexOf(regla.nivelPrioridad);
        if (idx < escalas.length - 1) return escalas[idx + 1];
      }
      return regla.nivelPrioridad;
    } catch (_) {
      return 'medio';
    }
  }
}
