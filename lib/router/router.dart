import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:nethive_neo/helpers/constants.dart';
import 'package:nethive_neo/pages/pages.dart';
import 'package:nethive_neo/pages/main_container/main_container_page.dart';
import 'package:nethive_neo/services/navigation_service.dart';

Page<void> _noTransition(Widget child) => CustomTransitionPage<void>(
      child: child,
      transitionsBuilder: (_, __, ___, c) => c,
      transitionDuration: Duration.zero,
      reverseTransitionDuration: Duration.zero,
    );

final GoRouter router = GoRouter(
  debugLogDiagnostics: true,
  navigatorKey: NavigationService.navigatorKey,
  initialLocation: routeNacional,
  errorBuilder: (_, __) => const PageNotFoundPage(),
  routes: [
    ShellRoute(
      builder: (context, state, child) =>
          MainContainerPage(currentPath: state.uri.toString(), child: child),
      routes: [
        GoRoute(path: routeNacional,     pageBuilder: (_, __) => _noTransition(const VisionNacionalPage())),
        GoRoute(path: routeEstatal,      pageBuilder: (_, __) => _noTransition(const CentroEstatalPage())),
        GoRoute(path: routeMunicipal,    pageBuilder: (_, __) => _noTransition(const DashboardMunicipalPage())),
        GoRoute(path: routeOrdenes,      pageBuilder: (_, __) => _noTransition(const OrdenesPage())),
        GoRoute(path: routeMapa,         pageBuilder: (_, __) => _noTransition(const MapaPage())),
        GoRoute(path: routeTecnicos,     pageBuilder: (_, __) => _noTransition(const TecnicosPage())),
        GoRoute(path: routeInventario,   pageBuilder: (_, __) => _noTransition(const InventarioPage())),
        GoRoute(path: routeBandejaIA,    pageBuilder: (_, __) => _noTransition(const BandejaIAPage())),
        GoRoute(path: routeAprobaciones, pageBuilder: (_, __) => _noTransition(const AprobacionesPage())),
        GoRoute(path: routeSla,          pageBuilder: (_, __) => _noTransition(const SlaPage())),
        GoRoute(path: routeReportes,     pageBuilder: (_, __) => _noTransition(const ReportesPage())),
        GoRoute(path: routeConfiguracion,pageBuilder: (_, __) => _noTransition(const ConfiguracionPage())),
        GoRoute(path: routeUsuarios,     pageBuilder: (_, __) => _noTransition(const UsuariosPage())),
        GoRoute(path: routeAuditoria,    pageBuilder: (_, __) => _noTransition(const AuditoriaPage())),
        GoRoute(path: routeCatalogos,    pageBuilder: (_, __) => _noTransition(const CatalogosPage())),
      ],
    ),
  ],
);
