import 'package:fletway_mobile/app/theme.dart';
import 'package:fletway_mobile/shared/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _envolver(Widget hijo) => MaterialApp(
      theme: FletwayTheme.light,
      home: Scaffold(body: hijo),
    );

void main() {
  group('FletwayButton', () {
    testWidgets('cada variante usa su botón de Material', (tester) async {
      const casos = {
        FletwayButtonVariante.primario: FilledButton,
        FletwayButtonVariante.secundario: OutlinedButton,
        FletwayButtonVariante.texto: TextButton,
      };
      for (final caso in casos.entries) {
        await tester.pumpWidget(
          _envolver(
            FletwayButton(
              texto: 'Aceptar',
              onPressed: () {},
              variante: caso.key,
            ),
          ),
        );
        expect(
          find.byWidgetPredicate((w) => w.runtimeType == caso.value),
          findsOneWidget,
          reason: 'variante ${caso.key}',
        );
      }
    });

    testWidgets('dispara onPressed al tocarlo', (tester) async {
      var toques = 0;
      await tester.pumpWidget(
        _envolver(FletwayButton(texto: 'Publicar', onPressed: () => toques++)),
      );
      await tester.tap(find.text('Publicar'));
      expect(toques, 1);
    });

    testWidgets('cargando lo deshabilita y muestra el indicador', (
      tester,
    ) async {
      var toques = 0;
      await tester.pumpWidget(
        _envolver(
          FletwayButton(
            texto: 'Publicar',
            onPressed: () => toques++,
            cargando: true,
          ),
        ),
      );
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await tester.tap(find.text('Publicar'));
      expect(toques, 0);
    });
  });

  group('FletwayTextField', () {
    testWidgets('muestra la etiqueta y valida dentro de un Form', (
      tester,
    ) async {
      final form = GlobalKey<FormState>();
      await tester.pumpWidget(
        _envolver(
          Form(
            key: form,
            child: FletwayTextField(
              etiqueta: 'Email',
              validator: (v) => (v == null || v.isEmpty) ? 'Obligatorio' : null,
            ),
          ),
        ),
      );
      expect(find.text('Email'), findsOneWidget);
      expect(form.currentState!.validate(), isFalse);
      await tester.pump();
      expect(find.text('Obligatorio'), findsOneWidget);

      await tester.enterText(find.byType(TextFormField), 'a@b.com');
      expect(form.currentState!.validate(), isTrue);
    });
  });

  group('FletwayCard', () {
    testWidgets('es tocable sólo si tiene onTap', (tester) async {
      var toques = 0;
      await tester.pumpWidget(
        _envolver(
          FletwayCard(onTap: () => toques++, child: const Text('Oferta')),
        ),
      );
      await tester.tap(find.text('Oferta'));
      expect(toques, 1);

      await tester.pumpWidget(
        _envolver(const FletwayCard(child: Text('Estática'))),
      );
      expect(find.byType(InkWell), findsNothing);
    });
  });

  group('Vistas de estado', () {
    testWidgets('FletwayLoading muestra el mensaje', (tester) async {
      await tester.pumpWidget(
        _envolver(const FletwayLoading(mensaje: 'Cargando')),
      );
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Cargando'), findsOneWidget);
    });

    testWidgets('FletwayErrorView reintenta sólo si hay acción', (
      tester,
    ) async {
      var reintentos = 0;
      await tester.pumpWidget(
        _envolver(
          FletwayErrorView(
            mensaje: 'No se pudo cargar',
            onReintentar: () => reintentos++,
          ),
        ),
      );
      await tester.tap(find.text('Reintentar'));
      expect(reintentos, 1);

      await tester.pumpWidget(
        _envolver(const FletwayErrorView(mensaje: 'No se pudo cargar')),
      );
      expect(find.text('Reintentar'), findsNothing);
    });

    testWidgets('FletwayEmptyView muestra la acción', (tester) async {
      await tester.pumpWidget(
        _envolver(
          FletwayEmptyView(
            mensaje: 'Todavía no publicaste solicitudes',
            accion: FletwayButton(texto: 'Publicar', onPressed: () {}),
          ),
        ),
      );
      expect(find.text('Todavía no publicaste solicitudes'), findsOneWidget);
      expect(find.text('Publicar'), findsOneWidget);
    });
  });
}
