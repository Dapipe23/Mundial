import 'dart:math' as math;

import 'package:flutter/material.dart';

// ─────────────────────────────────────────────
//  WORLD CUP 2026 – shared design tokens
// ─────────────────────────────────────────────

class WcColors {
  WcColors._();

  static const navy = Color(0xFF062A5A);
  static const green = Color(0xFF0B6E4F);
  static const red = Color(0xFFC41230);
  static const sky = Color(0xFF1565C0);
  static const gold = Color(0xFFF3C969);
  static const white = Colors.white;
  static const bgLight = Color(0xFFF2F6FA);

  static Color groupColor(String group) {
    switch (group.toUpperCase()) {
      case 'A':
        return const Color(0xFF1E40AF);
      case 'B':
        return const Color(0xFF0B6E4F);
      case 'C':
        return const Color(0xFFB91C1C);
      case 'D':
        return const Color(0xFFD97706);
      case 'E':
        return const Color(0xFF7C3AED);
      case 'F':
        return const Color(0xFF0891B2);
      case 'G':
        return const Color(0xFFBE123C);
      case 'H':
        return const Color(0xFF15803D);
      default:
        return navy;
    }
  }
}

class WcFlags {
  WcFlags._();

  static String _normalize(String value) {
    final lower = value.toLowerCase().trim();
    const replacements = {
      'á': 'a',
      'é': 'e',
      'í': 'i',
      'ó': 'o',
      'ú': 'u',
      'ü': 'u',
      'ñ': 'n',
    };

    var normalized = lower;
    replacements.forEach((from, to) {
      normalized = normalized.replaceAll(from, to);
    });
    return normalized;
  }

