import 'package:flutter/material.dart';
import 'package:nethive_neo/data/mock_data.dart';
import 'package:nethive_neo/models/models.dart';

class AuditoriaProvider extends ChangeNotifier {
  late List<EventoAuditoria> _eventos;
  String? _filtroModulo;
  String? _filtroNivel;
  String _filtroAccion = 'todos';

  AuditoriaProvider() {
    _eventos = List.from(mockAuditoria)
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  // ── Getters ───────────────────────────────────────────────────────────────
  List<EventoAuditoria> get todos => List.unmodifiable(_eventos);
  String? get filtroModulo => _filtroModulo;
  String? get filtroNivel => _filtroNivel;
  String get filtroAccion => _filtroAccion;

  Set<String> get modulos => _eventos.map((e) => e.modulo).toSet();
  Set<String> get acciones => _eventos.map((e) => e.accion).toSet();

  List<EventoAuditoria> get filtrados {
    var r = List<EventoAuditoria>.from(_eventos);
    if (_filtroModulo != null)
      r = r.where((e) => e.modulo == _filtroModulo).toList();
    if (_filtroNivel != null)
      r = r.where((e) => e.nivel == _filtroNivel).toList();
    if (_filtroAccion != 'todos')
      r = r.where((e) => e.accion == _filtroAccion).toList();
    return r;
  }

  // ── Filtros ───────────────────────────────────────────────────────────────
  void setFiltroModulo(String? v) {
    _filtroModulo = v;
    notifyListeners();
  }

  void setFiltroNivel(String? v) {
    _filtroNivel = v;
    notifyListeners();
  }

  void setFiltroAccion(String v) {
    _filtroAccion = v;
    notifyListeners();
  }

  void limpiarFiltros() {
    _filtroModulo = null;
    _filtroNivel = null;
    _filtroAccion = 'todos';
    notifyListeners();
  }

  bool get tieneFiltros =>
      _filtroModulo != null || _filtroNivel != null || _filtroAccion != 'todos';

  // ── Registrar evento ──────────────────────────────────────────────────────
  void registrar({
    required String modulo,
    required String accion,
    required String descripcion,
    String nivel = 'municipal',
    String? referenciaId,
  }) {
    final id = 'AUD-${(_eventos.length + 200).toString().padLeft(4, '0')}';
    _eventos.insert(
        0,
        EventoAuditoria(
          id: id,
          timestamp: DateTime.now(),
          usuario: 'Admin Terranex',
          nivel: nivel,
          modulo: modulo,
          accion: accion,
          descripcion: descripcion,
          referenciaId: referenciaId,
        ));
    notifyListeners();
  }
}
