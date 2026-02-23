// Terranex Smart City Operations — Constants
const String appName = 'Terranex';
const String appFullName = 'Terranex — Smart City Operations';
const String appTagline = 'Centro de Operaciones de Ciudad Inteligente';

// Tema
const String kThemeModeKey = '__theme_mode__';

// Responsividad
const int mobileSize = 768;
const int tabletSize = 1024;
const double sidebarWidth = 240.0;
const double sidebarCollapsedWidth = 60.0;
const double topbarHeight = 60.0;

// Demo context geografico
const String demoEstado = 'Baja California Norte';
const String demoMunicipio = 'Ensenada';
const String demoBreadcrumb = 'Mexico > Baja California > Ensenada';

// Rutas
const String routeNacional   = '/';
const String routeEstatal    = '/state';
const String routeMunicipal  = '/municipal';
const String routeOrdenes    = '/ordenes';
const String routeMapa       = '/mapa';
const String routeTecnicos   = '/tecnicos';
const String routeInventario = '/inventario';
const String routeBandejaIA  = '/bandeja-ia';
const String routeAprobaciones = '/aprobaciones';
const String routeSla        = '/sla';
const String routeReportes   = '/reportes';
const String routeConfiguracion = '/configuracion';
const String routeUsuarios   = '/usuarios';
const String routeAuditoria  = '/auditoria';
const String routeCatalogos  = '/catalogos';

// Salir de la demo
const String exitDemoUrl = 'https://cbluna.com/';

// Coordenadas demo
const double ensenadadLat = 31.8667;
const double ensenadaLng  = -116.5963;
const double bcLat = 30.5;
const double bcLng = -115.5;

// Niveles territoriales
enum NivelTerritorial { nacional, estatal, municipal }

// Categorias de incidencia
const List<String> categorias = [
  'alumbrado', 'bacheo', 'basura', 'seguridad', 'agua_drenaje', 'senalizacion'
];

// Entornos
const List<String> entornos = [
  'residencial', 'comercial', 'industrial', 'institucional'
];

// Prioridades (orden de severidad)
const List<String> prioridades = ['critico', 'alto', 'medio', 'bajo'];

// Estatus de incidencia
const List<String> estatusIncidencia = [
  'recibido', 'en_revision', 'aprobado', 'asignado',
  'en_proceso', 'resuelto', 'cerrado', 'rechazado'
];

// Roles de tecnico
const List<String> rolesTecnico = [
  'jefe_cuadrilla', 'tecnico_campo', 'supervisor'
];

// SLA default en horas por prioridad
const Map<String, int> slaHorasPorPrioridad = {
  'critico': 4,
  'alto':    24,
  'medio':   72,
  'bajo':    168,
};

// Demo version
const String demoVersion = '1.0.0';
