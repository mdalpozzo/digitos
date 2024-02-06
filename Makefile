.PHONY: clean get build run splash

clean:
	flutter clean

get:
	flutter pub get

build:
	flutter build apk

run:
	flutter run

splash:
	dart run flutter_native_splash:create

# You can add more tasks as needed
