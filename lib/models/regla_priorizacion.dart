class ReglaPriorizacion {
  final String id;
  final String categoria;
  final String entorno;
  final String nivelPrioridad; // critico | alto | medio | bajo
  final int slaHoras;
  final bool autoAprobar;
  final bool esReincidenteEscala;
  final bool activa;

  /// Criterios de clasificación en lenguaje natural.
  /// El operador define bullets como:
  ///   "Varios postes apagados en zona residencial"
  ///   "Cable caído con riesgo de electrocución"
  final List<String> criterios;

  const ReglaPriorizacion({
    required this.id,
    required this.categoria,
    required this.entorno,
    required this.nivelPrioridad,
    required this.slaHoras,
    required this.autoAprobar,
    required this.esReincidenteEscala,
    required this.activa,
    this.criterios = const [],
  });

  ReglaPriorizacion copyWith({
    String? nivelPrioridad,
    int? slaHoras,
    bool? autoAprobar,
    bool? esReincidenteEscala,
    bool? activa,
    List<String>? criterios,
  }) {
    return ReglaPriorizacion(
      id: id,
      categoria: categoria,
      entorno: entorno,
      nivelPrioridad: nivelPrioridad ?? this.nivelPrioridad,
      slaHoras: slaHoras ?? this.slaHoras,
      autoAprobar: autoAprobar ?? this.autoAprobar,
      esReincidenteEscala: esReincidenteEscala ?? this.esReincidenteEscala,
      activa: activa ?? this.activa,
      criterios: criterios ?? this.criterios,
    );
  }
}
