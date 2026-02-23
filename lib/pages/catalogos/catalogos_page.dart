import 'package:flutter/material.dart';
import 'package:nethive_neo/theme/theme.dart';
import 'package:nethive_neo/widgets/shared/section_header.dart';

class CatalogosPage extends StatelessWidget {
  const CatalogosPage({super.key});

  static const _categorias = [
    {'clave': 'alumbrado',    'label': 'Alumbrado Público',  'icon': Icons.lightbulb_outline,   'count': 4, 'color': 0xFFD97706},
    {'clave': 'bacheo',       'label': 'Bacheo y Pavimento', 'icon': Icons.construction,         'count': 3, 'color': 0xFF7A1E3A},
    {'clave': 'basura',       'label': 'Recolección Basura', 'icon': Icons.delete_outline,       'count': 3, 'color': 0xFF2D7A4F},
    {'clave': 'agua_drenaje', 'label': 'Agua y Drenaje',     'icon': Icons.water_drop_outlined,  'count': 5, 'color': 0xFF1D4ED8},
    {'clave': 'señalizacion', 'label': 'Señalización Vial',  'icon': Icons.traffic,              'count': 4, 'color': 0xFF64748B},
    {'clave': 'seguridad',    'label': 'Seguridad Pública',  'icon': Icons.security,             'count': 2, 'color': 0xFFB91C1C},
  ];

  static const _zonas = [
    {'nombre': 'Zona Centro', 'tipo': 'comercial', 'tecnicos': 3},
    {'nombre': 'Zona Norte Ensenada', 'tipo': 'residencial', 'tecnicos': 4},
    {'nombre': 'Zona Puerto', 'tipo': 'industrial', 'tecnicos': 2},
    {'nombre': 'Zona Chapultepec', 'tipo': 'residencial', 'tecnicos': 2},
    {'nombre': 'Zona Gobierno', 'tipo': 'institucional', 'tecnicos': 2},
  ];

  static const _dependencias = [
    {'nombre': 'Servicios Públicos', 'responsable': 'Ing. Laura Mendoza', 'categorias': 'Basura, Bacheo'},
    {'nombre': 'Electricidad Municipal', 'responsable': 'Ing. Pedro Ontiveros', 'categorias': 'Alumbrado'},
    {'nombre': 'CESPE', 'responsable': 'Ing. Maria F. Torres', 'categorias': 'Agua/Drenaje'},
    {'nombre': 'Tránsito Municipal', 'responsable': 'Lic. Jorge Espinoza', 'categorias': 'Señalización'},
    {'nombre': 'SSP Ensenada', 'responsable': 'C. Roberto Vega', 'categorias': 'Seguridad'},
  ];

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const SectionHeader(
          title: 'Catálogos del Sistema',
          subtitle: 'Categorías, zonas y dependencias configuradas para Ensenada',
        ),
        const SizedBox(height: 24),

        _SectionTitle(icon: Icons.category, label: 'Categorías de Incidencia', theme: theme),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 240, childAspectRatio: 2.0, crossAxisSpacing: 12, mainAxisSpacing: 12),
          itemCount: _categorias.length,
          itemBuilder: (_, i) {
            final c = _categorias[i];
            final color = Color(c['color'] as int);
            return Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: color.withOpacity(0.08), borderRadius: BorderRadius.circular(10),
                border: Border.all(color: color.withOpacity(0.25))),
              child: Row(children: [
                Icon(c['icon'] as IconData, color: color, size: 22),
                const SizedBox(width: 10),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text(c['label'] as String, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: theme.textPrimary)),
                  Text('${c['count']} subcategorías', style: TextStyle(fontSize: 11, color: theme.textSecondary)),
                ])),
              ]),
            );
          },
        ),
        const SizedBox(height: 28),

        _SectionTitle(icon: Icons.map_outlined, label: 'Zonas Operativas — Ensenada', theme: theme),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(color: theme.surface, borderRadius: BorderRadius.circular(10), border: Border.all(color: theme.border)),
          child: Column(children: _zonas.asMap().entries.map((e) {
            final i = e.key; final z = e.value;
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(border: i == 0 ? null : Border(top: BorderSide(color: theme.border.withOpacity(0.4)))),
              child: Row(children: [
                Icon(Icons.place_outlined, size: 16, color: theme.primaryColor),
                const SizedBox(width: 10),
                Expanded(child: Text(z['nombre'] as String, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: theme.textPrimary))),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(color: theme.border.withOpacity(0.4), borderRadius: BorderRadius.circular(6)),
                  child: Text(z['tipo'] as String, style: TextStyle(fontSize: 11, color: theme.textSecondary))),
                const SizedBox(width: 12),
                Icon(Icons.engineering, size: 14, color: theme.textSecondary),
                const SizedBox(width: 4),
                Text('${z['tecnicos']} técnicos', style: TextStyle(fontSize: 11, color: theme.textSecondary)),
              ]),
            );
          }).toList()),
        ),
        const SizedBox(height: 28),

        _SectionTitle(icon: Icons.business, label: 'Dependencias', theme: theme),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(color: theme.surface, borderRadius: BorderRadius.circular(10), border: Border.all(color: theme.border)),
          child: Column(children: _dependencias.asMap().entries.map((e) {
            final i = e.key; final d = e.value;
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(border: i == 0 ? null : Border(top: BorderSide(color: theme.border.withOpacity(0.4)))),
              child: Row(children: [
                CircleAvatar(radius: 14, backgroundColor: theme.primarySoft, child: Icon(Icons.business, size: 14, color: theme.primaryColor)),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(d['nombre'] as String, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: theme.textPrimary)),
                  Text('Responsable: ${d['responsable']}', style: TextStyle(fontSize: 11, color: theme.textSecondary)),
                ])),
                Text(d['categorias'] as String, style: TextStyle(fontSize: 11, color: theme.primaryColor, fontWeight: FontWeight.w600)),
              ]),
            );
          }).toList()),
        ),
      ]),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.icon, required this.label, required this.theme});
  final IconData icon; final String label; final AppTheme theme;
  @override
  Widget build(BuildContext context) => Row(children: [
    Icon(icon, size: 16, color: theme.primaryColor),
    const SizedBox(width: 6),
    Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: theme.textPrimary)),
    const SizedBox(width: 10),
    Expanded(child: Divider(color: theme.border)),
  ]);
}
