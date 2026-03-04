import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';

Future<void> initSupabase() async {
  await Supabase.initialize(
    url: SupabaseConfig.url,
    anonKey: SupabaseConfig.anonKey,
  );
}

SupabaseClient get supabase => Supabase.instance.client;
