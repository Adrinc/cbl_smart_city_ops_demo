import 'package:flutter/material.dart';
import 'package:nethive_neo/data/mock_data.dart';
import 'package:nethive_neo/helpers/formatters.dart';
import 'package:nethive_neo/models/models.dart';
import 'package:nethive_neo/theme/theme.dart';
import 'package:nethive_neo/widgets/shared/responsive_layout.dart';
import 'package:nethive_neo/widgets/shared/section_header.dart';
import 'package:pluto_grid/pluto_grid.dart';

class UsuariosPage extends StatefulWidget {
  const UsuariosPage({super.key});
  @override
  State<UsuariosPage> createState() => _UsuariosPageState();
}

class _UsuariosPageState extends State<UsuariosPage> {
  List<UsuarioSistema> _users = List.from(mockUsuarios);

  void _addUser(UsuarioSistema u) => setState(() => _users.add(u));

  List<PlutoColumn> _cols(AppTheme t) => [
    PlutoColumn(title: 'Usuario', field: 'nombre', type: PlutoColumnType.text(), width: 180,
      renderer: (r) {
        final u = _users.firstWhere((u) => u.nombre == r.cell.value, orElse: () => _users.first);
        return Row(children: [
          CircleAvatar(radius: 14, backgroundColor: t.primaryColor.withOpacity(0.12),
            backgroundImage: u.avatarPath != null ? AssetImage(u.avatarPath!) : null,
            child: u.avatarPath == null ? Text(u.iniciales, style: TextStyle(fontSize: 9, color: t.primaryColor, fontWeight: FontWeight.w700)) : null),
          const SizedBox(width: 8),
          Expanded(child: Text(u.nombre, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: t.textPrimary),
            overflow: TextOverflow.ellipsis)),
        ]);
      }),
    PlutoColumn(title: 'Email', field: 'email', type: PlutoColumnType.text(), width: 200,
      renderer: (r) => Text(r.cell.value, style: TextStyle(fontSize: 12, color: t.textSecondary))),
    PlutoColumn(title: 'Rol', field: 'rol', type: PlutoColumnType.text(), width: 140,
      renderer: (r) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(color: t.primarySoft, borderRadius: BorderRadius.circular(6)),
        child: Text((r.cell.value as String).replaceAll('_', ' '),
          style: TextStyle(fontSize: 11, color: t.primaryColor, fontWeight: FontWeight.w600)))),
    PlutoColumn(title: 'Nivel', field: 'nivel', type: PlutoColumnType.text(), width: 100,
      renderer: (r) => Text(_capitalizar(r.cell.value), style: TextStyle(fontSize: 12, color: t.textPrimary))),
    PlutoColumn(title: 'Estatus', field: 'estatus', type: PlutoColumnType.text(), width: 100,
      renderer: (r) {
        final active = r.cell.value == 'activo';
        final c = active ? t.low : t.neutral;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(color: c.withOpacity(0.12), borderRadius: BorderRadius.circular(6)),
          child: Text(active ? 'Activo' : 'Inactivo', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: c)));
      }),
    PlutoColumn(title: 'Último acceso', field: 'ultimo_acceso', type: PlutoColumnType.text(), width: 200,
      renderer: (r) => Text(r.cell.value, style: TextStyle(fontSize: 11, color: t.textSecondary))),
    PlutoColumn(title: 'Acciones', field: 'acciones', type: PlutoColumnType.text(), width: 100,
      enableSorting: false,
      renderer: (r) => Row(mainAxisSize: MainAxisSize.min, children: [
        IconButton(icon: Icon(Icons.edit_outlined, size: 16, color: t.textSecondary), onPressed: () {}, tooltip: 'Editar',
          padding: EdgeInsets.zero, constraints: const BoxConstraints(minWidth: 28, minHeight: 28)),
        IconButton(icon: Icon(Icons.block_outlined, size: 16, color: t.high), onPressed: () {}, tooltip: 'Desactivar',
          padding: EdgeInsets.zero, constraints: const BoxConstraints(minWidth: 28, minHeight: 28)),
      ])),
  ];

  List<PlutoRow> _rows() => _users.map((u) => PlutoRow(cells: {
    'nombre':        PlutoCell(value: u.nombre),
    'email':         PlutoCell(value: u.email),
    'rol':           PlutoCell(value: u.rol),
    'nivel':         PlutoCell(value: u.nivel),
    'estatus':       PlutoCell(value: u.estatus),
    'ultimo_acceso': PlutoCell(value: formatFechaHora(u.ultimoAcceso)),
    'acciones':      PlutoCell(value: ''),
  })).toList();

  static String _capitalizar(String s) => s.isEmpty ? s : '${s[0].toUpperCase()}${s.substring(1)}';

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SectionHeader(
          title: 'Usuarios del Sistema',
          subtitle: '${_users.length} usuarios registrados',
          trailing: FilledButton.icon(
            onPressed: () async {
              final result = await showDialog<UsuarioSistema>(
                context: context,
                builder: (_) => const _NuevoUsuarioDialog(),
              );
              if (result != null) _addUser(result);
            },
            icon: const Icon(Icons.person_add, size: 16),
            label: const Text('Nuevo Usuario'),
            style: FilledButton.styleFrom(backgroundColor: theme.primaryColor),
          ),
        ),
        const SizedBox(height: 20),
        Expanded(child: TableOrCards(
          tableView: _TableView(cols: _cols(theme), rows: _rows(), theme: theme),
          cardView: _MobileCardList(users: _users, theme: theme),
        )),
      ]),
    );
  }
}

