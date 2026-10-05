echo ========= Remove previous builds
rm -rf _builds
rm -rf ZXingCpp.xcframework

echo ========= Create project structure
cmake -S../../ -B_builds -GXcode \
    -DCMAKE_SYSTEM_NAME=Darwin \
    "-DCMAKE_OSX_ARCHITECTURES=arm64;x86_64" \
    -DCMAKE_OSX_DEPLOYMENT_TARGET=12.0 \
    -DCMAKE_INSTALL_PREFIX=`pwd`/_install \
    -DCMAKE_XCODE_ATTRIBUTE_ONLY_ACTIVE_ARCH=NO \
    -DBUILD_UNIT_TESTS=NO \
    -DBUILD_BLACKBOX_TESTS=NO \
    -DBUILD_EXAMPLES=NO \
    -DBUILD_READERS=YES \
    -DBUILD_WRITERS=NO \
    -DBUILD_APPLE_FRAMEWORK=YES

echo ========= Build the sdk for macOS
xcodebuild -project _builds/ZXing.xcodeproj build \
    -target ZXing \
    -parallelizeTargets \
    -configuration Release \
    -hideShellScriptEnvironment \
    -sdk macosx

echo ========= Create the xcframework
xcodebuild -create-xcframework \
    -framework ./_builds/core/Release/ZXing.framework \
    -output ZXingCpp.xcframework
