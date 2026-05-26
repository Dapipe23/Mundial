import 'package:flutter/material.dart';

import '../models/team.dart';
import '../services/album_data.dart';
import 'team_detail_screen.dart';
import 'widgets/book_page_route.dart';
import 'widgets/wc_theme.dart';

class CollectionScreen extends StatelessWidget {
  final AlbumData albumData;

  const CollectionScreen({super.key, required this.albumData});

  @override
  Widget build(BuildContext context) {
    final teams = albumData.teams;
    if (teams.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('⚽', style: TextStyle(fontSize: 56)),
              const SizedBox(height: 16),
              const Text(
                'No se cargaron las selecciones.\nVerifica tu conexión.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      );
    }

    final total = albumData.shieldCount + albumData.photoCount + albumData.playerCount;
    const fullAlbum = 32 + 32 + 576;
    final globalRatio = total / fullAlbum;

    final groupedTeams = <String, List<Team>>{};
    for (final team in teams) {
      groupedTeams.putIfAbsent(team.group, () => <Team>[]).add(team);
    }
    final sortedGroups = groupedTeams.keys.toList()..sort();

    return Stack(
      children: [
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF0B1F4A),
                  const Color(0xFF24114B),
                  const Color(0xFF0A3A3A),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ),
        Positioned(top: -80, right: -50, child: _bgOrb(const Color(0xFF0B6E4F), 180, 0.20)),
        Positioned(top: 220, left: -70, child: _bgOrb(const Color(0xFF7C3AED), 170, 0.16)),
        Positioned(bottom: 120, right: -60, child: _bgOrb(const Color(0xFF062A5A), 160, 0.14)),
        SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeroBanner(globalRatio, total),
              const SizedBox(height: 14),
              _buildStatsGrid(),
              const SizedBox(height: 22),
              ...sortedGroups.map(
                (group) => _buildGroupSection(context, group, groupedTeams[group]!),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _bgOrb(Color color, double size, double alpha) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: alpha),
      ),
    );
  }

  Widget _buildHeroBanner(double ratio, int total) {
    final pct = (ratio * 100).toStringAsFixed(1);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF062A5A), Color(0xFF0B3D8F), Color(0xFF0B6E4F)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: const Color(0xFF062A5A).withValues(alpha: 0.40), blurRadius: 16, offset: const Offset(0, 6)),
        ],
      ),
      child: Stack(
        children: [
          // Decorative balls
          Positioned(right: -8, top: -8, child: Text('⚽', style: TextStyle(fontSize: 70, color: Colors.white.withValues(alpha: 0.07)))),
          Positioned(right: 55, bottom: -10, child: Text('🏆', style: TextStyle(fontSize: 44, color: Colors.white.withValues(alpha: 0.07)))),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'MI ÁLBUM MUNDIAL',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFFF3C969), letterSpacing: 1.4),
              ),
              const SizedBox(height: 4),
              Text(
                '$pct% completado',
                style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: Colors.white),
              ),
              const SizedBox(height: 14),
              ClipRRect(
                borderRadius: BorderRadius.circular(99),
                child: LinearProgressIndicator(
                  minHeight: 10,
                  value: ratio,
                  backgroundColor: const Color(0xFF365787),
                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFF3C969)),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                '$total / 640 láminas pegadas',
                style: TextStyle(fontSize: 13, color: Colors.white.withValues(alpha: 0.80), fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid() {
    return Row(
      children: [
        Expanded(child: _statCard(Icons.shield_rounded, '${albumData.shieldCount}', 'Escudos', '/32', const Color(0xFF1E40AF))),
        const SizedBox(width: 10),
        Expanded(child: _statCard(Icons.photo_camera_rounded, '${albumData.photoCount}', 'Fotos', '/32', const Color(0xFF0EA5E9))),
        const SizedBox(width: 10),
        Expanded(child: _statCard(Icons.sports_soccer_rounded, '${albumData.playerCount}', 'Jugadores', '/576', const Color(0xFF0B6E4F))),
        const SizedBox(width: 10),
        Expanded(child: _statCard(Icons.autorenew_rounded, '${albumData.totalDuplicates()}', 'Repetidas', '', const Color(0xFFD97706))),
      ],
    );
  }

  Widget _statCard(IconData icon, String value, String label, String total, Color accent) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            accent.withValues(alpha: 0.34),
            const Color(0xFF10243F),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accent.withValues(alpha: 0.25)),
        boxShadow: [BoxShadow(color: accent.withValues(alpha: 0.16), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: Column(
        children: [
          Icon(icon, size: 20, color: accent),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900, color: accent),
          ),
          Text(
            label + total,
            style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w600, color: Color(0xFFD3E1F7)),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildGroupSection(BuildContext context, String group, List<Team> teams) {
    final groupColor = WcColors.groupColor(group);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Group header
        Row(
          children: [
            WcGroupBadge(group: group, size: 34),
            const SizedBox(width: 10),
            Text(
              'GRUPO $group',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: groupColor,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(child: Divider(color: groupColor.withValues(alpha: 0.25), thickness: 1.5)),
          ],
        ),
        const SizedBox(height: 10),
        ...teams.map((team) => _buildTeamTile(context, team, groupColor)),
        const SizedBox(height: 18),
      ],
    );
  }

  Widget _buildTeamTile(BuildContext context, Team team, Color groupColor) {
    final ratio = albumData.teamCompletionRate(team.name);
    final percentage = (ratio * 100).round();
    final level = albumData.teamProgressLevel(team.name);
    final tone = _toneForLevel(level);
    final label = _labelForLevel(level);
    final flag = WcFlags.of(team.name);
    final missing = albumData.teamMissingCount(team.name);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            groupColor.withValues(alpha: 0.28),
            const Color(0xFF101F38),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: groupColor.withValues(alpha: 0.20)),
        boxShadow: [BoxShadow(color: groupColor.withValues(alpha: 0.16), blurRadius: 11, offset: const Offset(0, 3))],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () {
          playBookFlipFeedback();
          Navigator.push(
            context,
            buildBookPageRoute(
              child: TeamDetailScreen(albumData: albumData, team: team),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
          child: Row(
            children: [
              // Flag
              Text(flag, style: const TextStyle(fontSize: 30)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            team.name,
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFFEAF2FF)),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: groupColor.withValues(alpha: 0.10),
                            borderRadius: BorderRadius.circular(99),
                            border: Border.all(color: groupColor.withValues(alpha: 0.30)),
                          ),
                          child: Text(
                            '$percentage%',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: groupColor),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 7),
                    WcProgressBar(value: ratio, color: tone, height: 7),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        WcSemaphore(color: tone, label: label),
                        const Spacer(),
                        Text(
                          missing == 0 ? 'Completa' : 'Faltan $missing',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: missing == 0 ? tone : const Color(0xFFC3D1E6)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 4),
              Icon(Icons.chevron_right_rounded, color: const Color(0xFFD6E0F2), size: 22),
            ],
          ),
        ),
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
