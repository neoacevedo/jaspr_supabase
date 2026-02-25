import 'package:jaspr/jaspr.dart';
import 'package:jaspr_supabase/jaspr_supabase.dart';

import 'components/app.dart';

Future<void> main() async {
  // Initialize Supabase before running the app
  await Supabase.initialize(
    url: 'https://xyz.supabase.co', // Replace with your project URL
    anonKey: 'public-anon-key', // Replace with your anon key
  );

  runApp(App());
}
