"""
Refactor completo:
- Modulariza BandejaIA en widgets/
- Mejora Técnicos (PlutoGrid + Nuevo Técnico dialog con image upload)
- Actualiza TecnicoProvider + Tecnico model
"""
import pathlib, textwrap

ROOT = pathlib.Path(r"g:\TRABAJO\FLUTTER\cbl_portal_demos\sistema_smart_sistem_demo")
LIB  = ROOT / "lib"
BI   = LIB / "pages" / "bandeja_ia" / "widgets"
BI.mkdir(parents=True, exist_ok=True)

# ═══════════════════════════════════════════════════════════════════════════════
# 1. helpers_bandeja.dart  — constantes y helpers compartidos
# ═══════════════════════════════════════════════════════════════════════════════
(BI / "helpers_bandeja.dart").write_text(r"""
import 'package:flutter/material.dart';
import 'package:nethive_neo/models/models.dart';

// ── Veredicto IA ─────────────────────────────────────────────────────────────
bool esRechazoIA(Incidencia inc) {
  final p = inc.imagenPath ?? '';
  return p.contains('rechazar') || p.contains('happyface') || p.contains('papelito');
}

// ── Dirección aproximada (Ensenada) ──────────────────────────────────────────
String approxDireccion(double lat, double lon) {
  if (lat > 31.876) return 'Col. Reforma Norte';
  if (lat > 31.872) return 'Col. El Sauzal';
  if (lat > 31.868) return 'Zona Centro Norte';
  if (lat > 31.864) return 'Centro Histórico';
  if (lat > 31.858) return 'Col. Miramar';
  if (lat > 31.854) return 'Col. Los Viñedos';
  return 'Col. Chapultepec';
}

// ── Iconos por categoría (usados en toda la app) ──────────────────────────────
const Map<String, IconData> kCatIcons = {
  'alumbrado':    Icons.lightbulb_outline,
  'bacheo':       Icons.construction,
  'basura':       Icons.delete_outline,
  'agua_drenaje': Icons.water_drop_outlined,
  'señalizacion': Icons.traffic,
  'senalizacion': Icons.traffic,
  'seguridad':    Icons.shield_outlined,
};

IconData catIcon(String categoria) =>
    kCatIcons[categoria] ?? Icons.help_outline;

// ── Color por prioridad ───────────────────────────────────────────────────────
Color prioColor(String prioridad) {
  switch (prioridad) {
    case 'critico': return const Color(0xFFB91C1C);
    case 'alto':    return const Color(0xFFD97706);
    case 'medio':   return const Color(0xFF1D4ED8);
    default:        return const Color(0xFF2D7A4F);
  }
}
""".strip(), encoding='utf-8')
print("✅ helpers_bandeja.dart")

# ═══════════════════════════════════════════════════════════════════════════════
# 2. filter_bar_bandeja.dart
# ═══════════════════════════════════════════════════════════════════════════════
(BI / "filter_bar_bandeja.dart").write_text(r"""
import 'package:flutter/material.dart';
import 'package:nethive_neo/helpers/formatters.dart';
import 'package:nethive_neo/theme/theme.dart';

class FilterBarBandeja extends StatelessWidget {
  const FilterBarBandeja({
    super.key,
    required this.search,
    required this.filterCategoria,
    required this.filterVeredicto,
    required this.cats,
    required this.theme,
    required this.onSearch,
    required this.onCategoria,
    required this.onVeredicto,
  });
  final String search, filterVeredicto;
  final String? filterCategoria;
  final List<String> cats;
  final AppTheme theme;
  final ValueChanged<String> onSearch;
  final ValueChanged<String?> onCategoria, onVeredicto;

  @override
  Widget build(BuildContext context) {
    return Wrap(spacing: 10, runSpacing: 8, crossAxisAlignment: WrapCrossAlignment.center, children: [
      SizedBox(width: 200, child: TextField(
        onChanged: onSearch,
        decoration: InputDecoration(
          hintText: 'Buscar ID o descripción…',
          hintStyle: TextStyle(fontSize: 12, color: theme.textSecondary),
          prefixIcon: Icon(Icons.search, size: 16, color: theme.textSecondary),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: theme.border)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: theme.border)),
          filled: true, fillColor: theme.surface,
        ),
      )),
      DropdownButtonHideUnderline(child: DropdownButton<String>(
        value: filterVeredicto,
        items: const [
          DropdownMenuItem(value: 'todos',               child: Text('Todos los veredictos')),
          DropdownMenuItem(value: 'recomienda_aprobar',  child: Text('IA: Recomienda Aprobar')),
          DropdownMenuItem(value: 'recomienda_rechazar', child: Text('IA: Recomienda Rechazar')),
        ],
        onChanged: onVeredicto, borderRadius: BorderRadius.circular(8),
      )),
      DropdownButtonHideUnderline(child: DropdownButton<String?>(
        value: filterCategoria,
        hint: Text('Todas las categorías', style: TextStyle(fontSize: 12, color: theme.textSecondary)),
        items: [
          const DropdownMenuItem<String?>(value: null, child: Text('Todas las categorías')),
          ...cats.map((c) => DropdownMenuItem<String?>(value: c, child: Text(labelCategoria(c)))),
        ],
        onChanged: onCategoria, borderRadius: BorderRadius.circular(8),
      )),
    ]);
  }
}
""".strip(), encoding='utf-8')
print("✅ filter_bar_bandeja.dart")

# ═══════════════════════════════════════════════════════════════════════════════
# 3. imagen_viewer_dialog.dart
# ═══════════════════════════════════════════════════════════════════════════════
(BI / "imagen_viewer_dialog.dart").write_text(r"""
import 'package:flutter/material.dart';
import 'package:nethive_neo/theme/theme.dart';

class ImagenViewerDialog extends StatelessWidget {
  const ImagenViewerDialog({super.key, required this.imagenPath, required this.theme});
  final String imagenPath;
  final AppTheme theme;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: size.width * 0.92, maxHeight: size.height * 0.88),
        child: Stack(children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.asset(imagenPath,
              fit: BoxFit.contain, width: double.infinity, height: double.infinity,
              errorBuilder: (_, __, ___) => Container(
                color: theme.surface, padding: const EdgeInsets.all(40),
                child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(Icons.broken_image_outlined, size: 64, color: theme.textDisabled),
                  const SizedBox(height: 8),
                  Text('Imagen no disponible', style: TextStyle(color: theme.textDisabled)),
                ])))),
          ),
          Positioned(top: 10, right: 10, child: Material(
            color: Colors.black.withOpacity(0.55),
            shape: const CircleBorder(),
            child: InkWell(
              onTap: () => Navigator.pop(context),
              customBorder: const CircleBorder(),
              child: const Padding(padding: EdgeInsets.all(8),
                child: Icon(Icons.close, color: Colors.white, size: 22))),
          )),
        ]),
      ),
    );
  }
}
""".strip(), encoding='utf-8')
print("✅ imagen_viewer_dialog.dart")

