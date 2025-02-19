# to run:  make clean

localization:
	echo "╠ Generating the localization files..." 
	flutter gen-l10n --arb-dir lib/presentation/l10n
	flutter pub get

clean:
	echo "╠ Cleaning the project..."
	rm -rf pubspec.lock
	flutter clean
	flutter pub get