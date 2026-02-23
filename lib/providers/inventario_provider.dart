import 'package:flutter/material.dart';
import 'package:nethive_neo/data/mock_data.dart';
import 'package:nethive_neo/models/models.dart';

class InventarioProvider extends ChangeNotifier {
  late List<MaterialItem> _materiales;

  InventarioProvider() {
    _materiales = List.from(mockMateriales);
  }

  List<MaterialItem> get todos => List.unmodifiable(_materiales);

  List<MaterialItem> get bajoStock =>
      _materiales.where((m) => m.estatus == 'bajo_stock').toList();

  List<MaterialItem> get agotados =>
      _materiales.where((m) => m.estatus == 'agotado').toList();

  List<MaterialItem> get alertas =>
      _materiales.where((m) => m.estatus != 'disponible').toList();

  MaterialItem? byId(String id) =>
      _materiales.where((m) => m.id == id).firstOrNull;

  bool reservar(String id, int cantidad) {
    final idx = _materiales.indexWhere((m) => m.id == id);
    if (idx == -1) return false;
    final m = _materiales[idx];
    if (m.disponibleReal < cantidad) return false;
    final nuevo = m.copyWith(
      reservado: m.reservado + cantidad,
      estatus: MaterialItem.calcEstatus(m.stockActual, m.stockMinimo),
    );
    _materiales[idx] = nuevo;
    notifyListeners();
    return true;
  }

  void consumir(String id, int cantidad) {
    final idx = _materiales.indexWhere((m) => m.id == id);
    if (idx == -1) return;
    final m = _materiales[idx];
    final nuevoStock = (m.stockActual - cantidad).clamp(0, 99999);
    final nuevoRes = (m.reservado - cantidad).clamp(0, nuevoStock);
    _materiales[idx] = m.copyWith(
      stockActual: nuevoStock,
      reservado: nuevoRes,
      estatus: MaterialItem.calcEstatus(nuevoStock, m.stockMinimo),
    );
    notifyListeners();
  }
}
