#!/bin/bash
unset ARM64_MACOSX_VERSION_MIN
ARM64_MACOSX_VERSION_MIN="11.0"
MACOSX_DEPLOYMENT_TARGET_ARM64="$ARM64_MACOSX_VERSION_MIN"
VKQ1_VERSION="1.1"

ICNSDIR="../Misc"
ICNS="vkQuake.icns"
PRODUCT_NAME="vkQuake"
WRAPPER_EXTENSION="app"
WRAPPER_NAME="${PRODUCT_NAME}.${WRAPPER_EXTENSION}"
CONTENTS_FOLDER_PATH="${WRAPPER_NAME}/Contents"
UNLOCALIZED_RESOURCES_FOLDER_PATH="${CONTENTS_FOLDER_PATH}/Resources"
EXECUTABLE_FOLDER_PATH="${CONTENTS_FOLDER_PATH}/MacOS"
EXECUTABLE_NAME="vkquake"

BUILT_PRODUCTS_DIR="build"

# make the thing
rm -rf "${BUILT_PRODUCTS_DIR}/${WRAPPER_NAME}"
make clean
make

# here we go
echo "Creating bundle '${BUILT_PRODUCTS_DIR}/${WRAPPER_NAME}'"

# make the application bundle directories
if [ ! -d "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}" ]; then
	mkdir -p "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}" || exit 1;
fi
if [ ! -d "${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}" ]; then
	mkdir -p "${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}" || exit 1;
fi

# copy and generate some application bundle resources
cp vkquake "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}"
cp /opt/homebrew/opt/sdl2/lib/libSDL2-2.0.0.dylib "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}"
cp /opt/homebrew/opt/molten-vk/lib/libMoltenVK.dylib "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}"
cp /opt/homebrew/opt/libvorbis/lib/libvorbisfile.3.dylib "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}"
cp /opt/homebrew/opt/libvorbis/lib/libvorbis.0.dylib "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}"
cp /opt/homebrew/opt/libogg/lib/libogg.0.dylib "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}"
cp /opt/homebrew/opt/mad/lib/libmad.0.dylib "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}"
cp ${ICNSDIR}/${ICNS} "${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/$ICNS" || exit 1;
echo -n ${PKGINFO} > "${BUILT_PRODUCTS_DIR}/${CONTENTS_FOLDER_PATH}/PkgInfo" || exit 1;

