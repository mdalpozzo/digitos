import 'dart:async';
import 'dart:collection';
import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import 'package:digitos/audio/songs.dart';
import 'package:digitos/audio/sounds.dart';
import 'package:digitos/services/app_lifecycle_service.dart';
import 'package:digitos/services/app_logger.dart';
import 'package:digitos/services/settings_service_interface.dart';
import 'package:flutter/foundation.dart';

class AudioService with ChangeNotifier {
  static final _log = AppLogger('AudioService');

  final AppLifecycleService _appLifecycleService;

  late StreamSubscription<bool> _audioOnSubscription;
  late StreamSubscription<bool> _musicOnSubscription;
  late StreamSubscription<bool> _soundsOnSubscription;

  final AudioPlayer _musicPlayer = AudioPlayer(playerId: 'musicPlayer');
  final List<AudioPlayer> _sfxPlayers;
  // TODO is this the best way to handle the playlist? init as empty then load later?
  Queue<Song> _playlist = Queue.from([]);
  int _currentSfxPlayer = 0;
  final Random _random = Random();
  final SettingsServiceInterface _settingsService;

  bool _assetsLoaded = false;

  bool _audioOn = true;
  bool _musicOn = true;
  bool _soundsOn = true;

  AudioService({
    int polyphony = 2,
    required SettingsServiceInterface settingsService,
    required AppLifecycleService appLifecycleService,
  })  : _settingsService = settingsService,
        _appLifecycleService = appLifecycleService,
        _sfxPlayers = List.generate(polyphony, (_) => AudioPlayer()).toList() {
    appLifecycleService.addOnResumedCallback(_preloadSfx);
    _musicPlayer.onPlayerComplete.listen((_) => _handleSongFinished());
    _audioOnSubscription = _settingsService.audioOnStream.listen(_setAudioOn);
    _musicOnSubscription = _settingsService.musicOnStream.listen(_setMusicOn);
    _soundsOnSubscription =
        _settingsService.soundsOnStream.listen(_setSoundsOn);
  }

  Future<void> _preloadSfx() async {
    _log.info('Preloading sfx');
    final sfxFiles = SfxType.values.expand(soundTypeToFilename).toList();
    await AudioCache(prefix: 'sfx/').loadAll(sfxFiles);

    _playlist = Queue.of(List<Song>.of(songs)..shuffle());
    _playCurrentSongInPlaylist();

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

  Future<void> _setAudioOn(bool on) async {
    _log.info('Toggling audio $on');
    _audioOn = on;
    if (!on) _stopAllSound();
  }

  Future<void> _setMusicOn(bool on) async {
    _log.info('Toggling music $on');
    _musicOn = on;

    if (on) {
      _playCurrentSongInPlaylist();
    } else {
      _musicPlayer.pause();
    }
  }

  Future<void> _setSoundsOn(bool on) async {
    _log.info('Toggling sounds $on');
    _soundsOn = on;
    if (!on) _sfxPlayers.forEach((player) => player.stop());
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

    if (_playlist.isEmpty) {
      _log.warning('Could not play song. Playlist is empty');
      return;
    }

    final song = _playlist.first;
    await _musicPlayer.play(AssetSource('music/${song.filename}'));
  }

  void _stopAllSound() {
    _log.info('Stopping all sound');
    _musicPlayer.stop();
    _sfxPlayers.forEach((player) => player.stop());
  }

  // Ensure to unregister the callbacks when the service is disposed
  @override
  void dispose() {
    _appLifecycleService.removeOnResumedCallback(_preloadSfx);
    _audioOnSubscription.cancel();
    _musicOnSubscription.cancel();
    _soundsOnSubscription.cancel();
    super.dispose();
  }
}
