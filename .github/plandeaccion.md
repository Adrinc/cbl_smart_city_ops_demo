# Plan de Acción — Terranex · Smart City Operations

**Fecha inicio**: 22 de febrero de 2026  
**Stack**: Flutter Web · Provider · GoRouter · PlutoGrid · fl_chart · flutter_map  
**Demo**: Admin Operativo Global · Sin auth · Datos hardcodeados

---

## FASE 0 — Fundación del Proyecto

> Base técnica que todas las fases siguientes consumen. Debe quedar sólida antes de construir páginas.

- [ ] **0.1** Limpiar `lib/` de todo código heredado del proyecto anterior (ERP nethive_neo) que no aplique al nuevo contexto
- [ ] **0.2** Actualizar `web/index.html`: título `Terranex — Smart City Operations`, favicon `assets/images/favicon.png`
- [ ] **0.3** Crear/reescribir `lib/theme/theme.dart` con paleta enterprise Vino (`#7A1E3A`) + semánticos operativos (crítico/alto/medio/bajo/neutral) + sidebar tokens + modo oscuro
- [ ] **0.4** Crear `lib/helpers/constants.dart`: breakpoints, tamaños sidebar, rutas como constantes
- [ ] **0.5** Crear `lib/helpers/formatters.dart`: `formatFecha()`, `formatSla()`, `formatPorcentaje()`, `formatIdIncidencia()`
- [ ] **0.6** Crear modelos en `lib/models/`: `Incidencia`, `Tecnico`, `Material`, `ReglaPriorizacion`, `EventoAuditoria`, `KpiNacional`, `KpiEstatal`, `KpiMunicipal`, `UsuarioSistema`
- [ ] **0.7** Crear `lib/data/mock_data.dart` con datos hardcodeados: ~80 incidencias (Ensenada), ~15 técnicos, ~40 materiales, ~12 reglas de priorización, ~20 eventos auditoria, KPIs 32 estados (nacionales), KPIs municipios BC
- [ ] **0.8** Registrar todos los Providers en `main.dart` vía `MultiProvider`

---

## FASE 1 — Shell Principal (Layout Base)

> Estructura visual que envuelve todas las páginas. El sidebar adaptativo es el corazón de la experiencia.

- [ ] **1.1** Crear `lib/providers/app_level_provider.dart`: nivel activo (`nacional`/`estatal`/`municipal`), breadcrumb, estado del sidebar (expandido/colapsado)
- [ ] **1.2** Crear `lib/pages/main_container/main_container_page.dart`: layout `Row(sidebar + body)`, responsivo
- [ ] **1.3** Crear `lib/widgets/sidebar/sidebar_widget.dart`: sidebar adaptativo por nivel (3 variantes de menú según `AppLevelProvider.nivel`)
  - Logo en parte superior
  - Context breadcrumb: `México > Baja California > Ensenada`
  - Menú adaptado por nivel (nacional = corto / estatal = medio / municipal = completo)
  - Separadores visuales por grupo de módulos
  - Ítem activo destacado con acento vino
  - **Botón "Salir de la Demo"** en la parte inferior (siempre visible) → `url_launcher` a `https://cbluna.com/` en `_self`
- [ ] **1.4** Crear `lib/widgets/topbar/topbar_widget.dart`: breadcrumb contextual, chip "Cambiar Nivel", notificaciones (simuladas), avatar usuario
- [ ] **1.5** Configurar `lib/router/router.dart` con GoRouter: rutas `/`, `/state`, `/municipal`, `/ordenes`, `/mapa`, `/tecnicos`, `/inventario`, `/bandeja-ia`, `/aprobaciones`, `/sla`, `/reportes`, `/configuracion`, `/usuarios`, `/auditoria`, `/catalogos`. Sin transiciones (`NoTransitionPage`).
- [ ] **1.6** Crear `lib/widgets/shared/`: `KpiCard`, `PriorityBadge`, `EstatusBadge`, `SlaTimer`, `AlertaRow`, `SectionHeader`

---

## FASE 2 — Visión Nacional (`/`)

> Primera pantalla al abrir la demo. Limpia, ejecutiva, estratégica. Su función es demostrar escala nacional.

