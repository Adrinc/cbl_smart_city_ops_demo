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