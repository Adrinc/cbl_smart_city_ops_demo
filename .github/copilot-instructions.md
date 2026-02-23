# Copilot Instructions — Terranex · SMART CITY OPERATIONS (Flutter Web Demo)

## ⚠️ REGLA CRÍTICA — ESTA DEMO ES WEB
**NUNCA ejecutar en Windows/Mac/Linux Desktop con `flutter run -d windows|macos|linux`.**
Esta es una **aplicación Flutter Web**. Ejecutar SIEMPRE en Chrome:
```bash
flutter run -d chrome
flutter build web --release
```

---

## Descripción General del Proyecto

**Terranex — Smart City Operations** es una **demo enterprise Flutter Web** que simula un **Centro de Operaciones de Ciudad Inteligente** para México.

- **Todo es hardcodeado y simulado** (sin backend real, sin base de datos).
- **NO es estática**: los módulos usan **Provider** para simular flujos reales (aprobaciones, cambios de estado, métricas que "se mueven", asignaciones).
- Objetivo: percibirse como un **producto SaaS enterprise** listo para licitación o despliegue real.
- **Rol único**: Admin Operativo Global (acceso total, sin auth).

---

## Jerarquía Territorial (Núcleo del Sistema)

El sistema opera en **3 niveles** — esta jerarquía es el valor diferencial del producto:

```
NACIONAL  →  ESTATAL  →  MUNICIPAL
(estratégico)  (coordinación)  (operación)
```

| Nivel | Enfoque | CTA principal |
|-------|---------|---------------|
| Nacional | KPIs país, mapa de calor, alertas críticas | "Ir a Estado →" |
| Estatal | Coordinación de municipios, SLA regional | "Entrar a Municipio →" |
| Municipal | Órdenes, mapa, técnicos, materiales, SLA | Operación completa |

**Demo hardcodeada**: Estado = Baja California Norte · Municipio = Ensenada

---

## Flujo de Incidencia (End-to-End simulado)

```
App Ciudadana → IA (validación/clasificación) → Bandeja Revisión Humana
→ Aprobación → Orden de Trabajo → Asignación Técnico → Ejecución → Cierre
```

La IA actúa como **asistente** (sugiere categoría, prioridad, coherencia imagen-texto).
El operador humano siempre revisa antes de aprobar (**humano en el loop**).

---

## Routing — GoRouter

**Rutas planas + nivel activo en Provider** (sin shell routes complejas):

| Ruta | Nivel | Descripción |
|------|-------|-------------|
| `/` | Nacional | Visión Nacional (dashboard de entrada) |
| `/state` | Estatal | Centro Operativo Estatal — Baja California Norte |
| `/municipal` | Municipal | Centro Operativo Municipal — Ensenada |
| `/ordenes` | Municipal | Órdenes / Incidencias (PlutoGrid completo) |
| `/mapa` | Municipal | Mapa operativo interactivo |
| `/tecnicos` | Municipal | Gestión de técnicos y cuadrillas |
| `/inventario` | Municipal | Inventario de materiales |
| `/bandeja-ia` | Municipal | Bandeja de revisión IA (pre-aprobados) |
| `/aprobaciones` | Municipal | Aprobaciones pendientes |
| `/sla` | Municipal | Monitor de SLA |
| `/reportes` | Estatal/Municipal | Analítica y reportes |
| `/configuracion` | Admin | Motor de priorización y reglas |
| `/usuarios` | Admin | Usuarios del sistema |
| `/auditoria` | Admin | Log de auditoría |
| `/catalogos` | Admin | Categorías, zonas, dependencias |

- **Sin transiciones**: `NoTransitionPage` o `pageBuilder` con `Duration.zero`
- **Sin autenticación**: acceso directo a todas las páginas
- **Exit button (parte inferior del sidebar)**: `url_launcher` → `https://cbluna.com/` en la **misma ventana (`_self`)**

---

## Sidebar Adaptativo (por nivel)

El sidebar **cambia su menú según el nivel activo**. Siempre muestra:
- Logo + nombre del sistema (parte superior)
- Context breadcrumb: `México > Baja California > Ensenada` (simulado)
- Botón **"Salir de la Demo"** (parte inferior, siempre visible)

