class UsuarioSistema {
  final String id;
  final String nombre;
  final String email;
  final String rol;       // admin | operador_nacional | operador_estatal | operador_municipal | supervisor
  final String estatus;   // activo | inactivo | bloqueado
  final DateTime ultimoAcceso;
  final String? avatarPath;
  final String nivel;     // nacional | estatal | municipal

  const UsuarioSistema({
    required this.id,
    required this.nombre,
    required this.email,
    required this.rol,
    required this.estatus,
    required this.ultimoAcceso,
    this.avatarPath,
    required this.nivel,
  });

  UsuarioSistema copyWith({String? estatus, String? rol}) {
    return UsuarioSistema(
      id: id,
      nombre: nombre,
      email: email,
      rol: rol ?? this.rol,
      estatus: estatus ?? this.estatus,
      ultimoAcceso: ultimoAcceso,
      avatarPath: avatarPath,
      nivel: nivel,
    );
  }

  String get iniciales {
    final parts = nombre.split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}';
    return nombre.isNotEmpty ? nombre[0] : '?';
  }

  String get rolLabel {
    const Map<String, String> labels = {
      'admin':              'Administrador',
      'operador_nacional':  'Operador Nacional',
      'operador_estatal':   'Operador Estatal',
      'operador_municipal': 'Operador Municipal',
      'supervisor':         'Supervisor',
    };
    return labels[rol] ?? rol;
  }
}
