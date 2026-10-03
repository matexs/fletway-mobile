import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

/// De dónde sale el archivo de un documento.
enum OrigenArchivo {
  /// Foto tomada en el momento.
  camara,

  /// Imagen de la galería.
  galeria,

  /// Archivo del teléfono (pdf, jpg o png).
  archivo,
}

/// Archivo elegido por el Transportista, listo para subir.
@immutable
class ArchivoElegido {
  /// Crea el archivo con su [nombre] original y su contenido.
  const ArchivoElegido({required this.nombre, required this.bytes});

  /// Nombre original, para sacar la extensión.
  final String nombre;

  /// Contenido del archivo.
  final Uint8List bytes;

  /// Extensión en minúscula, sin punto (`pdf`, `jpg`, `png`); vacía si no tiene.
  String get extension {
    final i = nombre.lastIndexOf('.');
    return i < 0 ? '' : nombre.substring(i + 1).toLowerCase();
  }
}

/// Selector de archivos del dispositivo. Se reemplaza en los tests.
final selectorArchivoProvider = Provider<SelectorArchivo>(
  (ref) => SelectorArchivo(),
);

/// Abre la cámara, la galería o el explorador de archivos (D-19: jpg, png o pdf).
class SelectorArchivo {
  /// Crea el selector.
  SelectorArchivo({ImagePicker? imagenes})
      : _imagenes = imagenes ?? ImagePicker();

  final ImagePicker _imagenes;

  /// Abre el selector de [origen]. Devuelve null si el usuario cancela. Las fotos
  /// se reducen (lado mayor de 2000 px, calidad 85) para quedar lejos del límite
  /// de 10 MB.
  Future<ArchivoElegido?> elegir(OrigenArchivo origen) async {
    switch (origen) {
      case OrigenArchivo.camara:
      case OrigenArchivo.galeria:
        final foto = await _imagenes.pickImage(
          source: origen == OrigenArchivo.camara
              ? ImageSource.camera
              : ImageSource.gallery,
          maxWidth: 2000,
          maxHeight: 2000,
          imageQuality: 85,
        );
        if (foto == null) return null;
        return ArchivoElegido(
            nombre: foto.name, bytes: await foto.readAsBytes());
      case OrigenArchivo.archivo:
        final archivo = await FilePicker.pickFile(
          type: FileType.custom,
          allowedExtensions: const ['pdf', 'jpg', 'jpeg', 'png'],
        );
        if (archivo == null) return null;
        return ArchivoElegido(
          nombre: archivo.name,
          bytes: await archivo.xFile.readAsBytes(),
        );
    }
  }
}
