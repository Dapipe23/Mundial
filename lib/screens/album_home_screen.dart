import 'package:flutter/material.dart';

import '../services/album_data.dart';
import 'collection_screen.dart';
import 'exchange_screen.dart';
import 'profile_screen.dart';

class AlbumHomeScreen extends StatefulWidget {
  final AlbumData albumData;

  const AlbumHomeScreen({super.key, required this.albumData});

  @override
  State<AlbumHomeScreen> createState() => _AlbumHomeScreenState();
}

class _AlbumHomeScreenState extends State<AlbumHomeScreen> {
  int _selectedIndex = 0;

  static const _tabTitles = [
    'Coleccion Mundialista',
    'Zona de Intercambios',
    'Mi Perfil',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _tabTitles[_selectedIndex],
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
            ),
            Text(
              widget.albumData.user.name,
              style: const TextStyle(fontSize: 13, color: Color(0xFF617693)),
            ),
          ],
        ),
      ),
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFEAF1FB), Color(0xFFF7FAFF)],
          ),
        ),
        child: IndexedStack(
          index: _selectedIndex,
          children: [
            CollectionScreen(albumData: widget.albumData),
            ExchangeScreen(albumData: widget.albumData),
            ProfileScreen(albumData: widget.albumData),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (value) {
          setState(() {
            _selectedIndex = value;
          });
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.album), label: 'Colección'),
          NavigationDestination(icon: Icon(Icons.swap_horiz), label: 'Intercambios'),
          NavigationDestination(icon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
    );
  }
}
