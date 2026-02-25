import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:nethive_neo/helpers/constants.dart';
import 'package:nethive_neo/providers/providers.dart';
import 'package:nethive_neo/theme/theme.dart';

class _Item {
  final String label;
  final IconData icon;
  final String route;
  const _Item(this.label, this.icon, this.route);
}

class _Section {
  final String? title;
  final List<_Item> items;
  const _Section({this.title, required this.items});
}

class SidebarWidget extends StatelessWidget {
  final String currentPath;
  final bool isExpanded;
  final bool showUserBlock;
  const SidebarWidget(
      {super.key,
      required this.currentPath,
      required this.isExpanded,
      this.showUserBlock = false});

  // Menú limpio por nivel (SIN cross-level links — eso lo maneja el selector)
  List<_Section> _sectionsFor(NivelTerritorial nivel) {
    switch (nivel) {
      case NivelTerritorial.nacional:
        return [
          _Section(items: [
            _Item('Visión Nacional', Icons.public, routeNacional),
            _Item('Territorio / Mapa', Icons.map_outlined, routeMapa),
            _Item(
                'Dependencias', Icons.account_balance_outlined, routeCatalogos),
            _Item('Supervisión', Icons.supervisor_account_outlined,
                routeReportes),
            _Item('Usuarios', Icons.manage_accounts_outlined, routeUsuarios),
            _Item('Configuración', Icons.settings_outlined, routeConfiguracion),
          ])
        ];

      case NivelTerritorial.estatal:
        return [
          _Section(items: [
            _Item(
                'Centro Estatal', Icons.account_balance_outlined, routeEstatal),
            _Item('Territorio Estatal', Icons.map_outlined, routeMapa),
            _Item('Catálogos', Icons.category_outlined, routeCatalogos),
            _Item('Supervisión', Icons.supervisor_account_outlined,
                routeReportes),
            _Item('Usuarios', Icons.manage_accounts_outlined, routeUsuarios),
            _Item('Configuración', Icons.settings_outlined, routeConfiguracion),
          ])
        ];

      case NivelTerritorial.municipal:
        return [
          _Section(items: [
            _Item('Dashboard Municipal', Icons.dashboard_outlined,
                routeMunicipal),
          ]),
          _Section(title: 'OPERACIÓN', items: [
            _Item('Órdenes / Incidencias', Icons.assignment_outlined,
                routeOrdenes),
            _Item('Bandeja IA', Icons.smart_toy_outlined, routeBandejaIA),
            _Item(
                'Aprobaciones', Icons.check_circle_outline, routeAprobaciones),
            _Item('Mapa Operativo', Icons.map_outlined, routeMapa),
          ]),
          _Section(title: 'RECURSOS', items: [
            _Item('Técnicos', Icons.engineering_outlined, routeTecnicos),
            _Item('Inventario', Icons.inventory_2_outlined, routeInventario),
          ]),
          _Section(title: 'ANALÍTICA', items: [
            _Item('SLA Monitor', Icons.timer_outlined, routeSla),
            _Item('Reportes', Icons.bar_chart_outlined, routeReportes),
          ]),
          _Section(title: 'ADMIN', items: [
            _Item('Configuración', Icons.settings_outlined, routeConfiguracion),
            _Item('Catálogos', Icons.category_outlined, routeCatalogos),
            _Item('Usuarios', Icons.manage_accounts_outlined, routeUsuarios),
            _Item('Auditoría', Icons.history_outlined, routeAuditoria),
          ]),
        ];
    }
  }

  bool _isActive(String route) => currentPath == route;

  @override
  Widget build(BuildContext context) {
    final appLevel = context.watch<AppLevelProvider>();
    final sections = _sectionsFor(appLevel.nivel);

    return Container(
      color: const Color(0xFF5C1528),
      child: Column(children: [
        _Header(isExpanded: isExpanded),
        const Divider(color: Color(0xFF7A3048), height: 1),

        // ── PERFIL DE USUARIO (solo en drawer) ──
        if (showUserBlock) ...[
          _UserBlock(isExpanded: isExpanded),
          const Divider(color: Color(0xFF7A3048), height: 1),
        ],

        // ── SELECTOR DE NIVEL (prominente, antes del menú) ──
        _NivelSelector(isExpanded: isExpanded),

        // ── SELECTOR DE TERRITORIO (estado / municipio) ──
        _TerritorioSelector(isExpanded: isExpanded),

        const Divider(color: Color(0xFF7A3048), height: 1),

        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(vertical: 8),
            children: sections
                .map((s) => _SectionBlock(
                      section: s,
                      currentPath: currentPath,
                      isExpanded: isExpanded,
                      isActive: _isActive,
                    ))
                .toList(),
          ),
        ),
        const Divider(color: Color(0xFF7A3048), height: 1),
        _SalirBtn(isExpanded: isExpanded),
      ]),
    );
  }
}

