import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:nethive_neo/data/mock_data.dart';
import 'package:nethive_neo/models/models.dart';

class TecnicoProvider extends ChangeNotifier {
  final List<Tecnico> _tecnicos = List.from(mockTecnicosTijuana);
  final Map<String, Uint8List> _avatarBytesCache = {};
  String _filtroEstatus = 'todos';

  // ── Getters ───────────────────────────────────────────────────────────────
  List<Tecnico> get todos => List.unmodifiable(_tecnicos);
  List<Tecnico> get activos =>
      _tecnicos.where((t) => t.estatus != 'inactivo').toList();
  List<Tecnico> get disponibles =>
      _tecnicos.where((t) => t.estatus == 'activo').toList();
  List<Tecnico> get enCampo =>
      _tecnicos.where((t) => t.estatus == 'en_campo').toList();
  String get filtroEstatus => _filtroEstatus;

  Tecnico? byId(String id) {
    try {
      return _tecnicos.firstWhere((t) => t.id == id);
    } catch (_) {
      return null;
    }
  }

  List<Tecnico> byEspecialidad(String esp) =>
      _tecnicos.where((t) => t.especialidad == esp).toList();

  // ── Filtro ────────────────────────────────────────────────────────────────
  void setFiltroEstatus(String estatus) {
    _filtroEstatus = estatus;
    notifyListeners();
  }

  List<Tecnico> get filtrados {
    if (_filtroEstatus == 'todos') return todos;
    return _tecnicos.where((t) => t.estatus == _filtroEstatus).toList();
  }

  // ── Conteos ───────────────────────────────────────────────────────────────
  Map<String, int> get conteoEstatus => {
        'activo': _tecnicos.where((t) => t.estatus == 'activo').length,
        'en_campo': _tecnicos.where((t) => t.estatus == 'en_campo').length,
        'descanso': _tecnicos.where((t) => t.estatus == 'descanso').length,
        'inactivo': _tecnicos.where((t) => t.estatus == 'inactivo').length,
      };

  // ── Acciones ──────────────────────────────────────────────────────────────
  void actualizarEstatus(String id, String nuevoEstatus) {
    final idx = _tecnicos.indexWhere((t) => t.id == id);
    if (idx == -1) return;
    _tecnicos[idx] = _tecnicos[idx].copyWith(estatus: nuevoEstatus);
    notifyListeners();
  }

  void agregarTecnico(Tecnico tecnico) {
    _tecnicos.add(tecnico);
    notifyListeners();
  }

  void incrementarActivas(String id) {
    final idx = _tecnicos.indexWhere((t) => t.id == id);
    if (idx == -1) return;
    _tecnicos[idx] = _tecnicos[idx].copyWith(
      incidenciasActivas: _tecnicos[idx].incidenciasActivas + 1,
      estatus: 'en_campo',
    );
    notifyListeners();
  }

  void decrementarActivas(String id) {
    final idx = _tecnicos.indexWhere((t) => t.id == id);
    if (idx == -1) return;
    final nvo = (_tecnicos[idx].incidenciasActivas - 1).clamp(0, 99);
    _tecnicos[idx] = _tecnicos[idx].copyWith(incidenciasActivas: nvo);
    notifyListeners();
  }

  // ── Avatar bytes (Flutter Web upload) ────────────────────────────────────
  void setAvatarBytes(String id, Uint8List bytes) {
    _avatarBytesCache[id] = bytes;
    notifyListeners();
  }

  Uint8List? getAvatarBytes(String id) => _avatarBytesCache[id];
}
