import 'package:supabase_flutter/supabase_flutter.dart';

const _supabaseUrl = 'https://dnxgoskgttvevvsqouhk.supabase.co';
const _supabaseAnonKey =
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImRueGdvc2tndHR2ZXZ2c3FvdWhrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzcyOTA1NTUsImV4cCI6MjA5Mjg2NjU1NX0.dtG0dl8GPGqvTP3ulcUPfgXJjRMgbkEe_sX1m7u7-Qs';

class SupabaseUtils {
  static void initialize() {
    Supabase.initialize(url: _supabaseUrl, anonKey: _supabaseAnonKey);
  }
}