# ═══════════════════════════════════════════════════════════════════════════════
# 4. mapa_ubicacion_dialog.dart  — marker con ícono de categoría
# ═══════════════════════════════════════════════════════════════════════════════
(BI / "mapa_ubicacion_dialog.dart").write_text(r"""
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:nethive_neo/helpers/formatters.dart';
import 'package:nethive_neo/models/models.dart';
import 'package:nethive_neo/theme/theme.dart';
import 'helpers_bandeja.dart';

class MapaUbicacionDialog extends StatelessWidget {
  const MapaUbicacionDialog({super.key, required this.inc, required this.theme});
  final Incidencia inc;
  final AppTheme theme;

  @override
  Widget build(BuildContext context) {
    final latLng = LatLng(inc.latitud, inc.longitud);
    final color  = prioColor(inc.prioridad);
    final dir    = approxDireccion(inc.latitud, inc.longitud);
    final icon   = catIcon(inc.categoria);
    final total  = MediaQuery.of(context).size;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.all(20),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 560, maxHeight: total.height * 0.82),
        child: Column(children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 12, 14),
            child: Row(children: [
              Icon(Icons.location_on, color: theme.primaryColor, size: 20),
              const SizedBox(width: 10),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Ubicación del reporte',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: theme.textPrimary)),
                Text('${formatIdIncidencia(inc.id)} · $dir',
                  style: TextStyle(fontSize: 12, color: theme.textSecondary),
                  overflow: TextOverflow.ellipsis),
              ])),
              IconButton(icon: Icon(Icons.close, color: theme.textSecondary, size: 20),
                onPressed: () => Navigator.pop(context)),
            ]),
          ),
          Divider(height: 1, color: theme.border),

          // Mapa
          Expanded(child: Stack(children: [
            FlutterMap(
              options: MapOptions(initialCenter: latLng, initialZoom: 15),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.cbluna.terranex'),
                MarkerLayer(markers: [
                  Marker(
                    point: latLng, width: 48, height: 48,
                    child: Container(
                      decoration: BoxDecoration(
                        color: color, shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2.5),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.35),
                          blurRadius: 8, offset: const Offset(0, 3))]),
                      child: Icon(icon, color: Colors.white, size: 22))),
                ]),
              ],
            ),
            Positioned(top: 10, left: 10, child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.92),
                borderRadius: BorderRadius.circular(8),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 6)]),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(icon, size: 14, color: color),
                const SizedBox(width: 5),
                Text('${labelCategoria(inc.categoria)} · ${inc.entorno}',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: theme.textPrimary)),
              ]))),
          ])),

          // Footer coords
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            decoration: BoxDecoration(
              color: theme.background,
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16))),
            child: Row(children: [
              Icon(Icons.gps_fixed, size: 13, color: theme.textSecondary),
              const SizedBox(width: 6),
              Expanded(child: Text(
                '${inc.latitud.toStringAsFixed(5)}, ${inc.longitud.toStringAsFixed(5)}',
                style: TextStyle(fontSize: 12, color: theme.textSecondary),
                overflow: TextOverflow.ellipsis)),
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cerrar')),
            ]),
          ),
        ]),
      ),
    );
  }
}
""".strip(), encoding='utf-8')
print("✅ mapa_ubicacion_dialog.dart")

# ═══════════════════════════════════════════════════════════════════════════════
# 5. confirmar_accion_dialog.dart
# ═══════════════════════════════════════════════════════════════════════════════
(BI / "confirmar_accion_dialog.dart").write_text(r"""
import 'package:flutter/material.dart';
import 'package:nethive_neo/helpers/formatters.dart';
import 'package:nethive_neo/models/models.dart';
import 'package:nethive_neo/theme/theme.dart';

class ConfirmarAccionDialog extends StatefulWidget {
  const ConfirmarAccionDialog({
    super.key,
    required this.tipo,
    required this.inc,
    required this.iaRechaza,
    required this.onConfirm,
  });
  final String tipo;       // 'aprobar' | 'rechazar'
  final Incidencia inc;
  final bool iaRechaza;
  final void Function(String motivo) onConfirm;
  @override
  State<ConfirmarAccionDialog> createState() => _ConfirmarAccionDialogState();
}

class _ConfirmarAccionDialogState extends State<ConfirmarAccionDialog> {
  final _motivoCtrl = TextEditingController();
  final _formKey    = GlobalKey<FormState>();

  bool get _motivoObligatorio => widget.tipo == 'rechazar' && !widget.iaRechaza;

  @override
  void dispose() { _motivoCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final theme     = AppTheme.of(context);
    final esAprobar = widget.tipo == 'aprobar';
    final acColor   = esAprobar ? theme.low : theme.critical;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Padding(
          padding: const EdgeInsets.all(26),
          child: Form(
            key: _formKey,
            child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(color: acColor.withOpacity(0.12), shape: BoxShape.circle),
                  child: Icon(esAprobar ? Icons.check_circle_outline : Icons.cancel_outlined,
                    color: acColor, size: 22)),
                const SizedBox(width: 14),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(esAprobar ? 'Confirmar aprobación' : 'Confirmar rechazo',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: theme.textPrimary)),
                  Text(formatIdIncidencia(widget.inc.id),
                    style: TextStyle(fontSize: 13, color: theme.textSecondary)),
                ])),
                IconButton(icon: Icon(Icons.close, size: 18, color: theme.textSecondary),
                  onPressed: () => Navigator.pop(context)),
              ]),
              const SizedBox(height: 16),
              Container(
                width: double.infinity, padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: theme.background, borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: theme.border)),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(labelCategoria(widget.inc.categoria),
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: theme.textSecondary)),
                  const SizedBox(height: 4),
                  Text(widget.inc.descripcion,
                    style: TextStyle(fontSize: 13, color: theme.textPrimary),
                    maxLines: 3, overflow: TextOverflow.ellipsis),
                ])),
              const SizedBox(height: 14),
              if (_motivoObligatorio)
                Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: theme.high.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: theme.high.withOpacity(0.3))),
                  child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Padding(padding: const EdgeInsets.only(top: 1),
                      child: Icon(Icons.warning_amber_outlined, size: 16, color: theme.high)),
                    const SizedBox(width: 8),
                    Expanded(child: Text(
                      'La IA recomendó APROBAR este reporte. Si lo rechazas, indica el motivo.',
                      style: TextStyle(fontSize: 12, color: theme.high, fontWeight: FontWeight.w500))),
                  ])),
              if (widget.tipo == 'rechazar') ...[
                Text(_motivoObligatorio ? 'Motivo de rechazo *' : 'Motivo (opcional)',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: theme.textSecondary)),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _motivoCtrl, maxLines: 3,
                  decoration: InputDecoration(
                    hintText: _motivoObligatorio
                      ? 'Explica por qué rechazas a pesar de la recomendación de la IA…'
                      : 'Ej. Imagen borrosa, fuera de jurisdicción, descripción insuficiente…',
                    hintStyle: TextStyle(fontSize: 12, color: theme.textDisabled),
                    contentPadding: const EdgeInsets.all(12),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: theme.border)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: theme.border)),
                    filled: true, fillColor: theme.background),
                  validator: _motivoObligatorio
                    ? (v) => (v == null || v.trim().isEmpty) ? 'El motivo es obligatorio' : null
                    : null,
                ),
                const SizedBox(height: 16),
              ] else
                const SizedBox(height: 4),
              Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(foregroundColor: theme.textSecondary,
                    side: BorderSide(color: theme.border)),
                  child: const Text('Cancelar')),
                const SizedBox(width: 10),
                FilledButton.icon(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      Navigator.pop(context);
                      widget.onConfirm(_motivoCtrl.text.trim());
                    }
                  },
                  icon: Icon(esAprobar ? Icons.check : Icons.close, size: 16),
                  label: Text(esAprobar ? 'Sí, aprobar' : 'Sí, rechazar'),
                  style: FilledButton.styleFrom(backgroundColor: acColor)),
              ]),
            ]),
          ),
        ),
      ),
    );
  }
}
""".strip(), encoding='utf-8')
print("✅ confirmar_accion_dialog.dart")

