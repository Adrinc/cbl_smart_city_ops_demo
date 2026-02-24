import 'package:flutter/material.dart';
import 'package:nethive_neo/data/mock_data.dart';
import 'package:nethive_neo/models/models.dart';

class ConfiguracionProvider extends ChangeNotifier {
  late List<ReglaPriorizacion> _reglas;
  late List<CategoriaConfig> _categorias;

  ConfiguracionProvider() {
    _reglas = List.from(mockReglaPriorizacion);
    _categorias = List.from(mockCategorias);
  }

  // ─────────────────────────────── REGLAS ────────────────────────────────────

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

  void deleteRegla(String id) {
    _reglas.removeWhere((r) => r.id == id);
    notifyListeners();
  }

  void updateCriterios(String id, List<String> nuevos) {
    final idx = _reglas.indexWhere((r) => r.id == id);
    if (idx == -1) return;
    _reglas[idx] = _reglas[idx].copyWith(criterios: List.from(nuevos));
    notifyListeners();
  }

  void reorderRegla(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) newIndex -= 1;
    final item = _reglas.removeAt(oldIndex);
    _reglas.insert(newIndex, item);
    notifyListeners();
  }

  String calcPrioridad(String categoria, String entorno, bool esReincidente) {
    try {
      final regla = _reglas.firstWhere(
          (r) => r.activa && r.categoria == categoria && r.entorno == entorno);
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

  // ──────────────────────────────── CATEGORÍAS ────────────────────────────────

  /// Todas las categorías (activas e inactivas).
  List<CategoriaConfig> get categorias => List.unmodifiable(_categorias);

  /// Solo categorías activas (disponibles para nuevos registros).
  List<CategoriaConfig> get categoriasActivas =>
      _categorias.where((c) => c.activa).toList();

  CategoriaConfig? categoriaById(String id) =>
      _categorias.where((c) => c.id == id).firstOrNull;

  /// Número de reglas que usan esta categoría.
  int reglasPorCategoria(String catId) =>
      _reglas.where((r) => r.categoria == catId).length;

  /// Devuelve true si existen reglas que referencian esta categoría.
  bool categoriaTieneReglas(String catId) =>
      _reglas.any((r) => r.categoria == catId);

  /// Agrega una nueva categoría personalizada.
  void addCategoria(CategoriaConfig cat) {
    _categorias.add(cat);
    notifyListeners();
  }

  /// Edita el label y/o icono de una categoría existente.
  void updateCategoria(String id, {String? label, int? iconCodePoint}) {
    final idx = _categorias.indexWhere((c) => c.id == id);
    if (idx == -1) return;
    _categorias[idx] = _categorias[idx].copyWith(
      label: label,
      iconCodePoint: iconCodePoint,
    );
    notifyListeners();
  }

  /// Desactiva una categoría (soft-delete).
  /// La categoría deja de estar disponible para nuevos registros,
  /// pero los datos históricos la conservan íntegra.
  void desactivarCategoria(String id) {
    final idx = _categorias.indexWhere((c) => c.id == id);
    if (idx == -1) return;
    _categorias[idx] = _categorias[idx].copyWith(activa: false);
    notifyListeners();
  }

  /// Reactiva una categoría previamente desactivada.
  void reactivarCategoria(String id) {
    final idx = _categorias.indexWhere((c) => c.id == id);
    if (idx == -1) return;
    _categorias[idx] = _categorias[idx].copyWith(activa: true);
    notifyListeners();
  }

  /// Elimina físicamente una categoría.
  /// Solo es posible si no es nativa y no tiene reglas asociadas.
  /// Lanza [StateError] si alguna condición no se cumple.
  void eliminarCategoria(String id) {
    final cat = _categorias.firstWhere((c) => c.id == id,
        orElse: () => throw StateError('Categoría $id no encontrada'));
    if (cat.esNativa) {
      throw StateError('No se puede eliminar una categoría nativa del sistema');
    }
    if (categoriaTieneReglas(id)) {
      throw StateError(
          'La categoría tiene reglas activas. Elimínalas primero o desactívala.');
    }
    _categorias.removeWhere((c) => c.id == id);
    notifyListeners();
  }
}
