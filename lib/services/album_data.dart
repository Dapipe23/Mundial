import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/models.dart';
import 'api_service.dart';

class AlbumData {
  final User user;
  final List<Team> teams;
  final String accountKey;

  final Map<String, Set<int>> ownedStickers = {};
  final Map<String, Set<int>> duplicateStickers = {};
  final List<ExchangeOffer> _offers = [];
  final Map<String, Future<List<Player>>> _playersByTeamCache = {};

  AlbumData._(this.user, this.teams, this.accountKey) {
    for (final team in teams) {
      ownedStickers[team.name] = <int>{};
      duplicateStickers[team.name] = <int>{};
    }
  }

  static Future<AlbumData> create(User user) async {
    final fetched = await ApiService.fetchSelecciones();
    final album = AlbumData._(user, fetched, user.storageKey);
    await album._loadState();
    return album;
  }

  Future<void> _loadState() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_stateKey);
    if (saved == null || saved.isEmpty) {
      final legacyKey = _legacyStateKey;
      final legacySaved = prefs.getString(legacyKey);
      if (legacySaved == null || legacySaved.isEmpty) return;
      await prefs.setString(_stateKey, legacySaved);
      await prefs.remove(legacyKey);
      return _loadState();
    }

    try {
      final decoded = json.decode(saved) as Map<String, dynamic>;
      final owned = decoded['owned'] as Map<String, dynamic>?;
      final duplicate = decoded['duplicate'] as Map<String, dynamic>?;
      final offers = decoded['offers'] as List<dynamic>?;

      if (owned != null) {
        for (final entry in owned.entries) {
          final teamName = entry.key;
          final values = (entry.value as List<dynamic>).map((e) => int.tryParse(e.toString()) ?? 0).where((n) => n > 0).toSet();
          ownedStickers[teamName] = values;
        }
      }
      if (duplicate != null) {
        for (final entry in duplicate.entries) {
          final teamName = entry.key;
          final values = (entry.value as List<dynamic>).map((e) => int.tryParse(e.toString()) ?? 0).where((n) => n > 0).toSet();
          duplicateStickers[teamName] = values;
        }
      }

      _offers
        ..clear()
        ..addAll(
          (offers ?? <dynamic>[])
              .whereType<Map<String, dynamic>>()
              .map(ExchangeOffer.fromJson),
        );
    } catch (_) {
      // ignore invalid saved state
    }
  }

  Future<void> _saveState() async {
    final prefs = await SharedPreferences.getInstance();
    final payload = {
      'owned': ownedStickers.map((key, value) => MapEntry(key, value.toList())),
      'duplicate': duplicateStickers.map((key, value) => MapEntry(key, value.toList())),
      'offers': _offers.map((offer) => offer.toJson()).toList(),
    };
    await prefs.setString(_stateKey, json.encode(payload));
  }

  String get _stateKey => 'album_state_$accountKey';

  String get _legacyStateKey {
    final legacyEmail = user.email.trim().toLowerCase().replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_');
    return 'album_state_$legacyEmail';
  }

  Future<String> addSticker(String teamName, int number, {required bool duplicate}) async {
    if (isOwned(teamName, number)) {
      return 'Ya tienes esta lámina en la colección oficial.';
    }

    if (duplicate) {
      if (isDuplicate(teamName, number)) {
        return 'Esta lámina ya está en tu lista de repetidas.';
      }
      duplicateStickers[teamName]?.add(number);
      await _saveState();
      return 'Lámina registrada como repetida.';
    }

    ownedStickers[teamName]?.add(number);
    duplicateStickers[teamName]?.remove(number);
    await _saveState();
    return 'Lámina registrada en la colección.';
  }

  Future<String> removeSticker(String teamName, int number) async {
    final wasOwned = isOwned(teamName, number);
    final wasDuplicate = isDuplicate(teamName, number);

    if (!wasOwned && !wasDuplicate) {
      return 'Esa lamina no estaba registrada.';
    }

    if (wasOwned) {
      ownedStickers[teamName]?.remove(number);
      await _saveState();
      return 'Lamina quitada de la coleccion.';
    }

    duplicateStickers[teamName]?.remove(number);
    await _saveState();
    return 'Lamina quitada de repetidas.';
  }

  Future<PlayerFetchResult> fetchPlayersForTeam(Team team) async {
    if (team.id.isEmpty) {
      return const PlayerFetchResult(
        players: <Player>[],
        success: false,
        count: 0,
        raw: '',
      );
    }

    final response = await ApiService.fetchJugadoresResponse(seleccionId: team.id);
    return PlayerFetchResult(
      players: response.data.map((e) => Player.fromJson(e)).toList(),
      success: response.success,
      count: response.count,
      raw: response.raw,
    );
  }

  Team? _teamByName(String teamName) {
    for (final team in teams) {
      if (team.name == teamName) {
        return team;
      }
    }
    return null;
  }

  Future<List<Player>> _playersForTeamName(String teamName) {
    final team = _teamByName(teamName);
    if (team == null || team.id.isEmpty) {
      return Future.value(<Player>[]);
    }

    return _playersByTeamCache.putIfAbsent(team.name, () async {
      final result = await fetchPlayersForTeam(team);
      return result.players;
    });
  }

  bool _isMetaAlbumEntry(Player player) {
    final pos = player.position.trim().toLowerCase();
    final name = player.name.trim().toLowerCase();
    const metaPositions = {
      'escudo',
      'equipo',
      'foto',
      'foto grupal',
      'team photo',
      'entrenador',
      'dt',
    };
    if (metaPositions.contains(pos)) return true;
    return name.startsWith('escudo ') || name.startsWith('seleccion ') || name.startsWith('selección ');
  }

  Map<int, Player> _stickerPlayersByNumber(List<Player> players) {
    final byNumber = <int, Player>{};
    final usedSlots = <int>{};

    final regularPlayers = players.where((player) => !_isMetaAlbumEntry(player)).toList();

    for (final player in regularPlayers) {
      final apiSlot = player.number;
      if (apiSlot < 2 || apiSlot > 19 || usedSlots.contains(apiSlot)) {
        continue;
      }
      byNumber[apiSlot] = player;
      usedSlots.add(apiSlot);
    }

    var nextSlot = 2;
    for (final player in regularPlayers) {
      if (byNumber.containsKey(player.number) && player.number >= 2 && player.number <= 19) {
        continue;
      }
      while (nextSlot <= 19 && usedSlots.contains(nextSlot)) {
        nextSlot++;
      }
      if (nextSlot > 19) {
        break;
      }
      byNumber[nextSlot] = player;
      usedSlots.add(nextSlot);
      nextSlot++;
    }

    return byNumber;
  }

  Future<String> stickerDisplayLabel(StickerRef ref) async {
    if (ref.number == 1) {
      return 'Lamina #1 • Escudo';
    }
    if (ref.number == 20) {
      return 'Lamina #20 • Foto del equipo';
    }

    final players = await _playersForTeamName(ref.teamName);
    final player = _stickerPlayersByNumber(players)[ref.number];
    final playerName = player?.name.trim();
    if (playerName != null && playerName.isNotEmpty) {
      return 'Lamina #${ref.number} • $playerName';
    }

    return 'Lamina #${ref.number} • Jugador';
  }

  Future<String> stickerExchangeLabel(StickerRef offering, StickerRef wanting) async {
    final offeringLabel = await stickerDisplayLabel(offering);
    final wantingLabel = await stickerDisplayLabel(wanting);
    return '$offeringLabel -> $wantingLabel';
  }

  bool isOwned(String teamName, int number) {
    return ownedStickers[teamName]?.contains(number) ?? false;
  }

  bool isDuplicate(String teamName, int number) {
    return duplicateStickers[teamName]?.contains(number) ?? false;
  }

  int ownedCount(String teamName) {
    return ownedStickers[teamName]?.length ?? 0;
  }

  int duplicateCount(String teamName) {
    return duplicateStickers[teamName]?.length ?? 0;
  }

  int totalOwned() {
    return ownedStickers.values.fold(0, (sum, next) => sum + next.length);
  }

  int totalDuplicates() {
    return duplicateStickers.values.fold(0, (sum, next) => sum + next.length);
  }

  int get shieldCount {
    return teams.where((team) => isOwned(team.name, 1)).length;
  }

  int get photoCount {
    return teams.where((team) => isOwned(team.name, 20)).length;
  }

  int get playerCount {
    return totalOwned() - shieldCount - photoCount;
  }

  int teamMissingCount(String teamName) {
    return 20 - ownedCount(teamName);
  }

  double teamCompletionRate(String teamName) {
    final owned = ownedCount(teamName);
    return owned / 20;
  }

  TeamProgressLevel teamProgressLevel(String teamName) {
    final ratio = teamCompletionRate(teamName);
    if (ratio >= 0.7) {
      return TeamProgressLevel.high;
    }
    if (ratio >= 0.35) {
      return TeamProgressLevel.medium;
    }
    return TeamProgressLevel.low;
  }

  List<StickerRef> duplicateStickerRefs() {
    final refs = <StickerRef>[];
    for (final team in teams) {
      final values = duplicateStickers[team.name] ?? <int>{};
      for (final number in values.toList()..sort()) {
        refs.add(StickerRef(teamName: team.name, number: number));
      }
    }
    return refs;
  }

  List<StickerRef> missingStickerRefs() {
    final refs = <StickerRef>[];
    for (final team in teams) {
      final teamOwned = ownedStickers[team.name] ?? <int>{};
      for (var number = 1; number <= 20; number++) {
        if (!teamOwned.contains(number)) {
          refs.add(StickerRef(teamName: team.name, number: number));
        }
      }
    }
    return refs;
  }

  List<ExchangeOffer> listOffers() {
    final sorted = [..._offers];
    sorted.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return sorted;
  }

  Future<String> createOffer({
    required StickerRef offering,
    required StickerRef wanting,
    required ExchangeType type,
    String? note,
  }) async {
    if (!isDuplicate(offering.teamName, offering.number)) {
      return 'La lamina ofrecida debe estar en repetidas antes de publicarla.';
    }

    if (isOwned(wanting.teamName, wanting.number)) {
      return 'La lamina que solicitas ya esta pegada en tu coleccion.';
    }

    final offer = ExchangeOffer(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      offering: offering,
      wanting: wanting,
      type: type,
      status: ExchangeStatus.open,
      note: note,
      createdAt: DateTime.now(),
    );

    _offers.add(offer);
    await _saveState();
    return 'Oferta publicada correctamente.';
  }

  Future<void> updateOfferStatus(String offerId, ExchangeStatus status) async {
    for (var i = 0; i < _offers.length; i++) {
      if (_offers[i].id == offerId) {
        _offers[i] = _offers[i].copyWith(status: status);
        break;
      }
    }
    await _saveState();
  }

  List<ExchangeMatch> findMatches() {
    final openOffers = _offers.where((offer) => offer.status == ExchangeStatus.open).toList();
    final matches = <ExchangeMatch>[];

    for (final offer in openOffers) {
      final partner = _communityOffers.firstWhere(
        (other) =>
            offer.offering.teamName == other.wanting.teamName &&
            offer.offering.number == other.wanting.number &&
            offer.wanting.teamName == other.offering.teamName &&
            offer.wanting.number == other.offering.number,
        orElse: () => ExchangeOffer.empty,
      );

      if (!partner.isEmpty) {
        matches.add(
          ExchangeMatch(
            userOffer: offer,
            partnerName: partner.note ?? 'Coleccionista local',
            partnerOffer: partner,
          ),
        );
      }
    }

    return matches;
  }

  List<ExchangeOffer> get _communityOffers {
    return [
      ExchangeOffer(
        id: 'community-1',
        offering: StickerRef(teamName: 'Panamá', number: 8),
        wanting: StickerRef(teamName: 'Argentina', number: 3),
        type: ExchangeType.virtual,
        status: ExchangeStatus.open,
        note: 'Valentina - Medellin',
      ),
      ExchangeOffer(
        id: 'community-2',
        offering: StickerRef(teamName: 'Brasil', number: 14),
        wanting: StickerRef(teamName: 'España', number: 7),
        type: ExchangeType.physical,
        status: ExchangeStatus.open,
        note: 'Nicolas - Bogota',
      ),
      ExchangeOffer(
        id: 'community-3',
        offering: StickerRef(teamName: 'Francia', number: 5),
        wanting: StickerRef(teamName: 'Panamá', number: 2),
        type: ExchangeType.virtual,
        status: ExchangeStatus.open,
        note: 'Laura - Cali',
      ),
    ];
  }
}

