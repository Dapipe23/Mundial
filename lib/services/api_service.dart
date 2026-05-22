import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/team.dart';

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
  final String? name;
  final String? email;

  const AuthResult({
    required this.success,
    required this.message,
    this.name,
    this.email,
  });
}

class ApiService {
  static const String baseUrl = 'https://album-panini-furq.vercel.app';
  static const String authBaseUrl = 'https://flutter-production-bdb7.up.railway.app';
  static const String seleccionesPath = '/api/selecciones';
  static const String jugadoresPath = '/api/jugadores';

  static const List<String> _registerPaths = [
    '/api/auth/register',
    '/api/register',
    '/api/usuarios/register',
    '/auth/register',
  ];

  static const List<String> _loginPaths = [
    '/api/auth/login',
    '/api/login',
    '/api/usuarios/login',
    '/auth/login',
  ];

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
    final payload = {
      'name': name,
      'nombre': name,
      'email': email,
      'password': password,
      'contrasena': password,
      'contraseña': password,
    };
    return _postAuth(
      candidatePaths: _registerPaths,
      payload: payload,
      fallbackMessage: 'No fue posible registrar. Verifica la configuración de autenticación del servidor.',
    );
  }

  static Future<AuthResult> loginUser({
    required String email,
    required String password,
  }) async {
    final payload = {
      'email': email,
      'password': password,
      'contrasena': password,
      'contraseña': password,
    };
    return _postAuth(
      candidatePaths: _loginPaths,
      payload: payload,
      fallbackMessage: 'No fue posible iniciar sesión. Verifica la configuración de autenticación del servidor.',
    );
  }

  static Future<AuthResult> _postAuth({
    required List<String> candidatePaths,
    required Map<String, dynamic> payload,
    required String fallbackMessage,
  }) async {
    for (final path in candidatePaths) {
      final uri = Uri.parse(authBaseUrl + path);
      try {
        final resp = await http
            .post(
              uri,
              headers: const {'Content-Type': 'application/json'},
              body: json.encode(payload),
            )
            .timeout(const Duration(seconds: 12));

        final is2xx = resp.statusCode >= 200 && resp.statusCode < 300;
        final decoded = _tryDecodeMap(resp.body);

        if (is2xx) {
          final success = decoded['success'] as bool? ?? true;
          if (!success) {
            continue;
          }
          final nestedUser = decoded['user'] as Map<String, dynamic>?;
          final resolvedName = _pickString([
            nestedUser?['name'],
            nestedUser?['nombre'],
            decoded['name'],
            decoded['nombre'],
          ]);
          final resolvedEmail = _pickString([
            nestedUser?['email'],
            decoded['email'],
          ]);
          final message = _pickString([
                decoded['message'],
                decoded['mensaje'],
              ]) ??
              'Operación completada correctamente.';

          return AuthResult(
            success: true,
            message: message,
            name: resolvedName,
            email: resolvedEmail,
          );
        }
      } catch (_) {
        // try next candidate endpoint
      }
    }

    return AuthResult(success: false, message: fallbackMessage);
  }

  static Map<String, dynamic> _tryDecodeMap(String body) {
    try {
      final decoded = json.decode(body);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
    } catch (_) {
      // ignore parse errors
    }
    return <String, dynamic>{};
  }

  static String? _pickString(List<dynamic> values) {
    for (final value in values) {
      if (value is String && value.trim().isNotEmpty) {
        return value.trim();
      }
    }
    return null;
  }
}
