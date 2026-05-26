import 'package:flutter/material.dart';

import '../models/models.dart';
import '../services/album_data.dart';
import '../services/api_service.dart';
import 'album_home_screen.dart';
import 'login_screen.dart';
import 'widgets/world_auth_shell.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
    });

    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    final auth = await ApiService.registerUser(name: name, email: email, password: password);

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
      name: auth.name ?? name,
      email: auth.email ?? email,
    );

    final albumData = await AlbumData.create(user);

    if (!mounted) return;

    setState(() {
      _isSubmitting = false;
    });

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => AlbumHomeScreen(albumData: albumData)),
      (route) => false,
    );
  }

  int _passwordStrength(String value) {
    var score = 0;
    if (value.length >= 8) score++;
    if (RegExp(r'[A-Z]').hasMatch(value)) score++;
    if (RegExp(r'[0-9]').hasMatch(value)) score++;
    if (RegExp(r'[^A-Za-z0-9]').hasMatch(value)) score++;
    return score;
  }

  @override
  Widget build(BuildContext context) {
    const accent = Color(0xFF16A34A);
    const accentGlow = Color(0xFF86EFAC);
    final strength = _passwordStrength(_passwordController.text);

    return WorldAuthShell(
      title: 'Crea tu cuenta',
      subtitle: 'Regístrate y empieza a completar tu álbum con un estilo mundialista.',
      accentColor: accent,
      icon: Icons.workspace_premium,
      chips: const ['Registro rápido', 'Protección de cuenta', 'Modo coleccionista'],
      formContent: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Completa tus datos para desbloquear tu panel de colección.',
              style: TextStyle(color: Color(0xFFD8E5FF), fontSize: 14),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _nameController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Nombre completo',
                prefixIcon: Icon(Icons.person_outline),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Ingresa tu nombre';
                }
                return null;
              },
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
                if (value.trim().length < 8) {
                  return 'Usa al menos 8 caracteres';
                }
                return null;
              },
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 10),
            _StrengthIndicator(score: strength),
            const SizedBox(height: 14),
            TextFormField(
              controller: _confirmPasswordController,
              obscureText: _obscureConfirmPassword,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Confirmar contraseña',
                prefixIcon: const Icon(Icons.verified_user_outlined),
                suffixIcon: IconButton(
                  onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                  icon: Icon(_obscureConfirmPassword ? Icons.visibility : Icons.visibility_off),
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Confirma la contraseña';
                }
                if (value.trim() != _passwordController.text.trim()) {
                  return 'Las contraseñas no coinciden';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [accent, Color(0xFFF59E0B)]),
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
                onPressed: _isSubmitting ? null : _register,
                icon: _isSubmitting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.person_add_alt_1),
                label: Text(_isSubmitting ? 'Creando cuenta...' : 'Crear cuenta y entrar'),
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
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  );
                },
                child: const Text(
                  '¿Ya tienes cuenta? Volver al login',
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

class _StrengthIndicator extends StatelessWidget {
  final int score;

  const _StrengthIndicator({required this.score});

  @override
  Widget build(BuildContext context) {
    final labels = ['Muy débil', 'Débil', 'Aceptable', 'Fuerte', 'Premium'];
    final tones = [
      const Color(0xFFE04646),
      const Color(0xFFE58D3D),
      const Color(0xFFD0A524),
      const Color(0xFF57A746),
      const Color(0xFF0B6E4F),
    ];

    final index = score.clamp(0, 4);

    return Row(
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              minHeight: 8,
              value: index / 4,
              backgroundColor: const Color(0xFF233047),
              valueColor: AlwaysStoppedAnimation<Color>(tones[index]),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          labels[index],
          style: TextStyle(color: tones[index], fontWeight: FontWeight.w700, fontSize: 12.5),
        ),
      ],
    );
  }
}
