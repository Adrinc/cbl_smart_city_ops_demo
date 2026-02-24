# Plan de Mejoras — Terranex Smart City Operations

**Última actualización:** Febrero 2026 · **Versión actual:** 3.1 · **Plataforma:** Flutter Web

---

## Estado Actual (v3.1 — Febrero 2026)

| Módulo | Estado | Notas |
|--------|--------|-------|
| Dashboard Nacional | ✅ Completo | KPIs, mapa calor, alertas |
| Dashboard Estatal | ✅ Completo | BC Norte, municipios |
| Dashboard Municipal | ✅ Completo | Ensenada, gráficas fl_chart |
| Bandeja IA | ✅ Completo v2 | Modularizada en widgets/, bulk approve, stats |
| Órdenes / Incidencias | ✅ Completo v3 | Íconos por categoría, columna técnico interactiva |
| Mapa Operativo | ✅ Completo | Marcadores ad hoc por categoría, panel lateral, filtro categoría |
| Técnicos | ✅ Completo v3 | PlutoGrid + NuevoTécnico + "Asignar caso" |
| Inventario | ✅ Completo | PlutoGrid + alertas stock |
| Aprobaciones | ✅ Completo | Flujo pendientes |
| SLA Monitor | ✅ Completo | Alertas por vencer |
| Reportes | ✅ Completo | fl_chart analítica + export PDF simulado |
| Configuración | ✅ Completo v3 | Motor priorización + **criterios/bullets por regla** |
| Usuarios | ✅ Completo | PlutoGrid + NuevoUsuario |
| Auditoría | ✅ Completo | Log real via AuditoriaProvider, export CSV |
| Catálogos | ✅ Completo | Categorías, zonas |

---

## Implementado en v3.1 (esta sesión)

### Configuración — Sistema de Criterios por Regla ⭐

**Modelo `ReglaPriorizacion`** actualizado:
- Nuevo campo `criterios: List<String>` (default `[]`)
- `copyWith` incluye criterios; JSON-serializable

**Datos mock** (`lib/data/mock_data.dart`):
- Todas las 12 reglas tienen criterios reales en español (3–5 bullets)
- Ejemplos: "Cable de poste caído accesible al público", "Accidente reportado activo en la zona", "Tambo de basura lleno dentro del predio — no aplica recolección"

**Provider** (`ConfiguracionProvider`):
- `deleteRegla(String id)` — elimina regla de la lista + `notifyListeners()`
- `updateCriterios(String id, List<String> nuevos)` — reemplaza criterios + `notifyListeners()`

**Widgets nuevos** en `lib/pages/configuracion/widgets/`:
- `criterios_editor.dart` — editor con `ReorderableListView` + drag handles + campo "Añadir criterio" inline; `onChanged` notifica cambios al padre
- `ver_criterios_dialog.dart` — dialog con modo lectura (bullets con punto de color semántico) y modo edición (muestra `CriteriosEditor`); botones Editar / Guardar / Cerrar

**PlutoGrid en `configuracion_page.dart`**:
- Nueva columna **Criterios**: badge contador (azul si ≥1, gris si ninguno), clic → abre `VerCriteriosDialog`
- Nueva columna **Acciones**: icono lápiz (editar criterios) + icono basura (eliminar con `AlertDialog` de confirmación)
- Dialog "Nueva Regla": ahora incluye el `CriteriosEditor` para definir criterios al crear

---

### Órdenes — Columna Técnico interactiva ⭐

**Widget `TecnicoChipDetalle`** (`lib/pages/ordenes/widgets/tecnico_chip_detalle.dart`):
- Técnico asignado → avatar circular + nombre tachado/subrayado, clic abre `_TecnicoDetalleDialog`
- Sin técnico + estado operable → chip verde **"+ Asignar"** que abre `AsignarTecnicoDialog`
- `_TecnicoDetalleDialog`: avatar grande, rol, estatus badge, métricas, botón **"Reasignar"**

**Columna Categoría** en PlutoGrid:
- Icono semántico por tipo de incidencia (bombilla, construcción, basura, agua, señal, escudo)
- `_catIcons` mapa estático + `_catIcon()` helper en `ordenes_page.dart`

---

### Técnicos — Acción "Asignar caso" ⭐

**Dialog `AsignarIncidenciaDialog`** (`lib/pages/tecnicos/widgets/asignar_incidencia_dialog.dart`):
- Filtra incidencias disponibles (`estatus ∈ {aprobado, recibido}` AND `tecnicoId == null`)
- Las incidencias de la misma especialidad del técnico aparecen primero con badge **"Recomendado"**
- Filter chips de prioridad (todos / crítico / alto / medio / bajo)
- `AnimatedContainer` cards con radio button de selección
- Al confirmar: `asignarTecnico()` + `incrementarActivas()` + registro en auditoría con módulo 'Técnicos'
- Factory estática `AsignarIncidenciaDialog.show(context, tecnico)`

