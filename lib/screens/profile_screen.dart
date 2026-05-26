import 'package:flutter/material.dart';

import '../models/team.dart';
import '../services/album_data.dart';
import 'widgets/wc_theme.dart';

class ProfileScreen extends StatelessWidget {
  final AlbumData albumData;

  const ProfileScreen({super.key, required this.albumData});

  @override
  Widget build(BuildContext context) {
    final topTeams = [...albumData.teams]
      ..sort((a, b) => albumData.ownedCount(b.name).compareTo(albumData.ownedCount(a.name)));

    final totalOwned = albumData.shieldCount + albumData.photoCount + albumData.playerCount;
    const total = 640;
    final pct = (totalOwned / total * 100).toStringAsFixed(1);

    return Stack(
      children: [
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF0A1C47),
                  const Color(0xFF2A124F),
                  const Color(0xFF0F3A57),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ),
        Positioned(top: -50, right: -30, child: _orb(const Color(0xFF0B6E4F), 150, 0.15)),
        Positioned(bottom: 130, left: -60, child: _orb(const Color(0xFF7C3AED), 170, 0.14)),
        SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildFifaCard(pct),
              const SizedBox(height: 18),
              _buildStatsGrid(),
              const SizedBox(height: 22),
              Row(
                children: [
                  const Text(
                    'MIS MEJORES EQUIPOS',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Color(0xFFF3C969), letterSpacing: 1.0),
                  ),
                  const Spacer(),
                  Text('Top ${topTeams.take(6).length}', style: const TextStyle(fontSize: 11, color: Color(0xFFC6D5EE), fontWeight: FontWeight.w600)),
                ],
              ),
              const SizedBox(height: 12),
              ...topTeams.take(6).map((t) => _buildTeamProgressTile(t)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _orb(Color color, double size, double alpha) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color.withValues(alpha: alpha)),
    );
  }

  Widget _buildFifaCard(String pct) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [Color(0xFF062A5A), Color(0xFF0B3D8F), Color(0xFF0B6E4F)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(color: const Color(0xFF062A5A).withValues(alpha: 0.45), blurRadius: 18, offset: const Offset(0, 7)),
        ],
      ),
      child: Stack(
        children: [
          // Watermark
          Positioned(
            right: -10,
            top: -10,
            child: Icon(Icons.emoji_events_rounded, size: 110, color: Colors.white.withValues(alpha: 0.06)),
          ),
          Positioned(
            left: 0,
            bottom: -20,
            child: Icon(Icons.sports_soccer_rounded, size: 80, color: Colors.white.withValues(alpha: 0.05)),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'FIFA WORLD CUP 2026',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFFF3C969), letterSpacing: 1.5),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    // Avatar
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                        border: Border.all(color: WcColors.gold.withValues(alpha: 0.6), width: 2.5),
                      ),
                      child: const Center(child: Icon(Icons.sports_soccer_rounded, size: 30, color: Colors.white)),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            albumData.user.name,
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.white),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            albumData.user.email,
                            style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.65)),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    // Rating badge
                    Column(
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: WcColors.gold,
                            shape: BoxShape.circle,
                            boxShadow: [BoxShadow(color: WcColors.gold.withValues(alpha: 0.5), blurRadius: 8)],
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            pct,
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Color(0xFF062A5A)),
                          ),
                        ),
                        const SizedBox(height: 3),
                        const Text('%', style: TextStyle(fontSize: 10, color: Color(0xFFF3C969), fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Global progress bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(99),
                  child: LinearProgressIndicator(
                    minHeight: 8,
                    value: double.tryParse(pct) != null ? double.parse(pct) / 100 : 0,
                    backgroundColor: Colors.white.withValues(alpha: 0.15),
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFF3C969)),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${albumData.shieldCount + albumData.photoCount + albumData.playerCount} / 640 laminas totales',
                  style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.75), fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid() {
    return Row(
      children: [
        Expanded(child: _statTile(Icons.shield_rounded, '${albumData.shieldCount}', 'Escudos', '/32', const Color(0xFF1E40AF))),
        const SizedBox(width: 10),
        Expanded(child: _statTile(Icons.photo_camera_rounded, '${albumData.photoCount}', 'Fotos', '/32', const Color(0xFF7C3AED))),
        const SizedBox(width: 10),
        Expanded(child: _statTile(Icons.sports_soccer_rounded, '${albumData.playerCount}', 'Jugadores', '/576', const Color(0xFF0B6E4F))),
        const SizedBox(width: 10),
        Expanded(child: _statTile(Icons.copy_rounded, '${albumData.totalDuplicates()}', 'Repetidas', '', const Color(0xFFD97706))),
      ],
    );
  }

  Widget _statTile(IconData icon, String value, String label, String total, Color accent) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF162A52),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accent.withValues(alpha: 0.32)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.20), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Column(
        children: [
          Icon(icon, size: 20, color: accent),
          const SizedBox(height: 5),
          Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: accent)),
          Text(label + total, style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w600, color: Color(0xFFB8C9E4)), textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildTeamProgressTile(Team team) {
    final ratio = albumData.teamCompletionRate(team.name);
    final percent = (ratio * 100).round();
    final level = albumData.teamProgressLevel(team.name);
    final tone = _toneForLevel(level);
    final label = _labelForLevel(level);
    final flag = WcFlags.of(team.name);
    final groupColor = WcColors.groupColor(team.group);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: const Color(0xFF162A52),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0x335C89C8)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.18), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          Text(flag, style: const TextStyle(fontSize: 26)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(team.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFFEAF2FF))),
                    ),
                    Text(
                      '${albumData.ownedCount(team.name)}/20',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: groupColor),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                WcProgressBar(value: ratio, color: tone, height: 6),
                const SizedBox(height: 5),
                WcSemaphore(color: tone, label: label),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text('$percent%', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: tone)),
        ],
      ),
    );
  }

  Color _toneForLevel(TeamProgressLevel level) {
    switch (level) {
      case TeamProgressLevel.high:
        return const Color(0xFF15803D);
      case TeamProgressLevel.medium:
        return const Color(0xFFCA8A04);
      case TeamProgressLevel.low:
        return const Color(0xFFDC2626);
    }
  }

  String _labelForLevel(TeamProgressLevel level) {
    switch (level) {
      case TeamProgressLevel.high:
        return 'Ritmo alto';
      case TeamProgressLevel.medium:
        return 'Ritmo medio';
      case TeamProgressLevel.low:
        return 'Ritmo bajo';
    }
  }
}