# ═══════════════════════════════════════════════════════════════════════════════
# 6. detalle_caso_dialog.dart — ver detalles completos del caso
# ═══════════════════════════════════════════════════════════════════════════════
(BI / "detalle_caso_dialog.dart").write_text(r"""
import 'package:flutter/material.dart';
import 'package:nethive_neo/helpers/formatters.dart';
import 'package:nethive_neo/models/models.dart';
import 'package:nethive_neo/theme/theme.dart';
import 'package:nethive_neo/widgets/shared/priority_badge.dart';
import 'helpers_bandeja.dart';
import 'imagen_viewer_dialog.dart';

class DetalleCasoDialog extends StatelessWidget {
  const DetalleCasoDialog({
    super.key,
    required this.inc,
    required this.theme,
    required this.onAprobar,
    required this.onRechazar,
    required this.onVerMapa,
  });
  final Incidencia inc;
  final AppTheme theme;
  final VoidCallback onAprobar;
  final VoidCallback onRechazar;
  final VoidCallback onVerMapa;

  @override
  Widget build(BuildContext context) {
    final igRechaza = esRechazoIA(inc);
    final conf      = inc.iaConfianza ?? 0.0;
    final confColor = conf >= 0.90 ? theme.low : conf >= 0.70 ? theme.high : theme.critical;
    final icon      = catIcon(inc.categoria);
    final dir       = approxDireccion(inc.latitud, inc.longitud);
    final total     = MediaQuery.of(context).size;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      insetPadding: const EdgeInsets.all(20),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 680, maxHeight: total.height * 0.88),
        child: Column(children: [
          // ── Header ────────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 20, 14, 14),
            child: Row(children: [
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                  color: (igRechaza ? theme.neutral : theme.primaryColor).withOpacity(0.1),
                  shape: BoxShape.circle),
                child: Icon(icon,
                  color: igRechaza ? theme.neutral : theme.primaryColor, size: 22)),
              const SizedBox(width: 14),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Text(formatIdIncidencia(inc.id),
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800,
                      color: igRechaza ? theme.textSecondary : theme.primaryColor)),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(color: theme.border.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(6)),
                    child: Text(labelCategoria(inc.categoria),
                      style: TextStyle(fontSize: 11, color: theme.textSecondary))),
                  const Spacer(),
                  PriorityBadge(prioridad: inc.prioridad),
                ]),
                const SizedBox(height: 3),
                Text(inc.descripcion,
                  style: TextStyle(fontSize: 13, color: theme.textPrimary),
                  maxLines: 2, overflow: TextOverflow.ellipsis),
              ])),
              const SizedBox(width: 6),
              IconButton(icon: Icon(Icons.close, color: theme.textSecondary, size: 20),
                onPressed: () => Navigator.pop(context)),
            ]),
          ),
          Divider(height: 1, color: theme.border),

          // ── Cuerpo scrollable ─────────────────────────────────────────────
          Expanded(child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              // Fila imagen + datos
              LayoutBuilder(builder: (_, box) {
                final wide = box.maxWidth > 500;
                final imageWidget = _ImageSection(inc: inc, theme: theme);
                final infoWidget  = _InfoSection(inc: inc, theme: theme, dir: dir,
                  conf: conf, confColor: confColor, igRechaza: igRechaza);
                if (wide) return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Expanded(flex: 2, child: imageWidget),
                  const SizedBox(width: 16),
                  Expanded(flex: 3, child: infoWidget),
                ]);
                return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [imageWidget, const SizedBox(height: 16), infoWidget]);
              }),

              const SizedBox(height: 16),

              // Veredicto IA
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: (igRechaza ? theme.neutral : theme.low).withOpacity(0.07),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: (igRechaza ? theme.neutral : theme.low).withOpacity(0.3))),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Icon(Icons.psychology_outlined, size: 14, color: theme.medium),
                    const SizedBox(width: 5),
                    Text('ANÁLISIS IA', style: TextStyle(
                      fontSize: 10, fontWeight: FontWeight.w700, color: theme.medium, letterSpacing: 0.8)),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(color: confColor.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                      child: Text('${(conf * 100).toStringAsFixed(1)}% confianza',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: confColor))),
                  ]),
                  const SizedBox(height: 10),
                  Row(children: [
                    Expanded(child: _InfoRow(label: 'Categoría sugerida', value: labelCategoria(inc.iaCategoriaSugerida ?? inc.categoria), theme: theme)),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('Prioridad sugerida', style: TextStyle(fontSize: 10, color: theme.textSecondary, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 2),
                      PriorityBadge(prioridad: inc.iaPrioridadSugerida ?? inc.prioridad),
                    ])),
                  ]),
                  if (inc.iaCoherenciaNota != null) ...[
                    const SizedBox(height: 8),
                    Text(inc.iaCoherenciaNota!,
                      style: TextStyle(fontSize: 11, color: theme.textSecondary, fontStyle: FontStyle.italic)),
                  ],
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: (igRechaza ? theme.neutral : theme.low).withOpacity(0.08),
                      borderRadius: BorderRadius.circular(7),
                      border: Border.all(color: (igRechaza ? theme.neutral : theme.low).withOpacity(0.25))),
                    child: Row(children: [
                      Icon(igRechaza ? Icons.report_off : Icons.check_circle_outline, size: 14,
                        color: igRechaza ? theme.neutral : theme.low),
                      const SizedBox(width: 7),
                      Expanded(child: Text(
                        igRechaza
                          ? 'IA recomienda RECHAZAR — imagen no relevante para infraestructura pública.'
                          : 'IA recomienda APROBAR — descripción e imagen son coherentes con la categoría.',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
                          color: igRechaza ? theme.neutral : theme.low))),
                    ]),
                  ),
                ]),
              ),
            ]),
          )),

          // ── Footer actions ────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 18),
            child: Row(children: [
              OutlinedButton.icon(
                onPressed: onVerMapa,
                icon: Icon(Icons.map_outlined, size: 14, color: theme.medium),
                label: Text('Ver en mapa', style: TextStyle(color: theme.medium)),
                style: OutlinedButton.styleFrom(side: BorderSide(color: theme.medium.withOpacity(0.4)))),
              const Spacer(),
              OutlinedButton.icon(
                onPressed: () { Navigator.pop(context); onRechazar(); },
                icon: const Icon(Icons.close, size: 14),
                label: const Text('Rechazar'),
                style: OutlinedButton.styleFrom(foregroundColor: theme.critical,
                  side: BorderSide(color: theme.critical.withOpacity(0.4)))),
              const SizedBox(width: 10),
              ElevatedButton.icon(
                onPressed: igRechaza ? null : () { Navigator.pop(context); onAprobar(); },
                icon: const Icon(Icons.check, size: 14),
                label: const Text('Aprobar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: igRechaza ? theme.neutral : theme.low,
                  foregroundColor: Colors.white)),
            ]),
          ),
        ]),
      ),
    );
  }
}

// ── Sección imagen ─────────────────────────────────────────────────────────────
class _ImageSection extends StatelessWidget {
  const _ImageSection({required this.inc, required this.theme});
  final Incidencia inc;
  final AppTheme theme;

  @override
  Widget build(BuildContext context) {
    if (inc.imagenPath == null)
      return Container(height: 180,
        decoration: BoxDecoration(color: theme.background, borderRadius: BorderRadius.circular(10),
          border: Border.all(color: theme.border)),
        child: Center(child: Icon(Icons.image_not_supported_outlined, size: 40, color: theme.textDisabled)));
    return GestureDetector(
      onTap: () => showDialog(context: context,
        builder: (_) => ImagenViewerDialog(imagenPath: inc.imagenPath!, theme: theme)),
      child: Stack(children: [
        Container(height: 200,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: theme.background,
            border: Border.all(color: theme.border)),
          child: ClipRRect(borderRadius: BorderRadius.circular(9),
            child: Image.asset(inc.imagenPath!, fit: BoxFit.cover, width: double.infinity, height: 200,
              errorBuilder: (_, __, ___) => Center(child: Icon(Icons.broken_image_outlined,
                size: 36, color: theme.textDisabled))))),
        Positioned(bottom: 6, right: 6, child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
          decoration: BoxDecoration(color: Colors.black.withOpacity(0.55), borderRadius: BorderRadius.circular(5)),
          child: const Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.zoom_in, size: 11, color: Colors.white),
            SizedBox(width: 3),
            Text('Ampliar', style: TextStyle(color: Colors.white, fontSize: 9)),
          ]))),
      ]),
    );
  }
}

// ── Sección info del caso ──────────────────────────────────────────────────────
class _InfoSection extends StatelessWidget {
  const _InfoSection({required this.inc, required this.theme, required this.dir,
    required this.conf, required this.confColor, required this.igRechaza});
  final Incidencia inc;
  final AppTheme theme;
  final String dir;
  final double conf;
  final Color confColor;
  final bool igRechaza;

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _InfoRow(label: 'Fecha de reporte', value: formatFechaHora(inc.fechaReporte), theme: theme),
      _InfoRow(label: 'Entorno', value: labelEntorno(inc.entorno), theme: theme),
      _InfoRow(label: 'Estatus actual', value: labelEstatus(inc.estatus), theme: theme),
      _InfoRow(label: 'Reincidente', value: inc.esReincidente ? 'Sí — caso previo registrado' : 'No', theme: theme),
      const SizedBox(height: 10),
      // Ubicación
      Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: theme.background, borderRadius: BorderRadius.circular(8),
          border: Border.all(color: theme.border.withOpacity(0.6))),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Icon(Icons.location_on_outlined, size: 13, color: theme.primaryColor),
            const SizedBox(width: 4),
            Text('UBICACIÓN', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700,
              color: theme.textSecondary, letterSpacing: 0.8)),
          ]),
          const SizedBox(height: 4),
          Text(dir, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: theme.textPrimary)),
          Text('${inc.latitud.toStringAsFixed(5)}, ${inc.longitud.toStringAsFixed(5)}',
            style: TextStyle(fontSize: 10, color: theme.textSecondary)),
        ])),
      if (inc.fechaLimite != null) ...[
        const SizedBox(height: 8),
        _InfoRow(label: 'SLA límite', value: formatFechaHora(inc.fechaLimite!), theme: theme),
      ],
    ]);
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value, required this.theme});
  final String label, value;
  final AppTheme theme;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(width: 110, child: Text(label,
          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: theme.textSecondary))),
        Expanded(child: Text(value,
          style: TextStyle(fontSize: 12, color: theme.textPrimary, fontWeight: FontWeight.w500))),
      ]),
    );
  }
}
""".strip(), encoding='utf-8')
print("✅ detalle_caso_dialog.dart")