### Sidebar Nacional
```
[Logo] Terranex
México > —
─────────────────
● Visión Nacional        ← activo
○ Territorio / Mapa
○ Dependencias
○ Supervisión
○ Usuarios
○ Configuración
─────────────────
[ Salir de la Demo ]
```

### Sidebar Estatal (Baja California Norte)
```
[Logo] Terranex
México > Baja California
─────────────────
○ Visión Nacional
● Centro Estatal         ← activo
○ Territorio Estatal
○ Catálogos
○ Supervisión
○ Usuarios
○ Configuración
─────────────────
[ Salir de la Demo ]
```

### Sidebar Municipal (Ensenada) — menú completo operativo
```
[Logo] Terranex
México > BC > Ensenada
─────────────────
○ Visión Nacional
○ Centro Estatal
● Dashboard Municipal    ← activo
─────────────────
  OPERACIÓN
  ○ Órdenes / Incidencias
  ○ Bandeja IA
  ○ Aprobaciones
  ○ Mapa Operativo
─────────────────
  RECURSOS
  ○ Técnicos
  ○ Inventario
─────────────────
  ANALÍTICA
  ○ SLA Monitor
  ○ Reportes
─────────────────
  ADMIN
  ○ Configuración
  ○ Catálogos
  ○ Usuarios
  ○ Auditoría
─────────────────
[ Salir de la Demo ]
```

**Transición entre niveles**: suave, animada, sin "brincos".
**Context Header**: breadcrumb fijo en el topbar que refleja el nivel activo.
**"Cambiar nivel"**: chip/badge pequeño en el topbar para navegar entre niveles rápidamente (para el evaluador de la demo).

---

## State Management — Provider

| Provider | Responsabilidad |
|----------|----------------|
| `AppLevelProvider` | Nivel activo (nacional/estatal/municipal), breadcrumb, sidebar state |
| `IncidenciaProvider` | Incidencias/órdenes de trabajo, cambios de estado |
| `BandejaIAProvider` | Reportes pendientes de revisión IA, aprobación/rechazo |
| `TecnicoProvider` | Gestión de técnicos y cuadrillas, disponibilidad |
| `InventarioProvider` | Materiales, stock, movimientos |
| `SlaProvider` | Monitor SLA, alertas por vencer |
| `ReporteProvider` | Analítica y métricas agregadas |
| `ConfiguracionProvider` | Motor de priorización, reglas, categorías |

**Setup**: Todos registrados en `main()` vía `MultiProvider`.

---

## Sistema de Colores — Enterprise Vino / Institucional

### Acento principal
```
Vino:         #7A1E3A   (sidebar activo, CTAs primarios, acento de marca)
Vino oscuro:  #5C1528   (fondo del sidebar)
```

### Filosofía semántica

| Token | Hex | Significado operativo |
|-------|-----|----------------------|
| `critical` | `#B91C1C` | SLA vencido, incidencia crítica, riesgo máximo |
| `high` | `#D97706` | Prioridad alta, próximo a vencer, advertencia |
| `medium` | `#1D4ED8` | Prioridad media, en proceso normal |
| `low` | `#2D7A4F` | Prioridad baja, resuelto, cumplido |
| `neutral` | `#64748B` | Cancelado, inactivo, sin estado |

### ❌ Prohibido
- Colores neón o vibrantes
- Gradientes llamativos
- Estética consumer/retail/startup
- Azul eléctrico como acento principal (reservado para prioridad "Medio")

### Paleta completa — Modo Claro

