// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

import 'package:flutter/material.dart';
import 'package:nethive_neo/helpers/constants.dart';
import 'package:nethive_neo/helpers/formatters.dart';
import 'package:nethive_neo/models/models.dart';
import 'package:nethive_neo/providers/providers.dart';
import 'package:nethive_neo/theme/theme.dart';
import 'package:nethive_neo/widgets/shared/section_header.dart';
import 'package:provider/provider.dart';

class AuditoriaPage extends StatelessWidget {
  const AuditoriaPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final prov = context.watch<AuditoriaProvider>();
    final events = prov.filtrados;
    final isMobile = MediaQuery.of(context).size.width < mobileSize;

    final modulos = prov.modulos.toList()..sort();
    const niveles = ['nacional', 'estatal', 'municipal'];

    return Padding(
      padding: EdgeInsets.all(isMobile ? 16 : 24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // ── Header ────────────────────────────────────────────────────────
        SectionHeader(
          title: 'Log de Auditoría',
          subtitle: '${prov.todos.length} eventos registrados',
          trailing: TextButton.icon(
            onPressed: () => _exportarCsv(prov.filtrados),
            icon: const Icon(Icons.download_outlined, size: 16),
            label: const Text('Exportar CSV'),
            style: TextButton.styleFrom(foregroundColor: theme.primaryColor),
          ),
        ),
        const SizedBox(height: 12),

        // ── Filtros ────────────────────────────────────────────────────────
        _FiltersBar(
          prov: prov,
          theme: theme,
          modulos: modulos,
          niveles: niveles,
          isMobile: isMobile,
        ),
        const SizedBox(height: 8),

        // Contador
        Row(children: [
          Text('${events.length} resultado${events.length != 1 ? "s" : ""}',
              style: TextStyle(
                  fontSize: 12,
                  color: theme.textSecondary,
                  fontStyle: FontStyle.italic)),
          if (prov.tieneFiltros) ...[
            const SizedBox(width: 12),
            GestureDetector(
              onTap: prov.limpiarFiltros,
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.clear, size: 14, color: theme.critical),
                const SizedBox(width: 4),
                Text('Limpiar filtros',
                    style: TextStyle(
                        fontSize: 12,
                        color: theme.critical,
                        fontWeight: FontWeight.w500)),
              ]),
            ),
          ],
        ]),
        const SizedBox(height: 12),

        // ── Contenido ─────────────────────────────────────────────────────
        Expanded(
          child: events.isEmpty
              ? Center(
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.history_outlined,
                      size: 56, color: theme.textDisabled),
                  const SizedBox(height: 12),
                  Text('Sin eventos para la selección',
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: theme.textSecondary)),
                ]))
              : isMobile
                  ? _MobileList(events: events, theme: theme)
                  : _DesktopList(events: events, theme: theme),
        ),
      ]),
    );
  }

  void _exportarCsv(List<EventoAuditoria> events) {
    final buffer = StringBuffer();
    buffer.writeln(
        'ID,Timestamp,Usuario,Nivel,Modulo,Accion,Descripcion,ReferenciaId');
    for (final e in events) {
      final desc = e.descripcion.replaceAll('"', '""');
      buffer.writeln(
        '"${e.id}","${formatFechaHora(e.timestamp)}","${e.usuario}","${e.nivel}",'
        '"${e.modulo}","${e.accion}","$desc","${e.referenciaId ?? ''}"',
      );
    }
    final bytes = buffer.toString().codeUnits;
    final blob = html.Blob([bytes], 'text/csv;charset=utf-8');
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement(href: url)
      ..setAttribute(
          'download', 'auditoria_${DateTime.now().millisecondsSinceEpoch}.csv')
      ..click();
    html.Url.revokeObjectUrl(url);
  }
}

// ── Filters bar ───────────────────────────────────────────────────────────────
class _FiltersBar extends StatelessWidget {
  const _FiltersBar({
    required this.prov,
    required this.theme,
    required this.modulos,
    required this.niveles,
    required this.isMobile,
  });
  final AuditoriaProvider prov;
  final AppTheme theme;
  final List<String> modulos;
  final List<String> niveles;
  final bool isMobile;

