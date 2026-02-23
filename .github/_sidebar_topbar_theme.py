
import pathlib
ROOT = pathlib.Path(r"g:\TRABAJO\FLUTTER\cbl_portal_demos\sistema_smart_sistem_demo")

# ── SIDEBAR ────────────────────────────────────────────────────────────────────
sidebar = r'''import 'package:flutter/material.dart';
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
  const SidebarWidget({super.key, required this.currentPath, required this.isExpanded});

  // Menú limpio por nivel (SIN cross-level links — eso lo maneja el selector)
  List<_Section> _sectionsFor(NivelTerritorial nivel) {
    switch (nivel) {
      case NivelTerritorial.nacional:
        return [_Section(items: [
          _Item('Visión Nacional',    Icons.public,                      routeNacional),
          _Item('Territorio / Mapa',  Icons.map_outlined,                routeMapa),
          _Item('Dependencias',       Icons.account_balance_outlined,     routeCatalogos),
          _Item('Supervisión',        Icons.supervisor_account_outlined,  routeReportes),
          _Item('Usuarios',           Icons.manage_accounts_outlined,     routeUsuarios),
          _Item('Configuración',      Icons.settings_outlined,            routeConfiguracion),
        ])];

      case NivelTerritorial.estatal:
        return [_Section(items: [
          _Item('Centro Estatal',     Icons.account_balance_outlined,    routeEstatal),
          _Item('Territorio Estatal', Icons.map_outlined,                routeMapa),
          _Item('Catálogos',          Icons.category_outlined,           routeCatalogos),
          _Item('Supervisión',        Icons.supervisor_account_outlined, routeReportes),
          _Item('Usuarios',           Icons.manage_accounts_outlined,    routeUsuarios),
          _Item('Configuración',      Icons.settings_outlined,           routeConfiguracion),
        ])];

      case NivelTerritorial.municipal:
        return [
          _Section(items: [
            _Item('Dashboard Municipal', Icons.dashboard_outlined, routeMunicipal),
          ]),
          _Section(title: 'OPERACIÓN', items: [
            _Item('Órdenes / Incidencias', Icons.assignment_outlined,  routeOrdenes),
            _Item('Bandeja IA',            Icons.smart_toy_outlined,   routeBandejaIA),
            _Item('Aprobaciones',          Icons.check_circle_outline, routeAprobaciones),
            _Item('Mapa Operativo',        Icons.map_outlined,         routeMapa),
          ]),
          _Section(title: 'RECURSOS', items: [
            _Item('Técnicos',   Icons.engineering_outlined, routeTecnicos),
            _Item('Inventario', Icons.inventory_2_outlined, routeInventario),
          ]),
          _Section(title: 'ANALÍTICA', items: [
            _Item('SLA Monitor', Icons.timer_outlined,     routeSla),
            _Item('Reportes',    Icons.bar_chart_outlined, routeReportes),
          ]),
          _Section(title: 'ADMIN', items: [
            _Item('Configuración', Icons.settings_outlined,        routeConfiguracion),
            _Item('Catálogos',     Icons.category_outlined,        routeCatalogos),
            _Item('Usuarios',      Icons.manage_accounts_outlined, routeUsuarios),
            _Item('Auditoría',     Icons.history_outlined,         routeAuditoria),
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

        // ── SELECTOR DE NIVEL (prominente, antes del menú) ──
        _NivelSelector(isExpanded: isExpanded),
        const Divider(color: Color(0xFF7A3048), height: 1),

        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(vertical: 8),
            children: sections.map((s) => _SectionBlock(
              section: s,
              currentPath: currentPath,
              isExpanded: isExpanded,
              isActive: _isActive,
            )).toList(),
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
    final nivel    = appLevel.nivel;

    const opts = [
      (NivelTerritorial.nacional,  'Nacional',  Icons.public,              routeNacional),
      (NivelTerritorial.estatal,   'Estatal',   Icons.account_balance,     routeEstatal),
      (NivelTerritorial.municipal, 'Municipal', Icons.location_city,       routeMunicipal),
    ];

    if (!isExpanded) {
      // Modo colapsado: icono + punto activo
      return Column(children: [
        for (final (n, lbl, ico, _) in opts) _CollapsedNivelBtn(
          icon: ico, label: lbl, isActive: nivel == n,
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
            child: Text('NIVEL TERRITORIAL', style: TextStyle(
              color: Color(0xFFB8909A), fontSize: 9.5,
              fontWeight: FontWeight.w700, letterSpacing: 1.3,
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
                if (i > 0) Divider(height: 1, color: const Color(0xFF7A3048).withOpacity(0.5)),
                _ExpandedNivelBtn(
                  icon:     opts[i].$3,
                  label:    opts[i].$2,
                  route:    opts[i].$4,
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
  const _ExpandedNivelBtn({required this.icon, required this.label, required this.route,
    required this.nivelTgt, required this.isActive});

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
          Icon(icon, size: 16,
            color: isActive ? Colors.white : const Color(0xFFB8909A)),
          const SizedBox(width: 10),
          Expanded(child: Text(label, style: TextStyle(
            fontSize: 13,
            fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
            color: isActive ? Colors.white : const Color(0xFFD4B8C0),
          ))),
          if (isActive)
            Container(
              width: 7, height: 7,
              decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
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
  const _CollapsedNivelBtn({required this.icon, required this.label, required this.isActive, required this.onTap});

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
          child: Icon(icon, size: 18,
            color: isActive ? Colors.white : const Color(0xFFB8909A)),
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
            width: 32, height: 32,
            decoration: BoxDecoration(
              color: const Color(0xFF7A1E3A),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.location_city, color: Colors.white, size: 18),
          ),
          if (isExpanded) ...[
            const SizedBox(width: 10),
            Expanded(child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('Terranex', style: TextStyle(
                  color: Color(0xFFF1E8EB), fontWeight: FontWeight.w700, fontSize: 15, letterSpacing: 0.5,
                )),
                Text('Smart City Ops', style: TextStyle(
                  color: Color(0xFFB8909A), fontSize: 10, letterSpacing: 0.3,
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
    required this.section, required this.currentPath,
    required this.isExpanded, required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      if (section.title != null)
        isExpanded
            ? Padding(
                padding: const EdgeInsets.only(left: 16, top: 14, bottom: 4),
                child: Text(section.title!, style: const TextStyle(
                  color: Color(0xFFB8909A), fontSize: 10,
                  fontWeight: FontWeight.w600, letterSpacing: 1.2,
                )),
              )
            : const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Divider(color: Color(0xFF7A3048), height: 1),
              ),
      ...section.items.map((item) => _NavTile(
        item: item, active: isActive(item.route), isExpanded: isExpanded,
      )),
    ]);
  }
}

// ── Nav Tile ───────────────────────────────────────────────────────────────────
class _NavTile extends StatelessWidget {
  final _Item item;
  final bool active;
  final bool isExpanded;

  const _NavTile({required this.item, required this.active, required this.isExpanded});

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
          padding: EdgeInsets.symmetric(horizontal: isExpanded ? 12 : 14, vertical: 9),
          decoration: BoxDecoration(
            color: active ? const Color(0xFF7A1E3A) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(children: [
            Icon(item.icon, size: 18,
              color: active ? Colors.white : const Color(0xFFB8909A)),
            if (isExpanded) ...[
              const SizedBox(width: 10),
              Expanded(child: Text(item.label, style: TextStyle(
                color: active ? Colors.white : const Color(0xFFD4B8C0),
                fontSize: 13,
                fontWeight: active ? FontWeight.w600 : FontWeight.w400,
              ), overflow: TextOverflow.ellipsis)),
            ],
          ]),
        ),
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
            padding: EdgeInsets.symmetric(horizontal: isExpanded ? 12 : 14, vertical: 9),
            decoration: BoxDecoration(
              color: const Color(0xFF7A1E3A).withOpacity(0.25),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFF9B2C4E).withOpacity(0.5)),
            ),
            child: Row(children: [
              const Icon(Icons.logout, size: 16, color: Color(0xFFD4B8C0)),
              if (isExpanded) ...[
                const SizedBox(width: 8),
                const Text('Salir de la Demo', style: TextStyle(
                  color: Color(0xFFD4B8C0), fontSize: 12, fontWeight: FontWeight.w500,
                )),
              ],
            ]),
          ),
        ),
      ),
    );
  }
}
'''

