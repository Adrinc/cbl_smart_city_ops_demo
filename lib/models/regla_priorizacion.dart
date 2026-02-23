class ReglaPriorizacion {
  final String id;
  final String categoria;
  final String entorno;
  final String nivelPrioridad;  // critico | alto | medio | bajo
  final int slaHoras;
  final bool autoAprobar;
  final bool esReincidenteEscala;
  final bool activa;

  const ReglaPriorizacion({
    required this.id,
    required this.categoria,
    required this.entorno,
    required this.nivelPrioridad,
    required this.slaHoras,
    required this.autoAprobar,
    required this.esReincidenteEscala,
    required this.activa,
  });

  ReglaPriorizacion copyWith({
    String? nivelPrioridad,
    int? slaHoras,
    bool? autoAprobar,
    bool? esReincidenteEscala,
    bool? activa,
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
    );
  }
}
