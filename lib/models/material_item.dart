class MaterialItem {
  final String id;
  final String clave;
  final String descripcion;
  final String categoria;   // electrico | pavimento | senales | saneamiento | herramientas | general
  final String unidad;      // PZA | KG | MTO | CJA | LT | JGO
  final int stockActual;
  final int stockMinimo;
  final int reservado;
  final String estatus;     // disponible | bajo_stock | agotado

  const MaterialItem({
    required this.id,
    required this.clave,
    required this.descripcion,
    required this.categoria,
    required this.unidad,
    required this.stockActual,
    required this.stockMinimo,
    required this.reservado,
    required this.estatus,
  });

  int get disponibleReal => stockActual - reservado;

  MaterialItem copyWith({int? stockActual, int? reservado, String? estatus}) {
    return MaterialItem(
      id: id,
      clave: clave,
      descripcion: descripcion,
      categoria: categoria,
      unidad: unidad,
      stockActual: stockActual ?? this.stockActual,
      stockMinimo: stockMinimo,
      reservado: reservado ?? this.reservado,
      estatus: estatus ?? this.estatus,
    );
  }

  static String calcEstatus(int stock, int minimo) {
    if (stock == 0) return 'agotado';
    if (stock <= minimo) return 'bajo_stock';
    return 'disponible';
  }
}
