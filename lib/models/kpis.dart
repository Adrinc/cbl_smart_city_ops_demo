class KpiNacional {
  final int incidenciasActivas;
  final int criticas;
  final double cumplimientoSla;
  final int porVencer;
  final int tecnicosActivos;
  final Map<String, int> porEstado;
  final Map<String, int> porCategoria;
  final List<double> tendencia7Dias;      // ultimos 7 dias recibidas
  final List<double> tendenciaResueltas;  // ultimos 7 dias resueltas
  final List<double> tendenciaCriticas;   // ultimos 7 dias criticas

  const KpiNacional({
    required this.incidenciasActivas,
    required this.criticas,
    required this.cumplimientoSla,
    required this.porVencer,
    required this.tecnicosActivos,
    required this.porEstado,
    required this.porCategoria,
    required this.tendencia7Dias,
    required this.tendenciaResueltas,
    required this.tendenciaCriticas,
  });
}

class KpiEstatal {
  final String estadoNombre;
  final int incidenciasActivas;
  final int criticas;
  final double cumplimientoSla;
  final int porVencer;
  final int tecnicosActivos;
  final int enProceso;
  final Map<String, int> porMunicipio;

  const KpiEstatal({
    required this.estadoNombre,
    required this.incidenciasActivas,
    required this.criticas,
    required this.cumplimientoSla,
    required this.porVencer,
    required this.tecnicosActivos,
    required this.enProceso,
    required this.porMunicipio,
  });
}

class KpiMunicipal {
  final String municipioNombre;
  final int incidenciasActivas;
  final int criticas;
  final double cumplimientoSla;
  final int abiertas;
  final int porVencer;
  final int tecnicosActivos;

  const KpiMunicipal({
    required this.municipioNombre,
    required this.incidenciasActivas,
    required this.criticas,
    required this.cumplimientoSla,
    required this.abiertas,
    required this.porVencer,
    required this.tecnicosActivos,
  });
}

class AlertaEstatal {
  final String estado;
  final String categoria;
  final String prioridad;
  final DateTime expira;
  final String descripcion;

  const AlertaEstatal({
    required this.estado,
    required this.categoria,
    required this.prioridad,
    required this.expira,
    required this.descripcion,
  });
}
