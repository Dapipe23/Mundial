import 'package:flutter/material.dart';

import '../services/album_data.dart';
import 'widgets/wc_theme.dart';

class ExchangeScreen extends StatefulWidget {
  final AlbumData albumData;

  const ExchangeScreen({super.key, required this.albumData});

  @override
  State<ExchangeScreen> createState() => _ExchangeScreenState();
}

class _ExchangeScreenState extends State<ExchangeScreen> {
  @override
  Widget build(BuildContext context) {
    final offers = widget.albumData.listOffers();
    final matches = widget.albumData.findMatches();
    final openCount = offers.where((e) => e.status == ExchangeStatus.open).length;

    return Stack(
      children: [
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF0A1D49),
                  const Color(0xFF261149),
                  const Color(0xFF0A3A3C),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ),
        Positioned(top: -90, right: -60, child: _bgGlow(const Color(0xFF7C3AED))),
        Positioned(top: 260, left: -80, child: _bgGlow(const Color(0xFF1E40AF))),
        Positioned(bottom: 110, right: -70, child: _bgGlow(const Color(0xFF0B6E4F))),
        SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
          // â”€â”€ Hero banner â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
          WcBanner(
            title: 'Zona de Intercambios',
            subtitle: 'Intercambia repetidas, encuentra match bilateral y completa tu album.',
            colors: const [Color(0xFF0B3D8F), Color(0xFF0B6E4F)],
          ),
          const SizedBox(height: 16),
          // â”€â”€ Stats row â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
          Row(
            children: [
              Expanded(
                child: WcStatChip(
                  icon: Icons.layers_rounded,
                  value: '${widget.albumData.totalDuplicates()}',
                  label: 'Repetidas',
                  color: const Color(0xFF0B6E4F),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: WcStatChip(
                  icon: Icons.campaign_rounded,
                  value: '$openCount',
                  label: 'Ofertas',
                  color: const Color(0xFFD97706),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: WcStatChip(
                  icon: Icons.handshake_rounded,
                  value: '${matches.length}',
                  label: 'Matches',
                  color: const Color(0xFF1E40AF),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // â”€â”€ Create offer button â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              icon: const Icon(Icons.add_circle_outline_rounded, size: 20),
              label: const Text('Crear oferta de intercambio'),
              style: FilledButton.styleFrom(
                backgroundColor: WcColors.navy,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                textStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
              ),
              onPressed: _openCreateOffer,
            ),
          ),
          const SizedBox(height: 24),
          // â”€â”€ Matches section â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
          _sectionHeader('MATCHES SUGERIDOS', matches.length),
          const SizedBox(height: 10),
          if (matches.isEmpty)
            _emptyCard(
              icon: Icons.sports_soccer_rounded,
              title: 'Aun no hay match bilateral.',
              subtitle: 'Publica ofertas desde tus repetidas para que el sistema encuentre un partner.',
            )
          else
            ...matches.map(_buildMatchTile),
          const SizedBox(height: 22),
          // â”€â”€ My offers section â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
          _sectionHeader('MIS OFERTAS', offers.length),
          const SizedBox(height: 10),
          if (offers.isEmpty)
            _emptyCard(
              icon: Icons.style_rounded,
              title: 'Sin ofertas publicadas.',
              subtitle: 'Usa el boton de arriba para publicar tu primera oferta.',
            )
          else
            ...offers.map(_buildOfferTile),
            ],
          ),
        ),
      ],
    );
  }

  Widget _bgGlow(Color color) {
    return Container(
      width: 200,
      height: 200,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: 0.13),
      ),
    );
  }

  Widget _sectionHeader(String title, int count) {
    return Row(
      children: [
        Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Color(0xFFEAF2FF), letterSpacing: 1.0)),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: const Color(0xFFEAF2FF).withValues(alpha: 0.16),
            borderRadius: BorderRadius.circular(99),
          ),
          child: Text('$count', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFFEAF2FF))),
        ),
        const SizedBox(width: 8),
        const Expanded(child: Divider(color: Color(0xFF7F93B5), thickness: 1.2)),
      ],
    );
  }

  Widget _emptyCard({required IconData icon, required String title, required String subtitle}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF172D5A), Color(0xFF31205E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF6F88B8)),
        boxShadow: [
          BoxShadow(color: const Color(0xFF1E40AF).withValues(alpha: 0.22), blurRadius: 12, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, size: 36, color: const Color(0xFFF3C969)),
          const SizedBox(height: 8),
          Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: Color(0xFFEAF2FF))),
          const SizedBox(height: 4),
          Text(subtitle, style: const TextStyle(fontSize: 12.5, color: Color(0xFFBFD0EA)), textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildMatchTile(ExchangeMatch match) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1B2F5B), Color(0xFF2B1F55)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFADC3F4), width: 1.5),
        boxShadow: [BoxShadow(color: const Color(0xFF1E40AF).withValues(alpha: 0.06), blurRadius: 8, offset: const Offset(0, 3))],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
            decoration: BoxDecoration(
              color: const Color(0xFF1E40AF).withValues(alpha: 0.18),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(17)),
            ),
            child: Row(
              children: [
                const Icon(Icons.handshake_rounded, size: 20, color: Color(0xFF1E40AF)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Match con ${match.partnerName}',
                    style: const TextStyle(fontWeight: FontWeight.w800, color: Color(0xFFEAF2FF), fontSize: 14),
                  ),
                ),
                FilledButton(
                  onPressed: () async {
                    await widget.albumData.updateOfferStatus(match.userOffer.id, ExchangeStatus.matched);
                    if (!mounted) return;
                    setState(() {});
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF1E40AF),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    textStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
                  ),
                  child: const Text('Confirmar'),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Expanded(child: _exchangeArrow('Tu ofreces', match.userOffer.offering, 'OFRECES', const Color(0xFF0B6E4F))),
                const Icon(Icons.swap_horiz_rounded, color: Color(0xFF8499B2), size: 28),
                Expanded(child: _exchangeArrow('Tu pides', match.userOffer.wanting, 'PIDES', const Color(0xFFD97706))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _exchangeArrow(String title, StickerRef ref, String emoji, Color color) {
    return Container(
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.20)),
      ),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 3),
          Text(title, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: color)),
          const SizedBox(height: 2),
          _stickerLabelText(ref, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF1A2940))),
        ],
      ),
    );
  }

  Widget _buildOfferTile(ExchangeOffer offer) {
    final tone = _statusTone(offer.status);
    final statusText = _statusText(offer.status);
    final statusIcon = _statusIcon(offer.status);
    final isOpen = offer.status == ExchangeStatus.open;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            tone.withValues(alpha: 0.25),
            const Color(0xFF182D57),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: tone.withValues(alpha: 0.25)),
        boxShadow: [BoxShadow(color: tone.withValues(alpha: 0.10), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 8),
            decoration: BoxDecoration(
              color: tone.withValues(alpha: 0.08),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(17)),
            ),
            child: Row(
              children: [
                Icon(statusIcon, size: 16, color: tone),
                const SizedBox(width: 8),
                Expanded(
                  child: _stickerPairLabelText(
                    offer.offering,
                    offer.wanting,
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: Color(0xFFEAF2FF)),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: tone.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(99),
                    border: Border.all(color: tone.withValues(alpha: 0.30)),
                  ),
                  child: Text(statusText, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: tone)),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 8, 14, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(offer.type == ExchangeType.virtual ? Icons.wifi_rounded : Icons.local_shipping_rounded,
                        size: 14, color: const Color(0xFF8499B2)),
                    const SizedBox(width: 5),
                    Text(
                      offer.type == ExchangeType.virtual ? 'Modalidad virtual' : 'Presencial / envio nacional',
                      style: const TextStyle(fontSize: 12, color: Color(0xFFC3D3EE)),
                    ),
                  ],
                ),
                if ((offer.note ?? '').trim().isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Nota: ${offer.note}',
                    style: const TextStyle(fontSize: 12, color: Color(0xFFC3D3EE)),
                  ),
                ],
                if (isOpen) ...[
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.check_circle_outline, size: 16),
                          label: const Text('Completar'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF15803D),
                            side: const BorderSide(color: Color(0xFF15803D)),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
                          ),
                          onPressed: () async {
                            await widget.albumData.updateOfferStatus(offer.id, ExchangeStatus.completed);
                            if (!mounted) return;
                            setState(() {});
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.cancel_outlined, size: 16),
                          label: const Text('Cancelar'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFFDC2626),
                            side: const BorderSide(color: Color(0xFFDC2626)),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
                          ),
                          onPressed: () async {
                            await widget.albumData.updateOfferStatus(offer.id, ExchangeStatus.cancelled);
                            if (!mounted) return;
                            setState(() {});
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openCreateOffer() async {
    final duplicates = widget.albumData.duplicateStickerRefs();
    final missing = widget.albumData.missingStickerRefs();

    if (duplicates.isEmpty) {
      _showMessage('No tienes repetidas para ofrecer. Marca primero laminas repetidas en cada equipo.');
      return;
    }
    if (missing.isEmpty) {
      _showMessage('Coleccion completa. Ya no tienes laminas pendientes.');
      return;
    }

    StickerRef offering = duplicates.first;
    StickerRef wanting = missing.first;
    ExchangeType type = ExchangeType.virtual;
    final noteController = TextEditingController();

    final created = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setStateDialog) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Nueva oferta', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF062A5A))),
                const SizedBox(height: 4),
                const Text('Elige que ofreces y que necesitas', style: TextStyle(fontSize: 12, color: Color(0xFF6B84A0))),
                const SizedBox(height: 18),
                DropdownButtonFormField<StickerRef>(
                  initialValue: offering,
                  decoration: const InputDecoration(labelText: 'Lamina que ofreces'),
                  items: duplicates
                      .map(
                        (item) => DropdownMenuItem<StickerRef>(
                          value: item,
                          child: _stickerLabelText(item),
                        ),
                      )
                      .toList(),
                  onChanged: (v) { if (v != null) setStateDialog(() => offering = v); },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<StickerRef>(
                  initialValue: wanting,
                  decoration: const InputDecoration(labelText: 'Lamina que necesitas'),
                  items: missing
                      .map(
                        (item) => DropdownMenuItem<StickerRef>(
                          value: item,
                          child: _stickerLabelText(item),
                        ),
                      )
                      .toList(),
                  onChanged: (v) { if (v != null) setStateDialog(() => wanting = v); },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<ExchangeType>(
                  initialValue: type,
                  decoration: const InputDecoration(labelText: 'Modalidad'),
                  items: const [
                    DropdownMenuItem(value: ExchangeType.virtual, child: Text('Virtual (coordinar por chat)')),
                    DropdownMenuItem(value: ExchangeType.physical, child: Text('Presencial / envio nacional')),
                  ],
                  onChanged: (v) { if (v != null) setStateDialog(() => type = v); },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: noteController,
                  decoration: const InputDecoration(
                    labelText: 'Nota de contacto (opcional)',
                    hintText: 'Ej: ciudad, horario, etc.',
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Cancelar'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: FilledButton.icon(
                        icon: const Icon(Icons.campaign_rounded, size: 18),
                        label: const Text('Publicar'),
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () => Navigator.pop(ctx, true),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );

    final note = noteController.text.trim();
    noteController.dispose();
    if (created != true) return;

    final message = await widget.albumData.createOffer(
      offering: offering,
      wanting: wanting,
      type: type,
      note: note.isEmpty ? null : note,
    );
    if (!mounted) return;
    _showMessage(message);
    setState(() {});
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(fontWeight: FontWeight.w600)),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        backgroundColor: WcColors.navy,
      ),
    );
  }

  Color _statusTone(ExchangeStatus status) {
    switch (status) {
      case ExchangeStatus.open:      return const Color(0xFFD97706);
      case ExchangeStatus.matched:   return const Color(0xFF1E40AF);
      case ExchangeStatus.completed: return const Color(0xFF15803D);
      case ExchangeStatus.cancelled: return const Color(0xFFDC2626);
    }
  }

  String _statusText(ExchangeStatus status) {
    switch (status) {
      case ExchangeStatus.open:      return 'Abierta';
      case ExchangeStatus.matched:   return 'Match';
      case ExchangeStatus.completed: return 'Completada';
      case ExchangeStatus.cancelled: return 'Cancelada';
    }
  }

  IconData _statusIcon(ExchangeStatus status) {
    switch (status) {
      case ExchangeStatus.open:
        return Icons.campaign_rounded;
      case ExchangeStatus.matched:
        return Icons.handshake_rounded;
      case ExchangeStatus.completed:
        return Icons.check_circle_rounded;
      case ExchangeStatus.cancelled:
        return Icons.cancel_rounded;
    }
  }

  String _stickerLabel(StickerRef ref) {
    final group = _groupForTeam(ref.teamName);
    final type = _stickerTypeLabel(ref.number);
    return 'Grupo $group • ${ref.teamName} • #${ref.number} • $type';
  }

  Widget _stickerLabelText(StickerRef ref, {TextStyle? style}) {
    return FutureBuilder<String>(
      future: widget.albumData.stickerDisplayLabel(ref),
      builder: (context, snapshot) {
        final text = snapshot.data ?? _stickerLabel(ref);
        return Text(
          text,
          style: style,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        );
      },
    );
  }

  Widget _stickerPairLabelText(StickerRef offering, StickerRef wanting, {TextStyle? style}) {
    return FutureBuilder<String>(
      future: widget.albumData.stickerExchangeLabel(offering, wanting),
      builder: (context, snapshot) {
        final text = snapshot.data ?? '${_stickerLabel(offering)} -> ${_stickerLabel(wanting)}';
        return Text(
          text,
          style: style,
          overflow: TextOverflow.ellipsis,
        );
      },
    );
  }

  String _groupForTeam(String teamName) {
    for (final team in widget.albumData.teams) {
      if (team.name.toLowerCase() == teamName.toLowerCase()) {
        return team.group;
      }
    }
    return '?';
  }

  String _stickerTypeLabel(int number) {
    if (number == 1) return 'Escudo';
    if (number == 20) return 'Foto de equipo';
    return 'Jugador';
  }
}


