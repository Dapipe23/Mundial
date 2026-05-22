import 'package:flutter/material.dart';

import '../services/album_data.dart';

class ProfileScreen extends StatelessWidget {
  final AlbumData albumData;

  const ProfileScreen({super.key, required this.albumData});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              gradient: const LinearGradient(
                colors: [Color(0xFF0B6E4F), Color(0xFF1B8E69)],
              ),
            ),
            child: const Text(
              'Tu Perfil Mundialista',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Colors.white),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFD8E3EF)),
            ),
            child: ListTile(
              leading: const CircleAvatar(
                radius: 24,
                backgroundColor: Color(0xFFEAF1FB),
                child: Icon(Icons.person, size: 30),
              ),
              title: Text(albumData.user.name, style: const TextStyle(fontWeight: FontWeight.w700)),
              subtitle: Text(albumData.user.email),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Resumen de coleccion',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          _buildSummaryTile('Escudos', '${albumData.shieldCount} / 32'),
          _buildSummaryTile('Fotos de equipo', '${albumData.photoCount} / 32'),
          _buildSummaryTile('Jugadores pegados', '${albumData.playerCount} / 576'),
          _buildSummaryTile('Laminas repetidas', '${albumData.totalDuplicates()}'),
        ],
      ),
    );
  }

  Widget _buildSummaryTile(String title, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFD8E3EF)),
      ),
      child: ListTile(
        title: Text(title),
        trailing: Text(value, style: const TextStyle(fontWeight: FontWeight.w800)),
      ),
    );
  }
}
