#!/bin/sh
PWD=`pwd`
ULALACA_SRC=$PWD/../ulalaca

PRODUCT_NAME="麗 -ulalaca-"
IDENTIFIER="pl.unstabler.ulalaca.prebuilt"
VERSION="0.1.0"

SIGN_IDENTITY="Developer ID Installer: team unstablers Inc."

SESSIONBROKER_IDENTIFIER="pl.unstabler.ulalaca.sessionbroker"
SESSIONPROJECTOR_IDENTIFIER="pl.unstabler.ulalaca.sessionprojector"
SESSIONPROJECTOR_LAUNCHER_IDENTIFIER="pl.unstabler.ulalaca.sessionprojector.launcher"

CODE_SIGN_STYLE="Manual"
CODE_SIGN_IDENTITY="Developer ID Application: team unstablers Inc."

function package_sessionbroker() {
    rm -rf $PWD/intermediate/sessionbroker
    mkdir -p $PWD/intermediate/sessionbroker
    xcodebuild DSTROOT=$PWD/intermediate/sessionbroker CODE_SIGN_STYLE="$CODE_SIGN_STYLE" CODE_SIGN_IDENTITY="$CODE_SIGN_IDENTITY" -workspace $ULALACA_SRC/Ulalaca.xcworkspace -scheme sessionbroker install

    mkdir -p $PWD/intermediate/sessionbroker/etc
    cp -rv $ULALACA_SRC/sessionbroker/pam.d $PWD/intermediate/sessionbroker/etc/

    mkdir -p $PWD/intermediate/sessionbroker/Library
    cp -rv $ULALACA_SRC/sessionbroker/LaunchDaemons $PWD/intermediate/sessionbroker/Library/

    pkgbuild \
        --identifier "$SESSIONBROKER_IDENTIFIER" \
        --version $VERSION \
        --min-os-version "13.0" \
        --root "$PWD/intermediate/sessionbroker" \
        --scripts "$PWD/scripts/sessionbroker" \
        --install-location "/" \
        "$PWD/sessionbroker.pkg"
}

function package_sessionprojector() {
    rm -rf $PWD/intermediate/sessionprojector
    mkdir -p $PWD/intermediate/sessionprojector
    xcodebuild DSTROOT=$PWD/intermediate/sessionprojector CODE_SIGN_STYLE="$CODE_SIGN_STYLE" CODE_SIGN_IDENTITY="$CODE_SIGN_IDENTITY" -workspace $ULALACA_SRC/Ulalaca.xcworkspace -scheme sessionprojector install

    # --identifier "$SESSIONPROJECTOR_IDENTIFIER" \
    pkgbuild \
        --component "$PWD/intermediate/sessionprojector/Applications/sessionprojector.app" \
        --version $VERSION \
        --min-os-version "13.0" \
        --install-location /Applications \
        "$PWD/sessionprojector.pkg"
}

function package_sessionprojector_launcher() {
    rm -rf $PWD/intermediate/sessionprojector-launcher
    mkdir -p $PWD/intermediate/sessionprojector-launcher
    xcodebuild DSTROOT=$PWD/intermediate/sessionprojector-launcher CODE_SIGN_STYLE="$CODE_SIGN_STYLE" CODE_SIGN_IDENTITY="$CODE_SIGN_IDENTITY" -workspace $ULALACA_SRC/Ulalaca.xcworkspace -scheme sessionprojector-launcher install

    mkdir -p $PWD/intermediate/sessionprojector/Library
    cp -rv $ULALACA_SRC/sessionprojector/LaunchAgents $PWD/intermediate/sessionprojector/Library/

    pkgbuild \
        --identifier "$SESSIONPROJECTOR_LAUNCHER_IDENTIFIER" \
        --version $VERSION \
        --min-os-version "13.0" \
        --root "$PWD/intermediate/sessionprojector-launcher" \
        --scripts "$PWD/scripts/sessionprojector-launcher" \
        --install-location "/" \
        "$PWD/sessionprojector-launcher.pkg"
}

package_sessionbroker
package_sessionprojector
package_sessionprojector_launcher

productbuild --distribution ./Distribution.xml --package-path . ./ulalaca.unsigned.pkg
productsign --sign "$SIGN_IDENTITY" ./ulalaca.unsigned.pkg ./ulalaca.signed.pkg
