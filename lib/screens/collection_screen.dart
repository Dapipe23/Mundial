import 'package:flutter/material.dart';

import '../models/team.dart';
import '../services/album_data.dart';
import 'team_detail_screen.dart';

class CollectionScreen extends StatelessWidget {
  final AlbumData albumData;

  const CollectionScreen({super.key, required this.albumData});

  @override
  Widget build(BuildContext context) {
    final teams = albumData.teams;
    if (teams.isEmpty) {
      return Center(
        child: Container(
          margin: const EdgeInsets.all(24),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
          ),
          child: const Text(
            'No se pudieron cargar las selecciones desde la API. Verifica tu conexión y vuelve a iniciar.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
      );
    }

    final groupedTeams = <String, List<Team>>{};
    for (final team in teams) {
      groupedTeams.putIfAbsent(team.group, () => <Team>[]).add(team);
    }
    final sortedGroups = groupedTeams.keys.toList()..sort();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF062A5A), Color(0xFF0B6E4F)],
              ),
              borderRadius: BorderRadius.circular(22),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Progreso de la Coleccion',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white),
                ),
                SizedBox(height: 8),
                Text(
                  'Sigue tus laminas y avanza grupo por grupo hasta completar el Mundial.',
                  style: TextStyle(color: Color(0xFFDCEBFF)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _buildProgressCard('Escudos', '${albumData.shieldCount}/32'),
              _buildProgressCard('Fotos de equipo', '${albumData.photoCount}/32'),
              _buildProgressCard('Jugadores', '${albumData.playerCount}/576'),
              _buildProgressCard('Repetidas', '${albumData.totalDuplicates()}'),
            ],
          ),
          const SizedBox(height: 22),
          ...sortedGroups.map(
            (group) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Equipos del grupo $group',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 10),
                ...groupedTeams[group]!.map((team) => _buildTeamTile(context, team)),
                const SizedBox(height: 14),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressCard(String title, String value) {
    return SizedBox(
      width: 170,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFD6E0ED)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF46617F))),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTeamTile(BuildContext context, Team team) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFD8E2EE)),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: const Color(0xFFEAF1FB),
          child: Text(team.group, style: const TextStyle(fontWeight: FontWeight.w700)),
        ),
        title: Text(team.name, style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text(team.group.isNotEmpty ? 'Grupo ${team.group}' : 'Grupo no asignado'),
        trailing: IconButton(
          icon: const Icon(Icons.chevron_right),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => TeamDetailScreen(
                  albumData: albumData,
                  team: team,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
