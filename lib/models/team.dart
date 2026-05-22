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
    return Team(
      id: json['id'] as String? ?? '',
      name: json['pais'] as String? ?? '',
      group: (json['grupos'] is String && (json['grupos'] as String).isNotEmpty)
          ? json['grupos'] as String
          : (json['grupo_id']?.toString() ?? ''),
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
