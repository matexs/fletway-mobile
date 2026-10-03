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

  group('FletwayTextField.decimal', () {
    testWidgets('sólo deja números con hasta 2 decimales', (tester) async {
      final c = TextEditingController();
      await tester.pumpWidget(
        _envolver(FletwayTextField.decimal(etiqueta: 'Largo', controller: c)),
      );
      await tester.enterText(find.byType(TextFormField), '2,456abc');
      expect(c.text, '2,45');
      expect(FletwayTextField.leerDecimal(c.text), 2.45);
    });

    test('leerDecimal acepta coma o punto', () {
      expect(FletwayTextField.leerDecimal('1350,5'), 1350.5);
      expect(FletwayTextField.leerDecimal('1350.5'), 1350.5);
      expect(FletwayTextField.leerDecimal(' '), isNull);
    });
  });

  testWidgets('FletwaySelector avisa la opción elegida', (tester) async {
    String? elegido;
    await tester.pumpWidget(
      _envolver(
        FletwaySelector<String>(
          etiqueta: 'Tipo',
          opciones: const [
            FletwayOpcion(valor: 'a', texto: 'Utilitario'),
            FletwayOpcion(valor: 'b', texto: 'Camión chico'),
          ],
          onChanged: (v) => elegido = v,
        ),
      ),
    );
    await tester.tap(find.text('Tipo'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Camión chico').last);
    await tester.pumpAndSettle();
    expect(elegido, 'b');
  });
}
