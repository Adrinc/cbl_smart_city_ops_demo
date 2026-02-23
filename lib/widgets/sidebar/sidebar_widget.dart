import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:nethive_neo/helpers/constants.dart';
import 'package:nethive_neo/providers/providers.dart';

// ── Models ────────────────────────────────────────────────────────────────────
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

// ── Widget ────────────────────────────────────────────────────────────────────
class SidebarWidget extends StatelessWidget {
  final String currentPath;
  final bool isExpanded;
  const SidebarWidget({super.key, required this.currentPath, required this.isExpanded});

  List<_Section> _sectionsFor(NivelTerritorial nivel) {
    switch (nivel) {
      case NivelTerritorial.nacional:
        return [_Section(items: [
          _Item('Visión Nacional',     Icons.public,                      routeNacional),
          _Item('Territorio / Mapa',   Icons.map_outlined,                routeMapa),
          _Item('Dependencias',        Icons.account_balance_outlined,     routeCatalogos),
          _Item('Supervisión',         Icons.supervisor_account_outlined,  routeReportes),
          _Item('Usuarios',            Icons.manage_accounts_outlined,     routeUsuarios),
          _Item('Configuración',       Icons.settings_outlined,            routeConfiguracion),
        ])];

      case NivelTerritorial.estatal:
        return [_Section(items: [
          _Item('Visión Nacional',     Icons.public,                      routeNacional),
          _Item('Centro Estatal',      Icons.account_balance_outlined,    routeEstatal),
          _Item('Territorio Estatal',  Icons.map_outlined,                routeMapa),
          _Item('Catálogos',           Icons.category_outlined,           routeCatalogos),
          _Item('Supervisión',         Icons.supervisor_account_outlined, routeReportes),
          _Item('Usuarios',            Icons.manage_accounts_outlined,    routeUsuarios),
          _Item('Configuración',       Icons.settings_outlined,           routeConfiguracion),
        ])];

      case NivelTerritorial.municipal:
        return [
          _Section(items: [
            _Item('Visión Nacional',      Icons.public,             routeNacional),
            _Item('Centro Estatal',       Icons.account_balance_outlined, routeEstatal),
            _Item('Dashboard Municipal',  Icons.dashboard_outlined, routeMunicipal),
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
            _Item('Configuración', Icons.settings_outlined,           routeConfiguracion),
            _Item('Catálogos',     Icons.category_outlined,           routeCatalogos),
            _Item('Usuarios',      Icons.manage_accounts_outlined,    routeUsuarios),
            _Item('Auditoría',     Icons.history_outlined,            routeAuditoria),
          ]),
        ];
    }
  }

  bool _isActive(String route) {
    if (currentPath == route) return true;
    // Para rutas raíz, no activen otros
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final appLevel = context.watch<AppLevelProvider>();
    final sections = _sectionsFor(appLevel.nivel);

    return Container(
      color: const Color(0xFF5C1528),
      child: Column(children: [
        _Header(isExpanded: isExpanded),
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

// ── Header ────────────────────────────────────────────────────────────────────
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

// ── Section Block ─────────────────────────────────────────────────────────────
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
        item: item,
        active: isActive(item.route),
        isExpanded: isExpanded,
      )),
    ]);
  }
}

// ── Nav Tile ──────────────────────────────────────────────────────────────────
class _NavTile extends StatelessWidget {
  final _Item item;
  final bool active;
  final bool isExpanded;

  const _NavTile({required this.item, required this.active, required this.isExpanded});

  NivelTerritorial _nivelForRoute(String r) {
    if (r == routeNacional) return NivelTerritorial.nacional;
    if (r == routeEstatal)  return NivelTerritorial.estatal;
    return NivelTerritorial.municipal;
  }

  @override
  Widget build(BuildContext context) {
    final appLevel = context.read<AppLevelProvider>();

    return Tooltip(
      message: isExpanded ? '' : item.label,
      child: InkWell(
        onTap: () {
          // Ajustar nivel según destino
          if (item.route == routeNacional) {
            appLevel.setNivel(NivelTerritorial.nacional);
          } else if (item.route == routeEstatal) {
            appLevel.setNivel(NivelTerritorial.estatal);
          } else if ([routeMunicipal, routeOrdenes, routeBandejaIA,
                      routeAprobaciones, routeTecnicos, routeInventario,
                      routeSla].contains(item.route)) {
            appLevel.setNivel(NivelTerritorial.municipal);
          }
          context.go(item.route);
          // Cerrar drawer en movil
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
              Expanded(child: Text(item.label,
                style: TextStyle(
                  color: active ? Colors.white : const Color(0xFFD4B8C0),
                  fontSize: 13,
                  fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                ),
                overflow: TextOverflow.ellipsis,
              )),
            ],
          ]),
        ),
      ),
    );
  }
}

// ── Salir Button ──────────────────────────────────────────────────────────────
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