  static const _map = <String, String>{
    'argentina'        : '🇦🇷',
    'brasil'           : '🇧🇷',
    'brazil'           : '🇧🇷',
    'france'           : '🇫🇷',
    'francia'          : '🇫🇷',
    'spain'            : '🇪🇸',
    'españa'           : '🇪🇸',
    'germany'          : '🇩🇪',
    'alemania'         : '🇩🇪',
    'england'          : '🏴󠁧󠁢󠁥󠁮󠁧󠁿',
    'inglaterra'       : '🏴󠁧󠁢󠁥󠁮󠁧󠁿',
    'portugal'         : '🇵🇹',
    'netherlands'      : '🇳🇱',
    'países bajos'     : '🇳🇱',
    'paises bajos'     : '🇳🇱',
    'holanda'          : '🇳🇱',
    'uruguay'          : '🇺🇾',
    'colombia'         : '🇨🇴',
    'mexico'           : '🇲🇽',
    'méxico'           : '🇲🇽',
    'usa'              : '🇺🇸',
    'estados unidos'   : '🇺🇸',
    'united states'    : '🇺🇸',
    'canada'           : '🇨🇦',
    'canadá'           : '🇨🇦',
    'ecuador'          : '🇪🇨',
    'peru'             : '🇵🇪',
    'perú'             : '🇵🇪',
    'chile'            : '🇨🇱',
    'venezuela'        : '🇻🇪',
    'bolivia'          : '🇧🇴',
    'paraguay'         : '🇵🇾',
    'panama'           : '🇵🇦',
    'panamá'           : '🇵🇦',
    'costa rica'       : '🇨🇷',
    'honduras'         : '🇭🇳',
    'jamaica'          : '🇯🇲',
    'morocco'          : '🇲🇦',
    'marruecos'        : '🇲🇦',
    'senegal'          : '🇸🇳',
    'nigeria'          : '🇳🇬',
    'cameroon'         : '🇨🇲',
    'camerún'          : '🇨🇲',
    'egypt'            : '🇪🇬',
    'egipto'           : '🇪🇬',
    'ghana'            : '🇬🇭',
    'south africa'     : '🇿🇦',
    'sudáfrica'        : '🇿🇦',
    'australia'        : '🇦🇺',
    'japan'            : '🇯🇵',
    'japón'            : '🇯🇵',
    'japon'            : '🇯🇵',
    'south korea'      : '🇰🇷',
    'corea del sur'    : '🇰🇷',
    'saudi arabia'     : '🇸🇦',
    'arabia saudita'   : '🇸🇦',
    'iran'             : '🇮🇷',
    'irán'             : '🇮🇷',
    'qatar'            : '🇶🇦',
    'serbia'           : '🇷🇸',
    'croatia'          : '🇭🇷',
    'croacia'          : '🇭🇷',
    'switzerland'      : '🇨🇭',
    'suiza'            : '🇨🇭',
    'belgium'          : '🇧🇪',
    'bélgica'          : '🇧🇪',
    'belgica'          : '🇧🇪',
    'italy'            : '🇮🇹',
    'italia'           : '🇮🇹',
    'poland'           : '🇵🇱',
    'polonia'          : '🇵🇱',
    'denmark'          : '🇩🇰',
    'dinamarca'        : '🇩🇰',
    'turkey'           : '🇹🇷',
    'turquía'          : '🇹🇷',
    'turquia'          : '🇹🇷',
    'austria'          : '🇦🇹',
    'scotland'         : '🏴󠁧󠁢󠁳󠁣󠁴󠁿',
    'escocia'          : '🏴󠁧󠁢󠁳󠁣󠁴󠁿',
    'wales'            : '🏴󠁧󠁢󠁷󠁬󠁳󠁿',
    'gales'            : '🏴󠁧󠁢󠁷󠁬󠁳󠁿',
    'ukraine'          : '🇺🇦',
    'ucrania'          : '🇺🇦',
    'new zealand'      : '🇳🇿',
    'nueva zelanda'    : '🇳🇿',
    'indonesia'        : '🇮🇩',
    'china'            : '🇨🇳',
    'india'            : '🇮🇳',
    'ivory coast'      : '🇨🇮',
    'costa de marfil'  : '🇨🇮',
    'mali'             : '🇲🇱',
    'tanzania'         : '🇹🇿',
    'zambia'           : '🇿🇲',
    'cuba'             : '🇨🇺',
    'haiti'            : '🇭🇹',
    'haití'            : '🇭🇹',
    'trinidad y tobago': '🇹🇹',
    'greek'            : '🇬🇷',
    'grecia'           : '🇬🇷',
    'slovakia'         : '🇸🇰',
    'eslovaquia'       : '🇸🇰',
    'czechia'          : '🇨🇿',
    'chequia'          : '🇨🇿',
    'hungría'          : '🇭🇺',
    'hungria'          : '🇭🇺',
    'romania'          : '🇷🇴',
    'rumania'          : '🇷🇴',
    'albania'          : '🇦🇱',
    'georgia'          : '🇬🇪',
    'norway'           : '🇳🇴',
    'noruega'          : '🇳🇴',
    'sweden'           : '🇸🇪',
    'suecia'           : '🇸🇪',
    'finland'          : '🇫🇮',
    'finlandia'        : '🇫🇮',
    'russia'           : '🇷🇺',
    'rusia'            : '🇷🇺',
    'iraq'             : '🇮🇶',
    'thailand'         : '🇹🇭',
    'tailandia'        : '🇹🇭',
    'vietnam'          : '🇻🇳',
    'viet nam'         : '🇻🇳',
    'israel'           : '🇮🇱',

    // Aliases from current API data
    'argelia'                                : '🇩🇿',
    'bosnia y herzegovina'                   : '🇧🇦',
    'cabo verde'                             : '🇨🇻',
    'catar'                                  : '🇶🇦',
    'curazao'                                : '🇨🇼',
    'jordania'                               : '🇯🇴',
    'republica checa'                        : '🇨🇿',
    'república checa'                        : '🇨🇿',
    'republica democratica del congo'        : '🇨🇩',
    'república democrática del congo'        : '🇨🇩',
    'tunez'                                  : '🇹🇳',
    'túnez'                                  : '🇹🇳',
    'uzbekistan'                             : '🇺🇿',
  };

  static final Map<String, String> _normalizedMap = {
    for (final entry in _map.entries) _normalize(entry.key): entry.value,
  };

  static String of(String name) =>
      _normalizedMap[_normalize(name)] ?? '🏳️';
}

// ─────────────────────────────────────────────
//  Shared widgets
// ─────────────────────────────────────────────

/// Decorative header banner with gradient + soccer ball motif
class WcBanner extends StatelessWidget {
  final String title;
  final String? subtitle;
  final List<Color> colors;
  final Widget? trailing;

