
import pathlib
ROOT = pathlib.Path(r"g:\TRABAJO\FLUTTER\cbl_portal_demos\sistema_smart_sistem_demo")

bandeja_ia = r'''import 'package:flutter/material.dart';
import 'package:nethive_neo/helpers/formatters.dart';
import 'package:nethive_neo/models/models.dart';
import 'package:nethive_neo/providers/providers.dart';
import 'package:nethive_neo/theme/theme.dart';
import 'package:nethive_neo/widgets/shared/priority_badge.dart';
import 'package:nethive_neo/widgets/shared/section_header.dart';
import 'package:provider/provider.dart';

class BandejaIAPage extends StatelessWidget {
  const BandejaIAPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme   = AppTheme.of(context);
    final bandeja = context.watch<BandejaIAProvider>();
    final pending = bandeja.pendientes;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            title: 'Bandeja de Revisión IA',
            subtitle: 'Reportes ciudadanos clasificados por IA — requieren validación humana',
            trailing: pending.isNotEmpty
              ? Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: theme.high.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: theme.high.withOpacity(0.3)),
                  ),
                  child: Text('${pending.length} pendientes',
                    style: TextStyle(color: theme.high, fontSize: 12, fontWeight: FontWeight.w700)),
                )
              : null,
          ),
          const SizedBox(height: 8),

          // Info banner
          Container(
            padding: const EdgeInsets.all(14),
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: theme.medium.withOpacity(0.07),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: theme.medium.withOpacity(0.2)),
            ),
            child: Row(children: [
              Icon(Icons.psychology_outlined, color: theme.medium, size: 20),
              const SizedBox(width: 10),
              Expanded(child: Text(
                'La IA valida la coherencia texto-imagen y sugiere categoría y prioridad. '
                'El operador revisa y aprueba o rechaza antes de generar la orden de trabajo.',
                style: TextStyle(fontSize: 12, color: theme.textSecondary),
              )),
            ]),
          ),

          if (pending.isEmpty)
            Center(child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 48),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.check_circle_outline, size: 56, color: theme.low),
                const SizedBox(height: 12),
                Text('Bandeja vacía — todos los reportes han sido revisados',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: theme.textPrimary)),
              ]),
            ))
          else
            ...pending.map((inc) => _BandejaCard(inc: inc)),
        ],
      ),
    );
  }
}

// ── _BandejaCard ──────────────────────────────────────────────────────────────
class _BandejaCard extends StatefulWidget {
  const _BandejaCard({required this.inc});
  final Incidencia inc;
  @override
  State<_BandejaCard> createState() => _BandejaCardState();
}

class _BandejaCardState extends State<_BandejaCard> {
  bool _expanded = true; // abierto por defecto para mostrar la imagen

  static const _catIcons = <String, IconData>{
    'alumbrado':    Icons.lightbulb_outline,
    'bacheo':       Icons.construction,
    'basura':       Icons.delete_outline,
    'agua_drenaje': Icons.water_drop_outlined,
    'senalizacion': Icons.signpost_outlined,
    'señalizacion': Icons.traffic,
    'seguridad':    Icons.security,
  };

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final inc   = widget.inc;
    final conf  = inc.iaConfianza ?? 0.0;
    final confColor = conf >= 0.90 ? theme.low : conf >= 0.70 ? theme.high : theme.critical;

    // Determinar si la IA sugiere rechazar (imágenes irrelevantes)
    final bool iaRechaza = _detectaRechazo(inc);

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: iaRechaza ? theme.neutral.withOpacity(0.4) : theme.border,
          width: iaRechaza ? 1 : 1,
        ),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 3))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──────────────────────────────────────────────────
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(children: [
                // Category icon or rechazar icon
                Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(
                    color: iaRechaza
                      ? theme.neutral.withOpacity(0.12)
                      : theme.primaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    iaRechaza ? Icons.report_off : (_catIcons[inc.categoria] ?? Icons.help_outline),
                    color: iaRechaza ? theme.neutral : theme.primaryColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Text(formatIdIncidencia(inc.id),
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800,
                          color: iaRechaza ? theme.textSecondary : theme.primaryColor)),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: theme.border.withOpacity(0.5), borderRadius: BorderRadius.circular(5)),
                        child: Text(labelCategoria(inc.categoria),
                          style: TextStyle(fontSize: 11, color: theme.textSecondary)),
                      ),
                      const Spacer(),
                      Text(formatFechaHora(inc.fechaReporte),
                        style: TextStyle(fontSize: 11, color: theme.textSecondary)),
                    ]),
                    const SizedBox(height: 5),
                    Text(inc.descripcion,
                      style: TextStyle(fontSize: 13, color: theme.textPrimary),
                      maxLines: 2, overflow: TextOverflow.ellipsis),
                  ],
                )),
                const SizedBox(width: 8),
                Icon(_expanded ? Icons.expand_less : Icons.expand_more, color: theme.textSecondary),
              ]),
            ),
          ),

          // ── Collapsed: solo barra resumen IA ────────────────────────
          if (!_expanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: _IaBar(inc: inc, confColor: confColor, conf: conf, theme: theme, compact: true),
            ),

          // ── Expanded: imagen + reporte + análisis IA ────────────────
          if (_expanded) ...[
            Divider(height: 1, color: theme.border.withOpacity(0.5)),
            Padding(
              padding: const EdgeInsets.all(16),
              child: _buildExpandedBody(context, inc, theme, conf, confColor, iaRechaza),
            ),
          ],

          // ── Actions ─────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
            decoration: BoxDecoration(
              color: theme.background,
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(14)),
            ),
            child: Row(children: [
              if (inc.esReincidente) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: theme.high.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.repeat, size: 13, color: theme.high),
                    const SizedBox(width: 4),
                    Text('Reincidente', style: TextStyle(fontSize: 11, color: theme.high, fontWeight: FontWeight.w600)),
                  ]),
                ),
                const SizedBox(width: 8),
              ],
              if (iaRechaza)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: theme.neutral.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(Icons.report_off, size: 13, color: theme.neutral),
                      const SizedBox(width: 4),
                      Text('IA recomienda rechazar', style: TextStyle(
                        fontSize: 11, color: theme.neutral, fontWeight: FontWeight.w600)),
                    ]),
                  ),
                ),
              const Spacer(),
              OutlinedButton.icon(
                onPressed: () {
                  context.read<BandejaIAProvider>().rechazar(inc.id);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('${formatIdIncidencia(inc.id)} rechazado'),
                    backgroundColor: theme.neutral));
                },
                icon: const Icon(Icons.close, size: 16),
                label: const Text('Rechazar'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: theme.critical,
                  side: BorderSide(color: theme.critical.withOpacity(0.5)),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: iaRechaza ? null : () {
                  context.read<BandejaIAProvider>().aprobar(inc.id,
                    prioridadOverride: inc.iaPrioridadSugerida);
                  context.read<IncidenciaProvider>().actualizarEstatus(inc.id, 'aprobado');
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('${formatIdIncidencia(inc.id)} aprobado — enviado a Órdenes'),
                    backgroundColor: theme.low));
                },
                icon: const Icon(Icons.check, size: 16),
                label: const Text('Aprobar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: iaRechaza ? theme.neutral : theme.low,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _buildExpandedBody(BuildContext context, Incidencia inc, AppTheme theme,
      double conf, Color confColor, bool iaRechaza) {

    final screenW = MediaQuery.of(context).size.width;
    final isNarrow = screenW < 700;

    final imagePanel = _ImagePanel(imagenPath: inc.imagenPath, iaRechaza: iaRechaza, theme: theme);
    final reportPanel = _ReportePanel(inc: inc, theme: theme);
    final iaPanel     = _IAAnalisisPanel(inc: inc, conf: conf, confColor: confColor, iaRechaza: iaRechaza, theme: theme);

    if (isNarrow) {
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        imagePanel,
        const SizedBox(height: 16),
        reportPanel,
        const SizedBox(height: 16),
        iaPanel,
      ]);
    }

    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // LEFT: imagen
      SizedBox(width: 260, child: imagePanel),
      const SizedBox(width: 16),
      // RIGHT: reporte + IA
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        reportPanel,
        const SizedBox(height: 14),
        iaPanel,
      ])),
    ]);
  }

  bool _detectaRechazo(Incidencia inc) {
    final p = inc.imagenPath ?? '';
    return p.contains('rechazar') || p.contains('happyface') || p.contains('papelito');
  }
}

// ── Image Panel ───────────────────────────────────────────────────────────────
class _ImagePanel extends StatelessWidget {
  const _ImagePanel({required this.imagenPath, required this.iaRechaza, required this.theme});
  final String? imagenPath;
  final bool iaRechaza;
  final AppTheme theme;

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Icon(Icons.camera_alt_outlined, size: 14, color: theme.textSecondary),
        const SizedBox(width: 5),
        Text('IMAGEN ENVIADA POR CIUDADANO', style: TextStyle(
          fontSize: 10.5, fontWeight: FontWeight.w700, color: theme.textSecondary, letterSpacing: 0.8)),
      ]),
      const SizedBox(height: 8),
      Container(
        height: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: iaRechaza ? theme.neutral.withOpacity(0.3) : theme.border,
            width: iaRechaza ? 2 : 1,
          ),
          color: theme.background,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(9),
          child: imagenPath != null
            ? Stack(children: [
                Image.asset(imagenPath!,
                  width: double.infinity, height: 200, fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _noImg(theme),
                ),
                if (iaRechaza)
                  Positioned(
                    top: 8, right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.65),
                        borderRadius: BorderRadius.circular(6)),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        const Icon(Icons.not_interested, size: 12, color: Colors.white),
                        const SizedBox(width: 4),
                        const Text('No relevante', style: TextStyle(
                          color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600)),
                      ]),
                    ),
                  ),
              ])
            : _noImg(theme),
        ),
      ),
      if (imagenPath == null) ...[
        const SizedBox(height: 8),
        Text('El ciudadano no adjuntó imagen', style: TextStyle(
          fontSize: 11, color: theme.textDisabled, fontStyle: FontStyle.italic)),
      ],
    ]);
  }

  Widget _noImg(AppTheme theme) => Center(child: Column(
    mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(Icons.image_not_supported_outlined, size: 40, color: theme.textDisabled),
      const SizedBox(height: 6),
      Text('Sin imagen', style: TextStyle(fontSize: 12, color: theme.textDisabled)),
    ],
  ));
}

// ── Reporte Panel ─────────────────────────────────────────────────────────────
class _ReportePanel extends StatelessWidget {
  const _ReportePanel({required this.inc, required this.theme});
  final Incidencia inc;
  final AppTheme theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.background,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: theme.border.withOpacity(0.7)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(Icons.person_outline, size: 14, color: theme.textSecondary),
          const SizedBox(width: 5),
          Text('REPORTE CIUDADANO', style: TextStyle(
            fontSize: 10.5, fontWeight: FontWeight.w700, color: theme.textSecondary, letterSpacing: 0.8)),
        ]),
        const SizedBox(height: 10),
        _Field(label: 'Descripción', value: inc.descripcion, theme: theme, multiline: true),
        const SizedBox(height: 8),
        Row(children: [
          Expanded(child: _Field(label: 'Categoría reportada', value: labelCategoria(inc.categoria), theme: theme)),
          const SizedBox(width: 12),
          Expanded(child: _Field(label: 'Entorno', value: labelEntorno(inc.entorno), theme: theme)),
        ]),
        const SizedBox(height: 8),
        Row(children: [
          Expanded(child: _Field(label: 'Fecha reporte', value: formatFechaHora(inc.fechaReporte), theme: theme)),
          const SizedBox(width: 12),
          Expanded(child: _Field(label: 'SLA límite', value: formatSla(inc.fechaLimite), theme: theme,
            valueColor: inc.estaVencida ? theme.critical : null)),
        ]),
      ]),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({required this.label, required this.value, required this.theme,
    this.multiline = false, this.valueColor});
  final String label, value;
  final AppTheme theme;
  final bool multiline;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: TextStyle(fontSize: 10, color: theme.textSecondary, fontWeight: FontWeight.w600)),
      const SizedBox(height: 2),
      Text(value, style: TextStyle(fontSize: 13, color: valueColor ?? theme.textPrimary),
        maxLines: multiline ? 4 : 1, overflow: TextOverflow.ellipsis),
    ],
  );
}

// ── IA Análisis Panel ─────────────────────────────────────────────────────────
class _IAAnalisisPanel extends StatelessWidget {
  const _IAAnalisisPanel({
    required this.inc, required this.conf, required this.confColor,
    required this.iaRechaza, required this.theme});
  final Incidencia inc;
  final double conf;
  final Color confColor;
  final bool iaRechaza;
  final AppTheme theme;

  @override
  Widget build(BuildContext context) {
    final veredictoColor  = iaRechaza ? theme.neutral : theme.low;
    final verdictoBg      = veredictoColor.withOpacity(0.1);
    final veredictoBorder = veredictoColor.withOpacity(0.28);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.medium.withOpacity(0.05),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: theme.medium.withOpacity(0.2)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(Icons.psychology_outlined, size: 16, color: theme.medium),
          const SizedBox(width: 6),
          Text('ANÁLISIS IA', style: TextStyle(
            fontSize: 10.5, fontWeight: FontWeight.w700, color: theme.medium, letterSpacing: 0.8)),
          const Spacer(),
          // Confianza badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: confColor.withOpacity(0.1), borderRadius: BorderRadius.circular(20),
              border: Border.all(color: confColor.withOpacity(0.3))),
            child: Text('${(conf * 100).toStringAsFixed(1)}% confianza',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: confColor)),
          ),
        ]),
        const SizedBox(height: 12),

        // Categoría y prioridad sugerida
        Row(children: [
          Expanded(child: _IAField(
            label: 'Categoría sugerida',
            value: labelCategoria(inc.iaCategoriaSugerida ?? inc.categoria),
            theme: theme,
          )),
          const SizedBox(width: 12),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Prioridad sugerida', style: TextStyle(fontSize: 10, color: theme.textSecondary, fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            PriorityBadge(prioridad: inc.iaPrioridadSugerida ?? inc.prioridad),
          ]),
        ]),

        // Coherencia texto-imagen
        if (inc.iaCoherenciaNota != null) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: theme.high.withOpacity(0.06),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: theme.high.withOpacity(0.2)),
            ),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Icon(Icons.compare, size: 14, color: theme.high),
              const SizedBox(width: 6),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('COHERENCIA TEXTO-IMAGEN', style: TextStyle(
                  fontSize: 9.5, fontWeight: FontWeight.w700, color: theme.high, letterSpacing: 0.7)),
                const SizedBox(height: 3),
              ]),
            ]),
          ),
          Padding(padding: const EdgeInsets.fromLTRB(8, 6, 0, 0),
            child: Text(inc.iaCoherenciaNota!,
              style: TextStyle(fontSize: 12, color: theme.textSecondary))),
        ],

        const SizedBox(height: 12),

        // Veredicto
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: verdictoBg, borderRadius: BorderRadius.circular(8),
            border: Border.all(color: veredictoBorder),
          ),
          child: Row(children: [
            Icon(iaRechaza ? Icons.report_off : Icons.check_circle_outline,
              size: 16, color: veredictoColor),
            const SizedBox(width: 8),
            Text(
              iaRechaza
                ? 'La IA recomienda RECHAZAR — imagen no corresponde a un incidente de infraestructura relevante.'
                : 'La IA recomienda APROBAR — descripción e imagen son coherentes con la categoría.',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: veredictoColor),
            ),
          ]),
        ),
      ]),
    );
  }
}

class _IAField extends StatelessWidget {
  const _IAField({required this.label, required this.value, required this.theme});
  final String label, value;
  final AppTheme theme;
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(label, style: TextStyle(fontSize: 10, color: theme.textSecondary, fontWeight: FontWeight.w600)),
    const SizedBox(height: 3),
    Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: theme.textPrimary)),
  ]);
}

class _IaBar extends StatelessWidget {
  const _IaBar({required this.inc, required this.conf, required this.confColor,
    required this.theme, this.compact = false});
  final Incidencia inc;
  final double conf;
  final Color confColor;
  final AppTheme theme;
  final bool compact;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: theme.medium.withOpacity(0.06),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.medium.withOpacity(0.2)),
      ),
      child: Row(children: [
        Icon(Icons.psychology_outlined, size: 15, color: theme.medium),
        const SizedBox(width: 6),
        Text('IA · ', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: theme.medium)),
        Text('${labelCategoria(inc.iaCategoriaSugerida ?? inc.categoria)} · ',
          style: TextStyle(fontSize: 12, color: theme.textSecondary)),
        PriorityBadge(prioridad: inc.iaPrioridadSugerida ?? inc.prioridad),
        const Spacer(),
        Text('${(conf * 100).toStringAsFixed(0)}%',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: confColor)),
      ]),
    );
  }
}
'''

p = ROOT / "lib" / "pages" / "bandeja_ia" / "bandeja_ia_page.dart"
p.write_text(bandeja_ia, encoding='utf-8')
print(f"✅ {p.name} ({len(bandeja_ia.splitlines())} líneas)")
