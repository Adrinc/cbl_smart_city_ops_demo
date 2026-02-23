class Tecnico {
  final String id;
  final String nombre;
  final String rol;           // jefe_cuadrilla | tecnico_campo | supervisor
  final String especialidad;  // alumbrado | bacheo | basura | agua_drenaje | general | seguridad
  final String estatus;       // activo | en_campo | inactivo | descanso
  final int incidenciasActivas;
  final int incidenciasCerradasMes;
  final double latitud;
  final double longitud;
  final String? municipioAsignado;
  final String? avatarPath;   // assets/images/avatares/<nombre>.png

  const Tecnico({
    required this.id,
    required this.nombre,
    required this.rol,
    required this.especialidad,
    required this.estatus,
    required this.incidenciasActivas,
    required this.incidenciasCerradasMes,
    required this.latitud,
    required this.longitud,
    this.municipioAsignado,
    this.avatarPath,
  });

  Tecnico copyWith({String? estatus, int? incidenciasActivas}) {
    return Tecnico(
      id: id,
      nombre: nombre,
      rol: rol,
      especialidad: especialidad,
      estatus: estatus ?? this.estatus,
      incidenciasActivas: incidenciasActivas ?? this.incidenciasActivas,
      incidenciasCerradasMes: incidenciasCerradasMes,
      latitud: latitud,
      longitud: longitud,
      municipioAsignado: municipioAsignado,
      avatarPath: avatarPath,
    );
  }

  String get iniciales {
    final parts = nombre.split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}';
    return nombre.isNotEmpty ? nombre[0] : '?';
  }
}
