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
