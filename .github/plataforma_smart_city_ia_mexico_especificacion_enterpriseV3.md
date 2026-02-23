# Plataforma SmartCity IA (México) — Especificación Enterprise

## 0) Objetivo
Construir una **plataforma enterprise** para gestión de incidencias urbanas (tipo “Ojo Ciudadano / Control Operativo”), donde la información llega desde una **App móvil ciudadana**, se procesa por un **pipeline automatizado (n8n + IA)** para validación/clasificación, y se opera desde un **CRM web** (con participación humana). Opcionalmente, existe una **App de Técnico** para ejecución en campo.

> Enfoque elegido: **la opción más profesional y completa** (multi-región escalable; México como ejemplo), con **IA asistiva + humano en el loop** como modo base; y una ruta clara para automatización avanzada.

---

## 1) Plataformas (3 frentes)
1) **App Ciudadana (móvil):** captura de incidencia (categoría + evidencia + texto + ubicación) y seguimiento.
2) **CRM Web (operación y administración):** revisión, priorización, asignación, materiales, ejecución, analítica, auditoría.
3) **App Técnico (móvil):** recepción de órdenes, navegación, checklist, evidencia de atención, consumo de materiales, cierre.

---

## 2) Flujo End-to-End (modelo base recomendado)
### 2.1 Captura (App Ciudadana)
1. Usuario abre app → **elige categoría** (ej. Alumbrado / Bacheo / Basura / etc.).
2. Captura o sube **foto/video** + añade **descripción**.
3. App adjunta **ubicación actual** (GPS) y metadatos (fecha, dispositivo, optional: dirección aproximada).
4. Envía → queda en estado **“Recibido”**.

### 2.2 Pipeline IA (n8n)$1

**Motor de priorización (reglas configurables):**
- La priorización no depende solo del modelo IA; se apoya en una **matriz de severidad/ponderación** editable por un administrador.
- Reglas por **categoría** y por **contexto** (p.ej. zona residencial vs industrial, cercanía a escuela/hospital, vialidad principal, reincidencia).
- Permite definir niveles: **No accionable / Muy baja / Baja / Media / Alta / Crítica** y acciones automáticas (depriorizar, mandar a revisión, rechazar con motivo).

### 2.3 Revisión humana (CRM Web)
1. Operador abre la bandeja **“Pre-aprobados”**.
2. Revisa evidencia + sugerencias IA (categoría, prioridad, SLA).
3. Decide:
   - **Aprobar** → se convierte en **Incidencia / Orden**.
   - **Rechazar** → motivo + notificación al ciudadano.
   - **Reclasificar** → ajusta categoría/prioridad.

### 2.4 Ejecución (Técnico)
1. Al aprobar, el sistema crea una **Orden de Trabajo**.
2. Se **asigna** a técnico/cuadrilla (manual por defecto).
3. Técnico recibe en su app: detalle, ubicación, checklist, materiales sugeridos.
4. Técnico atiende, sube evidencia de antes/después, registra consumo.
5. Supervisor valida cierre (opcional) → estado final **Resuelto/Cerrado**.

---

## 3) Automatización avanzada (opcional / roadmap)
> Modo “enterprise full automation” (si se decide):
- **Auto-aprobación** cuando el score de coherencia y confianza sea alto.
- **Auto-asignación** por reglas (zona + especialidad + disponibilidad + carga + distancia).
- **Auto-sugerencia de materiales** (por categoría + severidad + histórico).
- **Auto-programación/rutas** (optimización simple).

Recomendación profesional: iniciar con **IA asistiva + humano** y habilitar automatización por **umbrales** (p.ej. >0.92 auto-aprueba, 0.75–0.92 requiere humano).

---

## 4) Estados y Workflow (estándar enterprise)$1

### 4.4 Motor de Prioridad (Policy Engine)
- Cada categoría tiene una **rúbrica** (ej. Basura/Escombros) que define qué evidencia se considera **no accionable** y cómo escala la prioridad por volumen/severidad.
- Soporta **ponderación por contexto**:
  - Tipo de zona (residencial/comercial/industrial), vialidad (principal/secundaria), sensibilidad (escuelas/hospitales), y **reincidencia**.
- Mantiene **humano en el loop** por defecto; la auto-acción se habilita por umbrales de confianza.
- Versionado + auditoría de reglas (quién cambió qué y cuándo).

## 5) Roles (mínimo enterprise)
- **Admin:** configuración global, catálogos, integraciones, usuarios.
- **Supervisor:** aprueba/rechaza, reasigna, valida cierres.
- **Operador:** revisa y gestiona flujo diario.
- **Técnico:** ejecuta órdenes.
- **Auditor:** lectura + exportaciones.

Permisos por: **módulo**, **zona**, **categoría**, **acciones**.

---

## 6) Arquitectura Jerárquica Territorial (Modelo Enterprise)

La plataforma opera bajo un modelo escalable de **3 niveles territoriales**, evitando la sobrecarga operativa y permitiendo control estratégico + ejecución local.

