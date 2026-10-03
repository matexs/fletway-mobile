import 'package:fletway_mobile/features/auth/application/validadores.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('email', () {
    for (final (valor, valido) in [
      ('ana@ejemplo.com', true),
      ('  ana@ejemplo.com ', true),
      ('', false),
      ('ana', false),
      ('ana@ejemplo', false),
      ('a na@ejemplo.com', false),
    ]) {
      test('"$valor"', () {
        expect(ValidadoresAuth.email(valor) == null, valido);
      });
    }
  });

  group('telefono', () {
    for (final (valor, valido) in [
      ('1144440000', true),
      ('11 4444-0000', true),
      ('+5491144440000', true),
      ('', false),
      ('1234', false),
      ('11abc44440', false),
    ]) {
      test('"$valor"', () {
        expect(ValidadoresAuth.telefono(valor) == null, valido);
      });
    }
  });

  group('nombreCompleto', () {
    for (final (valor, valido) in [
      ('Ana Pérez', true),
      ('Ana', false),
      ('   ', false),
    ]) {
      test('"$valor"', () {
        expect(ValidadoresAuth.nombreCompleto(valor) == null, valido);
      });
    }
  });

  test('contrasenaNueva exige el largo mínimo', () {
    expect(ValidadoresAuth.contrasenaNueva('1234567'), isNotNull);
    expect(ValidadoresAuth.contrasenaNueva('12345678'), isNull);
  });

  test('confirmacion exige que coincida', () {
    expect(ValidadoresAuth.confirmacion('abc', 'abd'), isNotNull);
    expect(ValidadoresAuth.confirmacion('abc', 'abc'), isNull);
  });

  test('normalizarTelefono quita separadores', () {
    expect(ValidadoresAuth.normalizarTelefono('(11) 4444-0000'), '1144440000');
  });
}