// ── PlutoGrid Table ───────────────────────────────────────────────────────────
class _TableView extends StatelessWidget {
  const _TableView({required this.cols, required this.rows, required this.theme});
  final List<PlutoColumn> cols;
  final List<PlutoRow> rows;
  final AppTheme theme;
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: theme.surface, borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.border),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)]),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: PlutoGrid(
          columns: cols, rows: rows,
          onLoaded: (e) => e.stateManager.setPageSize(20, notify: false),
          createFooter: (s) => PlutoPagination(s),
          configuration: PlutoGridConfiguration(
            style: PlutoGridStyleConfig(
              gridBorderColor: theme.border, gridBackgroundColor: theme.surface,
              rowColor: theme.surface, activatedColor: theme.primaryColor.withOpacity(0.08),
              activatedBorderColor: theme.primaryColor, columnHeight: 40, rowHeight: 46,
              columnTextStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: theme.textSecondary),
            ),
            columnSize: const PlutoGridColumnSizeConfig(autoSizeMode: PlutoAutoSizeMode.scale),
          ),
        ),
      ),
    );
  }
}

// ── Mobile Card List ──────────────────────────────────────────────────────────
class _MobileCardList extends StatelessWidget {
  const _MobileCardList({required this.users, required this.theme});
  final List<UsuarioSistema> users;
  final AppTheme theme;
  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: users.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, i) {
        final u = users[i];
        final isActive = u.estatus == 'activo';
        final sc = isActive ? theme.low : theme.neutral;
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: theme.surface, borderRadius: BorderRadius.circular(12),
            border: Border.all(color: theme.border),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)]),
          child: Row(children: [
            CircleAvatar(radius: 22, backgroundColor: theme.primaryColor.withOpacity(0.12),
              backgroundImage: u.avatarPath != null ? AssetImage(u.avatarPath!) : null,
              child: u.avatarPath == null ? Text(u.iniciales, style: TextStyle(fontSize: 12, color: theme.primaryColor, fontWeight: FontWeight.w700)) : null),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(u.nombre, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: theme.textPrimary)),
              Text(u.email, style: TextStyle(fontSize: 11, color: theme.textSecondary)),
              const SizedBox(height: 4),
              Row(children: [
                Container(padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(color: theme.primarySoft, borderRadius: BorderRadius.circular(5)),
                  child: Text(u.rol.replaceAll('_', ' '), style: TextStyle(fontSize: 10, color: theme.primaryColor, fontWeight: FontWeight.w600))),
                const SizedBox(width: 6),
                Container(padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(color: sc.withOpacity(0.12), borderRadius: BorderRadius.circular(5)),
                  child: Text(isActive ? 'Activo' : 'Inactivo', style: TextStyle(fontSize: 10, color: sc, fontWeight: FontWeight.w600))),
              ]),
            ])),
            IconButton(icon: Icon(Icons.edit_outlined, size: 18, color: theme.textSecondary), onPressed: () {}),
          ]),
        );
      },
    );
  }
}

