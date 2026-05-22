import 'package:flutter/material.dart';

import '../services/album_data.dart';

class ExchangeScreen extends StatelessWidget {
  final AlbumData albumData;

  const ExchangeScreen({super.key, required this.albumData});

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
                colors: [Color(0xFF062A5A), Color(0xFF153E7A)],
              ),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Intercambios',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Colors.white),
                ),
                SizedBox(height: 8),
                Text(
                  'Planea tus cambios y arma la mejor estrategia para completar tu album.',
                  style: TextStyle(color: Color(0xFFDCE8FF)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoTile(
            'Estado de repetidas',
            '${albumData.totalDuplicates()} laminas repetidas registradas',
            Icons.layers,
            const Color(0xFF0B6E4F),
          ),
          const SizedBox(height: 12),
          _buildInfoTile(
            'Estado de coleccion',
            '${albumData.totalOwned()} laminas pegadas en la coleccion',
            Icons.stars,
            const Color(0xFF062A5A),
          ),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFD8E3EF)),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Proximo paso', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                SizedBox(height: 8),
                Text(
                  'Sigue marcando repetidas y pronto podras publicar ofertas para intercambio presencial o virtual.',
                  style: TextStyle(height: 1.35, color: Color(0xFF526983)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTile(String title, String subtitle, IconData icon, Color tone) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFD8E3EF)),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: tone.withValues(alpha: 0.14),
          child: Icon(icon, color: tone),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text(subtitle),
      ),
    );
  }
}
