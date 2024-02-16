abstract class SettingsServiceInterface {
  Future<bool> getAudioOn();
  Future<void> setAudioOn(bool on);
  Stream<bool> get audioOnStream;
  Future<bool> getMusicOn();
  Future<void> setMusicOn(bool on);
  Stream<bool> get musicOnStream;
  Future<bool> getSoundsOn();
  Future<void> setSoundsOn(bool on);
  Stream<bool> get soundsOnStream;
}
