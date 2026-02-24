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