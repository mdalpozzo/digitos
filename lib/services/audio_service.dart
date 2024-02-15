import 'dart:async';
import 'dart:collection';
import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import 'package:digitos/audio/songs.dart';
import 'package:digitos/audio/sounds.dart';
import 'package:digitos/services/app_lifecycle_service.dart';
import 'package:digitos/services/app_logger.dart';
import 'package:digitos/services/local_storage_service/local_storage_service.dart';
import 'package:flutter/foundation.dart';

class AudioService with ChangeNotifier {
  static final _log = AppLogger('AudioService');

  final AppLifecycleService _appLifecycleService;

  final AudioPlayer _musicPlayer = AudioPlayer(playerId: 'musicPlayer');
  final List<AudioPlayer> _sfxPlayers;
  // TODO is this the best way to handle the playlist? init as empty then load later?
  Queue<Song> _playlist = Queue.from([]);
  int _currentSfxPlayer = 0;
  final Random _random = Random();
  final LocalStorageService _localStorageService;

  bool _assetsLoaded = false;

  bool _audioOn = true;
  bool _musicOn = true;
  bool _soundsOn = true;

  AudioService({
    int polyphony = 2,
    required LocalStorageService localStorageService,
    required AppLifecycleService appLifecycleService,
  })  : _localStorageService = localStorageService,
        _appLifecycleService = appLifecycleService,
        _sfxPlayers = List.generate(polyphony, (_) => AudioPlayer()).toList() {
    appLifecycleService.addOnResumedCallback(_preloadSfx);
    _loadSettings();
    _musicPlayer.onPlayerComplete.listen((_) => _handleSongFinished());
  }

  Future<void> _loadSettings() async {
    _log.info('Loading audio settings');
    // Load preferences from local storage
    _audioOn = await _localStorageService.getBool('audioOn') ?? false;
    _musicOn = await _localStorageService.getBool('musicOn') ?? false;
    _soundsOn = await _localStorageService.getBool('soundsOn') ?? false;
  }

  Future<void> _preloadSfx() async {
    _log.info('Preloading sfx');
    final sfxFiles = SfxType.values.expand(soundTypeToFilename).toList();
    await AudioCache(prefix: 'sfx/').loadAll(sfxFiles);
    _playlist = Queue.of(List<Song>.of(songs)..shuffle());

    _assetsLoaded = true;
  }

  void onResume() {
    if (!_assetsLoaded) {
      _preloadSfx();
    }
  }

  void playSfx(SfxType type) {
    if (!_audioOn || !_soundsOn) return;
    _log.info('Playing sfx: $type');

    final options = soundTypeToFilename(type);
    final filename = options[_random.nextInt(options.length)];
    _sfxPlayers[_currentSfxPlayer].play(AssetSource('sfx/$filename'));
    _currentSfxPlayer = (_currentSfxPlayer + 1) % _sfxPlayers.length;
  }

  void playButtonTap() {
    playSfx(SfxType.buttonTap);
  }

  Future<void> toggleAudioOn() async {
    _log.info('Toggling audio');
    _audioOn = !_audioOn;
    await _localStorageService.setBool('audioOn', _audioOn);
    if (!_audioOn) _stopAllSound();
  }

  Future<void> toggleMusicOn() async {
    _log.info('Toggling music');
    _musicOn = !_musicOn;
    await _localStorageService.setBool('musicOn', _musicOn);
    if (_musicOn)
      _playCurrentSongInPlaylist();
    else
      _musicPlayer.pause();
  }

  Future<void> toggleSoundsOn() async {
    _log.info('Toggling sounds');
    _soundsOn = !_soundsOn;
    await _localStorageService.setBool('soundsOn', _soundsOn);
    if (!_soundsOn) _sfxPlayers.forEach((player) => player.stop());
  }

  void _handleSongFinished() {
    _log.info('Song finished');
    // Handle song completion
    _playlist.addLast(_playlist.removeFirst());
    _playCurrentSongInPlaylist();
  }

  Future<void> _playCurrentSongInPlaylist() async {
    _log.info('Playing current song');
    if (!_musicOn || !_audioOn) return;
    final song = _playlist.first;
    await _musicPlayer.play(AssetSource('music/${song.filename}'));
  }

  void _stopAllSound() {
    _log.info('Stopping all sound');
    _musicPlayer.stop();
    _sfxPlayers.forEach((player) => player.stop());
  }

  // Ensure to unregister the callbacks when the service is disposed
  void dispose() {
    _appLifecycleService.removeOnResumedCallback(_preloadSfx);
    super.dispose();
  }
}