# ═══════════════════════════════════════════════════════════════════════════════
# 7. bandeja_card.dart — mobile card modularizado
# ═══════════════════════════════════════════════════════════════════════════════
(BI / "bandeja_card.dart").write_text(r"""
import 'package:flutter/material.dart';
import 'package:nethive_neo/helpers/formatters.dart';
import 'package:nethive_neo/models/models.dart';
import 'package:nethive_neo/theme/theme.dart';
import 'package:nethive_neo/widgets/shared/priority_badge.dart';
import 'helpers_bandeja.dart';
import 'imagen_viewer_dialog.dart';
import 'mapa_ubicacion_dialog.dart';

class BandejaCard extends StatefulWidget {
  const BandejaCard({
    super.key,
    required this.inc,
    required this.onAprobar,
    required this.onRechazar,
    required this.onVerMapa,
  });
  final Incidencia inc;
  final ValueChanged<Incidencia> onAprobar, onRechazar, onVerMapa;
  @override
  State<BandejaCard> createState() => _BandejaCardState();
}

class _BandejaCardState extends State<BandejaCard> {
  bool _expanded = true;

  @override
  Widget build(BuildContext context) {
    final theme     = AppTheme.of(context);
    final inc       = widget.inc;
    final conf      = inc.iaConfianza ?? 0.0;
    final confColor = conf >= 0.90 ? theme.low : conf >= 0.70 ? theme.high : theme.critical;
    final igRechaza = esRechazoIA(inc);
    final icon      = catIcon(inc.categoria);

    return Container(
      decoration: BoxDecoration(
        color: theme.surface, borderRadius: BorderRadius.circular(14),
        border: Border.all(color: igRechaza ? theme.neutral.withOpacity(0.35) : theme.border),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 3))]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

        // ── Header tap para expandir ──────────────────────────────────────
        InkWell(
          onTap: () => setState(() => _expanded = !_expanded),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
            child: Row(children: [
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                  color: (igRechaza ? theme.neutral : theme.primaryColor).withOpacity(0.1),
                  shape: BoxShape.circle),
                child: Icon(icon,
                  color: igRechaza ? theme.neutral : theme.primaryColor, size: 20)),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Text(formatIdIncidencia(inc.id),
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800,
                      color: igRechaza ? theme.textSecondary : theme.primaryColor)),
                  const SizedBox(width: 6),
                  Flexible(child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: theme.border.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(5)),
                    child: Text(labelCategoria(inc.categoria),
                      style: TextStyle(fontSize: 10, color: theme.textSecondary),
                      overflow: TextOverflow.ellipsis))),
                ]),
                const SizedBox(height: 4),
                Text(inc.descripcion,
                  style: TextStyle(fontSize: 12, color: theme.textPrimary),
                  maxLines: 2, overflow: TextOverflow.ellipsis),
              ])),
              const SizedBox(width: 6),
              Icon(_expanded ? Icons.expand_less : Icons.expand_more,
                color: theme.textSecondary, size: 20),
            ]),
          ),
        ),

        // ── Body expandido ────────────────────────────────────────────────
        if (_expanded) ...[
          Divider(height: 1, color: theme.border.withOpacity(0.5)),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              // Imagen
              if (inc.imagenPath != null) ...[
                Row(children: [
                  Icon(Icons.camera_alt_outlined, size: 12, color: theme.textSecondary),
                  const SizedBox(width: 4),
                  Text('IMAGEN DEL CIUDADANO', style: TextStyle(
                    fontSize: 10, fontWeight: FontWeight.w700, color: theme.textSecondary, letterSpacing: 0.7)),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: () => showDialog(context: context,
                      builder: (_) => ImagenViewerDialog(imagenPath: inc.imagenPath!, theme: theme)),
                    icon: Icon(Icons.open_in_full, size: 12, color: theme.medium),
                    label: Text('Ver grande', style: TextStyle(fontSize: 11, color: theme.medium)),
                    style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2))),
                ]),
                const SizedBox(height: 5),
                GestureDetector(
                  onTap: () => showDialog(context: context,
                    builder: (_) => ImagenViewerDialog(imagenPath: inc.imagenPath!, theme: theme)),
                  child: Container(
                    height: 150,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(9),
                      border: Border.all(color: igRechaza ? theme.neutral.withOpacity(0.3) : theme.border),
                      color: theme.background),
                    child: ClipRRect(borderRadius: BorderRadius.circular(8),
                      child: Stack(fit: StackFit.expand, children: [
                        Image.asset(inc.imagenPath!, fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Center(child: Icon(Icons.broken_image_outlined,
                            color: theme.textDisabled, size: 28))),
                        if (igRechaza)
                          Positioned(top: 7, right: 7, child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                            decoration: BoxDecoration(color: Colors.black.withOpacity(0.65),
                              borderRadius: BorderRadius.circular(5)),
                            child: const Row(mainAxisSize: MainAxisSize.min, children: [
                              Icon(Icons.not_interested, size: 10, color: Colors.white),
                              SizedBox(width: 2),
                              Text('No relevante', style: TextStyle(color: Colors.white,
                                fontSize: 9, fontWeight: FontWeight.w600)),
                            ]))),
                        Positioned(bottom: 5, left: 5, child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                          decoration: BoxDecoration(color: Colors.black.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(4)),
                          child: const Row(mainAxisSize: MainAxisSize.min, children: [
                            Icon(Icons.zoom_in, size: 10, color: Colors.white),
                            SizedBox(width: 2),
                            Text('Toca para ampliar', style: TextStyle(color: Colors.white, fontSize: 9)),
                          ]))),
                      ]))),
                ),
                const SizedBox(height: 12),
              ],

              // Ubicación
              GestureDetector(
                onTap: () => showDialog(context: context,
                  builder: (_) => MapaUbicacionDialog(inc: inc, theme: theme)),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(color: theme.background, borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: theme.border.withOpacity(0.6))),
                  child: Row(children: [
                    Icon(Icons.location_on_outlined, size: 14, color: theme.primaryColor),
                    const SizedBox(width: 8),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(approxDireccion(inc.latitud, inc.longitud),
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: theme.textPrimary),
                        overflow: TextOverflow.ellipsis),
                      Text('${inc.latitud.toStringAsFixed(4)}, ${inc.longitud.toStringAsFixed(4)}',
                        style: TextStyle(fontSize: 10, color: theme.textSecondary)),
                    ])),
                    Icon(Icons.map_outlined, size: 14, color: theme.medium),
                  ])),
              ),
              const SizedBox(height: 12),

              // IA panel
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: theme.medium.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: theme.medium.withOpacity(0.2))),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Icon(Icons.psychology_outlined, size: 13, color: theme.medium),
                    const SizedBox(width: 5),
                    Text('ANÁLISIS IA', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700,
                      color: theme.medium, letterSpacing: 0.8)),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(color: confColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20)),
                      child: Text('${(conf * 100).toStringAsFixed(1)}% confianza',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: confColor))),
                  ]),
                  const SizedBox(height: 8),
                  Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('Categoría sugerida', style: TextStyle(fontSize: 10,
                        color: theme.textSecondary, fontWeight: FontWeight.w600)),
                      Text(labelCategoria(inc.iaCategoriaSugerida ?? inc.categoria),
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: theme.textPrimary)),
                    ])),
                    const SizedBox(width: 12),
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('Prioridad sugerida', style: TextStyle(fontSize: 10,
                        color: theme.textSecondary, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 2),
                      PriorityBadge(prioridad: inc.iaPrioridadSugerida ?? inc.prioridad),
                    ]),
                  ]),
                  if (inc.iaCoherenciaNota != null) ...[
                    const SizedBox(height: 8),
                    Text(inc.iaCoherenciaNota!,
                      style: TextStyle(fontSize: 11, color: theme.textSecondary, fontStyle: FontStyle.italic),
                      maxLines: 3, overflow: TextOverflow.ellipsis),
                  ],
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                    decoration: BoxDecoration(
                      color: (igRechaza ? theme.neutral : theme.low).withOpacity(0.08),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: (igRechaza ? theme.neutral : theme.low).withOpacity(0.25))),
                    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Padding(padding: const EdgeInsets.only(top: 1),
                        child: Icon(igRechaza ? Icons.report_off : Icons.check_circle_outline,
                          size: 14, color: igRechaza ? theme.neutral : theme.low)),
                      const SizedBox(width: 6),
                      Expanded(child: Text(
                        igRechaza
                          ? 'IA recomienda RECHAZAR — imagen no relevante.'
                          : 'IA recomienda APROBAR — descripción e imagen coherentes.',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
                          color: igRechaza ? theme.neutral : theme.low))),
                    ]),
                  ),
                ]),
              ),
            ]),
          ),
        ],

        // ── Barra de acciones ─────────────────────────────────────────────
        Container(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
          decoration: BoxDecoration(color: theme.background,
            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(14))),
          child: Row(children: [
            if (inc.esReincidente)
              Container(
                margin: const EdgeInsets.only(right: 6),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(color: theme.high.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(5)),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.repeat, size: 11, color: theme.high),
                  const SizedBox(width: 2),
                  Text('Reincidente', style: TextStyle(fontSize: 10, color: theme.high, fontWeight: FontWeight.w600)),
                ])),
            const Spacer(),
            TextButton.icon(
              onPressed: () => widget.onVerMapa(inc),
              icon: Icon(Icons.map_outlined, size: 14, color: theme.medium),
              label: Text('Mapa', style: TextStyle(fontSize: 12, color: theme.medium)),
              style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6))),
            const SizedBox(width: 4),
            OutlinedButton.icon(
              onPressed: () => widget.onRechazar(inc),
              icon: const Icon(Icons.close, size: 14),
              label: const Text('Rechazar', overflow: TextOverflow.ellipsis),
              style: OutlinedButton.styleFrom(foregroundColor: theme.critical,
                side: BorderSide(color: theme.critical.withOpacity(0.45)),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6))),
            const SizedBox(width: 6),
            ElevatedButton.icon(
              onPressed: igRechaza ? null : () => widget.onAprobar(inc),
              icon: const Icon(Icons.check, size: 14),
              label: const Text('Aprobar', overflow: TextOverflow.ellipsis),
              style: ElevatedButton.styleFrom(
                backgroundColor: igRechaza ? theme.neutral : theme.low,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6))),
          ]),
        ),
      ]),
    );
  }
}
""".strip(), encoding='utf-8')
print("✅ bandeja_card.dart")

