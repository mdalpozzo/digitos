import 'dart:async';

import 'package:digitos/services/app_logger.dart';
import 'package:digitos/services/local_storage_service/local_storage_service.dart';
import 'package:digitos/services/settings_service_interface.dart';

class SettingsService implements SettingsServiceInterface {
  static final _log = AppLogger('SettingsService');
  final LocalStorageService _localStorageService;
  final _audioOnController = StreamController<bool>.broadcast();
  final _musicOnController = StreamController<bool>.broadcast();
  final _soundsOnController = StreamController<bool>.broadcast();

  SettingsService(this._localStorageService) {
    getAudioOn().then((currentSetting) {
      _audioOnController.add(currentSetting);
    });
    getMusicOn().then((currentSetting) {
      _musicOnController.add(currentSetting);
    });
    getSoundsOn().then((currentSetting) {
      _soundsOnController.add(currentSetting);
    });
  }


  Stream<bool> get audioOnStream => _audioOnController.stream;

  Future<bool> getAudioOn() async {
    bool? value = await _localStorageService.getBool('audioOn');
    return value == true;
  }

  Future<void> setAudioOn(bool on) async {
    await _localStorageService.setBool('audioOn', on);
    _audioOnController.add(on);

    _log.info('AudioOn set to $on');
  }

  Stream<bool> get musicOnStream => _musicOnController.stream;

  Future<bool> getMusicOn() async {
    bool? value = await _localStorageService.getBool('musicOn');
    return value == true;
  }

  Future<void> setMusicOn(bool on) async {
    await _localStorageService.setBool('musicOn', on);
    _musicOnController.add(on);

    _log.info('MusicOn set to $on');
  }

  Stream<bool> get soundsOnStream => _soundsOnController.stream;

  Future<bool> getSoundsOn() async {
    bool? value = await _localStorageService.getBool('soundsOn');
    return value == true;
  }

  Future<void> setSoundsOn(bool on) async {
    await _localStorageService.setBool('soundsOn', on);
    _soundsOnController.add(on);
    _log.info('SoundsOn set to $on');
  }

  // Dispose method to close the controllers
  void dispose() {
    _audioOnController.close();
    _musicOnController.close();
    _soundsOnController.close();
  }
}
