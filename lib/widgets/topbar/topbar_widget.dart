import 'package:flutter/material.dart';
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
    final theme = AppTheme.of(context);
    final appLevel = context.watch<AppLevelProvider>();
    final incProv = context.watch<IncidenciaProvider>();
    final bProv = context.watch<BandejaIAProvider>();
    final isMobile = MediaQuery.of(context).size.width < mobileSize;
    final critCount = incProv.criticas.length;
    final bandejaCount = bProv.totalPendientes;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: theme.surface,
        border: Border(bottom: BorderSide(color: theme.border)),
      ),
      child: Row(
        children: [
          // Toggle
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

          const SizedBox(width: 4),

          // Breadcrumb
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(children: _buildCrumbs(appLevel.breadcrumb, theme)),
            ),
          ),

          // Badge criticas
          if (critCount > 0)
            _Badge(
              icon: Icons.warning_amber_rounded,
              label: '$critCount críticas',
              fgColor: const Color(0xFFB91C1C),
              bgColor: const Color(0xFFFEE2E2),
            ),

          const SizedBox(width: 6),

          // Badge bandeja IA
          if (bandejaCount > 0)
            GestureDetector(
              onTap: () => context.go(routeBandejaIA),
              child: _Badge(
                icon: Icons.smart_toy_outlined,
                label: '$bandejaCount en IA',
                fgColor: const Color(0xFFD97706),
                bgColor: const Color(0xFFFEF3C7),
              ),
            ),

          const SizedBox(width: 8),

          // Cambiar nivel chip
          _NivelChip(appLevel: appLevel),

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
        ],
      ),
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

class _NivelChip extends StatelessWidget {
  final AppLevelProvider appLevel;
  const _NivelChip({required this.appLevel});

  @override
  Widget build(BuildContext context) {
    final opts = <NivelTerritorial, (String, Color, String)>{
      NivelTerritorial.nacional:  ('Nacional',  const Color(0xFF1D4ED8), routeNacional),
      NivelTerritorial.estatal:   ('Estatal',   const Color(0xFF7A1E3A), routeEstatal),
      NivelTerritorial.municipal: ('Municipal', const Color(0xFF2D7A4F), routeMunicipal),
    };
    final (label, color, _) = opts[appLevel.nivel]!;

    return PopupMenuButton<NivelTerritorial>(
      tooltip: 'Cambiar nivel territorial',
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      offset: const Offset(0, 40),
      onSelected: (n) {
        appLevel.setNivel(n);
        context.go(opts[n]!.$3);
      },
      itemBuilder: (_) => NivelTerritorial.values.map((n) {
        final (lbl, clr, _) = opts[n]!;
        return PopupMenuItem<NivelTerritorial>(
          value: n,
          child: Row(children: [
            Icon(
              n == appLevel.nivel ? Icons.radio_button_checked : Icons.radio_button_off,
              size: 16, color: n == appLevel.nivel ? clr : Colors.grey,
            ),
            const SizedBox(width: 8),
            Text(lbl, style: TextStyle(
              fontSize: 13, fontWeight: n == appLevel.nivel ? FontWeight.w600 : FontWeight.w400,
              color: n == appLevel.nivel ? clr : null,
            )),
          ]),
        );
      }).toList(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.4)),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.layers_outlined, size: 14, color: color),
          const SizedBox(width: 5),
          Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color)),
          const SizedBox(width: 4),
          Icon(Icons.keyboard_arrow_down, size: 14, color: color),
        ]),
      ),
    );
  }
}
