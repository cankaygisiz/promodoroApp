#!/bin/bash
cd /Users/cankaygisiz/Development/projects/promodoro/Promodoro/Assets.xcassets/AppIcon.appiconset
sips -z 16 16 logo.png --out icon_16x16.png
sips -z 32 32 logo.png --out icon_16x16@2x.png
sips -z 32 32 logo.png --out icon_32x32.png
sips -z 64 64 logo.png --out icon_32x32@2x.png
sips -z 128 128 logo.png --out icon_128x128.png
sips -z 256 256 logo.png --out icon_128x128@2x.png
sips -z 256 256 logo.png --out icon_256x256.png
sips -z 512 512 logo.png --out icon_256x256@2x.png
sips -z 512 512 logo.png --out icon_512x512.png
sips -z 1024 1024 logo.png --out icon_512x512@2x.png
sips -z 1024 1024 logo.png --out icon_1024x1024.png
echo "All icons regenerated!"