```dart
// Identidad (Vino institucional)
static const Color primary       = Color(0xFF7A1E3A);
static const Color primaryLight  = Color(0xFF9B2C4E);
static const Color primarySoft   = Color(0xFFF9E8EC);

// Semánticos operativos
static const Color critical      = Color(0xFFB91C1C);
static const Color criticalSoft  = Color(0xFFFEE2E2);
static const Color high          = Color(0xFFD97706);
static const Color highSoft      = Color(0xFFFEF3C7);
static const Color medium        = Color(0xFF1D4ED8);
static const Color mediumSoft    = Color(0xFFEFF6FF);
static const Color low           = Color(0xFF2D7A4F);
static const Color lowSoft       = Color(0xFFE8F5EE);
static const Color neutral       = Color(0xFF64748B);

// Fondos y superficies
static const Color background    = Color(0xFFF4F6F9);
static const Color surface       = Color(0xFFFFFFFF);
static const Color border        = Color(0xFFE3E8EF);

// Texto
static const Color textPrimary   = Color(0xFF0F172A);
static const Color textSecondary = Color(0xFF475569);
static const Color textDisabled  = Color(0xFF94A3B8);

// Sidebar (vino oscuro)
static const Color sidebarBg     = Color(0xFF5C1528);
static const Color sidebarActive = Color(0xFF7A1E3A);
static const Color sidebarText   = Color(0xFFF1E8EB);
static const Color sidebarMuted  = Color(0xFFB8909A);
```

### Paleta — Modo Oscuro

```dart
static const Color backgroundDark    = Color(0xFF0D0F14);
static const Color surfaceDark       = Color(0xFF161B26);
static const Color borderDark        = Color(0xFF252D3D);
static const Color textPrimaryDark   = Color(0xFFF1F5F9);
static const Color textSecondaryDark = Color(0xFF94A3B8);
```

---

## Modelos de Datos

```dart
// Incidencia / Orden de Trabajo
class Incidencia {
  final String id;              // #15420
  final String municipio;
  final String estado;
  final String categoria;       // 'alumbrado' | 'bacheo' | 'basura' | 'seguridad' | 'agua_drenaje' | 'señalizacion'
  final String descripcion;
  final String? imagenPath;     // asset path: assets/images/casos/<categoria>/
  final double latitud;
  final double longitud;
  final String entorno;         // 'residencial' | 'comercial' | 'industrial' | 'institucional'
  final String prioridad;       // 'critico' | 'alto' | 'medio' | 'bajo'
  final String estatus;         // 'recibido' | 'en_revision' | 'aprobado' | 'asignado' | 'en_proceso' | 'resuelto' | 'cerrado' | 'rechazado'
  final String? tecnicoId;
  final DateTime fechaReporte;
  final DateTime? fechaLimite;  // SLA deadline
  final DateTime? fechaResolucion;
  final bool esReincidente;
  final String? iaCategoriaSugerida;
  final String? iaPrioridadSugerida;
  final double? iaConfianza;    // 0.0 - 1.0
  final String? iaCoherenciaNota;
}

// Técnico / Cuadrilla
class Tecnico {
  final String id;
  final String nombre;
  final String rol;             // 'jefe_cuadrilla' | 'tecnico_campo' | 'supervisor'
  final String especialidad;    // 'alumbrado' | 'bacheo' | 'basura' | 'agua_drenaje' | 'general'
  final String estatus;         // 'activo' | 'en_campo' | 'inactivo' | 'descanso'
  final int incidenciasActivas;
  final int incidenciasCerradasMes;
  final double latitud;
  final double longitud;
  final String? municipioAsignado;
}

// Material / Inventario
class Material {
  final String id;
  final String clave;
  final String descripcion;
  final String categoria;
  final String unidad;
  final int stockActual;
  final int stockMinimo;
  final int reservado;
  final String estatus;         // 'disponible' | 'bajo_stock' | 'agotado'
}

// Evento de Auditoría
class EventoAuditoria {
  final String id;
  final DateTime timestamp;
  final String usuario;
  final String nivel;           // 'nacional' | 'estatal' | 'municipal'
  final String modulo;
  final String accion;
  final String descripcion;
  final String? referenciaId;
}

// Regla de Priorización (motor configurable)
class ReglaPriorizacion {
  final String id;
  final String categoria;
  final String entorno;
  final String nivelPrioridad;  // 'critico' | 'alto' | 'medio' | 'bajo'
  final int slaHoras;
  final bool autoAprobar;
  final bool esReincidenteEscala;
  final bool activa;
}

// KPI Nacional
class KpiNacional {
  final int incidenciasActivas;
  final int criticas;
  final double cumplimientoSla;
  final int porVencer;
  final Map<String, int> porEstado;
  final Map<String, int> porCategoria;
}

// KPI Estatal
class KpiEstatal {
  final String estadoNombre;
  final int incidenciasActivas;
  final int criticas;
  final double cumplimientoSla;
  final int porVencer;
  final int tecnicosActivos;
  final int enProceso;
  final Map<String, int> porMunicipio;
}

// KPI Municipal
class KpiMunicipal {
  final String municipioNombre;
  final int incidenciasActivas;
  final int criticas;
  final double cumplimientoSla;
  final int abiertas;
  final int porVencer;
  final int tecnicosActivos;
}
```

