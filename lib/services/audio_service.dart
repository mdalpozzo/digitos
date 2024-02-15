import 'dart:async';
import 'dart:collection';
import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import 'package:digitos/audio/songs.dart';
import 'package:digitos/audio/sounds.dart';
import 'package:digitos/services/app_logger.dart';
import 'package:digitos/services/local_storage_service/local_storage_service.dart';

class AudioService {
  static final _log = AppLogger('AudioService');

  final AudioPlayer _musicPlayer = AudioPlayer(playerId: 'musicPlayer');
  final List<AudioPlayer> _sfxPlayers;
  final Queue<Song> _playlist = Queue.of(List<Song>.of(songs)..shuffle());
  int _currentSfxPlayer = 0;
  final Random _random = Random();
  final LocalStorageService _localStorageService;

  bool _audioOn = true;
  bool _musicOn = true;
  bool _soundsOn = true;

  AudioService({
    int polyphony = 2,
    required LocalStorageService localStorageService,
  })  : _localStorageService = localStorageService,
        _sfxPlayers = List.generate(polyphony, (_) => AudioPlayer()).toList() {
    _loadSettings();
    _musicPlayer.onPlayerComplete.listen((_) => _handleSongFinished());
    unawaited(_preloadSfx());
  }

  Future<void> _loadSettings() async {
    _log.info('Loading audio settings');
    // Load preferences from local storage
    _audioOn = await _localStorageService.getBool('audioOn') ?? true;
    _musicOn = await _localStorageService.getBool('musicOn') ?? true;
    _soundsOn = await _localStorageService.getBool('soundsOn') ?? true;
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

  Future<void> _preloadSfx() async {
    _log.info('Preloading sfx');
    final sfxFiles = SfxType.values.expand(soundTypeToFilename).toList();
    await AudioCache(prefix: 'sfx/').loadAll(sfxFiles);
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
}
