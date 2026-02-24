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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final critCount = incProv.criticas.length;
    final bandejaCount = bProv.totalPendientes;

    // ── MOBILE: solo hamburguesa + título centrado ────────────────────────
    if (isMobile) {
      final pageTitle =
          appLevel.breadcrumb.isNotEmpty ? appLevel.breadcrumb.last : appName;
      return Container(
        height: topbarHeight,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: theme.surface,
          border: Border(bottom: BorderSide(color: theme.border)),
        ),
        child: Row(children: [
          Builder(
            builder: (ctx) => IconButton(
              icon: Icon(Icons.menu, size: 22, color: theme.textSecondary),
              onPressed: () => Scaffold.of(ctx).openDrawer(),
            ),
          ),
          Expanded(
            child: Text(
              pageTitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: theme.textPrimary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          // Sólo toggle de tema — compacto
          IconButton(
            icon: Icon(
              isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
              size: 20,
              color: isDark ? const Color(0xFFD97706) : theme.textSecondary,
            ),
            onPressed: () {
              final next = isDark ? ThemeMode.light : ThemeMode.dark;
              setDarkModeSetting(context, next);
            },
            tooltip: isDark ? 'Modo claro' : 'Modo oscuro',
          ),
        ]),
      );
    }

    // ── DESKTOP ───────────────────────────────────────────────────────────
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: theme.surface,
        border: Border(bottom: BorderSide(color: theme.border)),
      ),
      child: Row(children: [
        // Toggle sidebar
        IconButton(
          icon: Icon(
            appLevel.sidebarExpanded ? Icons.menu_open : Icons.menu,
            size: 20,
            color: theme.textSecondary,
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
                  size: 16,
                  color: isDark ? const Color(0xFFD97706) : theme.textSecondary,
                ),
                const SizedBox(width: 4),
                Text(isDark ? 'Claro' : 'Oscuro',
                    style: TextStyle(
                      fontSize: 11,
                      color: theme.textSecondary,
                      fontWeight: FontWeight.w500,
                    )),
              ]),
            ),
          ),
        ),

        const SizedBox(width: 10),

        // ── Dropdown Admin ────────────────────────────────────────────────
        _AdminDropdown(theme: theme),
      ]),
    );
  }

  List<Widget> _buildCrumbs(List<String> parts, AppTheme theme) {
    final out = <Widget>[];
    for (int i = 0; i < parts.length; i++) {
      if (i > 0)
        out.add(Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: Icon(Icons.chevron_right, size: 16, color: theme.textDisabled),
        ));
      final isLast = i == parts.length - 1;
      out.add(Text(parts[i],
          style: TextStyle(
            fontSize: 13,
            fontWeight: isLast ? FontWeight.w600 : FontWeight.w400,
            color: isLast ? theme.primaryColor : theme.textSecondary,
          )));
    }
    return out;
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Admin dropdown
// ══════════════════════════════════════════════════════════════════════════════
class _AdminDropdown extends StatefulWidget {
  const _AdminDropdown({required this.theme});
  final AppTheme theme;
  @override
  State<_AdminDropdown> createState() => _AdminDropdownState();
}

class _AdminDropdownState extends State<_AdminDropdown> {
  final _menuController = MenuController();

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme;
    return MenuAnchor(
      controller: _menuController,
      alignmentOffset: const Offset(0, 6),
      style: MenuStyle(
        backgroundColor: WidgetStatePropertyAll(theme.surface),
        surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
        elevation: const WidgetStatePropertyAll(8),
        shape: WidgetStatePropertyAll(RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: theme.border))),
        padding: const WidgetStatePropertyAll(EdgeInsets.zero),
      ),
      menuChildren: [
        // ── Cabecera usuario ──────────────────────────────────────────────
        Container(
          width: 230,
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
          decoration: BoxDecoration(
              color: const Color(0xFF7A1E3A).withOpacity(0.06),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12))),
          child: Row(children: [
            CircleAvatar(
                radius: 20,
                backgroundImage:
                    const AssetImage('assets/images/avatares/Maria.png'),
                onBackgroundImageError: (_, __) {}),
            const SizedBox(width: 10),
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text('Admin Terranex',
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: theme.textPrimary)),
                  Text('Administrador',
                      style: TextStyle(
                          fontSize: 11,
                          color: const Color(0xFF7A1E3A),
                          fontWeight: FontWeight.w600)),
                ])),
          ]),
        ),
        Divider(height: 1, color: theme.border),
        // ── Opciones ──────────────────────────────────────────────────────
        _MenuOpt(
            icon: Icons.person_outline,
            label: 'Mi perfil',
            theme: theme,
            onTap: () {}),
        _MenuOpt(
            icon: Icons.history_outlined,
            label: 'Actividad reciente',
            theme: theme,
            onTap: () {}),
        _MenuOpt(
            icon: Icons.settings_outlined,
            label: 'Configuración',
            theme: theme,
            onTap: () {
              _menuController.close();
              context.go('/configuracion');
            }),
        _MenuOpt(
            icon: Icons.help_outline,
            label: 'Centro de ayuda',
            theme: theme,
            onTap: () {}),
        Divider(height: 1, color: theme.border),
        _MenuOpt(
            icon: Icons.logout,
            label: 'Cerrar sesión',
            theme: theme,
            isDestructive: true,
            onTap: () {
              _menuController.close();
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content:
                      Text('Esta es una demo — la sesión no puede cerrarse.'),
                  duration: Duration(seconds: 2)));
            }),
      ],
      builder: (ctx, controller, child) => InkWell(
        onTap: () => controller.isOpen ? controller.close() : controller.open(),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
              border: Border.all(color: theme.border),
              borderRadius: BorderRadius.circular(8)),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            CircleAvatar(
                radius: 14,
                backgroundImage:
                    const AssetImage('assets/images/avatares/Maria.png'),
                onBackgroundImageError: (_, __) {},
                backgroundColor: const Color(0xFF7A1E3A),
                child: null),
            const SizedBox(width: 8),
            Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Admin Terranex',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: theme.textPrimary)),
                  Text('Administrador',
                      style: TextStyle(
                          fontSize: 10,
                          color: const Color(0xFF7A1E3A),
                          fontWeight: FontWeight.w600)),
                ]),
            const SizedBox(width: 6),
            Icon(Icons.keyboard_arrow_down,
                size: 16, color: theme.textSecondary),
          ]),
        ),
      ),
    );
  }
}

class _MenuOpt extends StatelessWidget {
  const _MenuOpt(
      {required this.icon,
      required this.label,
      required this.theme,
      required this.onTap,
      this.isDestructive = false});
  final IconData icon;
  final String label;
  final AppTheme theme;
  final VoidCallback onTap;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    final color = isDestructive ? theme.critical : theme.textSecondary;
    return InkWell(
        onTap: onTap,
        child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 10),
              Text(label,
                  style: TextStyle(
                      fontSize: 13,
                      color:
                          isDestructive ? theme.critical : theme.textPrimary)),
            ])));
  }
}

class _Badge extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color fgColor;
  final Color bgColor;

  const _Badge(
      {required this.icon,
      required this.label,
      required this.fgColor,
      required this.bgColor});

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
        Text(label,
            style: TextStyle(
                fontSize: 12, fontWeight: FontWeight.w600, color: fgColor)),
      ]),
    );
  }
}
