# Copilot Instructions — Terranex · SMART CITY OPERATIONS (Flutter Web Demo)

## ⚠️ REGLA CRÍTICA — ESTA DEMO ES WEB
**NUNCA ejecutar en Windows/Mac/Linux Desktop con `flutter run -d windows|macos|linux`.**
Esta es una **aplicación Flutter Web**.

✅ Ejecutar SIEMPRE en Chrome:
```bash
flutter run -d chrome
```
✅ Build producción:
```bash
flutter build web --release
```

---

## Descripción General del Proyecto

**Terranex — SMART CITY OPERATIONS** es una **demo enterprise** creada con **Flutter Web** que simula un **Centro de Operaciones de Ciudad Inteligente**.

- **Todo es hardcodeado y simulado** (sin backend real, sin base de datos).
- Aun así, **NO es estática**: los módulos usan **Provider** para simular flujos reales (cambios de estado, aprobaciones, asignaciones, métricas que “se mueven”, etc.).
- El objetivo es que se perciba como un **producto SaaS enterprise** listo para operar incidencias, órdenes, SLA, recursos e inteligencia territorial.

### Rol único (para la demo)
La demo se enfoca en **un solo rol con máximos privilegios**:
- **Admin Operativo Global** (ve todo, configura todo, opera todo).

> Nota: No se modelan múltiples roles/permiso en UI; se asume acceso total para simplificar la demo.

---

## Objetivo de la Demo

Demostrar una plataforma tipo **Smart City Operations SaaS** con:
- **Visión ejecutiva** (KPIs, riesgo, tendencias)
- **Operación diaria** (incidencias/órdenes, bandejas, aprobaciones)
- **Territorio** (mapa operativo, zonas)
- **Recursos** (técnicos/cuadrillas)
- **Inventario** (materiales y movimientos)
- **Inteligencia** (analítica + SLA)
- **Administración** (políticas de priorización)

Todo con **look & feel enterprise**, navegación clara, y módulos bien segmentados.

---

## Arquitectura del Proyecto

### App Name & Package
- **App title display**: `Terranex — Smart City Operations`
- **Package name**: (mantener el existente del repo; NO renombrar si ya está creado)

### Estrategia de implementación
- **Datos mock centralizados**
- **Providers por módulo**
- **Routing con GoRouter**
- **Layout principal reutilizable** (Sidebar + Topbar + Body)
- **Componentes UI globales** (cards, chips, tablas, charts, filtros)

---

## Estructura de Carpetas (Recomendada)

```
lib/
├── main.dart
├── data/
│   ├── mock_data.dart                 ← Hub central de datos simulados
│   └── demo_scenarios.dart            ← Escenarios para “mover” métricas/estados
├── helpers/
│   ├── constants.dart                 ← Breakpoints, tamaños, espaciados
│   ├── formatters.dart                ← Dinero/fechas/porcentajes
│   ├── color_tokens.dart              ← Paleta (hex → Color)
│   ├── semantics.dart                 ← Estados/labels/chips
│   └── scroll_behavior.dart
├── models/
│   ├── incident.dart                  ← Incidencia/Orden
│   ├── approval.dart                  ← Aprobaciones
│   ├── technician.dart                ← Técnicos/cuadrillas
│   ├── inventory.dart                 ← Materiales/movimientos
│   ├── zone.dart                      ← Zonas/cuadrantes
│   └── kpi.dart                       ← KPIs y series
├── providers/
│   ├── visual_state_provider.dart     ← Navegación, tema, drawer
│   ├── dashboard_provider.dart
│   ├── inbox_provider.dart            ← Bandeja (pre-aprobados)
│   ├── incidents_provider.dart        ← Órdenes/incidencias (tabla core)
│   ├── approvals_provider.dart
│   ├── schedule_provider.dart
│   ├── map_provider.dart
│   ├── zones_provider.dart
│   ├── technicians_provider.dart
│   ├── inventory_provider.dart
│   ├── movements_provider.dart
│   ├── analytics_provider.dart
│   ├── sla_provider.dart
│   └── policies_provider.dart
├── router/
│   └── router.dart                    ← GoRouter
├── theme/
│   └── theme.dart                     ← AppTheme enterprise + tokens
├── widgets/
│   ├── layout/
│   │   ├── main_container.dart         ← Sidebar + Topbar + Body
│   │   ├── sidebar.dart
│   │   └── topbar.dart
│   ├── ui/
│   │   ├── kpi_card.dart
│   │   ├── section_header.dart
│   │   ├── status_chip.dart
│   │   ├── filters_bar.dart
│   │   └── empty_state.dart
│   ├── tables/
│   │   └── pluto_table.dart            ← Wrapper estándar PlutoGrid
│   └── charts/
│       └── charts.dart                 ← Wrappers fl_chart
└── pages/
    ├── page_not_found.dart
    ├── dashboard/
    │   └── dashboard_page.dart
    ├── inbox/
    │   └── inbox_page.dart
    ├── incidents/
    │   └── incidents_page.dart
    ├── approvals/
    │   └── approvals_page.dart
    ├── schedule/
    │   └── schedule_page.dart
    ├── map/
    │   └── map_page.dart
    ├── zones/
    │   └── zones_page.dart
    ├── technicians/
    │   └── technicians_page.dart
    ├── inventory/
    │   └── inventory_page.dart
    ├── movements/
    │   └── movements_page.dart
    ├── analytics/
    │   └── analytics_page.dart
    ├── sla/
    │   └── sla_page.dart
    └── policies/
        └── policies_page.dart
```

