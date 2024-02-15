import 'package:digitos/services/app_logger.dart';
import 'package:digitos/services/local_storage_service/local_storage_service.dart';

class SettingsService {
  static final _log = AppLogger('SettingsService');
  final LocalStorageService _localStorageService;

  SettingsService(this._localStorageService);

  Future<String?> getDisplayName() async {
    return await _localStorageService.getString('displayName');
  }

  Future<void> setDisplayName(String name) async {
    await _localStorageService.setString('displayName', name);
    _log.info('Display name set to $name');
  }

  Future<bool> getAudioOn() async {
    bool? value = await _localStorageService.getBool('audioOn');
    return value == true;
  }

  Future<void> setAudioOn(bool on) async {
    await _localStorageService.setBool('audioOn', on);
    _log.info('AudioOn set to $on');
  }

  Future<bool> getMusicOn() async {
    bool? value = await _localStorageService.getBool('musicOn');
    return value == true;
  }

  Future<void> setMusicOn(bool on) async {
    await _localStorageService.setBool('musicOn', on);
    _log.info('MusicOn set to $on');
  }

  Future<bool> getSoundsOn() async {
    bool? value = await _localStorageService.getBool('soundsOn');
    return value == true;
  }

  Future<void> setSoundsOn(bool on) async {
    await _localStorageService.setBool('soundsOn', on);
    _log.info('SoundsOn set to $on');
  }
}
