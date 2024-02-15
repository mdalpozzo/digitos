import 'dart:async';

import 'package:digitos/services/audio_service.dart';
import 'package:digitos/services/settings_service.dart';
import 'package:digitos/view_models/base_view_model.dart';

class SettingsViewModel extends BaseViewModel {
  final SettingsService settingsService;
  final AudioService audioService;

  String? _displayName;
  bool _audioOn = false;
  bool _musicOn = true;
  bool _soundsOn = true;

  late StreamSubscription<bool> _audioOnSubscription;
  late StreamSubscription<bool> _musicOnSubscription;
  late StreamSubscription<bool> _soundsOnSubscription;

  SettingsViewModel({
    required this.settingsService,
    required this.audioService,
  }) : super() {
    _loadSettings();

    // TODO can we group these values into a single audioSettings config object? and only update the changed vars to avoid multiple streams?
    _audioOnSubscription = settingsService.audioOnStream.listen((newState) {
      _audioOn = newState;
      notifyListeners();
    });
    _musicOnSubscription = settingsService.musicOnStream.listen((newState) {
      _musicOn = newState;
      notifyListeners();
    });
    _soundsOnSubscription = settingsService.soundsOnStream.listen((newState) {
      _soundsOn = newState;
      notifyListeners();
    });
  }

  // Getters for UI to consume
  String? get displayName => _displayName;
  bool get audioOn => _audioOn;
  bool get musicOn => _musicOn;
  bool get soundsOn => _soundsOn;

  // Internal method to load settings initially
  Future<void> _loadSettings() async {
    // TODO maybe see if this should be streamed
    _displayName = await settingsService.getDisplayName();
    notifyListeners();
  }

  // Update methods that modify the settings and notify listeners
  void setDisplayName(String? value) async {
    if (value == null) {
      return; // Optionally handle null/empty values if necessary
    }
    await settingsService.setDisplayName(value);
    _displayName = value;
    notifyListeners();
  }

  void toggleAudioOn() async {
    await settingsService.setAudioOn(!_audioOn);
    notifyListeners();
  }

  void toggleMusicOn() async {
    _musicOn = !_musicOn;
    await settingsService.setMusicOn(_musicOn);
    notifyListeners();
  }

  void toggleSoundsOn() async {
    _soundsOn = !_soundsOn;
    await settingsService.setSoundsOn(_soundsOn);
    notifyListeners();
  }

  @override
  void dispose() {
    _audioOnSubscription.cancel();
    _musicOnSubscription.cancel();
    _soundsOnSubscription.cancel();

    super.dispose();
  }
}
