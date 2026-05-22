import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/models.dart';
import 'api_service.dart';

class AlbumData {
  final User user;
  final List<Team> teams;

  final Map<String, Set<int>> ownedStickers = {};
  final Map<String, Set<int>> duplicateStickers = {};

  AlbumData._(this.user, this.teams) {
    for (final team in teams) {
      ownedStickers[team.name] = <int>{};
      duplicateStickers[team.name] = <int>{};
    }
  }

  static Future<AlbumData> create(User user) async {
    final fetched = await ApiService.fetchSelecciones();
    final album = AlbumData._(user, fetched);
    await album._loadState();
    return album;
  }

  Future<void> _loadState() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_stateKey);
    if (saved == null || saved.isEmpty) return;

    try {
      final decoded = json.decode(saved) as Map<String, dynamic>;
      final owned = decoded['owned'] as Map<String, dynamic>?;
      final duplicate = decoded['duplicate'] as Map<String, dynamic>?;

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
    } catch (_) {
      // ignore invalid saved state
    }
  }

  Future<void> _saveState() async {
    final prefs = await SharedPreferences.getInstance();
    final payload = {
      'owned': ownedStickers.map((key, value) => MapEntry(key, value.toList())),
      'duplicate': duplicateStickers.map((key, value) => MapEntry(key, value.toList())),
    };
    await prefs.setString(_stateKey, json.encode(payload));
  }

  String get _stateKey => 'album_state_${user.email}';

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
    return teams.where((team) => isOwned(team.name, 13)).length;
  }

  int get playerCount {
    return totalOwned() - shieldCount - photoCount;
  }
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