- [ ] **2.1** Crear `lib/providers/kpi_nacional_provider.dart` con datos mock de los 32 estados
- [ ] **2.2** Crear `lib/pages/nacional/vision_nacional_page.dart`
  - **KPI strip** (5 cards): Incidencias Activas (3,287) · Críticas (389) · Cumplimiento SLA (89%) · Por Vencer (42) · Técnicos Activos (nacional)
  - **Gráfica de tendencia** (fl_chart - LineChart): últimos 7 días (Recibidas / Resueltas / Críticas)
  - **Mapa de calor nacional** con burbujas de conteo por estado (fl_heatmap o solución SVG con `countries_world_map`)
  - **Tabla alertas estatales críticas**: Estado · Categoría · Prioridad · SLA restante (PlutoGrid ligero o ListView)
  - **CTA prominente**: Botón `"Ir a Estado →"` (vino, grande) → navega a `/state`
- [ ] **2.3** Sidebar en modo Nacional (menú corto con 6 ítems)

---

## FASE 3 — Centro Operativo Estatal (`/state`)

> Vista de coordinación regional. Más datos que el nacional, menos operativa que la municipal.

- [ ] **3.1** Crear `lib/providers/kpi_estatal_provider.dart`
- [ ] **3.2** Crear `lib/pages/estatal/centro_estatal_page.dart`
  - **KPI strip** (6 cards): Incidencias Activas (329) · Críticas (43) · Cumplimiento SLA (89%) · En Proceso (27) · Por Vencer (21) · Técnicos Activos (58)
  - **Mapa estatal** (flutter_map centrado en Baja California Norte) con marcadores por municipio + conteo de incidencias activas
  - **Tabla de incidencias por municipio** (PlutoGrid): ID · Municipio · Categoría · Entorno · Prioridad · Estado · SLA — con filtros de municipio y prioridad
  - **Panel alertas estatales**: SLA críticos próximos a vencer por municipio
  - **CTA prominente**: Botón `"Entrar a Municipio →"` → navega a `/municipal`
- [ ] **3.3** Sidebar en modo Estatal (menú medio)

---

## FASE 4 — Centro Operativo Municipal (`/municipal`)

> La pantalla más rica de la demo. Aquí se vende la capacidad operativa del sistema.

- [ ] **4.1** Crear `lib/providers/kpi_municipal_provider.dart`
- [ ] **4.2** Crear `lib/pages/municipal/dashboard_municipal_page.dart`
  - **KPI strip** (6 cards): Incidencias Activas (56) · Críticas (10) · Cumplimiento SLA (89%) · Abiertas (17) · Por Vencer (26) · Técnicos Activos (13)
  - **Layout 2 columnas**:
    - Izquierda: Mapa operativo Ensenada (flutter_map, marcadores por prioridad coloreados) + botón "Ver Mapa Completo"
    - Derecha: Grid ligero de incidencias recientes (últimas 5, con ID/categoría/prioridad/SLA/estado)
  - **Panel inferior izquierdo**: Alertas del municipio (SLA críticos)
  - **Panel inferior derecho**: Técnicos activos (lista con avatar/nombre/rol/incidencias activas/especialidad)
- [ ] **4.3** Sidebar en modo Municipal (menú completo con todos los grupos)

---

## FASE 5 — Módulo Órdenes / Incidencias (`/ordenes`)

> Bandeja operativa principal del nivel municipal.

- [ ] **5.1** Crear `lib/providers/incidencia_provider.dart`: lista completa, filtros, cambio de estado, asignación
- [ ] **5.2** Crear `lib/pages/ordenes/ordenes_page.dart`
  - PlutoGrid completo: ID · Municipio · Categoría · Entorno · Prioridad · Estado · SLA · Técnico asignado · Acciones
  - Filtros por: categoría, prioridad, estado, municipio, rango de fechas
  - Acciones por fila: Ver detalle · Asignar técnico · Cambiar estado · Cerrar
  - Botón "Crear Orden Manual +" (simulado con modal/form)
  - Badges coloreados para prioridad y estado
