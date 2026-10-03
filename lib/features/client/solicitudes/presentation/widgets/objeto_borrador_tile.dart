import 'package:flutter/material.dart';

import '../../../../../shared/extensions/numeros.dart';
import '../../../../../shared/widgets/icono_objeto.dart';
import '../../application/borrador_solicitud.dart';

/// Un objeto agregado al formulario, con su cantidad editable y la opción de
/// quitarlo.
class ObjetoBorradorTile extends StatelessWidget {
  /// Crea la fila. [onCantidad] recibe la cantidad nueva; [onQuitar] lo saca.
  const ObjetoBorradorTile({
    required this.objeto,
    required this.onCantidad,
    required this.onQuitar,
    super.key,
  });

  /// Objeto del borrador.
  final ObjetoBorrador objeto;

  /// Cambia la cantidad (1 a 100).
  final ValueChanged<int> onCantidad;

  /// Quita el objeto.
  final VoidCallback onQuitar;

  @override
  Widget build(BuildContext context) {
    final colores = Theme.of(context).colorScheme;
    final o = objeto;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: colores.primaryContainer,
        foregroundColor: colores.onPrimaryContainer,
        child: Icon(
          o.catalogo != null ? iconoDeObjeto(o.nombreVisible) : Icons.edit_note,
        ),
      ),
      title: Text(o.nombreVisible),
      subtitle: Text(
        '${(o.pesoUnitario * o.cantidad).legible} kg'
        '${o.catalogo == null ? ' · cargado a mano' : ''}',
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            tooltip: o.cantidad == 1 ? 'Quitar' : 'Uno menos',
            icon: Icon(o.cantidad == 1 ? Icons.delete_outline : Icons.remove),
            onPressed:
                o.cantidad == 1 ? onQuitar : () => onCantidad(o.cantidad - 1),
          ),
          Text('${o.cantidad}'),
          IconButton(
            tooltip: 'Uno más',
            icon: const Icon(Icons.add),
            onPressed:
                o.cantidad >= 100 ? null : () => onCantidad(o.cantidad + 1),
          ),
        ],
      ),
    );
  }
}
