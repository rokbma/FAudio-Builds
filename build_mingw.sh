#!/usr/bin/env bash
set -euo pipefail

TARGET="faudio-$1"

[ ! -d "$PWD/FAudio" ] && git clone https://github.com/FNA-XNA/FAudio.git
cd FAudio
git checkout "$1" || { git checkout master && git pull && git checkout "$1"; }

x86_64-w64-mingw32-cmake -H. -B_build_mingw64 -DCMAKE_INSTALL_PREFIX="$PWD/_faudio_mingw64" -DINSTALL_MINGW_DEPENDENCIES=ON  -DSDL2_INCLUDE_DIRS=/usr/x86_64-w64-mingw32/include/SDL2 -DSDL2_LIBRARIES=/usr/x86_64-w64-mingw32/lib/libSDL2.dll.a
cmake --build _build_mingw64 --target install -- -j

[ -d "$TARGET" ] && rm -r "$TARGET"
mkdir "$TARGET"
mv "$PWD/_faudio_mingw64/bin" "$TARGET/x64"

tar --numeric-owner -cvf "$TARGET.tar" "$TARGET"
zstd -f --ultra -22 -o "$TARGET.tar.zst" "$TARGET.tar"
rm -r "$TARGET" "$TARGET.tar"
mv "$TARGET.tar.zst" ../
