#!/bin/bash
#
# Script to make an installable package of the plugin.
#
# Uses xcodebuild, pkgbuild and productbuild.
#

# Create a clean install directory...
if test -d build/Package; then
	sudo chmod -R u+w build/Package
	sudo rm -rf build/Package
fi
mkdir -p build/Package/Root
mkdir -p build/Package/Resources

# Install into this directory...
xcodebuild -workspace "$PWD/QLWindowsApps.xcworkspace" \
           -scheme QLWindowsApps \
           -configuration Release \
           install \
           DSTROOT="$PWD/build/Package/Root"

# Extract the version number from the project...
ver=$(git describe | sed 's/release_//')
if [[ ! ( $? -eq 0 ) ]]; then
  ver=$(/usr/libexec/PlistBuddy -c "Print:CFBundleShortVersionString" "MicrosoftBinaries/Info.plist")
fi

# Make the package with pkgbuild and the product distribution with productbuild...
echo pkgbuild...
pkgbuild --identifier       com.danielecattaneo.qlgenerator.qlwindowsapps   \
         --version          "$ver"   \
         --root             build/Package/Root   \
         --scripts          ./MicrosoftBinaries/PackageResources/Scripts \
         "./QLWindowsApps.pkg"   
productbuild --distribution     ./MicrosoftBinaries/PackageResources/Distribution.xml   \
             --resources        ./MicrosoftBinaries/PackageResources/Resources \
             --package-path     ./ \
             "./QLWindowsApps-$ver.pkg"
rm ./QLWindowsApps.pkg