# ═══════════════════════════════════════════════════════════════════════════════
# 8. pluto_bandeja_view.dart — PlutoGrid desktop con columna de imagen
# ═══════════════════════════════════════════════════════════════════════════════
(BI / "pluto_bandeja_view.dart").write_text(r"""
import 'package:flutter/material.dart';
import 'package:nethive_neo/helpers/formatters.dart';
import 'package:nethive_neo/models/models.dart';
import 'package:nethive_neo/theme/theme.dart';
import 'package:nethive_neo/widgets/shared/priority_badge.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'helpers_bandeja.dart';
import 'imagen_viewer_dialog.dart';
import 'mapa_ubicacion_dialog.dart';
import 'detalle_caso_dialog.dart';

class PlutoBandejaView extends StatelessWidget {
  const PlutoBandejaView({
    super.key,
    required this.items,
    required this.theme,
    required this.onConfirmAccion,
  });
  final List<Incidencia> items;
  final AppTheme theme;
  final void Function(String tipo, Incidencia inc) onConfirmAccion;

  // ── Columnas ────────────────────────────────────────────────────────────────
  List<PlutoColumn> _cols(BuildContext context) => [
    // ID
    PlutoColumn(
      title: 'ID', field: 'id', type: PlutoColumnType.text(), width: 88,
      renderer: (r) => Text(formatIdIncidencia(r.cell.value),
        style: TextStyle(fontWeight: FontWeight.w800, color: theme.primaryColor, fontSize: 12))),

    // Imagen thumbnail
    PlutoColumn(
      title: '', field: 'img', type: PlutoColumnType.text(), width: 70,
      enableSorting: false, enableFilterMenuItem: false,
      renderer: (r) {
        final inc = _inc(r);
        final path = inc?.imagenPath;
        if (path == null || path.isEmpty) {
          return Center(child: Icon(catIcon(inc?.categoria ?? ''), size: 20, color: theme.textDisabled));
        }
        return GestureDetector(
          onTap: () => showDialog(context: context,
            builder: (_) => ImagenViewerDialog(imagenPath: path, theme: theme)),
          child: Tooltip(
            message: 'Clic para ampliar',
            child: Container(
              width: 52, height: 52,
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(6),
                border: Border.all(color: theme.border)),
              child: ClipRRect(borderRadius: BorderRadius.circular(5),
                child: Image.asset(path, fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Center(child:
                    Icon(catIcon(inc?.categoria ?? ''), size: 20, color: theme.textDisabled)))))));
      }),

    // Categoría con ícono
    PlutoColumn(
      title: 'Categoría', field: 'categoria', type: PlutoColumnType.text(), width: 130,
      renderer: (r) => Row(children: [
        Icon(catIcon(r.cell.value), size: 14, color: theme.textSecondary),
        const SizedBox(width: 5),
        Flexible(child: Text(labelCategoria(r.cell.value),
          style: TextStyle(fontSize: 12, color: theme.textPrimary),
          overflow: TextOverflow.ellipsis)),
      ])),

    // Descripción
    PlutoColumn(
      title: 'Descripción', field: 'descripcion', type: PlutoColumnType.text(), width: 210,
      renderer: (r) => Tooltip(message: r.cell.value,
        child: Text(r.cell.value, maxLines: 2, overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: 12, color: theme.textPrimary)))),

    // Confianza IA
    PlutoColumn(
      title: 'Confianza IA', field: 'confianza', type: PlutoColumnType.text(), width: 105,
      renderer: (r) {
        final conf = double.tryParse(r.cell.value) ?? 0.0;
        final c = conf >= 0.90 ? theme.low : conf >= 0.70 ? theme.high : theme.critical;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(color: c.withOpacity(0.12), borderRadius: BorderRadius.circular(20)),
          child: Text('${(conf * 100).toStringAsFixed(1)}%',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: c)));
      }),

    // Prioridad IA
    PlutoColumn(
      title: 'Prioridad IA', field: 'prio_ia', type: PlutoColumnType.text(), width: 112,
      renderer: (r) => r.cell.value.isEmpty
        ? Text('—', style: TextStyle(color: theme.textDisabled))
        : PriorityBadge(prioridad: r.cell.value)),

    // Veredicto IA
    PlutoColumn(
      title: 'Veredicto IA', field: 'veredicto', type: PlutoColumnType.text(), width: 140,
      renderer: (r) {
        final rechaza = r.cell.value == '1';
        final c = rechaza ? theme.neutral : theme.low;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
          decoration: BoxDecoration(color: c.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(rechaza ? Icons.report_off : Icons.check_circle_outline, size: 12, color: c),
            const SizedBox(width: 4),
            Flexible(child: Text(rechaza ? 'Rec. rechazar' : 'Rec. aprobar',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: c))),
          ]));
      }),

    // Ubicación
    PlutoColumn(
      title: 'Ubicación', field: 'ubicacion', type: PlutoColumnType.text(), width: 135,
      renderer: (r) => Text(r.cell.value,
        style: TextStyle(fontSize: 11, color: theme.textSecondary))),

    // Fecha
    PlutoColumn(
      title: 'Fecha', field: 'fecha', type: PlutoColumnType.text(), width: 108,
      renderer: (r) => Text(r.cell.value,
        style: TextStyle(fontSize: 11, color: theme.textSecondary))),

    // Acciones — 4 iconos compactos  
    PlutoColumn(
      title: 'Acciones', field: 'acciones', type: PlutoColumnType.text(), width: 150,
      enableSorting: false, enableFilterMenuItem: false,
      renderer: (r) {
        final inc = _inc(r);
        if (inc == null) return const SizedBox.shrink();
        final igRechaza = esRechazoIA(inc);
        return Row(mainAxisSize: MainAxisSize.min, children: [
          // Ver caso
          _IconAction(
            icon: Icons.article_outlined,
            tooltip: 'Ver caso completo',
            color: theme.primaryColor,
            onTap: () => showDialog(context: context, builder: (_) => DetalleCasoDialog(
              inc: inc, theme: theme,
              onAprobar:  () => onConfirmAccion('aprobar',  inc),
              onRechazar: () => onConfirmAccion('rechazar', inc),
              onVerMapa:  () => showDialog(context: context,
                builder: (_) => MapaUbicacionDialog(inc: inc, theme: theme)))),
          ),
          const SizedBox(width: 4),
          // Ver mapa
          _IconAction(
            icon: Icons.map_outlined,
            tooltip: 'Ver en mapa',
            color: theme.medium,
            onTap: () => showDialog(context: context,
              builder: (_) => MapaUbicacionDialog(inc: inc, theme: theme))),
          const SizedBox(width: 4),
          // Aprobar
          _IconAction(
            icon: Icons.check_circle_outline,
            tooltip: igRechaza ? 'IA recomienda rechazar' : 'Aprobar caso',
            color: igRechaza ? theme.neutral : theme.low,
            onTap: igRechaza ? null : () => onConfirmAccion('aprobar', inc)),
          const SizedBox(width: 4),
          // Rechazar
          _IconAction(
            icon: Icons.cancel_outlined,
            tooltip: 'Rechazar caso',
            color: theme.critical,
            onTap: () => onConfirmAccion('rechazar', inc)),
        ]);
      }),
  ];

  Incidencia? _inc(PlutoColumnRendererContext r) {
    final id = r.row.cells['id']?.value as String? ?? '';
    try { return items.firstWhere((i) => i.id == id); } catch (_) { return null; }
  }

  List<PlutoRow> _rows() => items.map((inc) => PlutoRow(cells: {
    'id':          PlutoCell(value: inc.id),
    'img':         PlutoCell(value: inc.imagenPath ?? ''),
    'categoria':   PlutoCell(value: inc.categoria),
    'descripcion': PlutoCell(value: inc.descripcion),
    'confianza':   PlutoCell(value: '${inc.iaConfianza ?? 0.0}'),
    'prio_ia':     PlutoCell(value: inc.iaPrioridadSugerida ?? ''),
    'veredicto':   PlutoCell(value: esRechazoIA(inc) ? '1' : '0'),
    'ubicacion':   PlutoCell(value: approxDireccion(inc.latitud, inc.longitud)),
    'fecha':       PlutoCell(value: formatFechaHoraCorta(inc.fechaReporte)),
    'acciones':    PlutoCell(value: ''),
  })).toList();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: theme.surface, borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.border),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))]),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: PlutoGrid(
          columns: _cols(context),
          rows: _rows(),
          onLoaded: (e) => e.stateManager.setPageSize(12, notify: false),
          createFooter: (s) => PlutoPagination(s),
          configuration: PlutoGridConfiguration(
            style: PlutoGridStyleConfig(
              gridBorderColor: theme.border,
              gridBackgroundColor: theme.surface,
              rowColor: theme.surface,
              activatedColor: theme.primaryColor.withOpacity(0.07),
              activatedBorderColor: theme.primaryColor,
              columnHeight: 44,
              rowHeight: 64,
              columnTextStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: theme.textSecondary),
            ),
            columnSize: const PlutoGridColumnSizeConfig(autoSizeMode: PlutoAutoSizeMode.none),
          ),
        ),
      ),
    );
  }
}

// ── Icono de acción mini ───────────────────────────────────────────────────────
class _IconAction extends StatelessWidget {
  const _IconAction({required this.icon, required this.tooltip, required this.color, this.onTap});
  final IconData icon;
  final String tooltip;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = onTap == null ? Colors.grey.shade400 : color;
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          width: 30, height: 30,
          decoration: BoxDecoration(
            color: c.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: c.withOpacity(0.3))),
          child: Icon(icon, size: 16, color: c))),
    );
  }
}
""".strip(), encoding='utf-8')
print("✅ pluto_bandeja_view.dart")