- [ ] **5.3** Crear `lib/pages/ordenes/widgets/detalle_incidencia_drawer.dart`: panel lateral con imagen de evidencia, datos completos, historial de cambios de estado, sugerencia IA

---

## FASE 6 — Bandeja IA (`/bandeja-ia`)

> Diferencial clave de la plataforma. Muestra el modelo "humano en el loop".

- [ ] **6.1** Crear `lib/providers/bandeja_ia_provider.dart`: reportes pendientes con metadata de IA (categoría sugerida, prioridad sugerida, confianza, nota coherencia)
- [ ] **6.2** Crear `lib/pages/bandeja_ia/bandeja_ia_page.dart`
  - Lista de reportes ciudadanos pendientes de revisión
  - Cada ítem muestra: imagen evidencia · descripción ciudadano · sugerencia IA (categoría + prioridad + % confianza + nota coherencia)
  - Acciones: **Aprobar** (con correcciones opcionales) · **Rechazar** (con motivo) · **Reclasificar**
  - Al aprobar → mueve a Órdenes con estado "aprobado" y dispara SnackBar
  - Contador badge en el sidebar con pendientes

---

## FASE 7 — Mapa Operativo (`/mapa`)

> Vista de mapa full-screen con todas las incidencias de Ensenada.

- [ ] **7.1** Crear `lib/pages/mapa/mapa_page.dart`
  - flutter_map full-width/height con OpenStreetMap
  - Marcadores coloreados por prioridad (con popup al hacer click: ID, categoría, estado, SLA)
  - Panel lateral colapsable con lista de incidencias filtrable
  - Capas: todo · solo críticas · por categoría
  - Marcadores de técnicos en campo (icono diferente)

---

## FASE 8 — Técnicos (`/tecnicos`)

- [ ] **8.1** Crear `lib/providers/tecnico_provider.dart`
- [ ] **8.2** Crear `lib/pages/tecnicos/tecnicos_page.dart`
  - Vista dual: tarjetas de técnicos (nombre, foto-avatar, rol, especialidad, estatus, incidencias activas) + tabla resumen
  - Indicador de estado en tiempo real simulado: activo · en campo · descanso
  - Mini-mapa con ubicación de cada técnico
  - Acciones: Ver detalle · Asignar a incidencia · Cambiar estatus

---

## FASE 9 — Inventario (`/inventario`)

- [ ] **9.1** Crear `lib/providers/inventario_provider.dart`
- [ ] **9.2** Crear `lib/pages/inventario/inventario_page.dart`
  - PlutoGrid: Clave · Descripción · Categoría · Unidad · Stock · Reservado · Disponible real · Stock mínimo · Estatus
  - Badge semántico de estatus: disponible (verde) · bajo stock (amber) · agotado (rojo)
  - Filtros por categoría y estatus
  - Acciones: Ajuste de stock (modal simulado) · Solicitar reposición

---

## FASE 10 — Monitor SLA (`/sla`)

- [ ] **10.1** Crear `lib/providers/sla_provider.dart`
- [ ] **10.2** Crear `lib/pages/sla/sla_page.dart`
  - KPI de cumplimiento global y por categoría
  - Tabla de incidencias próximas a vencer (ordenadas por urgencia)
  - Semáforo visual: verde (>80%) · amber (60-80%) · rojo (<60%)
  - Distribución de SLA: `<24h` · `24-48h` · `48-72h` · `>72h` · `Vencido` (gráfica de barras fl_chart)

---

## FASE 11 — Aprobaciones (`/aprobaciones`)

- [ ] **11.1** Crear `lib/pages/aprobaciones/aprobaciones_page.dart`
  - Lista de incidencias aprobadas esperando asignación de técnico
  - Acciones: Asignar técnico · Priorizar · Posponer (con motivo)
  - Vista rápida de disponibilidad de técnicos por especialidad

---

## FASE 12 — Reportes y Analítica (`/reportes`)

- [ ] **12.1** Crear `lib/providers/reporte_provider.dart`
- [ ] **12.2** Crear `lib/pages/reportes/reportes_page.dart`
  - Gráfica de área: Incidencias recibidas vs resueltas (últimos 30 días)
  - Gráfica de barras: Incidencias por categoría
  - Gráfica de barras: Desempeño por técnico (cerradas/mes)
  - Gráfica de donut: Distribución por prioridad
  - Tabla: Ranking de zonas/entornos con más incidencias
  - Filtro: Nacional / Estatal / Municipal / Rango de fechas
  - Botón "Exportar" → SnackBar de confirmación simulada

