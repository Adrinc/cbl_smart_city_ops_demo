# Plan de Mejoras — Terranex Smart City Operations

**Fecha:** Junio 2025 · **Versión:** 2.5 · **Plataforma:** Flutter Web

---

## Estado Actual (v2.2 — baseline)

| Módulo | Estado | Notas |
|--------|--------|-------|
| Dashboard Nacional | ✅ Completo | KPIs, mapa calor, alertas |
| Dashboard Estatal | ✅ Completo | BC Norte, municipios |
| Dashboard Municipal | ✅ Completo | Ensenada, gráficas fl_chart |
| Bandeja IA | ✅ Completo v2 | Modularizado en widgets/ |
| Órdenes / Incidencias | ✅ Completo | PlutoGrid + cards |
| Mapa Operativo | ✅ Completo | flutter_map, marcadores |
| Técnicos | ✅ Mejorado v2 | PlutoGrid + NuevoTécnico + avatar upload |
| Inventario | ✅ Completo | PlutoGrid + alertas stock |
| Aprobaciones | ✅ Completo | Flujo pendientes |
| SLA Monitor | ✅ Completo | Alertas por vencer |
| Reportes | ✅ Completo | fl_chart analítica |
| Configuración | ✅ Completo | Motor de priorización |
| Usuarios | ✅ Completo | PlutoGrid + NuevoUsuario |
| Auditoría | ✅ Completo | Log de eventos |
| Catálogos | ✅ Completo | Categorías, zonas |

---

## Mejoras Implementadas en v2.3

### BandejaIA (Modularización completa)
- **Widgets extraídos** a `lib/pages/bandeja_ia/widgets/`:
  - `helpers_bandeja.dart` — constantes `kCatIcons`, helpers `esRechazoIA`, `approxDireccion`
  - `filter_bar_bandeja.dart` — barra de filtros (search + dropdowns)
  - `imagen_viewer_dialog.dart` — visor pantalla completa
  - `mapa_ubicacion_dialog.dart` — mapa FlutterMap con icono de categoría en marcador
  - `confirmar_accion_dialog.dart` — confirmación con motivo obligatorio cuando IA aprueba pero operador rechaza
  - `detalle_caso_dialog.dart` — vista completa del caso (imagen grande, análisis IA, coordenadas, acciones)
  - `bandeja_card.dart` — tarjeta mobile mejorada
  - `pluto_bandeja_view.dart` — PlutoGrid desktop con columna de thumbnail y 4 acciones icono-solo
- **PlutoGrid mejorado**: columna de imagen (thumbnail 52×52), columna categoría con ícono, acciones compactas
- **Marcadores de mapa**: ícono específico por categoría (no genérico)
- `bandeja_ia_page.dart` reducido a ~120 líneas (orquestación pura)

### Técnicos (Reescritura v2)
- **PlutoGrid en desktop** (≥ 820px): columnas avatar, ID, nombre, rol, especialidad, estatus badge, activas, cerradas/mes, municipio, acciones
- **Cards mejoradas mobile**: avatar, badges de especialidad, métricas visuales, 2 botones de acción
- **"Nuevo Técnico"** dialog completo:
  - Upload de foto avatar desde dispositivo (dart:html FileReader → Uint8List)
  - Preview circular en tiempo real
  - Campos: nombre, rol, especialidad, estatus inicial
  - Genera ID auto (`TEC-014`, etc.)
- **Dialog "Ver detalle"**: avatar grande, todos los campos, estatus badge
- **Dialog "Cambiar estatus"**: RadioListTile con colores semánticos
- **TecnicoProvider**: `agregarTecnico()`, `setAvatarBytes()`, `getAvatarBytes()`, `setFiltroEstatus()`, `filtrados`
- **Filtros ChoiceChips**: todos, activos, en campo, descanso, inactivos

---

## Mejoras Implementadas en v2.4

### Mapa Operativo — Panel lateral derecho
- **`_MapaSidePanel`** slide desde la derecha al hacer clic en un marcador (`AnimatedPositioned` con transición suave 300 ms)
- **Imagen del incidente** como hero banner (180 px): overlay con badge de prioridad + ID formateado + botón de cierre circular
- **Tarjeta del técnico asignado**: avatar real (`AssetImage` vía `avatarPath` o `MemoryImage` para fotos subidas, con fallback de iniciales), nombre, rol y badge de estatus
- **Filas informativas**: especialidad, hora estimada de llegada (simulada por prioridad), tiempo estimado de reparación (por categoría × prioridad), incidencias activas
- **Materiales estimados**: lista bullet simulada por categoría (`_materialesPor`)
- **Footer**: badge de reincidente si aplica + enlace "Ver orden completa"
- `_TecRow` como helper widget interno reutilizable

