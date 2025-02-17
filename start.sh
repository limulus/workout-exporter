#!/usr/bin/env bash
set -eo pipefail

# Load environment variables from .env file
if [ -f .env ]; then
  export $(grep -v '^#' .env | xargs)
fi

xcodebuild -scheme "Workout Exporter" -destination "platform=iOS,id=${TARGET_DEVICE_UUID}" -configuration Debug build install
xcrun devicectl device process launch --console --device ${TARGET_DEVICE_UUID} --start-stopped net.limulus.Workout-Exporter
