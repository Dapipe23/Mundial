class Player {
  final String id;
  final String name;
  final int number;
  final String teamId;
  final String position;
  final String club;
  final String photoUrl;
  final String birthDate;
  final String height;
  final String weight;

  const Player({
    required this.id,
    required this.name,
    required this.number,
    required this.teamId,
    required this.position,
    required this.club,
    required this.photoUrl,
    required this.birthDate,
    required this.height,
    required this.weight,
  });

  factory Player.fromJson(Map<String, dynamic> json) {
    return Player(
      id: json['id'] as String? ?? '',
      name: json['nombre'] as String? ?? json['name'] as String? ?? 'Jugador',
      number: int.tryParse(json['numero']?.toString() ?? '') ?? 0,
      teamId: json['seleccion_id'] as String? ?? json['seleccionId'] as String? ?? '',
      position: json['posicion'] as String? ?? json['position'] as String? ?? '',
      club: json['club'] as String? ?? json['equipo'] as String? ?? '',
      photoUrl: json['foto_url'] as String? ?? json['photo_url'] as String? ?? json['imagen'] as String? ?? '',
      birthDate: json['fecha_nacimiento'] as String? ?? json['birthdate'] as String? ?? '',
      height: json['altura'] as String? ?? json['height'] as String? ?? '',
      weight: json['peso'] as String? ?? json['weight'] as String? ?? '',
    );
  }
}
