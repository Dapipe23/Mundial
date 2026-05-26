import 'package:flutter/material.dart';

import '../models/player.dart';
import '../models/team.dart';
import '../services/album_data.dart';
import 'team_detail_screen.dart';
import 'widgets/book_page_route.dart';
import 'widgets/wc_theme.dart';

class AlbumBookScreen extends StatefulWidget {
  final AlbumData albumData;

  const AlbumBookScreen({super.key, required this.albumData});

  @override
  State<AlbumBookScreen> createState() => _AlbumBookScreenState();
}

class _AlbumBookScreenState extends State<AlbumBookScreen> {
  static const _coverAsset = 'assets/images/world_cup_2026_logo.png';

  late final PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.96);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToPage(int page, int totalPages, {bool withFlipSound = false}) {
    if (page < 0 || page >= totalPages) return;
    if (withFlipSound) {
      playBookFlipFeedback();
    }
    _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 560),
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final teams = [...widget.albumData.teams]
      ..sort((a, b) {
        final groupCompare = a.group.compareTo(b.group);
        if (groupCompare != 0) return groupCompare;
        return a.name.compareTo(b.name);
      });

    final totalPages = teams.length + 1;

    return Stack(
      children: [
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF8D1265),
                  const Color(0xFFB62281),
                  const Color(0xFFC63E97),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ),
        Positioned(top: 24, right: -26, child: _orb(const Color(0xFF6E0E54), 170, 0.20)),
        Positioned(bottom: 70, left: -36, child: _orb(const Color(0xFF5A1456), 180, 0.18)),
        SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
                child: _BookTopBar(
                  pageText: _currentPage == 0
                      ? 'Portada'
                      : '$_currentPage / ${teams.length}',
                  canPrev: _currentPage > 0,
                  canNext: _currentPage < totalPages - 1,
                  onPrev: () => _goToPage(_currentPage - 1, totalPages, withFlipSound: true),
                  onNext: () => _goToPage(_currentPage + 1, totalPages, withFlipSound: true),
                  onGoCover: () => _goToPage(0, totalPages),
                ),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: totalPages,
                  onPageChanged: (page) => setState(() => _currentPage = page),
                  itemBuilder: (context, index) {
                    final page = _buildPage(index, teams);
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(10, 4, 10, 16),
                      child: _PageLeaf(
                        controller: _pageController,
                        index: index,
                        child: page,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPage(int index, List<Team> teams) {
    if (index == 0) {
      return const _CoverSpread(assetPath: _coverAsset);
    }

    final team = teams[index - 1];
    return _AlbumSpreadPage(
      team: team,
      pageNumber: index,
      albumData: widget.albumData,
      onOpenTeam: () {
        Navigator.of(context).push(
          buildBookPageRoute(
            child: TeamDetailScreen(albumData: widget.albumData, team: team),
          ),
        );
      },
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
}

class _BookTopBar extends StatelessWidget {
  final String pageText;
  final bool canPrev;
  final bool canNext;
  final VoidCallback onPrev;
  final VoidCallback onNext;
  final VoidCallback onGoCover;

  const _BookTopBar({
    required this.pageText,
    required this.canPrev,
    required this.canNext,
    required this.onPrev,
    required this.onNext,
    required this.onGoCover,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          colors: [Color(0xFF8B185F), Color(0xFFC52688)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4E123D).withValues(alpha: 0.35),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          _navButton(icon: Icons.chevron_left_rounded, onTap: canPrev ? onPrev : null),
          const SizedBox(width: 8),
          _navButton(icon: Icons.chevron_right_rounded, onTap: canNext ? onNext : null),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(99),
              border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
            ),
            child: Text(
              pageText,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
            ),
          ),
          const Spacer(),
          TextButton.icon(
            onPressed: onGoCover,
            style: TextButton.styleFrom(foregroundColor: Colors.white),
            icon: const Icon(Icons.home_filled),
            label: const Text('Portada'),
          ),
        ],
      ),
    );
  }

  Widget _navButton({required IconData icon, required VoidCallback? onTap}) {
    return Material(
      color: onTap == null ? const Color(0xFFB973A0) : Colors.white,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: SizedBox(
          width: 40,
          height: 34,
          child: Icon(
            icon,
            color: onTap == null ? const Color(0xFFF5D5EB) : const Color(0xFF8B185F),
            size: 26,
          ),
        ),
      ),
    );
  }
}

