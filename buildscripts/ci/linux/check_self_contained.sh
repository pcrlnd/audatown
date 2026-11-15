#!/usr/bin/env bash
# Checks if any dependency we build/bundle ourselves resolves to a system library,
set -euo pipefail

APP="${1:?usage: $0 <app-binary>}"
PREFIX="$(cd "$(dirname "$APP")/.." && pwd)"

# Libraries to check
OWNED='libvorbis|libvorbisenc|libvorbisfile|libogg|libFLAC|libopus|libopusfile|libsndfile|libmpg123|libmp3lame|libwavpack|libwx_base|libexpat|libportaudio|libfdk-aac|libfreetype|libharfbuzz|libz\.'

mapfile -t executables < <(find "$PREFIX/bin" -type f -perm -111)

leaks=""
for exe in "${executables[@]}"; do
    deps="$(LD_LIBRARY_PATH="$PREFIX/lib" ldd "$exe" 2>/dev/null || true)"
    exe_leaks="$(grep -E "$OWNED" <<< "$deps" | grep -E '=> /usr|=> /lib' || true)"
    if [ -n "$exe_leaks" ]; then
        leaks+="${exe}"$'\n'"${exe_leaks}"$'\n'
    fi
done

if [ -n "$leaks" ]; then
    echo "NOT self-contained, these owned libraries resolve to system paths:" >&2
    echo "$leaks" >&2
    exit 1
fi

echo "OK: all owned dependencies resolve inside the build tree"