# ── TOPBAR ────────────────────────────────────────────────────────────────────
topbar = r'''import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:nethive_neo/helpers/constants.dart';
import 'package:nethive_neo/providers/providers.dart';
import 'package:nethive_neo/theme/theme.dart';

class TopbarWidget extends StatelessWidget {
  final String currentPath;
  const TopbarWidget({super.key, required this.currentPath});

  @override
  Widget build(BuildContext context) {
    final theme    = AppTheme.of(context);
    final appLevel = context.watch<AppLevelProvider>();
    final incProv  = context.watch<IncidenciaProvider>();
    final bProv    = context.watch<BandejaIAProvider>();
    final isMobile = MediaQuery.of(context).size.width < mobileSize;
    final isDark   = Theme.of(context).brightness == Brightness.dark;
    final critCount   = incProv.criticas.length;
    final bandejaCount = bProv.totalPendientes;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: theme.surface,
        border: Border(bottom: BorderSide(color: theme.border)),
      ),
      child: Row(children: [
        // Hamburger / Toggle sidebar
        if (isMobile)
          Builder(builder: (ctx) => IconButton(
            icon: Icon(Icons.menu, size: 20, color: theme.textSecondary),
            onPressed: () => Scaffold.of(ctx).openDrawer(),
          ))
        else
          IconButton(
            icon: Icon(
              appLevel.sidebarExpanded ? Icons.menu_open : Icons.menu,
              size: 20, color: theme.textSecondary,
            ),
            onPressed: () => appLevel.toggleSidebar(),
            tooltip: 'Contraer sidebar',
          ),

        const SizedBox(width: 2),

        // Breadcrumb
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(children: _buildCrumbs(appLevel.breadcrumb, theme)),
          ),
        ),

        // Badge: incidencias críticas
        if (critCount > 0) ...[
          _Badge(
            icon: Icons.warning_amber_rounded,
            label: '$critCount críticas',
            fgColor: const Color(0xFFB91C1C),
            bgColor: const Color(0xFFFEE2E2),
          ),
          const SizedBox(width: 6),
        ],

        // Badge: bandeja IA
        if (bandejaCount > 0) ...[
          GestureDetector(
            onTap: () => context.go(routeBandejaIA),
            child: _Badge(
              icon: Icons.smart_toy_outlined,
              label: '$bandejaCount en IA',
              fgColor: const Color(0xFFD97706),
              bgColor: const Color(0xFFFEF3C7),
            ),
          ),
          const SizedBox(width: 6),
        ],

        // ── THEME TOGGLE ───────────────────────────────────────────────
        Tooltip(
          message: isDark ? 'Cambiar a modo claro' : 'Cambiar a modo oscuro',
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () {
              final next = isDark ? ThemeMode.light : ThemeMode.dark;
              setDarkModeSetting(context, next);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
              decoration: BoxDecoration(
                color: theme.border.withOpacity(0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(
                  isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
                  size: 16, color: isDark ? const Color(0xFFD97706) : theme.textSecondary,
                ),
                const SizedBox(width: 4),
                Text(isDark ? 'Claro' : 'Oscuro', style: TextStyle(
                  fontSize: 11, color: theme.textSecondary, fontWeight: FontWeight.w500,
                )),
              ]),
            ),
          ),
        ),

        const SizedBox(width: 10),

        // Avatar admin
        Tooltip(
          message: 'Admin Terranex',
          child: Container(
            width: 34, height: 34,
            decoration: const BoxDecoration(
              color: Color(0xFF7A1E3A), shape: BoxShape.circle,
            ),
            child: const Center(
              child: Text('AT', style: TextStyle(
                color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600,
              )),
            ),
          ),
        ),
      ]),
    );
  }

  List<Widget> _buildCrumbs(List<String> parts, AppTheme theme) {
    final out = <Widget>[];
    for (int i = 0; i < parts.length; i++) {
      if (i > 0) out.add(Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: Icon(Icons.chevron_right, size: 16, color: theme.textDisabled),
      ));
      final isLast = i == parts.length - 1;
      out.add(Text(parts[i], style: TextStyle(
        fontSize: 13,
        fontWeight: isLast ? FontWeight.w600 : FontWeight.w400,
        color: isLast ? theme.primaryColor : theme.textSecondary,
      )));
    }
    return out;
  }
}

class _Badge extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color fgColor;
  final Color bgColor;

  const _Badge({required this.icon, required this.label, required this.fgColor, required this.bgColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: fgColor.withOpacity(0.4)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 14, color: fgColor),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: fgColor)),
      ]),
    );
  }
}
'''

files = [
    (ROOT / "lib" / "widgets" / "sidebar" / "sidebar_widget.dart", sidebar),
    (ROOT / "lib" / "widgets" / "topbar"  / "topbar_widget.dart",  topbar),
]
for p, c in files:
    p.write_text(c, encoding='utf-8')
    print(f"✅ {p.name} ({len(c.splitlines())} líneas)")
