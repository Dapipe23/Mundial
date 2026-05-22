# album_panini

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Configurar Login/Register con Supabase

La app ahora soporta autenticacion con Supabase para registro e inicio de sesion.

1. Crea un proyecto en Supabase.
2. En **Authentication > Providers**, habilita **Email**.
3. Copia estos valores desde **Project Settings > API**:
	- `Project URL`
	- `anon public key`
4. Ejecuta la app con `--dart-define`:

```bash
flutter run --dart-define=SUPABASE_URL=TU_PROJECT_URL --dart-define=SUPABASE_ANON_KEY=TU_ANON_KEY
```

Notas:
- Si activas confirmacion por correo en Supabase, al registrarte veras un mensaje para confirmar email antes de iniciar sesion.
- Esta app usa autenticacion solo con Supabase.

## Usuarios de prueba en Supabase

Si quieres probar login y registro sin correo de confirmacion, usa esta tabla:

1. Abre Supabase > SQL Editor.
2. Ejecuta el script [supabase/app_users_schema.sql](supabase/app_users_schema.sql).

Que hace ese SQL:
- Crea la tabla `public.app_users` para usuarios de prueba.
- Guarda `full_name`, `email` y `password`.
- Permite que la app registre e inicie sesion desde el cliente.

La app ya esta conectada para:
- Registrar usuarios en `app_users`.
- Iniciar sesion comparando email y password en `app_users`.
