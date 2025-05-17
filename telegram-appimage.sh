#!/bin/sh

set -ex

export ARCH=$(uname -m)
export APPIMAGE_EXTRACT_AND_RUN=1
REPO="https://api.github.com/repos/telegramdesktop/tdesktop/releases"
APPIMAGETOOL="https://github.com/pkgforge-dev/appimagetool-uruntime/releases/download/continuous/appimagetool-$ARCH.AppImage"
UPINFO="gh-releases-zsync|$(echo $GITHUB_REPOSITORY | tr '/' '|')|latest|*$ARCH.AppImage.zsync"
DESKTOP="https://github.com/telegramdesktop/tdesktop/raw/refs/heads/dev/lib/xdg/org.telegram.desktop.desktop"
ICON="https://github.com/telegramdesktop/tdesktop/blob/dev/Telegram/Resources/art/icon256.png?raw=true"
export URUNTIME_PRELOAD=1 # really needed here

# the linux releases of telegram don't mention linuxi n the url wtf
tarball_url=$(wget "$REPO" -O - | sed 's/[()",{} ]/\n/g' | grep -oi "https.*.tar.xz$" | head -1)

export VERSION=$(echo "$tarball_url" | awk -F'/' '{print $(NF-1); exit}')
echo "$VERSION" > ~/version

wget "$tarball_url" -O ./package.tar.xz
tar xvf ./package.tar.xz
rm -f ./package.tar.xz

mv -v ./Telegram ./AppDir && (
	cd ./AppDir
	rm -f ./Updater

	ln -s Telegram ./AppRun
	chmod +x ./Telegram

	wget "$DESKTOP" -O  ./org.telegram.desktop.desktop
	wget "$ICON"    -O  ./org.telegram.desktop.png
	wget "$ICON"    -O  ./.DirIcon
)

wget "$APPIMAGETOOL" -O ./appimagetool
chmod +x ./appimagetool
./appimagetool -n -u "$UPINFO" ./AppDir

