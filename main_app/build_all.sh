set -e

#pushd ios
#flutter build ipa && fastlane distribute
#popd

pushd android
flutter build appbundle && fastlane distribute
popd


APP_VER=$(yq e '.version' pubspec.yaml)
echo "App version is $APP_VER"

AAB_FILE="./build/app/outputs/bundle/release/app-release.aab"
ls -l "$AAB_FILE"

DIST_DIR="/Users/yuku/Dropbox/grii_resmi-dist"
echo 'Copying Android output...'
cp "$AAB_FILE" "$DIST_DIR/grii_resmi-dist-release-$APP_VER.aab"

#echo 'Uploading Ios output...'
#xcodebuild -exportArchive -archivePath build/ios/archive/Runner.xcarchive -exportOptionsPlist ios/ExportOptions.plist
