class Player {
  final String id;
  final String name;
  final int number;
  final int age;
  final String teamId;
  final String apiPlayerId;
  final String position;
  final String club;
  final String photoUrl;
  final String birthDate;
  final String height;
  final String weight;
  final int dribbling;
  final int speed;
  final int shooting;
  final int defending;
  final int passing;
  final int physical;

  const Player({
    required this.id,
    required this.name,
    required this.number,
    required this.age,
    required this.teamId,
    required this.apiPlayerId,
    required this.position,
    required this.club,
    required this.photoUrl,
    required this.birthDate,
    required this.height,
    required this.weight,
    required this.dribbling,
    required this.speed,
    required this.shooting,
    required this.defending,
    required this.passing,
    required this.physical,
  });

  String get apiSportsPhotoUrl {
    if (apiPlayerId.isEmpty) return '';
    return 'https://media.api-sports.io/football/players/$apiPlayerId.png';
  }

  bool get hasOfficialApiPhoto {
    final raw = apiSportsPhotoUrl.trim();
    return raw.isNotEmpty;
  }

  String get displayPhotoUrl {
    if (hasOfficialApiPhoto) {
      return apiSportsPhotoUrl;
    }

    final raw = photoUrl.trim();
    if (raw.contains('media.api-sports.io/football/players/')) {
      return raw;
    }

    return '';
  }

  static String _pickPhotoUrl(Map<String, dynamic> json) {
    final nestedPlayer = json['player'];
    final nestedPhoto = nestedPlayer is Map<String, dynamic> ? nestedPlayer['photo'] : null;
    final apiPlayerId = _pickApiPlayerId(json);

    final apiSportsUrl = apiPlayerId.isNotEmpty
        ? 'https://media.api-sports.io/football/players/$apiPlayerId.png'
        : '';

    final candidates = [
      nestedPhoto,
      apiSportsUrl,
      json['photo'],
      json['foto_url'],
      json['photo_url'],
      json['imagen'],
      json['foto'],
      json['imagen_url'],
      json['image_url'],
      json['image'],
      json['avatar'],
    ];

    for (final value in candidates) {
      final raw = value?.toString().trim() ?? '';
      if (raw.isEmpty) continue;
      if (raw.startsWith('//')) {
        return 'https:$raw';
      }
      return raw;
    }

    return '';
  }

  static String _pickApiPlayerId(Map<String, dynamic> json) {
    final nestedPlayer = json['player'];
    final nestedId = nestedPlayer is Map<String, dynamic> ? nestedPlayer['id'] : null;
    final rawId = json['id'];

    String? numericRootId;
    if (rawId != null) {
      final candidate = rawId.toString().trim();
      if (RegExp(r'^\d+$').hasMatch(candidate)) {
        numericRootId = candidate;
      }
    }

    final candidates = [
      json['api_player_id'],
      json['apiPlayerId'],
      json['player_id'],
      json['api_sports_player_id'],
      numericRootId,
      nestedId,
    ];

    for (final value in candidates) {
      final raw = value?.toString().trim() ?? '';
      if (raw.isNotEmpty) return raw;
    }

    return '';
  }

  factory Player.fromJson(Map<String, dynamic> json) {
    final apiPlayerId = _pickApiPlayerId(json);

    return Player(
      id: (json['id'] ?? json['jugador_id'] ?? _pickApiPlayerId(json) ?? '').toString(),
      name: json['nombre'] as String? ?? json['name'] as String? ?? 'Jugador',
      number: int.tryParse((json['numero_camiseta'] ?? json['numero'] ?? json['number'])?.toString() ?? '') ?? 0,
      age: int.tryParse((json['edad'] ?? json['age'])?.toString() ?? '') ?? 0,
      teamId: (json['seleccion_id'] ?? json['seleccionId'] ?? json['team_id'] ?? '').toString(),
      apiPlayerId: apiPlayerId,
      position: json['posicion'] as String? ?? json['position'] as String? ?? '',
      club: json['club'] as String? ?? json['equipo'] as String? ?? '',
      photoUrl: _pickPhotoUrl(json),
      birthDate: json['fecha_nacimiento'] as String? ?? json['birthdate'] as String? ?? '',
      height: json['altura'] as String? ?? json['height'] as String? ?? '',
      weight: json['peso'] as String? ?? json['weight'] as String? ?? '',
      dribbling: int.tryParse((json['dribling'] ?? json['dribbling'] ?? json['regate'])?.toString() ?? '') ?? 0,
      speed: int.tryParse(json['velocidad']?.toString() ?? '') ?? 0,
      shooting: int.tryParse((json['tiro'] ?? json['shooting'])?.toString() ?? '') ?? 0,
      defending: int.tryParse((json['defensa'] ?? json['defending'])?.toString() ?? '') ?? 0,
      passing: int.tryParse((json['pase'] ?? json['passing'])?.toString() ?? '') ?? 0,
      physical: int.tryParse((json['fisico'] ?? json['physical'])?.toString() ?? '') ?? 0,
    );
  }
}
