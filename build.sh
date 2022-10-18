#!/bin/sh
PWD=`pwd`
ULALACA_SRC=$PWD/../ulalaca

PRODUCT_NAME="麗 -ulalaca-"
IDENTIFIER="pl.unstabler.ulalaca.prebuilt"
VERSION="0.1.0"

SIGN_IDENTITY="Developer ID Installer: team unstablers Inc."

SESSIONBROKER_IDENTIFIER="pl.unstabler.ulalaca.sessionbroker"
SESSIONPROJECTOR_IDENTIFIER="pl.unstabler.ulalaca.sessionprojector"

function package_sessionbroker() {
    rm -rf $PWD/intermediate/sessionbroker
    mkdir -p $PWD/intermediate/sessionbroker
    xcodebuild DSTROOT=$PWD/intermediate/sessionbroker -workspace $ULALACA_SRC/Ulalaca.xcworkspace -scheme sessionbroker install

    mkdir -p $PWD/intermediate/sessionbroker/etc
    cp -rv $ULALACA_SRC/sessionbroker/pam.d $PWD/intermediate/sessionbroker/etc/

    mkdir -p $PWD/intermediate/sessionbroker/Library
    cp -rv $ULALACA_SRC/sessionbroker/LaunchDaemons $PWD/intermediate/sessionbroker/Library/

    pkgbuild \
        --identifier "$SESSIONBROKER_IDENTIFIER" \
        --version $VERSION \
        --min-os-version "12.3" \
        --root "$PWD/intermediate/sessionbroker" \
        --scripts "$PWD/scripts/sessionbroker" \
        "$PWD/sessionbroker.pkg"
}

function package_sessionprojector() {
    rm -rf $PWD/intermediate/sessionprojector
    mkdir -p $PWD/intermediate/sessionprojector
    xcodebuild DSTROOT=$PWD/intermediate/sessionprojector -workspace $ULALACA_SRC/Ulalaca.xcworkspace -scheme sessionprojector install

    mkdir -p $PWD/intermediate/sessionprojector/Library
    cp -rv $ULALACA_SRC/sessionprojector/LaunchAgents $PWD/intermediate/sessionprojector/Library/

    pkgbuild \
        --identifier "$SESSIONPROJECTOR_IDENTIFIER" \
        --version $VERSION \
        --min-os-version "12.3" \
        --root "$PWD/intermediate/sessionprojector" \
        --scripts "$PWD/scripts/sessionprojector" \
        "$PWD/sessionprojector.pkg"
}

package_sessionbroker
package_sessionprojector

productbuild --distribution ./Distribution.xml --package-path . ./ulalaca_unsigned.pkg
productsign --sign "$SIGN_IDENTITY" ./ulalaca_unsigned.pkg ./ulalaca_signed.pkg