  static const Map<String, Color> _nivelColor = {
    'nacional': Color(0xFF7A1E3A),
    'estatal': Color(0xFF1D4ED8),
    'municipal': Color(0xFF2D7A4F),
  };

  @override
  Widget build(BuildContext context) {
    final nivelChips = Wrap(spacing: 4, children: [
      ChoiceChip(
        label: const Text('Todos', style: TextStyle(fontSize: 11)),
        selected: prov.filtroNivel == null,
        onSelected: (_) => prov.setFiltroNivel(null),
        selectedColor: theme.primaryColor,
        labelStyle: TextStyle(
            color: prov.filtroNivel == null ? Colors.white : null,
            fontSize: 11),
        side: BorderSide.none,
        padding: const EdgeInsets.symmetric(horizontal: 6),
        visualDensity: VisualDensity.compact,
      ),
      ...niveles.map((n) {
        final c = _nivelColor[n] ?? theme.neutral;
        final sel = prov.filtroNivel == n;
        return ChoiceChip(
          label: Text(_capFirst(n), style: const TextStyle(fontSize: 11)),
          selected: sel,
          onSelected: (_) => prov.setFiltroNivel(sel ? null : n),
          selectedColor: c,
          labelStyle: TextStyle(color: sel ? Colors.white : null, fontSize: 11),
          side: BorderSide.none,
          padding: const EdgeInsets.symmetric(horizontal: 6),
          visualDensity: VisualDensity.compact,
        );
      }),
    ]);

    final moduloDropdown = DropdownButtonHideUnderline(
        child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
          color: theme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: theme.border)),
      child: DropdownButton<String?>(
        value: prov.filtroModulo,
        isDense: true,
        hint: Text('Módulo',
            style: TextStyle(fontSize: 12, color: theme.textSecondary)),
        items: [
          const DropdownMenuItem(
              value: null,
              child: Text('Todos los módulos', style: TextStyle(fontSize: 12))),
          ...modulos.map((m) => DropdownMenuItem(
              value: m, child: Text(m, style: const TextStyle(fontSize: 12)))),
        ],
        onChanged: prov.setFiltroModulo,
        borderRadius: BorderRadius.circular(8),
      ),
    ));

    if (isMobile) {
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        nivelChips,
        const SizedBox(height: 8),
        moduloDropdown,
      ]);
    }
    return Row(children: [
      Text('Nivel:',
          style: TextStyle(
              fontSize: 12,
              color: theme.textSecondary,
              fontWeight: FontWeight.w500)),
      const SizedBox(width: 8),
      nivelChips,
      const SizedBox(width: 16),
      moduloDropdown,
    ]);
  }
}

// ── Desktop list ──────────────────────────────────────────────────────────────
class _DesktopList extends StatelessWidget {
  const _DesktopList({required this.events, required this.theme});
  final List<EventoAuditoria> events;
  final AppTheme theme;

