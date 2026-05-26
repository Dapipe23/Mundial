import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/team.dart';
import 'supabase_bootstrap.dart';

class JugadoresResponse {
  final bool success;
  final int count;
  final List<Map<String, dynamic>> data;
  final String raw;

  const JugadoresResponse({
    required this.success,
    required this.count,
    required this.data,
    required this.raw,
  });
}

class AuthResult {
  final bool success;
  final String message;
  final String? userId;
  final String? name;
  final String? email;

  const AuthResult({
    required this.success,
    required this.message,
    this.userId,
    this.name,
    this.email,
  });
}

class ApiService {
  static const String baseUrl = 'https://album-panini-furq.vercel.app';
  static const String seleccionesPath = '/api/selecciones';
  static const String jugadoresPath = '/api/jugadores';
  static const String appUsersTable = 'app_users';

  static Future<List<Team>> fetchSelecciones({bool forceRefresh = false}) async {
    final prefs = await SharedPreferences.getInstance();
    final cacheKey = 'cache_selecciones_json_v1';

    if (!forceRefresh) {
      final cached = prefs.getString(cacheKey);
      if (cached != null && cached.isNotEmpty) {
        try {
          final decoded = json.decode(cached) as Map<String, dynamic>;
          final data = decoded['data'] as List<dynamic>;
          return data.map((e) => Team.fromJson(e as Map<String, dynamic>)).toList();
        } catch (_) {
          // ignore cache parsing errors and fetch remotely
        }
      }
    }

    final uri = Uri.parse(baseUrl + seleccionesPath);
    try {
      final resp = await http.get(uri).timeout(const Duration(seconds: 10));
      if (resp.statusCode == 200) {
        prefs.setString(cacheKey, resp.body);
        final decoded = json.decode(resp.body) as Map<String, dynamic>;
        final data = decoded['data'] as List<dynamic>;
        return data.map((e) => Team.fromJson(e as Map<String, dynamic>)).toList();
      }
    } catch (e) {
      // network error - fall through to cached handling below
    }

    // fallback to cached data if available
    final cached = prefs.getString(cacheKey);
    if (cached != null && cached.isNotEmpty) {
      final decoded = json.decode(cached) as Map<String, dynamic>;
      final data = decoded['data'] as List<dynamic>;
      return data.map((e) => Team.fromJson(e as Map<String, dynamic>)).toList();
    }

    // if no data, return empty list
    return <Team>[];
  }

  static Future<List<Map<String, dynamic>>> fetchJugadores({String? seleccionId}) async {
    final response = await fetchJugadoresResponse(seleccionId: seleccionId);
    return response.data;
  }

  static Future<JugadoresResponse> fetchJugadoresResponse({String? seleccionId}) async {
    final uri = Uri.parse(baseUrl + jugadoresPath + (seleccionId != null ? '?seleccion_id=$seleccionId' : ''));
    try {
      final resp = await http.get(uri).timeout(const Duration(seconds: 10));
      if (resp.statusCode == 200) {
        final raw = resp.body;
        final decoded = json.decode(raw) as Map<String, dynamic>;
        final success = decoded['success'] as bool? ?? false;
        final count = int.tryParse(decoded['count']?.toString() ?? '0') ?? 0;
        final data = (decoded['data'] as List<dynamic>?)?.map((e) => e as Map<String, dynamic>).toList() ?? <Map<String, dynamic>>[];
        return JugadoresResponse(success: success, count: count, data: data, raw: raw);
      }
    } catch (_) {}
    return const JugadoresResponse(success: false, count: 0, data: <Map<String, dynamic>>[], raw: '');
  }

  static Future<AuthResult> registerUser({
    required String name,
    required String email,
    required String password,
  }) async {
    return _registerWithSupabase(name: name, email: email, password: password);
  }

  static Future<AuthResult> loginUser({
    required String email,
    required String password,
  }) async {
    return _loginWithSupabase(email: email, password: password);
  }

  static String? _pickString(List<dynamic> values) {
    for (final value in values) {
      if (value is String && value.trim().isNotEmpty) {
        return value.trim();
      }
    }
    return null;
  }

  static Future<AuthResult> _registerWithSupabase({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      await SupabaseBootstrap.ensureInitialized();

      final existing = await Supabase.instance.client
          .from(appUsersTable)
          .select('id')
          .eq('email', email)
          .maybeSingle();

      if (existing != null) {
        return const AuthResult(
          success: false,
          message: 'Ese correo ya existe. Inicia sesión con esa cuenta.',
        );
      }

      final inserted = await Supabase.instance.client
          .from(appUsersTable)
          .insert({
            'full_name': name,
            'email': email,
            'password': password,
          })
          .select('id, full_name, email')
          .single();

      return AuthResult(
        success: true,
        message: 'Cuenta creada correctamente.',
        userId: inserted['id']?.toString(),
        name: inserted['full_name'] as String? ?? name,
        email: inserted['email'] as String? ?? email,
      );
    } catch (e) {
      return AuthResult(
        success: false,
        message: 'Error al registrar en Supabase: ${e.toString()}',
      );
    }
  }

  static Future<AuthResult> _loginWithSupabase({
    required String email,
    required String password,
  }) async {
    try {
      await SupabaseBootstrap.ensureInitialized();
      final user = await Supabase.instance.client
          .from(appUsersTable)
          .select('id, full_name, email')
          .eq('email', email)
          .eq('password', password)
          .maybeSingle();

      if (user == null) {
        return const AuthResult(
          success: false,
          message: 'Correo o contraseña incorrectos.',
        );
      }

      final name = _pickString([
        user['full_name'],
      ]);

      return AuthResult(
        success: true,
        message: 'Inicio de sesión exitoso.',
        userId: user['id']?.toString(),
        name: name,
        email: user['email'] as String? ?? email,
      );
    } catch (e) {
      return AuthResult(
        success: false,
        message: 'Error al iniciar sesión con Supabase: ${e.toString()}',
      );
    }
  }
}