enum TeamProgressLevel { low, medium, high }

enum ExchangeType { physical, virtual }

enum ExchangeStatus { open, matched, completed, cancelled }

class StickerRef {
  final String teamName;
  final int number;

  const StickerRef({required this.teamName, required this.number});

  String get label => '$teamName #$number';

  Map<String, dynamic> toJson() => {
        'teamName': teamName,
        'number': number,
      };

  factory StickerRef.fromJson(Map<String, dynamic> json) {
    return StickerRef(
      teamName: json['teamName'] as String? ?? '',
      number: int.tryParse(json['number']?.toString() ?? '0') ?? 0,
    );
  }
}

class ExchangeOffer {
  final String id;
  final StickerRef offering;
  final StickerRef wanting;
  final ExchangeType type;
  final ExchangeStatus status;
  final String? note;
  final DateTime createdAt;

  ExchangeOffer({
    required this.id,
    required this.offering,
    required this.wanting,
    required this.type,
    required this.status,
    this.note,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);

  static ExchangeOffer get empty => ExchangeOffer(
        id: '',
        offering: const StickerRef(teamName: '', number: 0),
        wanting: const StickerRef(teamName: '', number: 0),
        type: ExchangeType.virtual,
        status: ExchangeStatus.open,
      );

  bool get isEmpty => id.isEmpty;

  ExchangeOffer copyWith({ExchangeStatus? status}) {
    return ExchangeOffer(
      id: id,
      offering: offering,
      wanting: wanting,
      type: type,
      status: status ?? this.status,
      note: note,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'offering': offering.toJson(),
        'wanting': wanting.toJson(),
        'type': type.name,
        'status': status.name,
        'note': note,
        'createdAt': createdAt.toIso8601String(),
      };

  factory ExchangeOffer.fromJson(Map<String, dynamic> json) {
    return ExchangeOffer(
      id: json['id'] as String? ?? '',
      offering: StickerRef.fromJson(json['offering'] as Map<String, dynamic>? ?? {}),
      wanting: StickerRef.fromJson(json['wanting'] as Map<String, dynamic>? ?? {}),
      type: _parseType(json['type']?.toString()),
      status: _parseStatus(json['status']?.toString()),
      note: json['note'] as String?,
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.now(),
    );
  }

  static ExchangeType _parseType(String? value) {
    return ExchangeType.values.firstWhere(
      (item) => item.name == value,
      orElse: () => ExchangeType.virtual,
    );
  }

  static ExchangeStatus _parseStatus(String? value) {
    return ExchangeStatus.values.firstWhere(
      (item) => item.name == value,
      orElse: () => ExchangeStatus.open,
    );
  }
}

class ExchangeMatch {
  final ExchangeOffer userOffer;
  final String partnerName;
  final ExchangeOffer partnerOffer;

  const ExchangeMatch({
    required this.userOffer,
    required this.partnerName,
    required this.partnerOffer,
  });
}

class PlayerFetchResult {
  final List<Player> players;
  final bool success;
  final int count;
  final String raw;

  const PlayerFetchResult({
    required this.players,
    required this.success,
    required this.count,
    required this.raw,
  });
}
