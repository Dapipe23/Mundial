enum StickerType { shield, teamPhoto, player }

class Sticker {
  final String team;
  final int number;

  Sticker({required this.team, required this.number});

  StickerType get type {
    if (number == 1) return StickerType.shield;
    if (number == 20) return StickerType.teamPhoto;
    return StickerType.player;
  }

  String get displayName {
    if (number == 1) return 'Escudo';
    if (number == 20) return 'Foto del equipo';
    return 'Jugador';
  }

  String get shortLabel => '#$team, #$number';

  String get key => '$team#$number';
}
