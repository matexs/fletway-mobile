import 'package:flutter/material.dart';

import '../../data/selector_archivo.dart';

/// Abre un panel inferior para elegir de dónde sale el archivo. Devuelve el
/// origen elegido o null si el usuario lo cierra.
Future<OrigenArchivo?> elegirOrigenArchivo(BuildContext context) =>
    showModalBottomSheet<OrigenArchivo>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final (origen, icono, texto) in const [
              (
                OrigenArchivo.camara,
                Icons.photo_camera_outlined,
                'Sacar una foto'
              ),
              (
                OrigenArchivo.galeria,
                Icons.photo_library_outlined,
                'Elegir de la galería'
              ),
              (
                OrigenArchivo.archivo,
                Icons.description_outlined,
                'Elegir un archivo (PDF, JPG o PNG)'
              ),
            ])
              ListTile(
                leading: Icon(icono),
                title: Text(texto),
                onTap: () => Navigator.of(context).pop(origen),
              ),
          ],
        ),
      ),
    );
