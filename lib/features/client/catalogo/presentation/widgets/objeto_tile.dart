import 'package:flutter/material.dart';

import '../../../../../shared/extensions/numeros.dart';
import '../../data/objeto_dto.dart';
import 'icono_objeto.dart';

/// Un objeto del catálogo con sus medidas, peso y restricciones de carga.
class ObjetoTile extends StatelessWidget {
  /// Crea la fila. [onTap] se dispara al elegirlo.
  const ObjetoTile({required this.objeto, this.onTap, super.key});

  /// Objeto a mostrar.
  final ObjetoCatalogo objeto;

  /// Acción al tocarlo; null la deja sólo de lectura.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final o = objeto;
    final restricciones = [
      if (!o.rotacionVertical) 'no se acuesta',
      if (!o.apilable) 'sin carga encima',
    ];
    final colores = Theme.of(context).colorScheme;
    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(
        backgroundColor: colores.primaryContainer,
        foregroundColor: colores.onPrimaryContainer,
        child: Icon(iconoDeObjeto(o.nombre)),
      ),
      title: Text(o.nombre),
      subtitle: Text(
        '${o.largoM.paraCampo} × ${o.anchoM.paraCampo} × ${o.altoM.paraCampo} m'
        ' · ${o.pesoEstimadoKg.legible} kg'
        '${restricciones.isEmpty ? '' : '\n${restricciones.join(' · ')}'}',
      ),
      isThreeLine: restricciones.isNotEmpty,
    );
  }
}
