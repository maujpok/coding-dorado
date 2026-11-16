#!/bin/sh
# Imprime el id del dispositivo conectado de una plataforma (android | ios),
# según `flutter devices --machine`. Prefiere emuladores y simuladores a los
# dispositivos físicos. No imprime nada si no hay ninguno.
#
# Uso: tool/device_id.sh android
# El comando de Flutter se puede cambiar con FLUTTER (por ejemplo "fvm flutter").
set -eu

platform="${1:?Uso: tool/device_id.sh android|ios}"

${FLUTTER:-flutter} devices --machine 2>/dev/null | python3 -c '
import json
import sys

platform = sys.argv[1]
try:
    devices = json.load(sys.stdin)
except ValueError:
    devices = []
matching = [d for d in devices if d.get("targetPlatform", "").startswith(platform)]
matching.sort(key=lambda d: not d.get("emulator", False))
if matching:
    print(matching[0]["id"])
' "$platform"