---

## Sidebar — Estructura (Terranex)

> SideMenu por capas: **Inicio / Operación / Territorio / Recursos / Inventario / Inteligencia / Administración**

```
┌──────────────────────────────────┐
│  [Isotipo] TERRANEX              │
│  SMART CITY OPERATIONS           │
├──────────────────────────────────┤
│  INICIO                          │
│   • Dashboard Ejecutivo          │
├──────────────────────────────────┤
│  OPERACIÓN                       │
│   • Bandeja (Pre-aprobados)      │
│   • Órdenes / Incidencias        │
│   • Aprobaciones                 │
│   • Agenda / Programación        │
├──────────────────────────────────┤
│  TERRITORIO                      │
│   • Mapa Operativo               │
│   • Zonas / Cuadrantes           │
├──────────────────────────────────┤
│  RECURSOS DE CAMPO               │
│   • Técnicos y Cuadrillas        │
│   • Vehículos / Equipamiento     │
├──────────────────────────────────┤
│  INVENTARIO Y MATERIALES         │
│   • Inventario                   │
│   • Solicitudes de Material      │
│   • Movimientos                  │
├──────────────────────────────────┤
│  INTELIGENCIA                    │
│   • Analítica                    │
│   • SLA y Desempeño              │
│   • Exportaciones                │
├──────────────────────────────────┤
│  ADMINISTRACIÓN                  │
│   • Políticas de Priorización    │
├──────────────────────────────────┤
│  [Salir de la Demo]              │
└──────────────────────────────────┘
```

---

## Páginas — Objetivo de Cada Módulo

### 1) Dashboard Ejecutivo (`/`)
- KPIs: backlog total, críticas, SLA compliance, tendencia 7/30 días, top zonas, top categorías.
- Acciones rápidas simuladas: “Aprobar pendientes”, “Asignar técnicos”, “Ver SLA por vencer”.
- Gráficas: tendencia por día/semana, distribución por prioridad, ranking por zona.

### 2) Bandeja (Pre-aprobados) (`/inbox`)
- Lista de reportes “pre-clasificados” (simulado) con evidencia/score.
- Acciones: aprobar, rechazar, reclasificar, ajustar prioridad.
- Al aprobar: genera/activa una Orden (simulado) y mueve contadores del dashboard.

### 3) Órdenes / Incidencias (Core) (`/incidents`)
- Tabla principal (PlutoGrid): filtros, vistas guardadas (simuladas), acciones masivas.
- Columnas: ID, categoría, prioridad, estado, SLA, zona, asignado, creado, última actualización.
- Drawer de detalle (derecha): evidencia, mapa, timeline de cambios, acciones.

### 4) Aprobaciones (`/approvals`)
- Bandeja de autorizaciones: solicitudes de material, reasignaciones, cierres.
- Acciones: aprobar / rechazar con comentario.

### 5) Agenda / Programación (`/schedule`)
- Calendar/Timeline por técnico y por zona.
- Drag & drop opcional (simulado) para reprogramar.

### 6) Mapa Operativo (`/map`)
- Mapa con clusters/pins/heat (según alcance demo).
- Panel lateral con incidencias filtradas.
- Quick actions: abrir detalle, cambiar prioridad/estado.

### 7) Zonas / Cuadrantes (`/zones`)
- Catálogo de zonas: nombre, tipo de entorno, responsable, horario.
- Simula herencia de reglas por zona.

### 8) Técnicos y Cuadrillas (`/technicians`)
- Disponibilidad, carga, especialidad, zona asignada.
- Detalle: historial, desempeño, tiempos promedio (simulados).

### 9) Vehículos / Equipamiento (`/assets`)
- Inventario de unidades/herramientas con estatus.
- Asignación a cuadrillas.

### 10) Inventario (`/inventory`)
- Stock, mínimos, almacén, lead time, proveedor, alertas.
- Chips semánticos: ok / bajo / crítico.