// ─────────────────────── DIÁLOGO NUEVO USUARIO ───────────────────────────────
class _NuevoUsuarioDialog extends StatefulWidget {
  const _NuevoUsuarioDialog();
  @override
  State<_NuevoUsuarioDialog> createState() => _NuevoUsuarioDialogState();
}

class _NuevoUsuarioDialogState extends State<_NuevoUsuarioDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nombre  = TextEditingController();
  final _email   = TextEditingController();
  final _pass    = TextEditingController();
  String _rol     = 'operador_municipal';
  String _nivel   = 'municipal';
  bool  _obscure  = true;

  static const _roles   = ['admin', 'operador_municipal', 'operador_estatal', 'operador_nacional', 'supervisor'];
  static const _niveles = ['municipal', 'estatal', 'nacional'];

  @override
  void dispose() {
    _nombre.dispose(); _email.dispose(); _pass.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: isMobile ? double.infinity : 520),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Form(
            key: _formKey,
            child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
              // Header
              Row(children: [
                Container(width: 40, height: 40, decoration: BoxDecoration(
                  color: theme.primaryColor.withOpacity(0.12), shape: BoxShape.circle),
                  child: Icon(Icons.person_add_outlined, color: theme.primaryColor, size: 20)),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Nuevo Usuario', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: theme.textPrimary)),
                  Text('Los cambios son temporales en esta demo', style: TextStyle(fontSize: 11, color: theme.textSecondary)),
                ])),
                IconButton(icon: Icon(Icons.close, size: 18, color: theme.textSecondary), onPressed: () => Navigator.pop(context)),
              ]),
              const SizedBox(height: 22),
              Divider(color: theme.border),
              const SizedBox(height: 18),

              // Nombre
              _Label('Nombre completo', theme),
              const SizedBox(height: 6),
              _Field(controller: _nombre, hint: 'Ej. María García López',
                icon: Icons.person_outline, theme: theme,
                validator: (v) => (v == null || v.isEmpty) ? 'Requerido' : null),
              const SizedBox(height: 14),

              // Email
              _Label('Correo electrónico', theme),
              const SizedBox(height: 6),
              _Field(controller: _email, hint: 'Ej. m.garcia@ensenada.gob.mx',
                icon: Icons.email_outlined, theme: theme,
                keyboardType: TextInputType.emailAddress,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Requerido';
                  if (!v.contains('@')) return 'Email inválido';
                  return null;
                }),
              const SizedBox(height: 14),

              // Rol + Nivel (lado a lado en desktop)
              isMobile
                ? Column(children: [
                    _DropRow('Rol', _roles, _rol, theme, (v) => setState(() => _rol = v!), _rolLabel),
                    const SizedBox(height: 14),
                    _DropRow('Nivel de acceso', _niveles, _nivel, theme, (v) => setState(() => _nivel = v!), _nivelLabel),
                  ])
                : Row(children: [
                    Expanded(child: _DropRow('Rol', _roles, _rol, theme, (v) => setState(() => _rol = v!), _rolLabel)),
                    const SizedBox(width: 14),
                    Expanded(child: _DropRow('Nivel de acceso', _niveles, _nivel, theme, (v) => setState(() => _nivel = v!), _nivelLabel)),
                  ]),
              const SizedBox(height: 14),

              // Contraseña temporal
              _Label('Contraseña temporal', theme),
              const SizedBox(height: 6),
              TextFormField(
                controller: _pass,
                obscureText: _obscure,
                decoration: InputDecoration(
                  hintText: 'Mínimo 8 caracteres',
                  hintStyle: TextStyle(fontSize: 12, color: theme.textSecondary),
                  prefixIcon: Icon(Icons.lock_outline, size: 16, color: theme.textSecondary),
                  suffixIcon: IconButton(
                    icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined, size: 16, color: theme.textSecondary),
                    onPressed: () => setState(() => _obscure = !_obscure)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: theme.border)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: theme.border)),
                  filled: true, fillColor: theme.background,
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Requerida';
                  if (v.length < 8) return 'Mínimo 8 caracteres';
                  return null;
                },
              ),
              const SizedBox(height: 6),
              Text('El usuario deberá cambiarla en su primer inicio de sesión.',
                style: TextStyle(fontSize: 11, color: theme.textSecondary, fontStyle: FontStyle.italic)),
              const SizedBox(height: 24),
              Divider(color: theme.border),
              const SizedBox(height: 16),

              // Actions
              Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                  style: OutlinedButton.styleFrom(foregroundColor: theme.textSecondary, side: BorderSide(color: theme.border))),
                const SizedBox(width: 10),
                FilledButton.icon(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      Navigator.pop(context, UsuarioSistema(
                        id: 'u_${DateTime.now().millisecondsSinceEpoch}',
                        nombre: _nombre.text.trim(),
                        email: _email.text.trim(),
                        rol: _rol, nivel: _nivel,
                        estatus: 'activo',
                        ultimoAcceso: DateTime.now(),
                      ));
                    }
                  },
                  icon: const Icon(Icons.check, size: 16),
                  label: const Text('Crear Usuario'),
                  style: FilledButton.styleFrom(backgroundColor: theme.primaryColor)),
              ]),
            ]),
          ),
        ),
      ),
    );
  }

  static String _rolLabel(String r) {
    const m = {
      'admin': 'Administrador',
      'operador_municipal': 'Op. Municipal',
      'operador_estatal': 'Op. Estatal',
      'operador_nacional': 'Op. Nacional',
      'supervisor': 'Supervisor',
    };
    return m[r] ?? r;
  }
  static String _nivelLabel(String n) {
    const m = {'municipal': 'Municipal', 'estatal': 'Estatal', 'nacional': 'Nacional'};
    return m[n] ?? n;
  }
}