---

## Datos Mock — Contexto Geográfico

**Nivel Nacional**: Métricas de los 32 estados de México (datos resumidos)
**Estado demo**: Baja California Norte
- Municipios: Tijuana, Mexicali, Ensenada, Tecate, Rosarito
- 329 incidencias activas, 43 críticas, 58 técnicos activos

**Municipio demo**: Ensenada
- 56 incidencias activas, 10 críticas, 13 técnicos activos
- SLA 89% cumplimiento

**Imágenes de evidencia** (reutilizar según categoría):
- `assets/images/casos/alumbrado/` → Alumbrado público
- `assets/images/casos/bacheo/` → Bacheo / baches
- `assets/images/casos/basura/` → Recolección de basura
- `assets/images/casos/señalizacion/` → Señalización vial

**Favicon**: `assets/images/favicon.png`

Todos los datos en `lib/data/mock_data.dart`.

---

## Mapa Operativo — flutter_map

```dart
// OpenStreetMap sin API key (flutter_map ya en pubspec.yaml)
FlutterMap(
  options: MapOptions(
    initialCenter: LatLng(31.8667, -116.5963), // Ensenada, BC
    initialZoom: 10,
  ),
  children: [
    TileLayer(
      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
      userAgentPackageName: 'com.cbluna.terranex',
    ),
    MarkerLayer(markers: _buildIncidenciaMarkers()),
  ],
)
```

Los marcadores usan color semántico según prioridad:
- Crítico → Rojo `#B91C1C`
- Alto → Amber `#D97706`
- Medio → Azul `#1D4ED8`
- Bajo → Verde `#2D7A4F`

---

## PlutoGrid — Patrón Estándar

**NUNCA usar `PlutoLazyPagination` con datos hardcodeados.**

```dart
// Provider construye las rows
List<PlutoRow> incidenciasRows = _incidencias.map((inc) => PlutoRow(cells: {
  'id':        PlutoCell(value: inc.id),
  'municipio': PlutoCell(value: inc.municipio),
  'categoria': PlutoCell(value: inc.categoria),
  'entorno':   PlutoCell(value: inc.entorno),
  'prioridad': PlutoCell(value: inc.prioridad),
  'estatus':   PlutoCell(value: inc.estatus),
  'sla':       PlutoCell(value: _formatSla(inc.fechaLimite)),
  '_objeto':   PlutoCell(value: inc), // objeto completo oculto
})).toList();

// PlutoGrid con paginación simple
createFooter: (stateManager) {
  stateManager.setPageSize(25, notify: false);
  return PlutoPagination(stateManager);
},
```

### Container estándar para PlutoGrid:
```dart
Container(
  decoration: BoxDecoration(
    color: theme.surface,
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: theme.border, width: 1),
    boxShadow: [
      BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
    ],
  ),
  child: ClipRRect(
    borderRadius: BorderRadius.circular(12),
    child: PlutoGrid(...),
  ),
)
```

---

## Badges de Prioridad y Estatus

