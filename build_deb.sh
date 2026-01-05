#!/bin/bash
set -e

APP_NAME="bleach"
VERSION="0.1.0"
BUILD_DIR="build"
DEB_DIR="$BUILD_DIR/${APP_NAME}_${VERSION}_all"

echo "Building Debian package for $APP_NAME v$VERSION..."

# Clean build
rm -rf "$BUILD_DIR"
mkdir -p "$DEB_DIR/DEBIAN"
mkdir -p "$DEB_DIR/usr/lib/python3/dist-packages"
mkdir -p "$DEB_DIR/usr/bin"

# Copy control file
cp packaging/debian/control "$DEB_DIR/DEBIAN/"
cp packaging/debian/postinst "$DEB_DIR/DEBIAN/"
chmod 755 "$DEB_DIR/DEBIAN/postinst"

# Copy source code
cp -r src/bleach "$DEB_DIR/usr/lib/python3/dist-packages/"

# Create wrapper script
cat <<EOF > "$DEB_DIR/usr/bin/bleach"
#!/bin/bash
python3 -m bleach.cli "\$@"
EOF
chmod 755 "$DEB_DIR/usr/bin/bleach"

# Build .deb
dpkg-deb --build "$DEB_DIR"

echo "Package built at: $BUILD_DIR/${APP_NAME}_${VERSION}_all.deb"
