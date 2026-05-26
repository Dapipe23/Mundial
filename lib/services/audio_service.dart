import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';

class WcAudioService {
  WcAudioService._();

  static final WcAudioService instance = WcAudioService._();

  static const _pageFlipAsset = 'assets/audio/page_flip.mp3';
  static const _bgMusicAsset = 'assets/audio/world_cup_theme.mp3';

  final AudioPlayer _sfxPlayer = AudioPlayer();
  final AudioPlayer _musicPlayer = AudioPlayer();

  bool _initialized = false;
  bool _hasPageFlipAsset = false;
  bool _hasBgMusicAsset = false;
  bool _musicMuted = false;
  bool _sfxMuted = false;

  Future<void> initialize() async {
    if (_initialized) return;

    _hasPageFlipAsset = await _assetExists(_pageFlipAsset);
    _hasBgMusicAsset = await _assetExists(_bgMusicAsset);

    await _sfxPlayer.setVolume(0.95);
    await _musicPlayer.setReleaseMode(ReleaseMode.loop);
    await _musicPlayer.setVolume(0.22);

    _initialized = true;
  }

  Future<void> playPageFlip() async {
    await initialize();
    if (_sfxMuted) return;
    if (!_hasPageFlipAsset) return;

    await _sfxPlayer.stop();
    await _sfxPlayer.play(AssetSource('audio/page_flip.mp3'));
  }

  Future<void> startBackgroundMusic() async {
    await initialize();
    if (_musicMuted) return;
    if (!_hasBgMusicAsset) return;
    if (_musicPlayer.state == PlayerState.playing) return;

    await _musicPlayer.play(AssetSource('audio/world_cup_theme.mp3'));
  }

  Future<void> pauseBackgroundMusic() async {
    if (!_initialized) return;
    await _musicPlayer.pause();
  }

  Future<bool> toggleMusicMute() async {
    await initialize();
    _musicMuted = !_musicMuted;

    if (_musicMuted) {
      await _musicPlayer.pause();
    } else {
      await startBackgroundMusic();
    }

    return _musicMuted;
  }

  Future<bool> toggleSfxMute() async {
    await initialize();
    _sfxMuted = !_sfxMuted;
    return _sfxMuted;
  }

  Future<void> dispose() async {
    if (!_initialized) return;
    await Future.wait([
      _sfxPlayer.dispose(),
      _musicPlayer.dispose(),
    ]);
  }

  Future<bool> _assetExists(String assetPath) async {
    try {
      await rootBundle.load(assetPath);
      return true;
    } catch (_) {
      return false;
    }
  }

  // Optional helper: useful if UI wants to show a "missing audio" hint.
  bool get hasAudioAssets => _hasPageFlipAsset || _hasBgMusicAsset;
  bool get isMusicMuted => _musicMuted;
  bool get isSfxMuted => _sfxMuted;
}