---

## FASE 13 — Motor de Priorización (`/configuracion`)

> Módulo admin diferencial: muestra que el sistema es configurable y no hardcodeado en lógica.

- [ ] **13.1** Crear `lib/providers/configuracion_provider.dart`
- [ ] **13.2** Crear `lib/pages/configuracion/configuracion_page.dart`
  - **Tabla de reglas de priorización**: Categoría · Entorno · Prioridad asignada · SLA (horas) · Auto-aprobar · Escalar reincidentes · Activa
  - Toggle para activar/desactivar reglas
  - Edición inline de SLA horas y prioridad
  - Botón "Nueva Regla" (modal)
  - Mensaje informativo: "Estas reglas son aplicadas por el motor de IA al clasificar nuevos reportes ciudadanos"

---

## FASE 14 — Catálogos (`/catalogos`)

- [ ] **14.1** Crear `lib/pages/catalogos/catalogos_page.dart`
  - Tabs: Categorías de incidencia · Zonas / Entornos · Dependencias municipales · Tipos de técnico
  - CRUD simulado en cada tab (listas editables con modal)

---

## FASE 15 — Usuarios (`/usuarios`)

- [ ] **15.1** Crear `lib/pages/usuarios/usuarios_page.dart`
  - PlutoGrid: Nombre · Email · Rol · Nivel de acceso · Último acceso · Estatus
  - Roles: `admin` · `operador_nacional` · `operador_estatal` · `operador_municipal` · `supervisor`
  - Acciones: Editar rol · Activar/Bloquear

---

## FASE 16 — Auditoría (`/auditoria`)

- [ ] **16.1** Crear `lib/pages/auditoria/auditoria_page.dart`
  - Log completo: Timestamp · Usuario · Nivel · Módulo · Acción · Descripción · Referencia
  - Filtros: por usuario, módulo, nivel, acción, rango de fechas
  - Exportar simulado

---

## FASE 17 — Pulido Enterprise y Cierre

> La diferencia entre "funciona" y "se ve como producto real".

- [ ] **17.1** Revisar consistencia visual de todos los módulos (colores, tipografía, espaciados, bordes)
- [ ] **17.2** Validar sidebar adaptativo en los 3 niveles (transiciones suaves)
- [ ] **17.3** Verificar CTA "Ir a Estado" (Nacional) y "Entrar a Municipio" (Estatal) funcionan correctamente
- [ ] **17.4** Verificar botón "Salir de la Demo" en todos los niveles → `https://cbluna.com/` en `_self`
- [ ] **17.5** Asegurar favicon cargando: `assets/images/favicon.png` referenciado en `web/index.html`
- [ ] **17.6** Revisar responsividad: desktop, tablet y móvil
- [ ] **17.7** SnackBars de feedback en todas las acciones operativas (aprobar, rechazar, asignar, cerrar, exportar)
- [ ] **17.8** Modo oscuro: verificar contraste y legibilidad en todos los módulos
- [ ] **17.9** Test de navegación completa: Nacional → Estatal → Municipal → todos los módulos del sidebar
- [ ] **17.10** `flutter build web --release` sin errores · verificar en Chrome

---

## Notas Técnicas Importantes

| Tema | Decisión |
|------|----------|
| Mapa | `flutter_map` + OpenStreetMap (sin API key) |
| Routing | Rutas planas + nivel activo en `AppLevelProvider` |
| Sidebar | Adaptativo por nivel (3 variantes de menú) |
| PlutoGrid | Sin `PlutoLazyPagination` (datos hardcodeados) |
| Imágenes evidencia | Reutilizar `assets/images/casos/<categoria>/` |
| Exit button | `url_launcher` → `https://cbluna.com/` en `_self` |
| Estado demo | Baja California Norte |
| Municipio demo | Ensenada |
| Auth | No existe. Acceso directo a todo. |