// ── NivelSelector ─────────────────────────────────────────────────────────────
class _NivelSelector extends StatelessWidget {
  final bool isExpanded;
  const _NivelSelector({required this.isExpanded});

  @override
  Widget build(BuildContext context) {
    final appLevel = context.watch<AppLevelProvider>();
    final nivel = appLevel.nivel;

    const opts = [
      (NivelTerritorial.nacional, 'Nacional', Icons.public, routeNacional),
      (
        NivelTerritorial.estatal,
        'Estatal',
        Icons.account_balance,
        routeEstatal
      ),
      (
        NivelTerritorial.municipal,
        'Municipal',
        Icons.location_city,
        routeMunicipal
      ),
    ];

    if (!isExpanded) {
      // Modo colapsado: icono + punto activo
      return Column(children: [
        for (final (n, lbl, ico, _) in opts)
          _CollapsedNivelBtn(
            icon: ico,
            label: lbl,
            isActive: nivel == n,
            onTap: () {
              appLevel.setNivel(n);
              context.go(opts.firstWhere((o) => o.$1 == n).$4);
            },
          ),
      ]);
    }

    // Modo expandido: pill segmentada
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 4, bottom: 6),
            child: Text('NIVEL TERRITORIAL',
                style: TextStyle(
                  color: Color(0xFFB8909A),
                  fontSize: 9.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.3,
                )),
          ),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF3D0E1C),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFF7A3048)),
            ),
            child: Column(children: [
              for (int i = 0; i < opts.length; i++) ...[
                if (i > 0)
                  Divider(
                      height: 1,
                      color: const Color(0xFF7A3048).withOpacity(0.5)),
                _ExpandedNivelBtn(
                  icon: opts[i].$3,
                  label: opts[i].$2,
                  route: opts[i].$4,
                  nivelTgt: opts[i].$1,
                  isActive: nivel == opts[i].$1,
                ),
              ],
            ]),
          ),
        ],
      ),
    );
  }
}

class _ExpandedNivelBtn extends StatelessWidget {
  final IconData icon;
  final String label, route;
  final NivelTerritorial nivelTgt;
  final bool isActive;
  const _ExpandedNivelBtn(
      {required this.icon,
      required this.label,
      required this.route,
      required this.nivelTgt,
      required this.isActive});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: () {
        context.read<AppLevelProvider>().setNivel(nivelTgt);
        context.go(route);
        if (Navigator.of(context).canPop()) Navigator.of(context).maybePop();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF7A1E3A) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(children: [
          Icon(icon,
              size: 16,
              color: isActive ? Colors.white : const Color(0xFFB8909A)),
          const SizedBox(width: 10),
          Expanded(
              child: Text(label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                    color: isActive ? Colors.white : const Color(0xFFD4B8C0),
                  ))),
          if (isActive)
            Container(
              width: 7,
              height: 7,
              decoration: const BoxDecoration(
                  color: Colors.white, shape: BoxShape.circle),
            ),
        ]),
      ),
    );
  }
}

class _CollapsedNivelBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  const _CollapsedNivelBtn(
      {required this.icon,
      required this.label,
      required this.isActive,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: label,
      child: InkWell(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          padding: const EdgeInsets.all(9),
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFF7A1E3A) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon,
              size: 18,
              color: isActive ? Colors.white : const Color(0xFFB8909A)),
        ),
      ),
    );
  }
}

// ── TerritorioSelector ────────────────────────────────────────────────────────
/// Muestra dropdowns de Estado y Municipio según el nivel activo.
/// Solo visible en modo expandido. Seleccionar otro estado/municipio
/// muestra un aviso demo — en producción se navegaría al territorio real.
class _TerritorioSelector extends StatelessWidget {
  final bool isExpanded;
  const _TerritorioSelector({required this.isExpanded});

