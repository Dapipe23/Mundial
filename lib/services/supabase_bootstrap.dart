import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseBootstrap {
  static const _url = 'https://eljahkrsyvpfwlbohfqg.supabase.co';
  static const _anonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImVsamFoa3JzeXZwZndsYm9oZnFnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Nzg3OTgyMTEsImV4cCI6MjA5NDM3NDIxMX0.jgOSnpuu-VpSnjTBvKoBLSgPrY0WqN3za2-Wt--sSY8';

  static Future<void>? _initializationFuture;

  static bool get isConfigured => _url.isNotEmpty && _anonKey.isNotEmpty;

  static bool get hasSession => isReady && Supabase.instance.client.auth.currentSession != null;

  static bool get isReady {
    try {
      Supabase.instance.client;
      return true;
    } catch (_) {
      return false;
    }
  }

  static Future<void> initialize() async {
    await ensureInitialized();
  }

  static Future<void> ensureInitialized() async {
    if (!isConfigured || isReady) {
      return;
    }

    if (_initializationFuture != null) {
      await _initializationFuture;
      return;
    }

    _initializationFuture = Supabase.initialize(
      url: _url,
      anonKey: _anonKey,
    );

    try {
      await _initializationFuture;
    } finally {
      _initializationFuture = null;
    }
  }
}