### Nivel 1 — Visión Nacional (Estratégico)
Enfoque: supervisión y dirección.
- KPIs agregados país (backlog total, críticas, SLA global, tendencia 7/30 días).
- Heatmap por estado.
- Ranking de estados por riesgo / vencimientos.
- Alertas críticas consolidadas.
- Acceso a "Ir a Estado".

Este nivel NO muestra tablas masivas operativas; se centra en métricas y riesgo.

---

### Nivel 2 — Centro Operativo Estatal (Regional)
Enfoque: coordinación regional.
- KPIs del estado.
- Mapa por municipio con clusters.
- Tabla filtrada por estado (PlutoGrid resumido).
- Alertas estatales.
- Acceso a "Entrar a Municipio".

Permite análisis por dependencia y comparativas municipales.

---

### Nivel 3 — Centro Operativo Municipal (Operativo)
Enfoque: ejecución diaria.
- KPIs municipales.
- Mapa urbano detallado.
- Tabla principal de Órdenes/Incidencias (PlutoGrid completo).
- Técnicos activos y carga.
- SLA local y alertas.
- Gestión de materiales vinculados.

Aquí ocurre la operación real.

---

### Permisos por Nivel
- Nacional: Admin Nacional / Auditor Nacional.
- Estatal: Supervisor Estatal / Operador Estatal.
- Municipal: Supervisor Municipal / Operador Municipal / Técnico.

Las reglas IA y políticas pueden heredarse por nivel con posibilidad de override controlado.

---

## 6) CRM Web — SideMenu (versión Enterprise Pro)
> Estructura por capas: Inicio / Operación / Territorio / Recursos / Inventario / Inteligencia / Administración.

### 6.1 Inicio
**Dashboard Ejecutivo**
- KPIs: backlog, críticos, SLA compliance, tendencia, top zonas, top categorías.
- Acciones rápidas: “Aprobar pendientes”, “Asignar técnicos”, “Ver SLA por vencer”.

### 6.2 Operación (Core)
**Bandeja IA (Pre-aprobados)**
- Lista de reportes validados por IA esperando revisión humana.
- Vista rápida de evidencia + score coherencia + sugerencias IA.

**Órdenes / Incidencias (Core)**
- Tabla principal (PlutoGrid): filtros avanzados, vistas guardadas, acciones masivas.
- Columnas recomendadas: ID, categoría, prioridad, estado, SLA, zona, asignado, creado, última actualización.

**Detalle de Incidencia / Orden**
- Evidencia (foto/video), mapa, datos del solicitante, timeline de cambios.
- Panel de acciones: asignar, solicitar materiales, reprogramar, escalar, cerrar, reabrir.

**Aprobaciones**
- Solicitudes que requieren “OK”: materiales, cierre con costo, reasignaciones, gastos.

**Agenda / Programación**
- Calendario de trabajos por técnico/cuadrilla y por zona.

### 6.3 Territorio
**Mapa Operativo**
- Pins + clusters + heatmap + panel lateral de incidencias.
- Filtros por categoría, prioridad, SLA, estado, fechas.

**Zonas / Cuadrantes**
- Catálogo de zonas, reglas de cobertura, horarios, responsables.

### 6.4 Recursos de Campo
**Técnicos y Cuadrillas**
- Vista operativa: disponibilidad, carga, órdenes activas, especialidad, zona.
- Detalle del técnico: historial, rating (si aplica), desempeño, tiempo promedio.

**Vehículos / Equipamiento** (opcional pero enterprise)
- Unidades, herramientas, asignación, mantenimiento.

### 6.5 Inventario y Materiales
**Inventario**
- Tabla pro: stock, mínimos, almacén, lead time, proveedor, alertas.

**Solicitudes de Materiales**
- Flujo: Borrador → Enviado → Aprobado → Entregado → Consumido/Devuelto.
- Siempre vinculado a una Orden.

**Movimientos**
- Entradas/salidas/ajustes con trazabilidad.

### 6.6 Inteligencia y Reportes
**Analítica**
- KPIs por dependencia, zona, técnico, categoría; comparativas temporales.

**SLA y Desempeño**
- Vencidos, por vencer, causas, ranking, reincidencia.

**Exportaciones**
- PDF/Excel/actas/evidencias (plantillas oficiales).

### 6.7 Administración$1

**Políticas IA y Priorización (Triage Rules)**
- Editor de reglas tipo tabla/árbol: condiciones (categoría, objetos detectados, volumen estimado, contexto de zona) → prioridad/SLA/acción.
- Plantillas por municipio/estado + overrides por zona.

---

## 7) App Ciudadana — Pantallas (mínimo pro)
- **Inicio/Categorías** (grid de categorías)
- **Crear reporte** (evidencia + descripción + confirmación ubicación)
- **Confirmación** (folio, estado “Recibido”)
- **Mis reportes** (estado, historial, comentarios)
- **Detalle de reporte** (motivo rechazo si aplica, o avances)
- **Perfil/Ajustes** (notificaciones, privacidad)