# ═══════════════════════════════════════════════════════════════════════════════
# 9. bandeja_ia_page.dart — página orquestadora simplificada
# ═══════════════════════════════════════════════════════════════════════════════
(LIB / "pages" / "bandeja_ia" / "bandeja_ia_page.dart").write_text(r"""
import 'package:flutter/material.dart';
import 'package:nethive_neo/models/models.dart';
import 'package:nethive_neo/providers/providers.dart';
import 'package:nethive_neo/theme/theme.dart';
import 'package:nethive_neo/widgets/shared/section_header.dart';
import 'package:provider/provider.dart';
import 'widgets/bandeja_card.dart';
import 'widgets/confirmar_accion_dialog.dart';
import 'widgets/filter_bar_bandeja.dart';
import 'widgets/helpers_bandeja.dart';
import 'widgets/mapa_ubicacion_dialog.dart';
import 'widgets/pluto_bandeja_view.dart';
import 'package:nethive_neo/helpers/formatters.dart';

class BandejaIAPage extends StatefulWidget {
  const BandejaIAPage({super.key});
  @override
  State<BandejaIAPage> createState() => _BandejaIAPageState();
}

class _BandejaIAPageState extends State<BandejaIAPage> {
  String? _filterCategoria;
  String  _filterVeredicto = 'todos';
  String  _search = '';

  List<Incidencia> _filter(List<Incidencia> all) {
    var r = all;
    if (_filterCategoria != null) r = r.where((i) => i.categoria == _filterCategoria).toList();
    if (_filterVeredicto == 'recomienda_aprobar')  r = r.where((i) => !esRechazoIA(i)).toList();
    if (_filterVeredicto == 'recomienda_rechazar') r = r.where((i) =>  esRechazoIA(i)).toList();
    if (_search.isNotEmpty)
      r = r.where((i) => i.descripcion.toLowerCase().contains(_search.toLowerCase()) ||
                         i.id.contains(_search)).toList();
    return r;
  }

  // Flujo confirmación → actualizar providers
  void _confirmAccion(BuildContext ctx, String tipo, Incidencia inc) {
    final iaRechaza = esRechazoIA(inc);
    showDialog(
      context: ctx,
      barrierDismissible: false,
      builder: (_) => ConfirmarAccionDialog(
        tipo: tipo, inc: inc, iaRechaza: iaRechaza,
        onConfirm: (motivo) {
          final bIa  = ctx.read<BandejaIAProvider>();
          final bInc = ctx.read<IncidenciaProvider>();
          if (tipo == 'aprobar') {
            bIa.aprobar(inc.id, prioridadOverride: inc.iaPrioridadSugerida);
            bInc.actualizarEstatus(inc.id, 'aprobado');
            ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
              content: Text('${formatIdIncidencia(inc.id)} aprobado — enviado a Órdenes'),
              backgroundColor: const Color(0xFF2D7A4F)));
          } else {
            bIa.rechazar(inc.id);
            bInc.actualizarEstatus(inc.id, 'rechazado');
            ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
              content: Text('${formatIdIncidencia(inc.id)} rechazado${motivo.isNotEmpty ? " · $motivo" : ""}'),
              backgroundColor: const Color(0xFF64748B)));
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme   = AppTheme.of(context);
    final bandeja = context.watch<BandejaIAProvider>();
    final all     = bandeja.pendientes;
    final pending = _filter(all);
    final cats    = all.map((i) => i.categoria).toSet().toList()..sort();

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Header
        SectionHeader(
          title: 'Bandeja de Revisión IA',
          subtitle: 'Reportes ciudadanos clasificados por IA — requieren validación humana',
          trailing: all.isNotEmpty
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: theme.high.withOpacity(0.15), borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: theme.high.withOpacity(0.3))),
                child: Text('${all.length} pendientes',
                  style: TextStyle(color: theme.high, fontSize: 12, fontWeight: FontWeight.w700)))
            : null,
        ),
        const SizedBox(height: 10),

        // Info banner
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          margin: const EdgeInsets.only(bottom: 14),
          decoration: BoxDecoration(color: theme.medium.withOpacity(0.07),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: theme.medium.withOpacity(0.2))),
          child: Row(children: [
            Icon(Icons.psychology_outlined, color: theme.medium, size: 18),
            const SizedBox(width: 10),
            Expanded(child: Text(
              'La IA valida coherencia texto-imagen y sugiere categoría y prioridad. '
              'El operador aprueba o rechaza antes de generar la orden.',
              style: TextStyle(fontSize: 12, color: theme.textSecondary))),
          ]),
        ),

        // Filtros
        FilterBarBandeja(
          search: _search, filterCategoria: _filterCategoria, filterVeredicto: _filterVeredicto,
          cats: cats, theme: theme,
          onSearch:    (v) => setState(() => _search = v),
          onCategoria: (v) => setState(() => _filterCategoria = v),
          onVeredicto: (v) => setState(() => _filterVeredicto = v ?? 'todos'),
        ),
        const SizedBox(height: 10),

        if (pending.length != all.length)
          Padding(padding: const EdgeInsets.only(bottom: 8),
            child: Text('${pending.length} de ${all.length} registros',
              style: TextStyle(fontSize: 12, color: theme.textSecondary, fontStyle: FontStyle.italic))),

        // Contenido
        if (pending.isEmpty)
          Expanded(child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.check_circle_outline, size: 56, color: theme.low),
            const SizedBox(height: 12),
            Text('Sin resultados para la selección actual',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: theme.textPrimary)),
          ])))
        else
          Expanded(child: LayoutBuilder(builder: (ctx, box) {
            if (box.maxWidth >= 800) {
              return PlutoBandejaView(
                items: pending,
                theme: theme,
                onConfirmAccion: (tipo, inc) => _confirmAccion(context, tipo, inc),
              );
            }
            return ListView.separated(
              itemCount: pending.length,
              separatorBuilder: (_, __) => const SizedBox(height: 14),
              itemBuilder: (_, i) => BandejaCard(
                inc: pending[i],
                onAprobar:  (inc) => _confirmAccion(context, 'aprobar',  inc),
                onRechazar: (inc) => _confirmAccion(context, 'rechazar', inc),
                onVerMapa:  (inc) => showDialog(context: context,
                  builder: (_) => MapaUbicacionDialog(inc: pending[i], theme: theme)),
              ),
            );
          })),
      ]),
    );
  }
}
""".strip(), encoding='utf-8')
print("✅ bandeja_ia_page.dart (simplificado)")

print("\n✅ BandejaIA: todos los archivos escritos")