  static const _estados = [
    'Aguascalientes',
    'Baja California Norte',
    'Baja California Sur',
    'Campeche',
    'Chiapas',
    'Chihuahua',
    'Ciudad de México',
    'Coahuila',
    'Colima',
    'Durango',
    'Estado de México',
    'Guanajuato',
    'Guerrero',
    'Hidalgo',
    'Jalisco',
    'Michoacán',
    'Morelos',
    'Nayarit',
    'Nuevo León',
    'Oaxaca',
    'Puebla',
    'Querétaro',
    'Quintana Roo',
    'San Luis Potosí',
    'Sinaloa',
    'Sonora',
    'Tabasco',
    'Tamaulipas',
    'Tlaxcala',
    'Veracruz',
    'Yucatán',
    'Zacatecas',
  ];

  static const _municipiosBC = [
    'Tijuana',
    'Mexicali',
    'Ensenada',
    'Tecate',
    'Playas de Rosarito',
  ];

  void _mostrarAvisoDemo(BuildContext context, String nombre) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(children: [
          const Icon(Icons.info_outline, color: Colors.white, size: 16),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'En producción accederías a $nombre. '
              'Esta demo opera sobre Baja California Norte / Tijuana.',
              style: const TextStyle(fontSize: 12),
            ),
          ),
        ]),
        backgroundColor: const Color(0xFF7A1E3A),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final nivel = context.watch<AppLevelProvider>().nivel;

    // Solo mostramos en niveles estatal o municipal (y solo expandido)
    if (nivel == NivelTerritorial.nacional || !isExpanded) {
      return const SizedBox.shrink();
    }

    const labelStyle = TextStyle(
      color: Color(0xFFB8909A),
      fontSize: 9.5,
      fontWeight: FontWeight.w700,
      letterSpacing: 1.3,
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Dropdown Estado ─────────────────────────────────────────────
          const Padding(
            padding: EdgeInsets.only(left: 4, bottom: 4),
            child: Text('ESTADO', style: labelStyle),
          ),
          _DropdownTerritorio(
            value: 'Baja California Norte',
            items: _estados,
            icon: Icons.account_balance_outlined,
            onChanged: (v) {
              if (v != null && v != 'Baja California Norte') {
                _mostrarAvisoDemo(context, v);
              }
            },
          ),

          // ── Dropdown Municipio (solo en nivel municipal) ─────────────────
          if (nivel == NivelTerritorial.municipal) ...[
            const SizedBox(height: 8),
            const Padding(
              padding: EdgeInsets.only(left: 4, bottom: 4),
              child: Text('MUNICIPIO', style: labelStyle),
            ),
            _DropdownTerritorio(
              value: 'Tijuana',
              items: _municipiosBC,
              icon: Icons.location_city_outlined,
              onChanged: (v) {
                if (v != null && v != 'Tijuana') {
                  _mostrarAvisoDemo(context, v);
                }
              },
            ),
          ],

          const SizedBox(height: 4),
        ],
      ),
    );
  }
}

// ── DropdownTerritorio ────────────────────────────────────────────────────────
class _DropdownTerritorio extends StatelessWidget {
  final String value;
  final List<String> items;
  final IconData icon;
  final ValueChanged<String?> onChanged;

  const _DropdownTerritorio({
    required this.value,
    required this.items,
    required this.icon,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF3D0E1C),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF7A3048)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          iconSize: 16,
          icon:
              const Icon(Icons.expand_more, color: Color(0xFFB8909A), size: 16),
          dropdownColor: const Color(0xFF3D0E1C),
          style: const TextStyle(
            color: Color(0xFFF1E8EB),
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
          ),
          selectedItemBuilder: (context) => items
              .map((item) => Row(children: [
                    Icon(icon, size: 14, color: const Color(0xFFD4B8C0)),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        item,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFFF1E8EB),
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ]))
              .toList(),
          items: items
              .map((item) => DropdownMenuItem(
                    value: item,
                    child: Row(children: [
                      if (item == value)
                        const Icon(Icons.circle,
                            size: 6, color: Color(0xFF7A1E3A))
                      else
                        const SizedBox(width: 6),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          item,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: item == value
                                ? const Color(0xFFF1E8EB)
                                : const Color(0xFFD4B8C0),
                            fontSize: 12.5,
                            fontWeight: item == value
                                ? FontWeight.w700
                                : FontWeight.w400,
                          ),
                        ),
                      ),
                    ]),
                  ))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

