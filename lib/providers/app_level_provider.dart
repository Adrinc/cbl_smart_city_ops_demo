import 'package:flutter/material.dart';
import 'package:nethive_neo/helpers/constants.dart';

class AppLevelProvider extends ChangeNotifier {
  NivelTerritorial _nivel = NivelTerritorial.nacional;
  bool _sidebarExpanded = true;

  NivelTerritorial get nivel => _nivel;
  bool get sidebarExpanded => _sidebarExpanded;

  String get nivelLabel {
    switch (_nivel) {
      case NivelTerritorial.nacional:
        return 'Nacional';
      case NivelTerritorial.estatal:
        return 'Estatal';
      case NivelTerritorial.municipal:
        return 'Municipal';
    }
  }

  List<String> get breadcrumb {
    switch (_nivel) {
      case NivelTerritorial.nacional:
        return ['México'];
      case NivelTerritorial.estatal:
        return ['México', demoEstado];
      case NivelTerritorial.municipal:
        return ['México', 'BC', demoMunicipio];
    }
  }

  void setNivel(NivelTerritorial nivel) {
    _nivel = nivel;
    notifyListeners();
  }

  void toggleSidebar() {
    _sidebarExpanded = !_sidebarExpanded;
    notifyListeners();
  }

  void setSidebarExpanded(bool value) {
    _sidebarExpanded = value;
    notifyListeners();
  }
}
