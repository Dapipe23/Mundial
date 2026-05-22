import 'package:flutter/material.dart';

import '../models/models.dart';
import '../screens/player_detail_screen.dart';
import '../services/album_data.dart';

class TeamDetailScreen extends StatefulWidget {
  final AlbumData albumData;
  final Team team;

  const TeamDetailScreen({super.key, required this.albumData, required this.team});

  @override
  State<TeamDetailScreen> createState() => _TeamDetailScreenState();
}

class _TeamDetailScreenState extends State<TeamDetailScreen> {
  late final Future<PlayerFetchResult> _playersFuture;

  @override
  void initState() {
    super.initState();
    _playersFuture = widget.albumData.fetchPlayersForTeam(widget.team);
  }

  Future<void> _registerSticker(int number) async {
    final isOwned = widget.albumData.isOwned(widget.team.name, number);
    if (isOwned) {
      _showMessage('Ya tienes esta lámina en la colección.');
      return;
    }

    final choice = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Registrar lámina #$number'),
          content: const Text('¿Deseas agregarla como colección o como repetida?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Colección'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Repetida'),
            ),
          ],
        );
      },
    );

    if (choice == null) return;

    final message = await widget.albumData.addSticker(widget.team.name, number, duplicate: choice);
    _showMessage(message);
    setState(() {});
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _showPlayerDetails(Player player) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PlayerDetailScreen(player: player),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final team = widget.team;
    final teamName = team.name;

    return Scaffold(
      appBar: AppBar(title: Text(teamName)),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                gradient: const LinearGradient(
                  colors: [Color(0xFF062A5A), Color(0xFF0B6E4F)],
                ),
              ),
              child: Text(
                'Laminas de $teamName',
                style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w800, color: Colors.white),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _statusChip('Colección', widget.albumData.ownedCount(teamName), Colors.green),
                const SizedBox(width: 8),
                _statusChip('Repetidas', widget.albumData.duplicateCount(teamName), Colors.orange),
              ],
            ),
            const SizedBox(height: 16),
            FutureBuilder<PlayerFetchResult>(
              future: _playersFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                final result = snapshot.data;
                if (result == null || result.players.isEmpty) {
                  final countText = result == null
                      ? ''
                      : 'API returned success=${result.success}, count=${result.count}.';
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Text(
                      'No hay datos de jugadores disponibles desde la API para esta selección. $countText',
                      style: const TextStyle(fontSize: 14),
                    ),
                  );
                }
                final players = result.players;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Jugadores detectados: ${result.count}',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 160,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: players.length,
                        separatorBuilder: (_, index) => const SizedBox(width: 12),
                        itemBuilder: (context, index) {
                          final player = players[index];
                          final owned = widget.albumData.isOwned(teamName, player.number);
                          final duplicate = widget.albumData.isDuplicate(teamName, player.number);
                          return SizedBox(
                            width: 180,
                            child: Card(
                              child: InkWell(
                                onTap: () => _showPlayerDetails(player),
                                borderRadius: BorderRadius.circular(4),
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('#${player.number}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                      const SizedBox(height: 8),
                                      Text(player.name, maxLines: 2, overflow: TextOverflow.ellipsis),
                                      if (player.position.isNotEmpty)
                                        Padding(
                                          padding: const EdgeInsets.only(top: 6),
                                          child: Text(
                                            player.position,
                                            style: const TextStyle(fontSize: 12, color: Colors.black54),
                                          ),
                                        ),
                                      const Spacer(),
                                      if (owned)
                                        const Chip(label: Text('Pega'), backgroundColor: Color(0xFFC5F2DA))
                                      else if (duplicate)
                                        const Chip(label: Text('Repetida'), backgroundColor: Color(0xFFFFE1BF))
                                      else
                                        FilledButton(
                                          onPressed: () => _registerSticker(player.number),
                                          child: const Text('Registrar'),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                );
              },
            ),
            Expanded(
              child: GridView.builder(
                itemCount: 20,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.9,
                ),
                itemBuilder: (context, index) {
                  final number = index + 1;
                  final sticker = Sticker(team: teamName, number: number);
                  final owned = widget.albumData.isOwned(teamName, number);
                  final duplicate = widget.albumData.isDuplicate(teamName, number);
                    final color = owned
                      ? const Color(0xFFC5F2DA)
                      : duplicate
                        ? const Color(0xFFFFE1BF)
                        : const Color(0xFFF3F6FA);
                  final border = owned
                      ? Border.all(color: Colors.green, width: 1.6)
                      : duplicate
                          ? Border.all(color: Colors.orange, width: 1.6)
                          : Border.all(color: Colors.grey.shade300, width: 1);

                  return GestureDetector(
                    onTap: () => _registerSticker(number),
                    child: Container(
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(12),
                        border: border,
                      ),
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(sticker.shortLabel, style: const TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 6),
                          Text(sticker.displayName, style: const TextStyle(fontSize: 12)),
                          const Spacer(),
                          if (owned)
                            const Chip(label: Text('Pega'), backgroundColor: Color(0xFFC5F2DA))
                          else if (!owned && duplicate)
                            const Chip(label: Text('Repetida'), backgroundColor: Color(0xFFFFE1BF)),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusChip(String label, int value, Color color) {
    return Chip(
      label: Text('$label: $value'),
      backgroundColor: color.withValues(alpha: 0.18),
    );
  }
}
