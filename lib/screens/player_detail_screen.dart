import 'package:flutter/material.dart';

import '../models/player.dart';

class PlayerDetailScreen extends StatelessWidget {
  final Player player;

  const PlayerDetailScreen({super.key, required this.player});

  String _proxyImageUrl(String url) {
    final raw = url.trim();
    if (raw.isEmpty) return raw;
    final noScheme = raw.replaceFirst(RegExp(r'^https?://'), '');
    final encoded = Uri.encodeComponent(noScheme);
    return 'https://images.weserv.nl/?url=$encoded&w=520&h=520&fit=cover';
  }

  Widget _playerPhoto() {
    final urls = <String>[];

    final display = player.displayPhotoUrl.trim();
    if (display.isNotEmpty) {
      urls.add(display);
    }

    if (urls.isEmpty) {
      return _nameFallback();
    }

    return _networkWithFallback(urls, 0);
  }

  Widget _nameFallback() {
    final shirt = player.number == 0 ? 'N/A' : player.number.toString();
    final position = player.position.trim().isEmpty ? 'Sin posicion' : player.position.trim();

    return Container(
      width: 180,
      height: 180,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A315B), Color(0xFF2C214F), Color(0xFF0B6E4F)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0x55F3C969)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFFF3C969).withValues(alpha: 0.18),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0x99F3C969)),
                ),
                child: const Icon(Icons.person_rounded, size: 20, color: Color(0xFFF3C969)),
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'FOTO NO DISPONIBLE',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Color(0xFFF3C969),
                    fontSize: 10.5,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.9,
                    height: 1.1,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Expanded(
            child: Center(
              child: Text(
                player.name,
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  height: 1.1,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              _fallbackChip('No $shirt'),
              _fallbackChip(position),
            ],
          ),
        ],
      ),
    );
  }

  Widget _fallbackChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: Colors.white.withValues(alpha: 0.26)),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFFEAF2FF),
          fontWeight: FontWeight.w800,
          fontSize: 10,
        ),
      ),
    );
  }

  Widget _networkWithFallback(List<String> urls, int index) {
    if (index >= urls.length) {
      return _nameFallback();
    }

    final raw = urls[index];

    return Image.network(
      raw,
      width: 180,
      height: 180,
      fit: BoxFit.cover,
      webHtmlElementStrategy: WebHtmlElementStrategy.prefer,
      errorBuilder: (context, error, stackTrace) {
        final proxy = _proxyImageUrl(raw);
        if (proxy != raw) {
          return Image.network(
            proxy,
            width: 180,
            height: 180,
            fit: BoxFit.cover,
            webHtmlElementStrategy: WebHtmlElementStrategy.prefer,
            errorBuilder: (context, error2, stackTrace2) => _networkWithFallback(urls, index + 1),
          );
        }
        return _networkWithFallback(urls, index + 1);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    const bgTop = Color(0xFF0A1C47);
    const bgMid = Color(0xFF2A124F);
    const bgBottom = Color(0xFF47136B);

    return Scaffold(
      backgroundColor: const Color(0xFF0A1C47),
      appBar: AppBar(
        title: Text(player.name),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [bgTop, bgMid, bgBottom],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
          Positioned(top: -40, right: -30, child: _orb(const Color(0xFF0B6E4F), 150, 0.20)),
          Positioned(bottom: 120, left: -50, child: _orb(const Color(0xFF1D4ED8), 170, 0.18)),
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 6, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeroCard(),
                const SizedBox(height: 16),
                _buildIdentityCard(),
                if (_hasRatings(player)) ...[
                  const SizedBox(height: 16),
                  const Text(
                    'ESTADISTICAS',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFFF3C969),
                      letterSpacing: 1.1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _ratingsGrid(player),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _orb(Color color, double size, double alpha) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: alpha),
      ),
    );
  }

  Widget _buildHeroCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [Color(0xFF062A5A), Color(0xFF2B1F6B), Color(0xFF0B6E4F)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: const Color(0x55F3C969)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF061B3C).withValues(alpha: 0.45),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: SizedBox(width: 100, height: 110, child: _playerPhoto()),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'FICHA OFICIAL',
                  style: TextStyle(
                    color: Color(0xFFF3C969),
                    fontWeight: FontWeight.w900,
                    fontSize: 11,
                    letterSpacing: 1.1,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  player.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 22,
                    height: 1.0,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    _heroChip('No ${player.number == 0 ? 'N/A' : player.number}'),
                    if (player.position.isNotEmpty) _heroChip(player.position),
                    if (player.age > 0) _heroChip('${player.age} anos'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _heroChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: Colors.white.withValues(alpha: 0.22)),
      ),
      child: Text(
        text,
        style: const TextStyle(color: Color(0xFFEAF2FF), fontWeight: FontWeight.w800, fontSize: 11),
      ),
    );
  }

  Widget _buildIdentityCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: const Color(0xFF162A52),
        border: Border.all(color: const Color(0x334986D6)),
      ),
      child: Column(
        children: [
          _detailRow('Nombre', player.name),
          _detailRow('Numero', player.number == 0 ? 'N/A' : player.number.toString()),
          if (player.position.isNotEmpty) _detailRow('Posicion', player.position),
          if (player.club.isNotEmpty) _detailRow('Club', player.club),
          if (player.birthDate.isNotEmpty) _detailRow('Nacimiento', player.birthDate),
          if (player.height.isNotEmpty) _detailRow('Altura', player.height),
          if (player.weight.isNotEmpty) _detailRow('Peso', player.weight),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1B3562),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0x335C89C8)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: Color(0xFFF3C969))),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 15, color: Color(0xFFE6EEFF)))),
        ],
      ),
    );
  }

  bool _hasRatings(Player p) {
    return p.dribbling > 0 || p.speed > 0 || p.shooting > 0 || p.defending > 0 || p.passing > 0 || p.physical > 0;
  }

  Widget _ratingsGrid(Player p) {
    final stats = [
      ('Dribbling', p.dribbling),
      ('Velocidad', p.speed),
      ('Tiro', p.shooting),
      ('Defensa', p.defending),
      ('Pase', p.passing),
      ('Fisico', p.physical),
    ];

    final validStats = stats.where((s) => s.$2 > 0).toList();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF162A52),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0x335C89C8)),
      ),
      child: Column(
        children: validStats
            .map(
              (s) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _ratingBar(s.$1, s.$2),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _ratingBar(String label, int value) {
    final safe = value.clamp(0, 99);
    final ratio = safe / 99;
    final color = _ratingColor(safe);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFFEAF2FF)),
              ),
            ),
            Text(
              '$safe',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: color),
            ),
          ],
        ),
        const SizedBox(height: 5),
        ClipRRect(
          borderRadius: BorderRadius.circular(99),
          child: LinearProgressIndicator(
            minHeight: 9,
            value: ratio,
            backgroundColor: const Color(0xFF2A4068),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }

  Color _ratingColor(int value) {
    if (value >= 85) return const Color(0xFF16A34A);
    if (value >= 70) return const Color(0xFFCA8A04);
    return const Color(0xFFDC2626);
  }
}
