import 'package:digitos/services/settings_service.dart';
import 'package:digitos/view_models/base_view_model.dart';

class SettingsViewModel extends BaseViewModel {
  final SettingsService settingsService;

  String? _displayName;
  bool _audioOn = false;
  bool _musicOn = true;
  bool _soundsOn = true;

  SettingsViewModel({required this.settingsService}) {
    _loadSettings();
  }

  // Getters for UI to consume
  String? get displayName => _displayName;
  bool get audioOn => _audioOn;
  bool get musicOn => _musicOn;
  bool get soundsOn => _soundsOn;

  // Internal method to load settings initially
  Future<void> _loadSettings() async {
    _displayName = await settingsService.getDisplayName();
    _audioOn = await settingsService.getAudioOn();
    _musicOn = await settingsService.getMusicOn();
    _soundsOn = await settingsService.getSoundsOn();
    notifyListeners(); // Notify UI after loading all settings
  }

  // Update methods that modify the settings and notify listeners
  void setDisplayName(String? value) async {
    if (value == null)
      return; // Optionally handle null/empty values if necessary
    await settingsService.setDisplayName(value);
    _displayName = value;
    notifyListeners(); // Notify UI about the change
  }

  void toggleAudioOn() async {
    _audioOn = !_audioOn;
    await settingsService.setAudioOn(_audioOn);
    notifyListeners(); // Notify UI about the change
  }

  void toggleMusicOn() async {
    _musicOn = !_musicOn;
    await settingsService.setMusicOn(_musicOn);
    notifyListeners(); // Notify UI about the change
  }

  void toggleSoundsOn() async {
    _soundsOn = !_soundsOn;
    await settingsService.setSoundsOn(_soundsOn);
    notifyListeners(); // Notify UI about the change
  }
}