// ── Header ─────────────────────────────────────────────────────────────────────
class _Header extends StatelessWidget {
  final bool isExpanded;
  const _Header({required this.isExpanded});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: topbarHeight,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Row(children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: const Color(0xFF7A1E3A),
              borderRadius: BorderRadius.circular(8),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                'assets/images/favicon.png',
                width: 32,
                height: 32,
                fit: BoxFit.contain,
              ),
            ),
          ),
          if (isExpanded) ...[
            const SizedBox(width: 10),
            Expanded(
                child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('Terranex',
                    style: TextStyle(
                      color: Color(0xFFF1E8EB),
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      letterSpacing: 0.5,
                    )),
                Text('Smart City Ops',
                    style: TextStyle(
                      color: Color(0xFFB8909A),
                      fontSize: 10,
                      letterSpacing: 0.3,
                    )),
              ],
            )),
          ],
        ]),
      ),
    );
  }
}

// ── Section Block ──────────────────────────────────────────────────────────────
class _SectionBlock extends StatelessWidget {
  final _Section section;
  final String currentPath;
  final bool isExpanded;
  final bool Function(String) isActive;

  const _SectionBlock({
    required this.section,
    required this.currentPath,
    required this.isExpanded,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      if (section.title != null)
        isExpanded
            ? Padding(
                padding: const EdgeInsets.only(left: 16, top: 14, bottom: 4),
                child: Text(section.title!,
                    style: const TextStyle(
                      color: Color(0xFFB8909A),
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.2,
                    )),
              )
            : const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Divider(color: Color(0xFF7A3048), height: 1),
              ),
      ...section.items.map((item) => _NavTile(
            item: item,
            active: isActive(item.route),
            isExpanded: isExpanded,
          )),
    ]);
  }
}

// ── Nav Tile ───────────────────────────────────────────────────────────────────
class _NavTile extends StatelessWidget {
  final _Item item;
  final bool active;
  final bool isExpanded;

  const _NavTile(
      {required this.item, required this.active, required this.isExpanded});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: isExpanded ? '' : item.label,
      child: InkWell(
        onTap: () {
          context.go(item.route);
          if (Navigator.of(context).canPop()) Navigator.of(context).maybePop();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
          padding: EdgeInsets.symmetric(
              horizontal: isExpanded ? 12 : 14, vertical: 9),
          decoration: BoxDecoration(
            color: active ? const Color(0xFF7A1E3A) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(children: [
            Icon(item.icon,
                size: 18,
                color: active ? Colors.white : const Color(0xFFB8909A)),
            if (isExpanded) ...[
              const SizedBox(width: 10),
              Expanded(
                  child: Text(item.label,
                      style: TextStyle(
                        color: active ? Colors.white : const Color(0xFFD4B8C0),
                        fontSize: 13,
                        fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                      ),
                      overflow: TextOverflow.ellipsis)),
            ],
          ]),
        ),
      ),
    );
  }
}

// ── User Block (Drawer — parte superior) ────────────────────────────────────
class _UserBlock extends StatelessWidget {
  final bool isExpanded;
  const _UserBlock({required this.isExpanded});

  void _showMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _UserBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _showMenu(context),
        splashColor: const Color(0xFF9B2C4E).withOpacity(0.2),
        highlightColor: const Color(0xFF9B2C4E).withOpacity(0.1),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(children: [
            // Avatar con indicador de estado
            Stack(children: [
              CircleAvatar(
                radius: 22,
                backgroundImage:
                    const AssetImage('assets/images/avatares/Maria.png'),
                onBackgroundImageError: (_, __) {},
                backgroundColor: const Color(0xFF9B2C4E),
              ),
              Positioned(
                bottom: 1,
                right: 1,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2D7A4F),
                    shape: BoxShape.circle,
                    border:
                        Border.all(color: const Color(0xFF5C1528), width: 2),
                  ),
                ),
              ),
            ]),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Admin Terranex',
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Colors.white),
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF7A1E3A).withOpacity(0.55),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                            color: const Color(0xFF9B2C4E).withOpacity(0.6)),
                      ),
                      child: const Text('Administrador',
                          style: TextStyle(
                              fontSize: 10,
                              color: Color(0xFFD4B8C0),
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.3)),
                    ),
                  ]),
            ),
            const Icon(Icons.unfold_more, size: 18, color: Color(0xFF9B7A85)),
          ]),
        ),
      ),
    );
  }
}

