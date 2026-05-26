import 'package:flutter/material.dart';

import '../models/models.dart';
import '../services/album_data.dart';
import '../services/api_service.dart';
import 'album_home_screen.dart';
import 'register_screen.dart';
import 'widgets/world_auth_shell.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
    });

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    final auth = await ApiService.loginUser(email: email, password: password);

    if (!mounted) return;

    if (!auth.success) {
      setState(() {
        _isSubmitting = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(auth.message)));
      return;
    }

    final user = User(
      id: auth.userId ?? '',
      name: auth.name ?? 'Coleccionista',
      email: auth.email ?? email,
    );

    final albumData = await AlbumData.create(user);

    if (!mounted) return;

    setState(() {
      _isSubmitting = false;
    });

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => AlbumHomeScreen(albumData: albumData)),
    );
  }

  @override
  Widget build(BuildContext context) {
    const accent = Color(0xFF2563EB);
    const accentGlow = Color(0xFF67E8F9);

    return WorldAuthShell(
      title: 'Bienvenido de vuelta',
      subtitle: 'Accede a tu progreso de colección con una experiencia mundialista vibrante.',
      accentColor: accent,
      icon: Icons.sports_soccer,
      chips: const ['Modo torneo', 'Colección sincronizada', 'Login seguro'],
      formContent: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Inicia sesión con tu correo y contraseña.',
              style: TextStyle(color: Color(0xFFD8E5FF), fontSize: 14),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Correo electrónico',
                prefixIcon: Icon(Icons.alternate_email),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Ingresa tu correo';
                }
                const emailPattern = r'^[^@]+@[^@]+\.[^@]+';
                if (!RegExp(emailPattern).hasMatch(value.trim())) {
                  return 'Correo no válido';
                }
                return null;
              },
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Contraseña',
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Ingresa tu contraseña';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [accent, Color(0xFF7C3AED)]),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: accentGlow.withValues(alpha: 0.24),
                    blurRadius: 24,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: FilledButton.icon(
                onPressed: _isSubmitting ? null : _login,
                icon: _isSubmitting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.login),
                label: Text(_isSubmitting ? 'Conectando...' : 'Entrar al álbum'),
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  shadowColor: Colors.transparent,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const RegisterScreen()),
                  );
                },
                child: const Text(
                  '¿No tienes cuenta? Crear cuenta ahora',
                  style: TextStyle(color: Color(0xFFE6F0FF), fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