# use install_name tool to point executable to bundled resources (probably wrong long term way to do it)
install_name_tool -change /opt/homebrew/opt/sdl2/lib/libSDL2-2.0.0.dylib @executable_path/libSDL2-2.0.0.dylib ${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/${EXECUTABLE_NAME}
install_name_tool -change /opt/homebrew/opt/molten-vk/lib/libMoltenVK.dylib @executable_path/libMoltenVK.dylib ${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/${EXECUTABLE_NAME}
install_name_tool -change /opt/homebrew/opt/libvorbis/lib/libvorbisfile.3.dylib @executable_path/libvorbisfile.3.dylib ${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/${EXECUTABLE_NAME}
install_name_tool -change /opt/homebrew/opt/libvorbis/lib/libvorbis.0.dylib @executable_path/libvorbis.0.dylib ${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/${EXECUTABLE_NAME}
install_name_tool -change /opt/homebrew/opt/libogg/lib/libogg.0.dylib @executable_path/libogg.0.dylib ${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/${EXECUTABLE_NAME}
install_name_tool -change /opt/homebrew/opt/mad/lib/libmad.0.dylib @executable_path/libmad.0.dylib ${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/${EXECUTABLE_NAME}

install_name_tool -change /opt/homebrew/Cellar/libvorbis/1.3.7/lib/libvorbis.0.dylib @executable_path/libvorbis.0.dylib ${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/libvorbisfile.3.dylib
install_name_tool -change /opt/homebrew/opt/libogg/lib/libogg.0.dylib @executable_path/libogg.0.dylib ${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/libvorbisfile.3.dylib
install_name_tool -change /opt/homebrew/opt/libogg/lib/libogg.0.dylib @executable_path/libogg.0.dylib ${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/libvorbis.0.dylib

# create Info.Plist
PLIST="<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<!DOCTYPE plist PUBLIC \"-//Apple//DTD PLIST 1.0//EN\" \"http://www.apple.com/DTDs/PropertyList-1.0.dtd\">
<plist version=\"1.0\">
<dict>
    <key>CFBundleDevelopmentRegion</key>
    <string>en</string>
    <key>CFBundleExecutable</key>
    <string>${EXECUTABLE_NAME}</string>
    <key>CFBundleIconFile</key>
    <string>vkQuake</string>
    <key>CFBundleIdentifier</key>
    <string>com.macsourceports.${PRODUCT_NAME}</string>
    <key>CFBundleInfoDictionaryVersion</key>
    <string>6.0</string>
    <key>CFBundleName</key>
    <string>${PRODUCT_NAME}</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>${VKQ1_VERSION}</string>
    <key>CFBundleSignature</key>
    <string>????</string>
    <key>CFBundleVersion</key>
    <string>${VKQ1_VERSION}</string>
    <key>CGDisableCoalescedUpdates</key>
    <true/>
    <key>LSMinimumSystemVersion</key>
    <string>${MACOSX_DEPLOYMENT_TARGET}</string>"

if [ -n "${MACOSX_DEPLOYMENT_TARGET_X86_64}" ] || [ -n "${MACOSX_DEPLOYMENT_TARGET_ARM64}" ]; then
	PLIST="${PLIST}
    <key>LSMinimumSystemVersionByArchitecture</key>
    <dict>"

	if [ -n "${MACOSX_DEPLOYMENT_TARGET_X86_64}" ]; then
	PLIST="${PLIST}
        <key>x86_64</key>
        <string>${MACOSX_DEPLOYMENT_TARGET_X86_64}</string>"
	fi
	
	if [ -n "${MACOSX_DEPLOYMENT_TARGET_ARM64}" ]; then
	PLIST="${PLIST}
        <key>arm64</key>
        <string>${MACOSX_DEPLOYMENT_TARGET_ARM64}</string>"
	fi

	PLIST="${PLIST}
    </dict>"
fi

PLIST="${PLIST}
    <key>NSHumanReadableCopyright</key>
    <string>QUAKE III ARENA Copyright © 1999-2000 id Software, Inc. All rights reserved.</string>
    <key>NSPrincipalClass</key>
    <string>NSApplication</string>
    <key>NSHighResolutionCapable</key>
    <false/>
    <key>NSRequiresAquaSystemAppearance</key>
    <false/>
</dict>
</plist>
"
echo -e "${PLIST}" > "${BUILT_PRODUCTS_DIR}/${CONTENTS_FOLDER_PATH}/Info.plist"

echo "bundle done."

# ****************************************************************************************
# identity as specified in Keychain
SIGNING_IDENTITY="Developer ID Application: Your Name (XXXXXXXXX)"

ASC_USERNAME="your@apple.id"

# signing password is app-specific (https://appleid.apple.com/account/manage) and stored in Keychain (as "notarize-app" in this case)
ASC_PASSWORD="@keychain:notarize-app"

# ProviderShortname can be found with
# xcrun altool --list-providers -u your@apple.id -p "@keychain:notarize-app"
ASC_PROVIDER="XXXXXXXXX"
# ****************************************************************************************

source make-macosx-values.sh

# sign the resulting app bundle
echo "signing..."
# codesign --force --options runtime --deep --entitlements "${ENTITLEMENTS_FILE}" --sign "${SIGNING_IDENTITY}" ${RELEASE_LOCATION}/${RELEASE_BUILD}	# sign the resulting app bundle
codesign --force --deep --sign "${SIGNING_IDENTITY}" ${BUILT_PRODUCTS_DIR}/${WRAPPER_NAME}