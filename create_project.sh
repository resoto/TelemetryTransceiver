#!/bin/bash

# Create Xcode project for TelemetryTransceiver
cd /Users/resoto/Desktop/ios1/TelemetryTransceiver

# Use xcrun to create a new iOS app project
mkdir -p TelemetryTransceiver.xcodeproj

cat > project.yml << 'EOF'
name: TelemetryTransceiver
options:
  bundleIdPrefix: com.telemetry
targets:
  TelemetryTransceiver:
    type: application
    platform: iOS
    deploymentTarget: "16.0"
    sources:
      - TelemetryTransceiver
    info:
      path: TelemetryTransceiver/Info.plist
    settings:
      PRODUCT_BUNDLE_IDENTIFIER: com.telemetry.transceiver
      DEVELOPMENT_TEAM: ""
      CODE_SIGN_STYLE: Automatic
      INFOPLIST_FILE: TelemetryTransceiver/Info.plist
      SWIFT_VERSION: "5.0"
      TARGETED_DEVICE_FAMILY: "1,2"
EOF

echo "Project structure created"
