import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:nethive_neo/helpers/constants.dart';
import 'package:nethive_neo/providers/providers.dart';
import 'package:nethive_neo/theme/theme.dart';
import 'package:nethive_neo/widgets/sidebar/sidebar_widget.dart';
import 'package:nethive_neo/widgets/topbar/topbar_widget.dart';

class MainContainerPage extends StatelessWidget {
  final Widget child;
  final String currentPath;

  const MainContainerPage({
    super.key,
    required this.child,
    required this.currentPath,
  });

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final appLevel = context.watch<AppLevelProvider>();
    final isExpanded = appLevel.sidebarExpanded;
    final screenW = MediaQuery.of(context).size.width;
    final isMobile = screenW < mobileSize;

    return Scaffold(
      backgroundColor: theme.background,
      body: Row(
        children: [
          // ── Sidebar ──
          if (!isMobile)
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: isExpanded ? sidebarWidth : sidebarCollapsedWidth,
              child: SidebarWidget(
                currentPath: currentPath,
                isExpanded: isExpanded,
              ),
            ),

          // ── Main Content ──
          Expanded(
            child: Column(
              children: [
                SizedBox(
                  height: topbarHeight,
                  child: TopbarWidget(currentPath: currentPath),
                ),
                Expanded(child: child),
              ],
            ),
          ),
        ],
      ),
      drawer: isMobile
          ? Drawer(
              width: sidebarWidth,
              child: SidebarWidget(
                  currentPath: currentPath,
                  isExpanded: true,
                  showUserBlock: true),
            )
          : null,
    );
  }
}
