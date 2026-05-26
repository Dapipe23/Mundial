import 'package:flutter/material.dart';

import '../models/models.dart';
import '../screens/player_detail_screen.dart';
import '../services/album_data.dart';
import 'widgets/book_page_route.dart';
import 'widgets/wc_theme.dart';

class TeamDetailScreen extends StatefulWidget {
  final AlbumData albumData;
  final Team team;

  const TeamDetailScreen({super.key, required this.albumData, required this.team});

  @override
  State<TeamDetailScreen> createState() => _TeamDetailScreenState();
}

class _TeamDetailScreenState extends State<TeamDetailScreen> with SingleTickerProviderStateMixin {
  late final Future<PlayerFetchResult> _playersFuture;
  final Map<int, Player> _playersByNumber = {};
  final Map<String, int> _stickerSlotByPlayerKey = {};
  final _quickNumberController = TextEditingController();
  bool _quickMode = false;
  bool _quickDuplicate = false;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _playersFuture = widget.albumData.fetchPlayersForTeam(widget.team);
    _playersFuture.then((result) {
      if (!mounted) return;
      setState(() {
        _rebuildStickerPlayerMapping(result.players);
      });
    });
    _pulseController = AnimationController(vsync: this, duration: const Duration(milliseconds: 600))
      ..addStatusListener((s) {
        if (s == AnimationStatus.completed) _pulseController.reset();
      });
    _pulseAnim = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeOut),
    );
  }

  String _playerKey(Player player) {
    return '${player.id}|${player.name}|${player.position}|${player.club}|${player.displayPhotoUrl}';
  }

  int _slotForPlayer(Player player) {
    return _stickerSlotByPlayerKey[_playerKey(player)] ?? 0;
  }

  bool _isMetaAlbumEntry(Player p) {
    final pos = p.position.trim().toLowerCase();
    final name = p.name.trim().toLowerCase();
    const metaPositions = {
      'escudo',
      'equipo',
      'foto',
      'foto grupal',
      'team photo',
      'entrenador',
      'dt',
    };
    if (metaPositions.contains(pos)) return true;
    return name.startsWith('escudo ') || name.startsWith('seleccion ') || name.startsWith('selección ');
  }

  void _rebuildStickerPlayerMapping(List<Player> players) {
    _playersByNumber.clear();
    _stickerSlotByPlayerKey.clear();

    final regularPlayers = players.where((p) => !_isMetaAlbumEntry(p)).toList();

    final usedSlots = <int>{};

    // 1) Prefer explicit sticker slot from API when it falls in player range 2..19.
    for (final player in regularPlayers) {
      final apiSlot = player.number;
      if (apiSlot < 2 || apiSlot > 19 || usedSlots.contains(apiSlot)) {
        continue;
      }
      _playersByNumber[apiSlot] = player;
      _stickerSlotByPlayerKey[_playerKey(player)] = apiSlot;
      usedSlots.add(apiSlot);
    }

    // 2) Fallback: assign sequentially to empty slots 2..19.
    var nextSlot = 2;
    for (final player in regularPlayers) {
      if (_stickerSlotByPlayerKey.containsKey(_playerKey(player))) {
        continue;
      }
      while (nextSlot <= 19 && usedSlots.contains(nextSlot)) {
        nextSlot++;
      }
      if (nextSlot > 19) {
        break;
      }
      _playersByNumber[nextSlot] = player;
      _stickerSlotByPlayerKey[_playerKey(player)] = nextSlot;
      usedSlots.add(nextSlot);
      nextSlot++;
    }
  }

  @override
  void dispose() {
    _quickNumberController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _registerSticker(int number, {bool? duplicateMode, bool askMode = true}) async {
    if (number < 1 || number > 20) {
      _showMessage('Numero invalido. Usa valores entre 1 y 20.');
      return;
    }
    final isOwned = widget.albumData.isOwned(widget.team.name, number);
    if (isOwned) {
      _showMessage('Ya tienes esta lamina en la coleccion.');
      return;
    }

    if (!askMode) {
      final message = await widget.albumData.addSticker(
        widget.team.name, number, duplicate: duplicateMode ?? false,
      );
      _showMessage(message);
      _pulseController.forward(from: 0);
      setState(() {});
      return;
    }

    if (!mounted) return;
    final choice = await showDialog<bool>(
      context: context,
      builder: (ctx) => _buildRegisterDialog(ctx, number),
    );
    if (choice == null) return;
    final message = await widget.albumData.addSticker(widget.team.name, number, duplicate: choice);
    _showMessage(message);
    _pulseController.forward(from: 0);
    setState(() {});
  }

  Future<void> _onStickerTap(int number) async {
    final teamName = widget.team.name;
    final isOwned = widget.albumData.isOwned(teamName, number);
    final isDuplicate = widget.albumData.isDuplicate(teamName, number);

    if (!isOwned && !isDuplicate) {
      await _registerSticker(number, duplicateMode: _quickDuplicate, askMode: !_quickMode);
      return;
    }

    if (!mounted) return;
    final remove = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Lamina ya registrada'),
        content: Text(isOwned
            ? 'Esta lamina ya esta pegada. Deseas quitarla de la coleccion?'
            : 'Esta lamina esta en repetidas. Deseas quitarla?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Quitar')),
        ],
      ),
    );

    if (remove == true) {
      final message = await widget.albumData.removeSticker(teamName, number);
      _showMessage(message);
      if (mounted) setState(() {});
    }
  }

  String? _stickerImageUrl(int number) {
    if (number == 1) {
      return widget.team.escudoUrl.isEmpty ? null : widget.team.escudoUrl;
    }

    if (number == 20) {
      return null;
    }

    final player = _playersByNumber[number];
    if (player == null) {
      return null;
    }

    final display = player.displayPhotoUrl.trim();
    if (display.isNotEmpty) return display;

    return null;
  }

  String _stickerLabel(int number) {
    if (number == 1) return 'Escudo';
    if (number == 20) return 'Foto grupal';

    final player = _playersByNumber[number];
    final name = player?.name.trim() ?? '';
    if (name.isNotEmpty) return name;

    final sticker = Sticker(team: widget.team.name, number: number);
    return sticker.displayName;
  }

  Future<void> _registerFromQuickInput() async {
    final number = int.tryParse(_quickNumberController.text.trim());
    if (number == null) {
      _showMessage('Ingresa un numero de lamina valido.');
      return;
    }
    await _registerSticker(number, duplicateMode: _quickDuplicate, askMode: false);
    _quickNumberController.clear();
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

  void _showPlayerDetails(Player player) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => PlayerDetailScreen(player: player)));
  }

  Widget _buildRegisterDialog(BuildContext ctx, int number) {
    return Dialog(
      backgroundColor: const Color(0xFF132A52),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.sports_soccer_rounded, size: 40, color: Color(0xFF0B6E4F)),
            const SizedBox(height: 10),
            Text(
              'Lamina #$number',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFFEAF2FF)),
            ),
            const SizedBox(height: 8),
            Text(
              'Grupo ${widget.team.group} • ${widget.team.name}',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF0B6E4F)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Como deseas registrarla?',
              style: TextStyle(color: Color(0xFFC3D3EE)),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.check_circle_outline, size: 18),
                    label: const Text('Coleccion'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      foregroundColor: const Color(0xFF0B6E4F),
                      side: const BorderSide(color: Color(0xFF0B6E4F)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () => Navigator.pop(ctx, false),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton.icon(
                    icon: const Icon(Icons.copy, size: 18),
                    label: const Text('Repetida'),
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFFFF8C00),
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
    );
  }

  @override
  Widget build(BuildContext context) {
    final team = widget.team;
    final teamName = team.name;
    final flag = WcFlags.of(teamName);
    final groupColor = WcColors.groupColor(team.group);
    final ratio = widget.albumData.teamCompletionRate(teamName);
    final owned = widget.albumData.ownedCount(teamName);
    final dupes = widget.albumData.duplicateCount(teamName);
    final missing = widget.albumData.teamMissingCount(teamName);

    return Scaffold(
      backgroundColor: WcColors.bgLight,
      body: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF0A1C47),
                    const Color(0xFF2A124F),
                    const Color(0xFF0A3A38),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
          Positioned(top: 200, right: -70, child: _bgPulseOrb(const Color(0xFF8A0C57), 170, 0.13)),
          Positioned(top: 420, left: -50, child: _bgPulseOrb(const Color(0xFF0B3D8F), 140, 0.10)),
          CustomScrollView(
        slivers: [
          // â”€â”€ Hero SliverAppBar â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
          SliverAppBar(
            expandedHeight: 180,
            pinned: true,
            backgroundColor: groupColor,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [groupColor, WcColors.navy],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Stack(
                  children: [
                    // Watermark balls
                    Positioned(
                      right: -20,
                      top: -20,
                      child: Icon(Icons.sports_soccer_rounded, size: 130, color: Colors.white.withValues(alpha: 0.06)),
                    ),
                    Positioned(
                      left: 20,
                      bottom: -20,
                      child: Icon(Icons.sports_soccer_rounded, size: 80, color: Colors.white.withValues(alpha: 0.05)),
                    ),
                    // Content
                    SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 46, 20, 16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            ScaleTransition(
                              scale: _pulseAnim,
                              child: Text(flag, style: const TextStyle(fontSize: 52)),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.20),
                                      borderRadius: BorderRadius.circular(99),
                                    ),
                                    child: Text(
                                      'GRUPO ${team.group}',
                                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: 1.2),
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    teamName,
                                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.white),
                                  ),
                                ],
                              ),
                            ),
                            // Circular progress
                            _buildCircularProgress(ratio),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // â”€â”€ Body â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Stats row
                  _buildStatsRow(owned, dupes, missing),
                  const SizedBox(height: 14),
                  // Quick mode panel
                  _buildQuickModePanel(),
                  const SizedBox(height: 20),
                  // Players horizontal carousel
                  FutureBuilder<PlayerFetchResult>(
                    future: _playersFuture,
                    builder: (ctx, snap) {
                      if (snap.connectionState != ConnectionState.done) {
                        return const Center(child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator()));
                      }
                      final result = snap.data;
                      if (result != null && result.players.isNotEmpty) {
                        final visiblePlayers = result.players.where((p) => !_isMetaAlbumEntry(p)).toList();
                        if (visiblePlayers.isEmpty) {
                          return const SizedBox.shrink();
                        }
                        return _buildPlayersCarousel(visiblePlayers, teamName, groupColor);
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                  const SizedBox(height: 8),
                  _buildAlbumSpread(team, groupColor),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
          ),
        ],
      ),
    );
  }

  Widget _bgPulseOrb(Color color, double size, double alpha) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: alpha),
      ),
    );
  }

  Widget _buildAlbumSpread(Team team, Color groupColor) {
    final teamName = team.name;
    final owned = widget.albumData.ownedCount(teamName);
    final ratio = widget.albumData.teamCompletionRate(teamName);

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          colors: [Color(0xFF8A0C57), Color(0xFFB1105E), Color(0xFF6E0E68)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(color: const Color(0xFF5E0A47).withValues(alpha: 0.35), blurRadius: 14, offset: const Offset(0, 6)),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text('ALBUM INTERIOR', style: TextStyle(color: Colors.white.withValues(alpha: 0.95), fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1.1)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(99),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.20)),
                ),
                child: Text('Grupo ${team.group} • $owned/20', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 11)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              minHeight: 8,
              value: ratio,
              backgroundColor: const Color(0xFF2E4977),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFF3C969)),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF10253F),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF2E4E7B)),
            ),
            child: Container(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: const LinearGradient(
                  colors: [Color(0xFF18335A), Color(0xFF1A2B46)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('WE ARE ${team.name.toUpperCase()}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFFEAF2FF))),
                            const SizedBox(height: 2),
                            Text('Seleccion ${team.name} • Grupo ${team.group}', style: const TextStyle(fontSize: 11, color: Color(0xFFBFD1ED), fontWeight: FontWeight.w700)),
                          ],
                        ),
                      ),
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: groupColor.withValues(alpha: 0.16),
                        child: Text(WcFlags.of(team.name), style: const TextStyle(fontSize: 20)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Centro del libro
                  Container(height: 2, color: const Color(0xFF355885)),
                  const SizedBox(height: 10),
                  GridView.builder(
                    itemCount: 20,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 5,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                      childAspectRatio: 0.70,
                    ),
                    itemBuilder: (ctx, index) {
                      final number = index + 1;
                      final isOwned = widget.albumData.isOwned(teamName, number);
                      final isDuplicate = widget.albumData.isDuplicate(teamName, number);
                      final isSpecial = number == 1 || number == 20;

                      return Transform.translate(
                        offset: Offset(0, (index % 2 == 0) ? 0 : 1.5),
                        child: WcStickerCard(
                        number: number,
                        label: _stickerLabel(number),
                        owned: isOwned,
                        duplicate: isDuplicate,
                        isSpecial: isSpecial,
                        imageUrl: _stickerImageUrl(number),
                        accentColor: groupColor,
                        onTap: () => _onStickerTap(number),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _navArrowButton(icon: Icons.chevron_left_rounded, onTap: () => _goToTeamOffset(-1)),
              const SizedBox(width: 10),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 9),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.80),
                    borderRadius: BorderRadius.circular(99),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.20)),
                  ),
                  child: Text(
                    team.name.toUpperCase(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 0.8),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              _navArrowButton(icon: Icons.chevron_right_rounded, onTap: () => _goToTeamOffset(1)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _navArrowButton({required IconData icon, required VoidCallback onTap}) {
    return Material(
      color: const Color(0xFF162C52),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 42,
          height: 42,
          child: Icon(icon, color: const Color(0xFFEAF2FF), size: 28),
        ),
      ),
    );
  }

  void _goToTeamOffset(int delta) {
    final teams = widget.albumData.teams;
    if (teams.isEmpty) return;

    final currentIndex = teams.indexWhere((t) => t.id == widget.team.id);
    if (currentIndex < 0) return;

    var nextIndex = currentIndex + delta;
    if (nextIndex < 0) {
      nextIndex = teams.length - 1;
    } else if (nextIndex >= teams.length) {
      nextIndex = 0;
    }

    final nextTeam = teams[nextIndex];
    playBookFlipFeedback();
    Navigator.of(context).pushReplacement(
      buildBookPageRoute(
        reverseFlip: delta < 0,
        child: TeamDetailScreen(albumData: widget.albumData, team: nextTeam),
      ),
    );
  }

  Widget _buildCircularProgress(double ratio) {
    final pct = (ratio * 100).round();
    return SizedBox(
      width: 62,
      height: 62,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: ratio,
            strokeWidth: 5,
            backgroundColor: const Color(0xFF2E4A79),
            valueColor: AlwaysStoppedAnimation<Color>(WcColors.gold),
          ),
          Text(
            '$pct%',
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(int owned, int dupes, int missing) {
    return Row(
      children: [
        Expanded(
          child: WcStatChip(
            icon: Icons.check_circle_rounded,
            value: '$owned',
            label: 'Pegadas',
            color: const Color(0xFF15803D),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: WcStatChip(
            icon: Icons.copy_rounded,
            value: '$dupes',
            label: 'Repetidas',
            color: const Color(0xFFD97706),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: WcStatChip(
            icon: Icons.hourglass_empty_rounded,
            value: '$missing',
            label: 'Faltan',
            color: const Color(0xFFDC2626),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickModePanel() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      decoration: BoxDecoration(
        gradient: _quickMode
            ? const LinearGradient(
                colors: [Color(0xFF062A5A), Color(0xFF0B3D8F)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : const LinearGradient(
                colors: [Color(0xFF182E5C), Color(0xFF2D1F59)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: _quickMode ? WcColors.gold.withValues(alpha: 0.5) : const Color(0xFFDEE8F2),
          width: _quickMode ? 1.5 : 1.0,
        ),
        boxShadow: _quickMode
            ? [BoxShadow(color: WcColors.navy.withValues(alpha: 0.30), blurRadius: 12, offset: const Offset(0, 4))]
            : [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 4)],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: _quickMode ? WcColors.gold.withValues(alpha: 0.20) : const Color(0xFFDCEAFE),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.bolt_rounded, size: 18, color: _quickMode ? WcColors.gold : WcColors.navy),
                ),
                const SizedBox(width: 10),
                Text(
                  'Modo registro rapido',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                    color: _quickMode ? Colors.white : WcColors.navy,
                  ),
                ),
                const Spacer(),
                Switch(
                  value: _quickMode,
                  onChanged: (v) => setState(() => _quickMode = v),
                  activeThumbColor: WcColors.gold,
                  activeTrackColor: WcColors.gold.withValues(alpha: 0.35),
                  inactiveThumbColor: const Color(0xFF6B7280),
                  inactiveTrackColor: const Color(0xFFD1D5DB),
                ),
              ],
            ),
            if (_quickMode) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  _modeChip('Pegada', !_quickDuplicate, () => setState(() => _quickDuplicate = false)),
                  const SizedBox(width: 8),
                  _modeChip('Repetida', _quickDuplicate, () => setState(() => _quickDuplicate = true)),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _quickNumberController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                      decoration: InputDecoration(
                        hintText: 'No de lamina (1-20)',
                        hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.45), fontSize: 13),
                        isDense: true,
                        filled: true,
                        fillColor: Colors.white.withValues(alpha: 0.10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.20)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.20)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: WcColors.gold, width: 1.5),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  FilledButton.icon(
                    icon: const Icon(Icons.add_rounded, size: 18),
                    label: const Text('Registrar'),
                    style: FilledButton.styleFrom(
                      backgroundColor: WcColors.gold,
                      foregroundColor: WcColors.navy,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      textStyle: const TextStyle(fontWeight: FontWeight.w800),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: _registerFromQuickInput,
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _modeChip(String label, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? WcColors.gold : Colors.white.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(99),
          border: Border.all(
            color: selected ? WcColors.gold : Colors.white.withValues(alpha: 0.25),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? WcColors.navy : Colors.white.withValues(alpha: 0.80),
            fontWeight: FontWeight.w800,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildPlayersCarousel(List<Player> players, String teamName, Color groupColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'PLANTILLA',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: WcColors.navy, letterSpacing: 1.0),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                color: groupColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(99),
                border: Border.all(color: groupColor.withValues(alpha: 0.25)),
              ),
              child: Text('${players.length} jugadores', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: groupColor)),
            ),
          ],
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 130,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: players.length,
            separatorBuilder: (context, index) => const SizedBox(width: 8),
            itemBuilder: (ctx, i) {
              final player = players[i];
              final slot = _slotForPlayer(player);
              final hasSlot = slot >= 2 && slot <= 19;
              final isOwned = hasSlot && widget.albumData.isOwned(teamName, slot);
              final isDuplicate = hasSlot && widget.albumData.isDuplicate(teamName, slot);
              return GestureDetector(
                onTap: () => _showPlayerDetails(player),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 90,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isOwned
                          ? [const Color(0xFFE2FCEB), const Color(0xFFF3FFF8)]
                          : [const Color(0xFF1A315B), const Color(0xFF2C214F)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isOwned ? groupColor.withValues(alpha: 0.4) : const Color(0xFFDEE8F2),
                      width: isOwned ? 1.6 : 1,
                    ),
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4)],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: isOwned ? groupColor : const Color(0xFFE5EBF2),
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: isOwned
                            ? const Icon(Icons.check, color: Colors.white, size: 18)
                            : Text(
                                hasSlot ? '$slot' : '-',
                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Color(0xFF8499B2)),
                              ),
                      ),
                      const SizedBox(height: 6),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: Text(
                          player.name.split(' ').last,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: isOwned ? groupColor : const Color(0xFF3D4F62),
                          ),
                        ),
                      ),
                      if (player.position.isNotEmpty)
                        Text(
                          player.position,
                          style: const TextStyle(fontSize: 9, color: Color(0xFF9BA8B4)),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      if (isDuplicate)
                        Container(
                          margin: const EdgeInsets.only(top: 4),
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF8C00),
                            borderRadius: BorderRadius.circular(99),
                          ),
                          child: const Text('2x', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w800)),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