Widget _DropRow(String label, List<String> opts, String val, AppTheme theme,
    ValueChanged<String?> onChange, String Function(String) labelFn) {
  return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    _Label(label, theme),
    const SizedBox(height: 6),
    Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: theme.background, borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.border)),
      child: DropdownButtonHideUnderline(child: DropdownButton<String>(
        value: val, isExpanded: true,
        items: opts.map((o) => DropdownMenuItem(value: o, child: Text(labelFn(o), style: TextStyle(fontSize: 13)))).toList(),
        onChanged: onChange,
      )),
    ),
  ]);
}

class _Label extends StatelessWidget {
  const _Label(this.text, this.theme);
  final String text;
  final AppTheme theme;
  @override
  Widget build(BuildContext context) => Text(text,
    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: theme.textSecondary));
}

class _Field extends StatelessWidget {
  const _Field({required this.controller, required this.hint, required this.icon,
    required this.theme, this.validator, this.keyboardType});
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final AppTheme theme;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  @override
  Widget build(BuildContext context) => TextFormField(
    controller: controller,
    keyboardType: keyboardType,
    validator: validator,
    decoration: InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(fontSize: 12, color: theme.textSecondary),
      prefixIcon: Icon(icon, size: 16, color: theme.textSecondary),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: theme.border)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: theme.border)),
      filled: true, fillColor: theme.background,
    ),
  );
}