class _PageLeaf extends StatelessWidget {
  final PageController controller;
  final int index;
  final Widget child;

  const _PageLeaf({
    required this.controller,
    required this.index,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      child: child,
      builder: (context, pageChild) {
        double page = controller.initialPage.toDouble();
        if (controller.hasClients) {
          page = controller.page ?? controller.initialPage.toDouble();
        }

        final delta = index - page;
        final clamped = delta.clamp(-1.0, 1.0);
        final absDelta = clamped.abs();
        final rotateY = clamped * 0.58;
        final rotateZ = clamped * 0.03;
        final scale = 1.0 - (absDelta * 0.055);
        final elevation = 0.14 + (0.24 * (1 - absDelta));
        final foldStrength = (1.0 - absDelta).clamp(0.0, 1.0);
        final paperShadow = 0.42 * foldStrength;
        final edgeGlow = 0.30 * foldStrength;
        final bendInset = 26.0 * foldStrength;
        final turnFromRight = clamped <= 0;
        final edgeAlignment = turnFromRight ? Alignment.centerRight : Alignment.centerLeft;
        final bendAlignment = turnFromRight ? Alignment.centerLeft : Alignment.centerRight;

        return Transform(
          alignment: clamped > 0 ? Alignment.centerLeft : Alignment.centerRight,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.0024)
            ..rotateY(rotateY)
            ..rotateZ(rotateZ)
            ..scaleByDouble(scale, scale, 1, 1),
          child: DecoratedBox(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: elevation),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  pageChild!,
                  // Oscurece el reverso durante el giro para simular papel doblado.
                  Positioned.fill(
                    child: IgnorePointer(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: turnFromRight
                                ? [
                                    Colors.black.withValues(alpha: paperShadow),
                                    Colors.black.withValues(alpha: 0.02),
                                  ]
                                : [
                                    Colors.black.withValues(alpha: 0.02),
                                    Colors.black.withValues(alpha: paperShadow),
                                  ],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Destello del borde de la hoja al girar.
                  Align(
                    alignment: edgeAlignment,
                    child: IgnorePointer(
                      child: Container(
                        width: 10,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.white.withValues(alpha: edgeGlow),
                              Colors.white.withValues(alpha: 0.0),
                            ],
                            begin: turnFromRight ? Alignment.centerRight : Alignment.centerLeft,
                            end: turnFromRight ? Alignment.centerLeft : Alignment.centerRight,
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Sombra de curvatura cerca del lomo para efecto de hoja flexible.
                  Align(
                    alignment: bendAlignment,
                    child: IgnorePointer(
                      child: Container(
                        width: bendInset,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.black.withValues(alpha: 0.16 * foldStrength),
                              Colors.black.withValues(alpha: 0.0),
                            ],
                            begin: turnFromRight ? Alignment.centerLeft : Alignment.centerRight,
                            end: turnFromRight ? Alignment.centerRight : Alignment.centerLeft,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _CoverSpread extends StatelessWidget {
  final String assetPath;

  const _CoverSpread({required this.assetPath});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [Color(0xFFB0124B), Color(0xFF8D0E4D), Color(0xFF6E103F)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        border: Border.all(color: const Color(0xFFD75387), width: 1.2),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(26, 16, 26, 20),
          child: AspectRatio(
            aspectRatio: 0.72,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.36),
                    blurRadius: 24,
                    offset: const Offset(0, 14),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(28),
                      child: Image.asset(assetPath, fit: BoxFit.cover),
                    ),
                  ),
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(28),
                        gradient: LinearGradient(
                          colors: [
                            Colors.black.withValues(alpha: 0.12),
                            Colors.black.withValues(alpha: 0.58),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 14,
                    top: 12,
                    bottom: 12,
                    child: Container(
                      width: 11,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(9),
                        gradient: const LinearGradient(
                          colors: [Color(0xFF4D1B61), Color(0xFF9F2B8A), Color(0xFF4D1B61)],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 30,
                    right: 22,
                    bottom: 24,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'ALBUM OFICIAL',
                          style: TextStyle(
                            color: Color(0xFFF3C969),
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.2,
                          ),
                        ),
                        SizedBox(height: 3),
                        Text(
                          'MUNDIAL 2026',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Usa las flechas para pasar hojas',
                          style: TextStyle(
                            color: Color(0xFFF5D5EB),
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AlbumSpreadPage extends StatelessWidget {
  final Team team;
  final int pageNumber;
  final AlbumData albumData;
  final VoidCallback onOpenTeam;

  const _AlbumSpreadPage({
    required this.team,
    required this.pageNumber,
    required this.albumData,
    required this.onOpenTeam,
  });

  @override
  Widget build(BuildContext context) {
    final groupColor = WcColors.groupColor(team.group);
    final completion = albumData.teamCompletionRate(team.name);
    final owned = albumData.ownedCount(team.name);
    final missing = albumData.teamMissingCount(team.name);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [Color(0xFFB0124B), Color(0xFF8D0E4D), Color(0xFF6E103F)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        border: Border.all(color: const Color(0xFFD75387), width: 1.2),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(10),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight - 20),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  color: const Color(0xFFCC2D67),
                  border: Border.all(color: const Color(0xFFE97FAA), width: 1),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(14, 14, 10, 14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              team.name.toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                fontSize: 26,
                                height: 1.0,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'GROUP ${team.group}  ·  PAGINA $pageNumber',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.9),
                                fontWeight: FontWeight.w700,
                                fontSize: 11,
                                letterSpacing: 0.9,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Text(WcFlags.of(team.name), style: const TextStyle(fontSize: 32)),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(99),
                                    child: LinearProgressIndicator(
                                      minHeight: 8,
                                      value: completion,
                                      backgroundColor: Colors.white.withValues(alpha: 0.26),
                                      valueColor: AlwaysStoppedAnimation<Color>(groupColor),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '$owned/20 pegadas · Faltan $missing',
                              style: const TextStyle(
                                color: Color(0xFFFDEAF3),
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 14),
                            FilledButton.icon(
                              onPressed: onOpenTeam,
                              style: FilledButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: const Color(0xFF8B185F),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              icon: const Icon(Icons.open_in_new_rounded),
                              label: const Text('Abrir seleccion'),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      width: 14,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFF6E0A39).withValues(alpha: 0.92),
                            const Color(0xFFFAB4D4).withValues(alpha: 0.35),
                            const Color(0xFF6E0A39).withValues(alpha: 0.92),
                          ],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(10, 12, 12, 12),
                        child: _BookStickerGrid(team: team, albumData: albumData),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _BookStickerGrid extends StatefulWidget {
  final Team team;
  final AlbumData albumData;

  const _BookStickerGrid({required this.team, required this.albumData});

  @override
  State<_BookStickerGrid> createState() => _BookStickerGridState();
}

class _BookStickerGridState extends State<_BookStickerGrid> {
  late Future<PlayerFetchResult> _playersFuture;
  final Map<int, Player> _playersBySlot = {};

  @override
  void initState() {
    super.initState();
    _playersFuture = widget.albumData.fetchPlayersForTeam(widget.team);
    _playersFuture.then((result) {
      if (!mounted) return;
      setState(() => _rebuildPlayerSlots(result.players));
    });
  }

  @override
  void didUpdateWidget(covariant _BookStickerGrid oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.team.id != widget.team.id) {
      _playersFuture = widget.albumData.fetchPlayersForTeam(widget.team);
      _playersFuture.then((result) {
        if (!mounted) return;
        setState(() => _rebuildPlayerSlots(result.players));
      });
    }
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

  void _rebuildPlayerSlots(List<Player> players) {
    _playersBySlot.clear();
    final regular = players.where((p) => !_isMetaAlbumEntry(p)).toList();
    final used = <int>{};

    for (final player in regular) {
      final slot = player.number;
      if (slot < 2 || slot > 19 || used.contains(slot)) continue;
      _playersBySlot[slot] = player;
      used.add(slot);
    }

    var next = 2;
    for (final player in regular) {
      if (_playersBySlot.containsValue(player)) continue;
      while (next <= 19 && used.contains(next)) {
        next++;
      }
      if (next > 19) break;
      _playersBySlot[next] = player;
      used.add(next);
      next++;
    }
  }

  String? _imageForNumber(int number) {
    if (number == 1) {
      return widget.team.escudoUrl.trim().isEmpty ? null : widget.team.escudoUrl;
    }

    if (number == 20) {
      return null;
    }

    final player = _playersBySlot[number];
    if (player == null) return null;

    final display = player.displayPhotoUrl.trim();
    if (display.isNotEmpty) return display;

    return null;
  }

  String? _labelForNumber(int number) {
    if (number == 1) return 'Escudo';
    if (number == 20) return 'Foto grupal';

    final player = _playersBySlot[number];
    if (player == null) return null;
    return player.name.trim().isEmpty ? null : player.name.trim();
  }

  String? _positionForNumber(int number) {
    if (number == 1 || number == 20) return null;
    final player = _playersBySlot[number];
    if (player == null) return null;
    final pos = player.position.trim();
    return pos.isEmpty ? null : pos;
  }

  String _proxyImageUrl(String url) {
    final raw = url.trim();
    if (raw.isEmpty) return raw;
    final noScheme = raw.replaceFirst(RegExp(r'^https?://'), '');
    final encoded = Uri.encodeComponent(noScheme);
    return 'https://images.weserv.nl/?url=$encoded&w=240&h=320&fit=cover';
  }

  Widget _slotImage(String url, bool owned) {
    return ColorFiltered(
      colorFilter: owned
          ? const ColorFilter.mode(Colors.transparent, BlendMode.dst)
          : const ColorFilter.matrix([
              0.2126, 0.7152, 0.0722, 0, 0,
              0.2126, 0.7152, 0.0722, 0, 0,
              0.2126, 0.7152, 0.0722, 0, 0,
              0, 0, 0, 1, 0,
            ]),
      child: Opacity(
        opacity: owned ? 1.0 : 0.62,
        child: Image.network(
          url,
          fit: BoxFit.cover,
          webHtmlElementStrategy: WebHtmlElementStrategy.prefer,
          errorBuilder: (context, error, stackTrace) {
            final proxy = _proxyImageUrl(url);
            if (proxy == url) {
              return const SizedBox.shrink();
            }
            return Image.network(
              proxy,
              fit: BoxFit.cover,
              webHtmlElementStrategy: WebHtmlElementStrategy.prefer,
              errorBuilder: (context, error2, stackTrace2) => const SizedBox.shrink(),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PlayerFetchResult>(
      future: _playersFuture,
      builder: (context, snapshot) {
        return GridView.builder(
          itemCount: 20,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            mainAxisSpacing: 6,
            crossAxisSpacing: 6,
            childAspectRatio: 0.72,
          ),
          itemBuilder: (context, index) {
            final number = index + 1;
            final owned = widget.albumData.isOwned(widget.team.name, number);
            final isSpecial = number == 1 || number == 20;
            final imageUrl = _imageForNumber(number);
            final label = _labelForNumber(number);
            final position = _positionForNumber(number);

            return Transform.rotate(
              angle: ((index % 5) - 2) * 0.008,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(7),
                  color: owned ? const Color(0xFF1B72C3) : const Color(0xFFF6E8D1),
                  border: Border.all(
                    color: isSpecial ? const Color(0xFFEAC161) : const Color(0xFFD2B88A),
                    width: isSpecial ? 1.2 : 0.8,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: owned ? 0.28 : 0.12),
                      blurRadius: 3,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (imageUrl != null && imageUrl.trim().isNotEmpty)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: _slotImage(imageUrl, owned),
                      ),
                    if ((imageUrl == null || imageUrl.trim().isEmpty) && label != null)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(6, 16, 6, 6),
                        child: Align(
                          alignment: Alignment.center,
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.fromLTRB(4, 6, 4, 5),
                            decoration: BoxDecoration(
                              color: owned
                                  ? const Color(0x3310172A)
                                  : const Color(0x77FFFFFF),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: owned
                                    ? Colors.white.withValues(alpha: 0.22)
                                    : const Color(0xFFD2B88A),
                              ),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.person_rounded,
                                  size: 13,
                                  color: owned
                                      ? const Color(0xFFF3C969)
                                      : const Color(0xFF8A6D45),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  label,
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: owned ? Colors.white : const Color(0xFF6E5536),
                                    fontSize: 8.6,
                                    fontWeight: FontWeight.w900,
                                    height: 1.05,
                                  ),
                                ),
                                if (position != null) ...[
                                  const SizedBox(height: 2),
                                  Text(
                                    position,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: owned
                                          ? Colors.white.withValues(alpha: 0.82)
                                          : const Color(0xFF8A6D45),
                                      fontSize: 7.8,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),
                    Align(
                      alignment: Alignment.topLeft,
                      child: Container(
                        margin: const EdgeInsets.all(3),
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.38),
                          borderRadius: BorderRadius.circular(99),
                        ),
                        child: Text(
                          '$number',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                    if (!owned)
                      Center(
                        child: Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.44),
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: const Icon(Icons.lock_rounded, size: 10, color: Colors.white),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