  const WcBanner({
    super.key,
    required this.title,
    this.subtitle,
    this.colors = const [Color(0xFF062A5A), Color(0xFF0B6E4F)],
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: colors, begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(color: colors.first.withValues(alpha: 0.35), blurRadius: 14, offset: const Offset(0, 5)),
        ],
      ),
      child: Stack(
        children: [
          // Decorative large ball watermark
          Positioned(
            right: -10,
            top: -10,
            child: Text('⚽', style: TextStyle(fontSize: 72, color: Colors.white.withValues(alpha: 0.08))),
          ),
          Positioned(
            right: 50,
            bottom: -14,
            child: Text('⚽', style: TextStyle(fontSize: 44, color: Colors.white.withValues(alpha: 0.06))),
          ),
          // Content
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: -0.3)),
                    if (subtitle != null) ...[
                      const SizedBox(height: 6),
                      Text(subtitle!, style: TextStyle(fontSize: 13, color: Colors.white.withValues(alpha: 0.80))),
                    ],
                  ],
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
        ],
      ),
    );
  }
}

/// Circular group badge (bold letter in colored circle)
class WcGroupBadge extends StatelessWidget {
  final String group;
  final double size;

  const WcGroupBadge({super.key, required this.group, this.size = 36});

  @override
  Widget build(BuildContext context) {
    final color = WcColors.groupColor(group);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      alignment: Alignment.center,
      child: Text(
        group,
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: size * 0.42),
      ),
    );
  }
}

/// A Panini-style sticker card for the grid
class WcStickerCard extends StatefulWidget {
  final int number;
  final String label;
  final bool owned;
  final bool duplicate;
  final bool isSpecial;
  final String? imageUrl;
  final Color accentColor;
  final VoidCallback? onTap;
  final bool enableManualFlip;

  const WcStickerCard({
    super.key,
    required this.number,
    required this.label,
    required this.owned,
    required this.duplicate,
    this.isSpecial = false,
    this.imageUrl,
    this.accentColor = const Color(0xFF062A5A),
    this.onTap,
    this.enableManualFlip = true,
  });

  @override
  State<WcStickerCard> createState() => _WcStickerCardState();
}

class _WcStickerCardState extends State<WcStickerCard> {
  late bool _showFront;

  bool get _hasImage => widget.imageUrl != null && widget.imageUrl!.trim().isNotEmpty;

  bool get _canFlip => widget.enableManualFlip && widget.owned && _hasImage;

  @override
  void initState() {
    super.initState();
    _showFront = _canFlip;
  }

  @override
  void didUpdateWidget(covariant WcStickerCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    final hadFlip = oldWidget.enableManualFlip && oldWidget.owned && (oldWidget.imageUrl?.trim().isNotEmpty ?? false);
    if (!hadFlip && _canFlip) {
      _showFront = true;
      return;
    }
    if (!_canFlip) {
      _showFront = false;
    }
  }

  void _onMainTap() {
    if (_canFlip) {
      setState(() => _showFront = !_showFront);
      return;
    }
    widget.onTap?.call();
  }

  void _runPrimaryAction() {
    widget.onTap?.call();
  }

  String _proxyImageUrl(String url) {
    final raw = url.trim();
    if (raw.isEmpty) return raw;
    final noScheme = raw.replaceFirst(RegExp(r'^https?://'), '');
    final encoded = Uri.encodeComponent(noScheme);
    return 'https://images.weserv.nl/?url=$encoded&w=320&h=420&fit=cover';
  }

