import 'package:flutter/material.dart';
import 'package:nethive_neo/helpers/constants.dart';

// ── Cuadrícula responsiva de KPI cards ───────────────────────────────────────
/// En desktop: fila horizontal. En mobile: 2 columnas tipo grid.
class KpiGrid extends StatelessWidget {
  const KpiGrid({super.key, required this.children, this.minColWidth = 160});
  final List<Widget> children;
  final double minColWidth;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, box) {
      final isMobile = box.maxWidth < mobileSize;
      if (isMobile) {
        // 2 columnas en mobile
        final rows = <Widget>[];
        for (var i = 0; i < children.length; i += 2) {
          final a = children[i];
          final b = i + 1 < children.length ? children[i + 1] : const SizedBox();
          rows.add(Row(children: [
            Expanded(child: a),
            const SizedBox(width: 10),
            Expanded(child: b),
          ]));
          if (i + 2 < children.length) rows.add(const SizedBox(height: 10));
        }
        return Column(children: rows);
      }
      // Desktop: fila completa
      final expanded = <Widget>[];
      for (var i = 0; i < children.length; i++) {
        expanded.add(Expanded(child: children[i]));
        if (i < children.length - 1) expanded.add(const SizedBox(width: 12));
      }
      return Row(children: expanded);
    });
  }
}

// ── Layout de dos columnas que apila en mobile ────────────────────────────────
class TwoColumnLayout extends StatelessWidget {
  const TwoColumnLayout({
    super.key,
    required this.left,
    required this.right,
    this.leftFlex = 6,
    this.rightFlex = 4,
    this.gap = 16,
  });
  final Widget left, right;
  final int leftFlex, rightFlex;
  final double gap;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, box) {
      if (box.maxWidth < mobileSize) {
        return Column(children: [left, SizedBox(height: gap), right]);
      }
      return IntrinsicHeight(
        child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Expanded(flex: leftFlex, child: left),
          SizedBox(width: gap),
          Expanded(flex: rightFlex, child: right),
        ]),
      );
    });
  }
}

// ── Accesos rápidos en grid ────────────────────────────────────────────────────  
class QuickAccessGrid extends StatelessWidget {
  const QuickAccessGrid({super.key, required this.children, this.crossAxisCount = 3});
  final List<Widget> children;
  final int crossAxisCount;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, box) {
      final cols = box.maxWidth < mobileSize ? 2 : crossAxisCount;
      return GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: cols,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: box.maxWidth < mobileSize ? 2.0 : 2.4,
        children: children,
      );
    });
  }
}

// ── Tabla vs Cards switcher ───────────────────────────────────────────────────
/// Muestra `tableView` en desktop y `cardView` en mobile.
class TableOrCards extends StatelessWidget {
  const TableOrCards({
    super.key,
    required this.tableView,
    required this.cardView,
  });
  final Widget tableView;
  final Widget cardView;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (_, box) {
      return box.maxWidth < mobileSize ? cardView : tableView;
    });
  }
}