```dart
Widget priorityBadge(String prioridad) {
  final Map<String, Color> colors = {
    'critico': const Color(0xFFB91C1C),
    'alto':    const Color(0xFFD97706),
    'medio':   const Color(0xFF1D4ED8),
    'bajo':    const Color(0xFF2D7A4F),
  };
  final color = colors[prioridad] ?? const Color(0xFF64748B);
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
    decoration: BoxDecoration(
      color: color.withOpacity(0.12),
      borderRadius: BorderRadius.circular(6),
      border: Border.all(color: color.withOpacity(0.4)),
    ),
    child: Text(
      prioridad.toUpperCase(),
      style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 11),
    ),
  );
}

Widget estatusBadge(String estatus) {
  final Map<String, Color> colors = {
    'recibido':   const Color(0xFF64748B),
    'en_revision':const Color(0xFFD97706),
    'aprobado':   const Color(0xFF1D4ED8),
    'asignado':   const Color(0xFF7A1E3A),
    'en_proceso': const Color(0xFF1D4ED8),
    'resuelto':   const Color(0xFF2D7A4F),
    'cerrado':    const Color(0xFF2D7A4F),
    'rechazado':  const Color(0xFF64748B),
    'vencido':    const Color(0xFFB91C1C),
  };
  final color = colors[estatus] ?? const Color(0xFF64748B);
  // mismo widget con el color correspondiente
}
```

---

## Formato de Datos

| Tipo | Formato | Ejemplo |
|------|---------|---------|
| Fecha larga | `22 de febrero de 2026` | — |
| Fecha + hora | `22/02/2026 14:35` | — |
| SLA restante | `3h 28m` / `Vencido` / `1d 12m` | — |
| ID incidencia | `#15420` | — |
| Porcentaje | `89 %` | — |
| Confianza IA | `96.4 %` | — |

---

## Convenciones de Código

- **Archivos**: `snake_case.dart`
- **Clases**: `PascalCase`
- **Variables**: `camelCase`
- **Imports**: (1) dart:, (2) package:flutter, (3) package:third_party, (4) relativos
- **Nunca mutar estado directamente**: siempre nuevas instancias + `notifyListeners()`
- **Dispose**: limpiar controllers/listeners en `dispose()`
- **Feedback**: SnackBar para acciones operativas (aprobar, rechazar, asignar, cerrar)
- **Persistencia**: Solo en memoria durante la sesión. Sin backend. Sin base de datos.
- **Package name**: `nethive_neo` (NO renombrar)

---

## Dependencias Clave (ya en pubspec.yaml)

| Paquete | Uso |
|---------|-----|
| `pluto_grid: ^8.0.0` | Tablas de incidencias/órdenes |
| `fl_chart: ^0.69.0` | Gráficas de tendencia y analítica |
| `flutter_map: ^7.0.2` | Mapa operativo (OpenStreetMap, sin API key) |
| `latlong2: ^0.9.1` | Coordenadas geográficas |
| `provider: ^6.1.1` | State management |
| `go_router: ^14.6.2` | Routing declarativo |
| `google_fonts: ^6.2.1` | Tipografía Inter |
| `url_launcher: ^6.2.0` | Botón "Salir" → cbluna.com (misma ventana) |
| `url_strategy: ^0.2.0` | URLs sin `#` en web |
| `intl: ^0.19.0` | Fechas/números en español |
| `auto_size_text: ^3.0.0` | Texto responsivo en KPI cards |
| `fl_heatmap: ^0.4.4` | Mapa de calor nacional |

---

## Diseño Responsivo

| Breakpoint | Comportamiento |
|------------|---------------|
| Desktop (> 1024px) | Sidebar fijo expandido + contenido completo |
| Tablet (768–1024px) | Sidebar colapsable (solo íconos) |
| Mobile (< 768px) | Drawer + cards apiladas |

Constante `mobileSize = 768` en `lib/helpers/constants.dart`

---

## Quick Reference

| Item | Valor |
|------|-------|
| **Producto** | Terranex — Smart City Operations |
| **Tipo** | Demo enterprise Flutter Web |
| **Contexto** | SaaS gestión incidencias urbanas — México |
| **Acento** | Vino `#7A1E3A` |
| **Sidebar bg** | Vino oscuro `#5C1528` |
| **Background claro** | `#F4F6F9` |
| **Background oscuro** | `#0D0F14` |
| **Fuente** | Inter (Google Fonts) |
| **Exit URL** | https://cbluna.com/ (misma ventana `_self`) |
| **Favicon** | `assets/images/favicon.png` |
| **Estado demo** | Baja California Norte |
| **Municipio demo** | Ensenada |
| **Package name** | `nethive_neo` (no cambiar) |
| **Mapa** | OpenStreetMap via flutter_map (sin API key) |
| **Imágenes evidencia** | `assets/images/casos/<categoria>/` |