**Integración en `tecnicos_page.dart`**:
- Método `_asignarIncidencia(BuildContext, Tecnico)` en `_TecnicosPageState`
- `_PlutoTecnicosView`: nuevo parámetro `onAsignarIncidencia`, columna Acciones expandida a `width: 180`, tercer botón etiquetado **"Asignar"** (verde, borde + fondo suave `theme.low`)
- `_TecnicoCard` (mobile): nuevo botón `OutlinedButton.icon` "Asignar caso" en fila propia debajo de Detalle + Estatus

---

## Implementado en versiones anteriores

### v2.5
- `AuditoriaProvider` con `registrar()`, filtros por módulo/nivel/acción, export CSV
- Auditoría: págica real con ChoiceChips + dropdown módulo
- BandejaIA: stats row, bulk approve, registro auditoría
- Órdenes: `AsignarTecnicoDialog` (filter por especialidad), auditoría en asignar/iniciar/resolver
- Mapa: filtro por categoría en controles
- Configuración: drag-and-drop `ReorderableListView` en mobile

### v2.4
- Mapa: panel lateral deslizante con imagen hero, técnico asignado, materiales estimados, SLA
- Topbar: dropdown de administrador con `MenuAnchor`, avatar real `Maria.png`

### v2.3
- BandejaIA: modularizada completa en `widgets/`; PlutoGrid con thumbnail, 4 acciones icono; `VerCriteriosDialog`
- Técnicos: reescritura completa con PlutoGrid, avatar upload, detalle dialog

---

## Roadmap pendiente

### Alta prioridad
- [ ] Mapa: técnicos en campo como marcadores diferenciados (pin azul oscuro con inicial)
- [ ] Mapa: panel lateral → lista de incidencias visibles en pantalla (modo exploración)
- [ ] Órdenes: link "Ver técnico" en TecnicoDetalleDialog → navega a `/tecnicos` con técnico resaltado

### Media prioridad
- [ ] Reportes: gráfica de tendencia 30 días (time-series simulada con fl_chart)
- [ ] Reportes: comparativa municipios (BarChart) con `KpiEstatal`
- [ ] Auditoría: timeline view alternativa (`VerticalTimeline`)
- [ ] Técnicos: modularizar `tecnicos_page.dart` → `widgets/` (pluto_tecnicos_view, tecnico_card, dialogs)

### Baja prioridad
- [ ] Modo oscuro: toggle topbar, `ThemeMode` en `AppLevelProvider`
- [ ] Mobile drawer: reemplazar sidebar fijo en `< 768 px`
- [ ] Mapa: clustering de marcadores en zoom < 12
- [ ] Mapa: polígonos de zonas (GeoJSON hardcodeado)

---

## Convenciones de Desarrollo

### Archivos
- `snake_case.dart` para archivos · `PascalCase` para clases · `_` prefijo para widgets privados

### PlutoGrid — Reglas de oro
1. **NUNCA** `PlutoLazyPagination` con datos hardcodeados
2. `setPageSize(N, notify: false)` en `onLoaded`
3. `autoSizeMode: PlutoAutoSizeMode.scale` para auto-fill (preferido)
4. Objeto oculto en celda `_objeto` para lookup rápido sin ID join

### Estado
- `copyWith` + nueva lista + `notifyListeners()`. Nunca mutar directamente.
- Snackbar para toda acción operativa visible al usuario.

### Colores semánticos
```
Crítico:  #B91C1C   high:  #D97706   medio: #1D4ED8   bajo: #2D7A4F
Neutral:  #64748B   Primario (vino): #7A1E3A
```

---

## Checklist de Quality Gate (demo)

- [ ] `flutter build web --no-tree-shake-icons` sin errores ni warnings relevantes
- [ ] Todas las rutas navegan sin `null` errors
- [ ] Sidebar adaptativo funciona en los 3 niveles (nacional/estatal/municipal)
- [ ] PlutoGrid paginado en: Órdenes, BandejaIA, Inventario, Usuarios, Técnicos, Config
- [ ] Columna Criterios en Configuración muestra badge y abre dialog correctamente
- [ ] Columna Técnico en Órdenes muestra chip interactivo o "Asignar" según estado
- [ ] Botón "Asignar caso" en Técnicos abre dialog con incidencias disponibles
- [ ] Mapa carga tiles OSM sin API key
- [ ] Botón "Salir de la Demo" → https://cbluna.com/ en misma ventana (`_self`)
- [ ] Favicon cargado
- [ ] Sin strings en inglés expuestos al usuario final

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