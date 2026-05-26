import 'package:flutter/material.dart';

import '../services/album_data.dart';
import '../services/audio_service.dart';
import 'album_book_screen.dart';
import 'collection_screen.dart';
import 'exchange_screen.dart';
import 'profile_screen.dart';
import 'widgets/wc_theme.dart';

class AlbumHomeScreen extends StatefulWidget {
  final AlbumData albumData;

  const AlbumHomeScreen({super.key, required this.albumData});

  @override
  State<AlbumHomeScreen> createState() => _AlbumHomeScreenState();
}

class _AlbumHomeScreenState extends State<AlbumHomeScreen> {
  int _selectedIndex = 0;
  bool _musicMuted = false;
  bool _sfxMuted = false;

  @override
  void initState() {
    super.initState();
    _startBackgroundMusic();
  }

  @override
  void dispose() {
    WcAudioService.instance.pauseBackgroundMusic();
    super.dispose();
  }

  Future<void> _startBackgroundMusic() async {
    await WcAudioService.instance.startBackgroundMusic();
    if (!mounted) return;
    setState(() {
      _musicMuted = WcAudioService.instance.isMusicMuted;
      _sfxMuted = WcAudioService.instance.isSfxMuted;
    });
  }

  Future<void> _toggleMusicMute() async {
    final muted = await WcAudioService.instance.toggleMusicMute();
    if (!mounted) return;
    setState(() => _musicMuted = muted);
  }

  Future<void> _toggleSfxMute() async {
    final muted = await WcAudioService.instance.toggleSfxMute();
    if (!mounted) return;
    setState(() => _sfxMuted = muted);
  }

  static const _tabTitles = [
    'Album Tipo Libro',
    'Coleccion Mundialista',
    'Zona de Intercambios',
    'Mi Perfil',
  ];

  static const _navDestinations = [
    NavigationDestination(
      icon: Icon(Icons.menu_book_outlined),
      selectedIcon: Icon(Icons.menu_book_rounded),
      label: 'Album',
    ),
    NavigationDestination(
      icon: Icon(Icons.style_outlined),
      selectedIcon: Icon(Icons.style),
      label: 'Colección',
    ),
    NavigationDestination(
      icon: Icon(Icons.swap_horiz_outlined),
      selectedIcon: Icon(Icons.swap_horiz),
      label: 'Intercambios',
    ),
    NavigationDestination(
      icon: Icon(Icons.emoji_events_outlined),
      selectedIcon: Icon(Icons.emoji_events),
      label: 'Perfil',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final totalOwned = (widget.albumData.shieldCount +
        widget.albumData.photoCount +
        widget.albumData.playerCount);

    return Scaffold(
      backgroundColor: const Color(0xFF081A3F),
      extendBody: true,
      appBar: _buildAppBar(totalOwned),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          AlbumBookScreen(albumData: widget.albumData),
          CollectionScreen(albumData: widget.albumData),
          ExchangeScreen(albumData: widget.albumData),
          ProfileScreen(albumData: widget.albumData),
        ],
      ),
      bottomNavigationBar: _buildNavBar(),
    );
  }

  PreferredSizeWidget _buildAppBar(int totalOwned) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(88),
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF062A5A), Color(0xFF0A4080)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [BoxShadow(color: Color(0x33000000), blurRadius: 10, offset: Offset(0, 3))],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            child: Row(
              children: [
                // FIFA 2026 branding
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: WcColors.gold,
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: WcColors.gold.withValues(alpha: 0.5), blurRadius: 8)],
                  ),
                  alignment: Alignment.center,
                  child: const Text('🏆', style: TextStyle(fontSize: 22)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'FIFA WORLD CUP 2026™',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFFF3C969),
                          letterSpacing: 1.2,
                        ),
                      ),
                      Text(
                        _tabTitles[_selectedIndex],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          widget.albumData.user.name.split(' ').first,
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: WcColors.gold.withValues(alpha: 0.25),
                            borderRadius: BorderRadius.circular(99),
                            border: Border.all(color: WcColors.gold.withValues(alpha: 0.4)),
                          ),
                          child: Text(
                            '$totalOwned láminas',
                            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFFF3C969)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 8),
                    IconButton.filledTonal(
                      onPressed: _toggleMusicMute,
                      tooltip: _musicMuted ? 'Activar música' : 'Silenciar música',
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white.withValues(alpha: 0.14),
                        foregroundColor: const Color(0xFFF3C969),
                      ),
                      icon: Icon(
                        _musicMuted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 6),
                    IconButton.filledTonal(
                      onPressed: _toggleSfxMute,
                      tooltip: _sfxMuted ? 'Activar sonido de hojas' : 'Silenciar sonido de hojas',
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white.withValues(alpha: 0.14),
                        foregroundColor: const Color(0xFFF3C969),
                      ),
                      icon: Icon(
                        _sfxMuted ? Icons.menu_book_outlined : Icons.menu_book_rounded,
                        size: 20,
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
  }

  Widget _buildNavBar() {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF062A5A), Color(0xFF2A124F), Color(0xFF0B6E4F)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border(
            top: BorderSide(color: const Color(0xFFF3C969).withValues(alpha: 0.55), width: 1.3),
          ),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.35), blurRadius: 16, offset: const Offset(0, -5)),
            BoxShadow(color: const Color(0xFF1E40AF).withValues(alpha: 0.28), blurRadius: 24, offset: const Offset(0, -2)),
          ],
        ),
        child: NavigationBarTheme(
          data: NavigationBarThemeData(
            backgroundColor: Colors.transparent,
            elevation: 0,
            indicatorColor: const Color(0xFFF3C969).withValues(alpha: 0.26),
            iconTheme: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return const IconThemeData(color: Color(0xFFF3C969), size: 24);
              }
              return IconThemeData(color: Colors.white.withValues(alpha: 0.72), size: 22);
            }),
            labelTextStyle: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFFF3C969));
              }
              return TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white.withValues(alpha: 0.66));
            }),
          ),
          child: NavigationBar(
            height: 74,
            selectedIndex: _selectedIndex,
            onDestinationSelected: (value) {
              setState(() => _selectedIndex = value);
              _startBackgroundMusic();
            },
            destinations: _navDestinations,
          ),
        ),
      ),
    );
  }
}