Notas pro:
- Mensajes claros de rechazo (por IA): “La evidencia no coincide con la categoría: …”
- Tips para capturar evidencia útil.

---

## 8) App Técnico — Pantallas (mínimo pro)
- **Bandeja de órdenes** (Asignadas / Hoy / Vencidas)
- **Detalle de orden** (mapa, evidencia, checklist, SLA)
- **Iniciar trabajo / En ruta** (cambia estado)
- **Materiales** (solicitar/confirmar consumo)
- **Evidencia** (antes/después, notas)
- **Cerrar orden** (firma opcional, comentarios)
- **Perfil** (disponibilidad, horario)

---

## 9) UI/UX — Reglas profesionales (Flutter + PlutoGrid)
- Listados enterprise: **PlutoGrid** con filtros, orden, export, acciones masivas.
- Responsive: en móvil/tablet usar **cards** equivalentes a filas.
- Detalle rápido: panel lateral (drawer derecho) para ver/editar sin salir del listado.
- Estados siempre con chips semánticos (no solo color decorativo).

---

## 10) Colores — Propuesta profesional (jerarquía semántica)
### Principio
Mantener identidad institucional (vino) **como acento**, pero no como “tinta” en todo. La UI principal debe vivir en **neutros**, y los estados deben usar **colores semánticos**.

### Tokens sugeridos (conceptual)
- **Brand/Primary (acento institucional):** vino/borgoña (solo CTA primario, sidebar/topbar)
- **Surface/Background:** neutros claros (Light) o gris/azul muy oscuro (Dark)
- **Info:** azul
- **Success:** verde
- **Warning:** ámbar
- **Error:** rojo (exclusivo para fallas/rechazos)

Regla clave: **rojo ≠ brand**. Rojo es error. El vino es “brand accent”.

---

## 10.0 Entornos Operativos (Perfiles de Contexto)

El sistema contempla **Perfiles de Entorno** configurables por superusuario. Estos determinan ponderaciones de prioridad, SLA y acciones automáticas.

### Entornos estándar recomendados (Demo)
- **Residencial**: Zonas habitacionales.
- **Comercial**: Zonas de comercio y alto tránsito.
- **Industrial**: Parques industriales y zonas privadas de producción.
- **Institucional**: Escuelas, hospitales, edificios públicos y zonas sensibles.

Cada entorno puede definir:
- Ponderador de prioridad (+1, 0, -1, etc.)
- SLA base por categoría
- Reglas de escalamiento automático
- Excepciones (ej. cerca de hospital = forzar nivel mínimo Alta)

Estos entornos se muestran como columna "Entorno" en las tablas de Incidencias/Órdenes y se heredan automáticamente según la zona geográfica del reporte.

---

## 10.1 Plantillas de Priorización (Demo Ready)

Para efectos de demo (sin ejecución real), se incluyen **plantillas editables por categoría**, visibles en el módulo "Políticas IA y Priorización".

### Ejemplo: Plantilla "Basura y Escombros"

**Nivel 0 – No accionable**
- Objetos detectados: papel, envolturas pequeñas, chicle
- Área estimada < 0.2 m²
- Acción: Rechazar automático con mensaje educativo

**Nivel 1 – Muy baja**
- 1 contenedor aislado sin desborde
- Área < 1 m²
- SLA sugerido: 72h

**Nivel 2 – Baja**
- Contenedor desbordado visible
- Área 1–3 m²
- SLA sugerido: 48h

**Nivel 3 – Media**
- Acumulación extendida 3–6 m²
- Evidencia de obstrucción parcial
- SLA sugerido: 24h

**Nivel 4 – Alta/Crítica**
- Obstrucción de vialidad
- Cercanía a escuela/hospital
- Reincidencia en 30 días
- SLA sugerido: 4–12h

---

### Ponderadores de Contexto (editables)
- Zona residencial: +1 nivel
- Zona industrial privada: -1 nivel
- Cercanía a escuela/hospital: +1 nivel
- Reincidencia: +1 nivel

Estas plantillas son completamente editables en la demo para mostrar el potencial del sistema, aunque no ejecuten lógica real.

---

## 11) Alcance Demo vs Producto
**Demo (rápido y convincente):**
- Flujo ciudadano → IA (n8n) → pre-aprobado → revisión humana → orden → técnico.
- Mapa operativo + tabla de órdenes + detalle + solicitud materiales.

**Producto (roadmap):**
- Auto-aprobación por umbral
- Auto-asignación y rutas
- Costos/presupuesto
- Reincidencia y predicción

---

## 12) Resultado esperado
Una plataforma que se percibe como **Smart City Operations SaaS**, escalable a más estados/municipios, con una experiencia enterprise coherente y profesional (UI, módulos, roles, auditoría, SLA, analítica) y con IA integrada como motor de eficiencia.

