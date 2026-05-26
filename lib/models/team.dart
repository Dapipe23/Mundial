class Team {
  final String id;
  final String name;
  final String group;
  final String confederation;
  final int worldCups;
  final String escudoUrl;

  const Team({
    required this.id,
    required this.name,
    required this.group,
    required this.confederation,
    required this.worldCups,
    required this.escudoUrl,
  });

  factory Team.fromJson(Map<String, dynamic> json) {
    String parsedGroup = '';
    final grupos = json['grupos'];

    if (grupos is Map<String, dynamic>) {
      final abbr = grupos['abreviatura']?.toString().trim();
      if (abbr != null && abbr.isNotEmpty) {
        parsedGroup = abbr;
      } else {
        final nombre = grupos['nombre']?.toString().trim() ?? '';
        if (nombre.toLowerCase().startsWith('grupo ') && nombre.length >= 7) {
          parsedGroup = nombre.substring(6).trim();
        }
      }
    } else if (grupos is String && grupos.trim().isNotEmpty) {
      parsedGroup = grupos.trim();
    }

    if (parsedGroup.toLowerCase().startsWith('grupo ')) {
      parsedGroup = parsedGroup.substring(6).trim();
    }

    if (parsedGroup.isEmpty) {
      parsedGroup = (json['grupo_id']?.toString() ?? '').trim();
    }

    return Team(
      id: json['id'] as String? ?? '',
      name: json['pais'] as String? ?? '',
      group: parsedGroup,
      confederation: json['confederacion'] as String? ?? '',
      worldCups: (json['campeonatos_mundiales'] is int)
          ? json['campeonatos_mundiales'] as int
          : int.tryParse(json['campeonatos_mundiales']?.toString() ?? '0') ?? 0,
      escudoUrl: json['escudo_url'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'pais': name,
        'grupos': group,
        'confederacion': confederation,
        'campeonatos_mundiales': worldCups,
        'escudo_url': escudoUrl,
      };
}
