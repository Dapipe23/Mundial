import 'package:flutter/material.dart';

import '../models/player.dart';

class PlayerDetailScreen extends StatelessWidget {
  final Player player;

  const PlayerDetailScreen({super.key, required this.player});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(player.name)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                gradient: const LinearGradient(
                  colors: [Color(0xFF062A5A), Color(0xFF153E7A)],
                ),
              ),
              child: const Text(
                'Ficha Oficial del Jugador',
                style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800),
              ),
            ),
            const SizedBox(height: 16),
            if (player.photoUrl.isNotEmpty)
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    player.photoUrl,
                    width: 180,
                    height: 180,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.person,
                      size: 120,
                    ),
                  ),
                ),
              ),
            if (player.photoUrl.isNotEmpty) const SizedBox(height: 20),
            _detailRow('Nombre', player.name),
            _detailRow('Numero', player.number == 0 ? 'N/A' : player.number.toString()),
            if (player.position.isNotEmpty) _detailRow('Posicion', player.position),
            if (player.club.isNotEmpty) _detailRow('Club', player.club),
            if (player.birthDate.isNotEmpty) _detailRow('Nacimiento', player.birthDate),
            if (player.height.isNotEmpty) _detailRow('Altura', player.height),
            if (player.weight.isNotEmpty) _detailRow('Peso', player.weight),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: const Color(0xFFD8E3EF)),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Text(
                'Esta pantalla muestra toda la informacion disponible del jugador desde la API.',
                style: TextStyle(fontSize: 14, color: Color(0xFF405872)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFD8E3EF)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 15))),
        ],
      ),
    );
  }
}
