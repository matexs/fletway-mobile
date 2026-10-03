import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app/app.dart';
import 'core/config/env.dart';
import 'core/supabase/supabase_client.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: '.env');
  // Nombres de días y meses en es-AR para DateFormat (shared/extensions).
  await initializeDateFormatting('es_AR');
  Env.validate();

  await SupabaseInit.ensureInitialized();

  runApp(const ProviderScope(child: FletwayApp()));
}