### Topbar Global — Dropdown de administrador
- Avatar real circular (`assets/images/avatares/Maria.png`) en reemplazo del simple contenedor "AT"
- Nombre **Admin Terranex** + rol **Administrador** visibles en el topbar sin necesidad de abrir el menú
- `MenuAnchor` con cabecera decorativa (avatar grande 20 r, nombre, rol)
- Opciones: Ver perfil, Actividad reciente, Configuración (navega a `/configuracion`), Centro de ayuda, separador, **Cerrar sesión** (snackbar informativo de demo)
- `_AdminDropdown` y `_MenuOpt` como widgets privados independientes

### PlutoGrid — Auto-expand de columnas
- Cambiado `PlutoAutoSizeMode.none` → `PlutoAutoSizeMode.scale` en:
  - `lib/pages/bandeja_ia/widgets/pluto_bandeja_view.dart`
  - `lib/pages/tecnicos/tecnicos_page.dart`
- Las columnas ahora se distribuyen proporcionalmente para rellenar el 100% del ancho disponible del contenedor

---

## Mejoras Implementadas en v2.5

### AuditoriaProvider (nuevo)
- `lib/providers/auditoria_provider.dart` — provider central con `registrar()`, `filtrados`, `setFiltroModulo/Nivel/Accion()`, `limpiarFiltros()`, `tieneFiltros`
- Registrado en `main.dart` vía `MultiProvider`

### Auditoría — Log real de acciones
- Página reescrita para consumir `AuditoriaProvider` (en vez de `mockAuditoria` directo)
- **Filtros con ChoiceChips** por nivel (Nacional / Estatal / Municipal) + dropdown módulo
- **Limpiar filtros** inline con contador de resultados
- **Exportar CSV** (`dart:html` blob download) con todos los campos del evento
- **Mobile cards** (`< 768 px`): badge nivel, modulo, acción, descripción, referencia, usuario
- **Desktop**: lista con icono por módulo, badges de nivel + usuario + referencia

### Bandeja IA — Mejoras menores
- **Stats row** en el header: contadores "Recomienda aprobar" (verde), "Recomienda rechazar" (rojo), "Sin fallo" (neutral)
- **Acción bulk** "Aprobar todos los recomendados" (`FilledButton.tonal`)
- `_confirmAccion` + `_bulkAprobar` registran evento en `AuditoriaProvider`
- Widget `_StatPill` (icono + conteo en columna)

### Órdenes — Técnico asignado y auditoría
- **Dialog "Asignar técnico"** (`lib/pages/ordenes/widgets/asignar_tecnico_dialog.dart`):
  - Filter chips por especialidad (pre-seleccionado según categoría de la incidencia)
  - Avatar real (asset / MemoryImage / iniciales fallback)
  - Al confirmar: `asignarTecnico()` + `incrementarActivas()` + `registrar()` en auditoría
- **Panel de detalle** (`_showDetail`) muestra `_TecnicoInfoRow` con nombre + especialidad + avatar
- Botones "Iniciar" y "Marcar Resuelta" también registran evento de auditoría
- `TecnicoProvider`: métodos `incrementarActivas(id)` y `decrementarActivas(id)`
- `formatters.dart`: función `labelEspecialidad()`

### Reportes — PDF simulado + responsive
- **Botón "Descargar PDF"** en el header `trailing`: abre dialog de progreso → tras 2 s cierra y muestra SnackBar "Reporte generado"
- **KPI row responsivo** con `LayoutBuilder`: en pantallas `< 700 px` cambia de `Row` a `Wrap` de 2 columnas

### Mapa — Filtro por categoría
- Nuevo filtro **Categoría** en segunda fila de controles (ChoiceChips: Alumbrado, Bacheo, Basura, Agua / Drenaje, Señalización, Seguridad)
- `_buildIncidenciaMarkers` aplica ambos filtros: `_filterPrioridad` AND `_filterCategoria`

### Configuración — Drag-and-drop
- `ConfiguracionProvider.reorderRegla(oldIndex, newIndex)` — intercambia posición + `notifyListeners()`
- Vista **mobile** reemplaza `Column` por `ReorderableListView` con handles de arrastre automáticos
- `_ReglaCard` actualizada con `super.key` para soporte `ValueKey`

---

## Roadmap Próximas Mejoras

### Prioridad Alta

#### 1. Coherencia Mapa ↔ Órdenes
- [x] ~~Al hacer clic en marcador del mapa → panel lateral derecho con imagen + técnico + materiales~~ ✅ v2.4
- [x] ~~Filtrar marcadores por categoría/prioridad desde el mapa~~ ✅ v2.5
- [ ] Mostrar técnicos en campo como marcadores diferenciados (azul oscuro)
- [ ] Panel lateral: lista de incidencias visibles en pantalla (modo exploración)

#### 2. Órdenes — columna Técnico asignado
- [x] ~~Agregar columna "Técnico" en PlutoGrid de órdenes~~ ✅ v2.5 (via `_TecnicoInfoRow` en panel detalle)
- [ ] Si no asignado: badge "Sin asignar" en columna PlutoGrid
- [x] ~~Dialog "Asignar técnico": dropdown con disponibles filtrados por especialidad~~ ✅ v2.5
- [x] ~~Al asignar → cambiar estatus a `asignado` + incrementar `incidenciasActivas` del técnico~~ ✅ v2.5
- [ ] Link "Ver técnico" → navegar a `/tecnicos` con técnico resaltado