// ── User Bottom Sheet ─────────────────────────────────────────────────────────
class _UserBottomSheet extends StatelessWidget {
  const _UserBottomSheet();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        top: false,
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          // Handle
          Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 4),
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                  color: const Color(0xFFE3E8EF),
                  borderRadius: BorderRadius.circular(2)),
            ),
          ),
          // Cabecera
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
            child: Row(children: [
              Stack(children: [
                CircleAvatar(
                  radius: 26,
                  backgroundImage:
                      const AssetImage('assets/images/avatares/Maria.png'),
                  onBackgroundImageError: (_, __) {},
                  backgroundColor: const Color(0xFF9B2C4E),
                ),
                Positioned(
                  bottom: 1,
                  right: 1,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2D7A4F),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
              ]),
              const SizedBox(width: 14),
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    const Text('Admin Terranex',
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F172A))),
                    const SizedBox(height: 3),
                    Row(children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF7A1E3A).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                              color: const Color(0xFF7A1E3A).withOpacity(0.3)),
                        ),
                        child: const Text('Administrador',
                            style: TextStyle(
                                fontSize: 10,
                                color: Color(0xFF7A1E3A),
                                fontWeight: FontWeight.w700)),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        width: 7,
                        height: 7,
                        decoration: const BoxDecoration(
                          color: Color(0xFF2D7A4F),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Text('Activo',
                          style: TextStyle(
                              fontSize: 10,
                              color: Color(0xFF2D7A4F),
                              fontWeight: FontWeight.w600)),
                    ]),
                  ])),
            ]),
          ),
          const Divider(height: 1, color: Color(0xFFE3E8EF)),
          // Opciones
          _SheetOpt(
              icon: Icons.person_outline,
              label: 'Mi perfil',
              onTap: () => Navigator.pop(context)),
          _SheetOpt(
              icon: Icons.history_outlined,
              label: 'Actividad reciente',
              onTap: () => Navigator.pop(context)),
          _SheetOpt(
              icon: Icons.settings_outlined,
              label: 'Configuración',
              onTap: () {
                Navigator.pop(context);
                context.go('/configuracion');
              }),
          _SheetOpt(
              icon: Icons.help_outline,
              label: 'Centro de ayuda',
              onTap: () => Navigator.pop(context)),
          const Divider(height: 1, color: Color(0xFFE3E8EF)),
          _SheetOpt(
            icon: Icons.logout,
            label: 'Cerrar sesión',
            isDestructive: true,
            onTap: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content:
                      Text('Esta es una demo — la sesión no puede cerrarse.'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
          const SizedBox(height: 8),
        ]),
      ),
    );
  }
}

// ── Sheet Option ──────────────────────────────────────────────────────────────
class _SheetOpt extends StatelessWidget {
  const _SheetOpt({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isDestructive = false,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    final color =
        isDestructive ? const Color(0xFFB91C1C) : const Color(0xFF0F172A);
    final iconColor =
        isDestructive ? const Color(0xFFB91C1C) : const Color(0xFF475569);
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(children: [
          Icon(icon, size: 18, color: iconColor),
          const SizedBox(width: 14),
          Text(label,
              style: TextStyle(
                  fontSize: 14,
                  color: color,
                  fontWeight:
                      isDestructive ? FontWeight.w600 : FontWeight.w400)),
        ]),
      ),
    );
  }
}

// ── Salir Button ───────────────────────────────────────────────────────────────
class _SalirBtn extends StatelessWidget {
  final bool isExpanded;
  const _SalirBtn({required this.isExpanded});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Tooltip(
        message: isExpanded ? '' : 'Salir de la Demo',
        child: InkWell(
          onTap: () async {
            await launchUrl(Uri.parse(exitDemoUrl), webOnlyWindowName: '_self');
          },
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: EdgeInsets.symmetric(
                horizontal: isExpanded ? 12 : 14, vertical: 9),
            decoration: BoxDecoration(
              color: const Color(0xFF7A1E3A).withOpacity(0.25),
              borderRadius: BorderRadius.circular(8),
              border:
                  Border.all(color: const Color(0xFF9B2C4E).withOpacity(0.5)),
            ),
            child: Row(children: [
              const Icon(Icons.logout, size: 16, color: Color(0xFFD4B8C0)),
              if (isExpanded) ...[
                const SizedBox(width: 8),
                const Text('Salir de la Demo',
                    style: TextStyle(
                      color: Color(0xFFD4B8C0),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    )),
              ],
            ]),
          ),
        ),
      ),
    );
  }
}