### 11) Solicitudes de Material (`/material-requests`)
- Flujo: borrador → enviado → aprobado → entregado → consumido/devuelto.
- Siempre vinculado a una Orden (simulado por ID).

### 12) Movimientos (`/movements`)
- Entradas/salidas/ajustes con trazabilidad.

### 13) Analítica (`/analytics`)
- KPIs por dependencia/zona/técnico/categoría.
- Comparativas temporales.

### 14) SLA y Desempeño (`/sla`)
- Vencidos / por vencer.
- Causas, ranking por zona/técnico.

### 15) Exportaciones (`/exports`)
- Botones de export simulado (SnackBar) para PDF/Excel/actas.

### 16) Políticas de Priorización (`/policies`)
- Editor de reglas “tipo enterprise” (tabla/árbol simulado).
- Ajusta ponderadores por zona/entorno.

---

## Routing — GoRouter

**Router config**: `lib/router/router.dart`

| Ruta | Página |
|------|--------|
| `/` | Dashboard Ejecutivo |
| `/inbox` | Bandeja (Pre-aprobados) |
| `/incidents` | Órdenes / Incidencias |
| `/approvals` | Aprobaciones |
| `/schedule` | Agenda / Programación |
| `/map` | Mapa Operativo |
| `/zones` | Zonas / Cuadrantes |
| `/technicians` | Técnicos y Cuadrillas |
| `/assets` | Vehículos / Equipamiento |
| `/inventory` | Inventario |
| `/material-requests` | Solicitudes de Material |
| `/movements` | Movimientos |
| `/analytics` | Analítica |
| `/sla` | SLA y Desempeño |
| `/exports` | Exportaciones |
| `/policies` | Políticas de Priorización |

- Sin auth real.
- Sin transiciones (usar `NoTransitionPage`).
- Botón “Salir” abre `https://cbluna.com/`.

---

## State Management — Provider

- `VisualStateProvider`: sidebar (expand/collapse), ruta activa, tema.
- Providers por módulo: cada página tiene provider con datos mock + mutaciones simuladas.

**Regla demo:** al ejecutar acciones (aprobar, asignar, cerrar, etc.) debe:
1) actualizar el objeto en memoria
2) emitir un evento en un “timeline” simulado
3) mover KPIs del Dashboard (también en memoria)

---

## Sistema de Colores — Terranex (Enterprise)

### Principio
- La UI vive en **neutros**.
- El color institucional **vino** es **acento** (CTA primario, item activo, highlights).
- **Rojo es exclusivo de error/estado crítico**, NO de branding.

### Paleta (Hex)
**Neutros / Superficie**
- Background: `#F5F7FA`
- Surface: `#FFFFFF`
- Border: `#E5E9F2`
- Text Primary: `#1F2937`
- Text Secondary: `#6B7280`

**Brand (Acento)**
- Brand / Primary Accent: `#7A1E3A`
- Brand Hover: `#64182F`
- Sidebar Background (Dark): `#1C1F2A`

**Semánticos**
- Info: `#2563EB`
- Success: `#16A34A`
- Warning: `#F59E0B`
- Error: `#DC2626`
- Critical (opcional): `#B91C1C`

### Dark Mode (opcional demo)
- Background Dark: `#111827`
- Surface Dark: `#1F2937`
- Border Dark: `#374151`

---

## UI/UX — Reglas Enterprise

- Tablas administrativas con **PlutoGrid** (sin lazy pagination con mock).
- Detalle rápido con **drawer derecho** (no navegar a otra pantalla).
- Filtros consistentes en todas las tablas.
- Estados con **chips semánticos** (no solo color).
- Animación sutil (nunca flashy). Preferir micro-interacciones.

---

## Dependencias Clave (Recomendadas)

| Paquete | Uso |
|--------|-----|
| `pluto_grid` | Tablas enterprise |
| `fl_chart` o `syncfusion_flutter_charts` | Gráficas |
| `provider` | State management |
| `go_router` | Routing |
| `google_fonts` | Tipografía (Inter) |
| `intl` | Formateo de fechas/números |
| `url_launcher` | Botón “Salir” |
| `flutter_animate` | Animaciones sutiles |
| `flutter_map` (opcional) | Mapa real (si aplica) |

---

## Comandos

```bash
flutter pub get
flutter run -d chrome
flutter build web --release
```

---

## Quick Reference

- **Nombre**: Terranex — Smart City Operations
- **Tipo**: Flutter Web Demo (mock + simulación)
- **Rol**: Admin Operativo Global
- **Paleta**: Vino `#7A1E3A` + neutros + semánticos
- **Layout**: Sidebar + Topbar + Body
- **Core**: Órdenes/Incidencias + Mapa + Bandeja + SLA