  static const Map<String, Color> _nivelColor = {
    'nacional': Color(0xFF7A1E3A),
    'estatal': Color(0xFF1D4ED8),
    'municipal': Color(0xFF2D7A4F),
  };
  static const Map<String, IconData> _moduloIcon = {
    'Bandeja IA': Icons.smart_toy_outlined,
    'Técnicos': Icons.engineering,
    'Aprobaciones': Icons.approval,
    'Inventario': Icons.inventory_2_outlined,
    'Configuración': Icons.settings_outlined,
    'Usuarios': Icons.people_outline,
    'Reportes': Icons.bar_chart,
    'Órdenes': Icons.assignment_outlined,
    'SLA': Icons.timer_outlined,
    'KPIs': Icons.dashboard_outlined,
    'Supervisión': Icons.monitor_heart_outlined,
    'Catálogos': Icons.category_outlined,
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: theme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.border),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)
          ]),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: ListView.separated(
          itemCount: events.length,
          separatorBuilder: (_, __) =>
              Divider(height: 0, color: theme.border.withOpacity(0.5)),
          itemBuilder: (_, i) {
            final e = events[i];
            final nivelColor = _nivelColor[e.nivel] ?? const Color(0xFF64748B);
            final icon = _moduloIcon[e.modulo] ?? Icons.history;
            return ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              leading: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                    color: nivelColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10)),
                child: Icon(icon, size: 18, color: nivelColor),
              ),
              title: Row(children: [
                Expanded(
                    child: Text('${e.accion} — ${e.modulo}',
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: theme.textPrimary))),
                Text(formatFechaHora(e.timestamp),
                    style: TextStyle(fontSize: 11, color: theme.textSecondary)),
              ]),
              subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Row(children: [
                      _AudBadge(text: _capFirst(e.nivel), color: nivelColor),
                      const SizedBox(width: 6),
                      _AudBadge(text: e.usuario, color: theme.neutral),
                      if (e.referenciaId != null) ...[
                        const SizedBox(width: 6),
                        _AudBadge(text: e.referenciaId!, color: theme.medium),
                      ],
                    ]),
                    const SizedBox(height: 3),
                    Text(e.descripcion,
                        style:
                            TextStyle(fontSize: 12, color: theme.textSecondary),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis),
                  ]),
            );
          },
        ),
      ),
    );
  }
}

// ── Mobile list ───────────────────────────────────────────────────────────────
class _MobileList extends StatelessWidget {
  const _MobileList({required this.events, required this.theme});
  final List<EventoAuditoria> events;
  final AppTheme theme;

  static const Map<String, Color> _nivelColor = {
    'nacional': Color(0xFF7A1E3A),
    'estatal': Color(0xFF1D4ED8),
    'municipal': Color(0xFF2D7A4F),
  };

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: events.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, i) {
        final e = events[i];
        final nivelColor = _nivelColor[e.nivel] ?? const Color(0xFF64748B);
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
              color: theme.surface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: theme.border),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6)
              ]),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              _AudBadge(text: _capFirst(e.nivel), color: nivelColor),
              const SizedBox(width: 6),
              _AudBadge(text: e.modulo, color: theme.neutral),
              const Spacer(),
              Text(formatFechaHora(e.timestamp),
                  style: TextStyle(fontSize: 10, color: theme.textDisabled)),
            ]),
            const SizedBox(height: 8),
            Text(e.accion,
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: theme.textPrimary)),
            const SizedBox(height: 4),
            Text(e.descripcion,
                style: TextStyle(fontSize: 12, color: theme.textSecondary)),
            if (e.referenciaId != null) ...[
              const SizedBox(height: 6),
              Row(children: [
                Icon(Icons.tag, size: 12, color: theme.medium),
                const SizedBox(width: 4),
                Text(e.referenciaId!,
                    style: TextStyle(
                        fontSize: 11,
                        color: theme.medium,
                        fontWeight: FontWeight.w500)),
              ]),
            ],
            const SizedBox(height: 6),
            Row(children: [
              Icon(Icons.person_outline, size: 13, color: theme.textDisabled),
              const SizedBox(width: 4),
              Text(e.usuario,
                  style: TextStyle(fontSize: 11, color: theme.textDisabled)),
            ]),
          ]),
        );
      },
    );
  }
}

// ── Shared ────────────────────────────────────────────────────────────────────
String _capFirst(String s) =>
    s.isEmpty ? s : '${s[0].toUpperCase()}${s.substring(1)}';

class _AudBadge extends StatelessWidget {
  const _AudBadge({required this.text, required this.color});
  final String text;
  final Color color;
  @override
  Widget build(BuildContext context) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
          color: color.withOpacity(0.10),
          borderRadius: BorderRadius.circular(4)),
      child: Text(text,
          style: TextStyle(
              fontSize: 10, color: color, fontWeight: FontWeight.w600)));
}
