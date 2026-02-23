class Incidencia {
  final String id;
  final String municipio;
  final String estado;
  final String categoria;
  final String descripcion;
  final String? imagenPath;
  final double latitud;
  final double longitud;
  final String entorno;
  final String prioridad;     // critico | alto | medio | bajo
  final String estatus;       // recibido|en_revision|aprobado|asignado|en_proceso|resuelto|cerrado|rechazado
  final String? tecnicoId;
  final DateTime fechaReporte;
  final DateTime? fechaLimite;
  final DateTime? fechaResolucion;
  final bool esReincidente;
  final String? iaCategoriaSugerida;
  final String? iaPrioridadSugerida;
  final double? iaConfianza;
  final String? iaCoherenciaNota;

  const Incidencia({
    required this.id,
    required this.municipio,
    required this.estado,
    required this.categoria,
    required this.descripcion,
    this.imagenPath,
    required this.latitud,
    required this.longitud,
    required this.entorno,
    required this.prioridad,
    required this.estatus,
    this.tecnicoId,
    required this.fechaReporte,
    this.fechaLimite,
    this.fechaResolucion,
    this.esReincidente = false,
    this.iaCategoriaSugerida,
    this.iaPrioridadSugerida,
    this.iaConfianza,
    this.iaCoherenciaNota,
  });

  Incidencia copyWith({
    String? estatus,
    String? tecnicoId,
    DateTime? fechaResolucion,
    DateTime? fechaLimite,
    String? prioridad,
  }) {
    return Incidencia(
      id: id,
      municipio: municipio,
      estado: estado,
      categoria: categoria,
      descripcion: descripcion,
      imagenPath: imagenPath,
      latitud: latitud,
      longitud: longitud,
      entorno: entorno,
      prioridad: prioridad ?? this.prioridad,
      estatus: estatus ?? this.estatus,
      tecnicoId: tecnicoId ?? this.tecnicoId,
      fechaReporte: fechaReporte,
      fechaLimite: fechaLimite ?? this.fechaLimite,
      fechaResolucion: fechaResolucion ?? this.fechaResolucion,
      esReincidente: esReincidente,
      iaCategoriaSugerida: iaCategoriaSugerida,
      iaPrioridadSugerida: iaPrioridadSugerida,
      iaConfianza: iaConfianza,
      iaCoherenciaNota: iaCoherenciaNota,
    );
  }

  bool get estaVencida {
    if (fechaLimite == null) return false;
    return DateTime.now().isAfter(fechaLimite!) &&
        estatus != 'resuelto' && estatus != 'cerrado';
  }

  bool get estaActiva =>
      estatus != 'cerrado' && estatus != 'rechazado' && estatus != 'resuelto';
}