  Widget _playerImage(String url) {
    return Image.network(
      url,
      fit: BoxFit.cover,
      webHtmlElementStrategy: WebHtmlElementStrategy.prefer,
      errorBuilder: (context, error, stackTrace) {
        final proxyUrl = _proxyImageUrl(url);
        if (proxyUrl == url) {
          return Container(
            color: const Color(0xFFEAF1FB),
            alignment: Alignment.center,
            child: const Icon(Icons.person, size: 18, color: Color(0xFF9AA7B5)),
          );
        }
        return Image.network(
          proxyUrl,
          fit: BoxFit.cover,
          webHtmlElementStrategy: WebHtmlElementStrategy.prefer,
          errorBuilder: (context, error2, stackTrace2) => Container(
            color: const Color(0xFFEAF1FB),
            alignment: Alignment.center,
            child: const Icon(Icons.person, size: 18, color: Color(0xFF9AA7B5)),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    Color headerColor;
    Color cardBg;
    Gradient? cardGradient;
    Color borderColor;
    List<BoxShadow> shadows = const [];

    if (widget.isSpecial) {
      headerColor = const Color(0xFFF3C969);
      cardBg = const Color(0xFF1A2D4A);
      cardGradient = const LinearGradient(
        colors: [Color(0xFF1A2D4A), Color(0xFF3A1F62), Color(0xFF0F5A67), Color(0xFFB68B2E)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
      borderColor = widget.owned ? const Color(0xFFF3C969) : const Color(0xFF86A1C8);
      shadows = [
        BoxShadow(color: const Color(0xFFF3C969).withValues(alpha: 0.28), blurRadius: 8, offset: const Offset(0, 2)),
      ];
    } else if (widget.owned) {
      headerColor = widget.accentColor;
      cardBg      = Colors.white;
      borderColor = widget.accentColor.withValues(alpha: 0.35);
      shadows = [BoxShadow(color: widget.accentColor.withValues(alpha: 0.18), blurRadius: 6, offset: const Offset(0, 2))];
    } else {
      headerColor = const Color(0xFFB0BEC5);
      cardBg      = const Color(0xFFF5F7FA);
      borderColor = const Color(0xFFDDE3EC);
    }

    return GestureDetector(
      onTap: _onMainTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          color: cardGradient == null ? cardBg : null,
          gradient: cardGradient,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: borderColor, width: widget.owned ? 1.8 : 1.2),
          boxShadow: shadows,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(9),
          child: Column(
            children: [
              // Colored header stripe
              Container(
                width: double.infinity,
                height: 7,
                color: headerColor,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(4, 4, 4, 4),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 620),
                    switchInCurve: Curves.easeOutCubic,
                    switchOutCurve: Curves.easeInCubic,
                    layoutBuilder: (currentChild, previousChildren) {
                      return Stack(
                        fit: StackFit.expand,
                        children: [
                          ...previousChildren,
                          ?currentChild,
                        ],
                      );
                    },
                    transitionBuilder: (child, animation) {
                      final rotate = Tween<double>(begin: math.pi, end: 0).animate(animation);
                      return AnimatedBuilder(
                        animation: rotate,
                        child: child,
                        builder: (context, flipChild) {
                          final angle = rotate.value;
                          return Transform(
                            alignment: Alignment.center,
                            transform: Matrix4.identity()
                              ..setEntry(3, 2, 0.002)
                              ..rotateY(angle),
                            child: flipChild,
                          );
                        },
                      );
                    },
                    child: (_canFlip && _showFront)
                        ? _buildFrontFace(key: const ValueKey('front-face'))
                        : _buildBackFace(key: const ValueKey('back-face')),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBackVisual() {
    if (!widget.owned && _hasImage) {
      return Stack(
        alignment: Alignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              width: 54,
              height: 66,
              child: ColorFiltered(
                colorFilter: const ColorFilter.matrix([
                  0.2126, 0.7152, 0.0722, 0, 0,
                  0.2126, 0.7152, 0.0722, 0, 0,
                  0.2126, 0.7152, 0.0722, 0, 0,
                  0, 0, 0, 1, 0,
                ]),
                child: Opacity(
                  opacity: 0.84,
                  child: _playerImage(widget.imageUrl!),
                ),
              ),
            ),
          ),
          Positioned(
            right: 2,
            top: 2,
            child: Container(
              width: 15,
              height: 15,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.34),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: const Icon(Icons.lock_rounded, size: 9, color: Colors.white),
            ),
          ),
        ],
      );
    }

    if (widget.duplicate) {
      return Container(
        width: 28,
        height: 28,
        decoration: const BoxDecoration(
          color: Color(0xFFFF8C00),
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: const Text('2x', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w900)),
      );
    } else if (widget.owned) {
      return Container(
        width: 28,
        height: 28,
        decoration: const BoxDecoration(
          color: Color(0xFF22C55E),
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: const Icon(Icons.check, color: Colors.white, size: 16),
      );
    } else if (widget.isSpecial) {
      return const Text('✨', style: TextStyle(fontSize: 20));
    } else {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFFE9EEF5),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFD6DEE8)),
        ),
        child: Text(
          widget.label,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 8.5,
            fontWeight: FontWeight.w800,
            color: Color(0xFF7A8798),
            height: 1.1,
          ),
        ),
      );
    }
  }