#### 3. Bandeja IA — mejoras menores
- [x] ~~Contador de "recomienda aprobar" vs "recomienda rechazar" en header~~ ✅ v2.5
- [x] ~~Acción "Aprobar todos los recomendados" (bulk action)~~ ✅ v2.5
- [ ] Animación de salida cuando se aprueba/rechaza un ítem (AnimatedList)

### Prioridad Media

#### 4. Auditoría — Historial real de acciones
- [x] ~~Registrar en `AuditoriaProvider` cada acción: aprobaciones, rechazos, asignaciones~~ ✅ v2.5
- [x] ~~PlutoGrid con filtro por módulo, fecha, usuario, nivel~~ ✅ v2.5 (ChoiceChips + dropdown)
- [x] ~~Export CSV (dart:html blob)~~ ✅ v2.5
- [ ] Timeline view alternativa (VerticalTimeline)

#### 5. Reportes — Coherencia con datos reales
- [x] ~~Descargar reporte PDF simulado (mostrar dialog de "generando…" → snackbar éxito)~~ ✅ v2.5
- [x] ~~Row KPI responsivo (Wrap en mobile < 700 px)~~ ✅ v2.5
- [ ] Gráfica de tendencia 30 días (simulated time series)
- [ ] Comparativa municipios (BarChart) usando datos de `KpiEstatal`

#### 6. Configuración — Descripción de reglas
- [x] ~~Reordenar reglas por drag-and-drop (ReorderableListView)~~ ✅ v2.5
- [ ] En cada `ReglaPriorizacion`, agregar descripción en lenguaje natural (campo extra)
- [ ] Vista expandida por regla con chips de parámetros visuales

### Prioridad Baja

#### 7. Modo Oscuro
- [ ] Toggle en topbar (switch Claro/Oscuro)
- [ ] `AppTheme` ya tiene constantes `*Dark` — implementar `ThemeMode` en `AppLevelProvider`
- [ ] Verificar contraste en sidebar, PlutoGrid, badges

#### 8. Responsivo Mobile
- [ ] Breakpoint `< 768px`: drawer en lugar de sidebar fijo
- [ ] Cards apiladas en todos los dashboards
- [ ] Topbar colapsable (solo logo + hamburger)

#### 9. Mapa — Enriquecimiento
- [ ] Polígonos de zonas/colonias (GeoJSON hardcodeado)
- [ ] Heatmap de densidad de incidencias (flutter_map plugin)
- [ ] Clustering de marcadores cuando zoom < 12

---

## Convenciones de Desarrollo

### Archivos
- `snake_case.dart` para archivos
- `PascalCase` para clases
- `_` prefijo para widgets privados dentro de la misma página
- Widgets reutilizables → `lib/widgets/shared/`

### PlutoGrid — Reglas de oro
1. **NUNCA** `PlutoLazyPagination` con datos hardcodeados
2. Siempre `setPageSize(N, notify: false)` en `onLoaded`
3. `rowHeight: 60-64` si hay imágenes o badges
4. `autoSizeMode: PlutoAutoSizeMode.scale` para auto-fill del contenedor (✅ preferido) o `PlutoAutoSizeMode.none` con widths fijos para tablas muy anchas
5. ID en celda oculta o usar `row.cells['id']?.value` para lookup

### State Management
- **Nunca mutar listas/objetos directamente** → `copyWith` + nueva lista + `notifyListeners()`
- Un provider por dominio, todos registrados en `main.dart` via `MultiProvider`
- Snackbar para cada acción operativa

### Colores semánticos
```
Crítico:  #B91C1C   (SLA vencido, prioridad crítica)
Alto:     #D97706   (por vencer, prioridad alta)
Medio:    #1D4ED8   (en proceso, prioridad media)
Bajo:     #2D7A4F   (resuelto, cumplido, activo)
Neutral:  #64748B   (inactivo, cancelado)
Primario: #7A1E3A   (vino — identidad, sidebar activo, CTAs)
```

---

## Checklist de Calidad antes de Demo

- [ ] `flutter build web --no-tree-shake-icons` sin errores
- [ ] Todas las rutas navegan sin error
- [ ] Sidebar adaptativo (nacional/estatal/municipal) funciona
- [ ] PlutoGrid paginado en: Órdenes, BandejaIA, Inventario, Usuarios, Técnicos
- [ ] Dialogs: NuevoTécnico, NuevoUsuario, NuevaRegla, Confirmar acción
- [ ] Mapa carga tiles OSM sin API key
- [ ] Botón "Salir de la Demo" → https://cbluna.com/ en misma ventana (`_self`)
- [ ] No hay strings en inglés expuestos al usuario
- [ ] Favicon cargado correctamente