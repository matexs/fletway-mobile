import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'router.dart';
import 'theme.dart';

/// Idioma de la app: sólo español de Argentina (D-17).
const localeApp = Locale('es', 'AR');

/// Raíz de la app: tema, idioma y router.
class FletwayApp extends ConsumerWidget {
  /// Crea la app.
  const FletwayApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      title: 'Fletway',
      debugShowCheckedModeBanner: false,
      theme: FletwayTheme.light,
      darkTheme: FletwayTheme.dark,
      routerConfig: router,
      locale: localeApp,
      supportedLocales: const [localeApp],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
    );
  }
}
