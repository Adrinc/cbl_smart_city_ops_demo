import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:nethive_neo/pages/pages.dart';
import 'package:nethive_neo/services/navigation_service.dart';

/// The route configuration.
final GoRouter router = GoRouter(
  debugLogDiagnostics: true,
  navigatorKey: NavigationService.navigatorKey,
  initialLocation: '/',
  errorBuilder: (context, state) => const PageNotFoundPage(),
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      name: 'root',
      builder: (BuildContext context, GoRouterState state) {
        // Temporary placeholder - will be replaced with Dashboard Container
        return Container(
            color: const Color(0xFF2563EB),
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: const Center(
                child: Text(
              'CBLuna Dashboard Demos - Coming Soon',
              style: TextStyle(color: Colors.white, fontSize: 24),
            )));
      },
    ),
  ],
);
