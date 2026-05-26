class User {
  final String id;
  final String name;
  final String email;

  const User({this.id = '', required this.name, required this.email});

  String get storageKey {
    final source = id.trim().isNotEmpty ? id.trim() : email.trim().toLowerCase();
    return source.replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_');
  }
}
