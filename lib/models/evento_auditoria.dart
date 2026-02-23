class EventoAuditoria {
  final String id;
  final DateTime timestamp;
  final String usuario;
  final String nivel;       // nacional | estatal | municipal
  final String modulo;
  final String accion;
  final String descripcion;
  final String? referenciaId;

  const EventoAuditoria({
    required this.id,
    required this.timestamp,
    required this.usuario,
    required this.nivel,
    required this.modulo,
    required this.accion,
    required this.descripcion,
    this.referenciaId,
  });
}
