#!/bin/bash

set -e

ROOT="$(readlink -f "$0" | xargs dirname)"
DIST="$ROOT/dist"
BUILD="$ROOT/build"
CACHE="$BUILD/cache"
WORK="$BUILD/work"
GNUPLOT_VERSION="$ROOT/gnuplot_version"

CHECK_VERSION_URL="https://sourceforge.net/projects/gnuplot/best_release.json"

function update {
  version_info=$(wget $CHECK_VERSION_URL -O - | jq -Mcr '.platform_releases.linux | .filename, .md5sum, .bytes')

  if (! [ -f "$GNUPLOT_VERSION" ]) || [ "$version_info" != "$(cat $GNUPLOT_VERSION)" ]; then
    echo "$version_info" > "$GNUPLOT_VERSION"

    version="$(echo $version_info | sed -r 's/.*gnuplot-(.+)\.tar.*/\1/g')"
    echo "successful!" >& 2
    echo "update gnuplot version to $version"
  fi
}

function get {
  [ -f "$GNUPLOT_VERSION" ] || update

  read -d '\n' URL MD5 SIZE < "$GNUPLOT_VERSION" || true
  NAME="${URL##*/}"

  [ -d "$CACHE" ] || mkdir -p "$CACHE"

  if ! [ -f "$CACHE/$NAME" ]; then
    wget -O "$CACHE/$NAME" "https://downloads.sourceforge.net/project/gnuplot$URL"
  fi

  echo "$MD5 $CACHE/$NAME" | md5sum -c --quiet

  [ -d "$BUILD/gnuplot" ] && rm -rf "$BUILD/gnuplot"
  mkdir -p "$BUILD/gnuplot" && tar -xf "$CACHE/$NAME" -C "$BUILD/gnuplot" --strip-components=1

  patch "$BUILD/gnuplot/src/term.h" < "$ROOT/disable_term.patch"
}

function configure {
  [ -d "$BUILD/gnuplot" ] || get

  [ -d "$WORK" ] && rm -rf "$WORK"
  mkdir -p "$WORK" && cd "$WORK"

  emconfigure ../gnuplot/configure \
    --disable-plugins \
    --disable-largefile \
    --disable-wxwidgets \
    --disable-x11-mbfonts \
    --disable-x11-external \
    --disable-history-file \
    --disable-raise-console \
    --without-x \
    --without-x-dcop \
    --without-gd \
    --without-qt \
    --without-lua \
    --without-mif \
    --without-gpic \
    --without-tgif \
    --without-cairo \
    --without-cwdrc \
    --without-latex \
    --without-regis \
    --without-libcerf \
    --without-aquaterm \
    --without-readline \
    --without-row-help \
    --without-tektronix \
    --without-bitmap-terminals \
    --without-wx-multithreaded
}

function build {
  [ -d "$WORK" ] || configure
  cd "$WORK"

  emmake make \
    CFLAGS="-Oz -flto" \
    CXXFLAGS="-Oz -flto" \
    LDFLAGS="--js-transform $ROOT/apply_template.sh -sINVOKE_RUN=0 -sENVIRONMENT=web -sINCOMING_MODULE_JS_API=arguments,printErr,onAbort,onRuntimeInitialized,instantiateWasm" \
    EXEEXT=".js" \
    gnuplot
}

function install {
  [ -f "$WORK/src/gnuplot.js" ] && [ -f"$WORK/src/gnuplot.wasm" ] || build

  [ -d "$DIST" ] || mkdir -p "$DIST"
  mv -vf "$WORK/src/gnuplot.js" "$DIST/gnuplot.js"
  mv -vf "$WORK/src/gnuplot.wasm" "$DIST/gnuplot.wasm"
  cp -vf "$ROOT/template/demo.html" "$DIST/index.html"
}

function clean {
  cd "$WORK" && emmake make clean
}

function help {
    cat <<\EOF
usage: build.sh [OPTION]

option:
    -g, get         Get gnuplot source file.
    -c, configure   Configure makefile.
    -b, build       Build gnuplot to wasm.
    -i, install     Install build file.
    -u, update      Update gnuplot version.
    -h, help        Show this help.
    clean           Clean build file.

e.g.
    build.sh -i
or
    build.sh install
EOF
}

# START ##############################################################

case "$1" in
  '')
    ;&
  -g|get)
    get
    ;&
  -c|configure)
    configure
    ;&
  -b|build)
    build
    ;&
  -i|install)
    install
    ;;
  -u|update)
    update
    ;;
  clean)
    clean
    ;;
  *)
    help
    ;;
esac