  Widget _buildBackFace({required Key key}) {
    return Container(
      key: key,
      padding: const EdgeInsets.fromLTRB(2, 1, 2, 1),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '#${widget.number}',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w900,
                color: widget.isSpecial
                    ? const Color(0xFFF3C969)
                    : (widget.owned ? widget.accentColor : const Color(0xFF9BA8B4)),
              ),
            ),
          ),
          _buildBackVisual(),
          Text(
            widget.label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: widget.isSpecial
                  ? const Color(0xFFEAF2FF)
                  : (widget.owned ? const Color(0xFF2D3748) : const Color(0xFFADB5BD)),
            ),
          ),
          if (_canFlip && widget.onTap != null)
            Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                onTap: _runPrimaryAction,
                child: Container(
                  width: 18,
                  height: 18,
                  decoration: const BoxDecoration(color: Color(0xFF0B2C5E), shape: BoxShape.circle),
                  alignment: Alignment.center,
                  child: const Icon(Icons.remove_rounded, size: 11, color: Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFrontFace({required Key key}) {
    return Container(
      key: key,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: widget.isSpecial ? const Color(0xFFF3C969) : widget.accentColor.withValues(alpha: 0.35),
          width: widget.isSpecial ? 1.6 : 1.2,
        ),
        gradient: widget.isSpecial
            ? const LinearGradient(
                colors: [Color(0xFF1A2D4A), Color(0xFF3A1F62), Color(0xFF0F5A67)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        color: widget.isSpecial ? null : const Color(0xFFE8F0FB),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(7),
            child: _playerImage(widget.imageUrl ?? ''),
          ),
          Positioned(
            left: 4,
            top: 3,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.45),
                borderRadius: BorderRadius.circular(99),
              ),
              child: Text(
                '#${widget.number}',
                style: const TextStyle(fontSize: 8, fontWeight: FontWeight.w900, color: Colors.white),
              ),
            ),
          ),
          if (widget.isSpecial)
            Positioned.fill(
              child: IgnorePointer(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(7),
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFFFFFFFF).withValues(alpha: 0.20),
                        const Color(0xFFFFFFFF).withValues(alpha: 0.03),
                        const Color(0xFF93C5FD).withValues(alpha: 0.08),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
              ),
            ),
          if (_canFlip && widget.onTap != null)
            Positioned(
              right: 3,
              top: 3,
              child: GestureDetector(
                onTap: _runPrimaryAction,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: const BoxDecoration(color: Color(0xFF0B2C5E), shape: BoxShape.circle),
                  alignment: Alignment.center,
                  child: const Icon(Icons.remove_rounded, size: 10, color: Colors.white),
                ),
              ),
            ),
          if (widget.duplicate)
            Positioned(
              right: 3,
              bottom: 3,
              child: Container(
                width: 17,
                height: 17,
                decoration: const BoxDecoration(color: Color(0xFFFF8C00), shape: BoxShape.circle),
                alignment: Alignment.center,
                child: const Text('2x', style: TextStyle(color: Colors.white, fontSize: 7, fontWeight: FontWeight.w900)),
              ),
            )
          else
            Positioned(
              right: 3,
              bottom: 3,
              child: Container(
                width: 17,
                height: 17,
                decoration: const BoxDecoration(color: Color(0xFF22C55E), shape: BoxShape.circle),
                alignment: Alignment.center,
                child: const Icon(Icons.check, color: Colors.white, size: 10),
              ),
            ),
        ],
      ),
    );
  }
}

/// Fancy gold progress bar
class WcProgressBar extends StatelessWidget {
  final double value;
  final Color? color;
  final double height;

  const WcProgressBar({super.key, required this.value, this.color, this.height = 8});

  @override
  Widget build(BuildContext context) {
    final barColor = color ?? const Color(0xFF0B6E4F);
    return ClipRRect(
      borderRadius: BorderRadius.circular(99),
      child: LinearProgressIndicator(
        minHeight: height,
        value: value,
        backgroundColor: const Color(0xFFE2EAF4),
        valueColor: AlwaysStoppedAnimation<Color>(barColor),
      ),
    );
  }
}

/// Semaphore dot + label
class WcSemaphore extends StatelessWidget {
  final Color color;
  final String label;

  const WcSemaphore({super.key, required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 9, height: 9, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 5),
        Text(label, style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: color)),
      ],
    );
  }
}

/// Quick stat chip (icon + value + label)
class WcStatChip extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const WcStatChip({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: color)),
          Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: color.withValues(alpha: 0.75))),
        ],
      ),
    );
  }
}
