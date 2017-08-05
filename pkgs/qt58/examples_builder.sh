source $setup

tar -xf $src qtbase-opensource-src-$version/examples

mv qtbase-opensource-src-$version/examples .
rmdir qtbase-opensource-src-$version

mkdir build
cd build
mkdir bin moc obj

cat > obj/plugins.cpp <<EOF
#include <QtPlugin>
#ifdef _WIN32
Q_IMPORT_PLUGIN (QWindowsIntegrationPlugin);
#endif
#ifdef __linux__
Q_IMPORT_PLUGIN (QLinuxFbIntegrationPlugin);
Q_IMPORT_PLUGIN (QXcbIntegrationPlugin);
#endif
EOF

echo "compiling reference to plugins"
$host-g++ \
  $(pkg-config-cross --cflags Qt5Core) \
  -c obj/plugins.cpp \
  -o obj/plugins.o

CFLAGS="-g -I. $(pkg-config-cross --cflags Qt5Widgets)"
LIBS="$(pkg-config-cross --libs Qt5Widgets)"
LDFLAGS="-Wl,-gc-sections"

if [ $os = "windows" ]; then
  CFLAGS="-mwindows $CFLAGS"
fi

echo "compiling dynamiclayouts"
$qtbase/bin/moc ../examples/widgets/layouts/dynamiclayouts/dialog.h > moc/dynamiclayouts.cpp
$host-g++ $CFLAGS $LDFLAGS \
  ../examples/widgets/layouts/dynamiclayouts/dialog.cpp \
  ../examples/widgets/layouts/dynamiclayouts/main.cpp \
  moc/dynamiclayouts.cpp \
  obj/plugins.o \
  $LIBS -o bin/dynamiclayouts$exe_suffix

mkdir $out && cp -r bin $out && exit 0  # TODO: remove this line

echo "compiling rasterwindow"
$qtbase/bin/moc ../examples/gui/rasterwindow/rasterwindow.h > moc/rasterwindow.cpp
$host-g++ $CFLAGS $LDFLAGS \
  ../examples/gui/rasterwindow/rasterwindow.cpp \
  ../examples/gui/rasterwindow/main.cpp \
  moc/rasterwindow.cpp \
  obj/plugins.o \
  $LIBS -o bin/rasterwindow$exe_suffix

echo "compiling analogclock"
$host-g++ $CFLAGS $LDFLAGS \
  -I../examples/gui/rasterwindow/ \
  ../examples/gui/analogclock/main.cpp \
  ../examples/gui/rasterwindow/rasterwindow.cpp \
  moc/rasterwindow.cpp \
  obj/plugins.o \
  $LIBS -o bin/analogclock$exe_suffix

echo "compiling openglwindow"
$qtbase/bin/moc ../examples/gui/openglwindow/openglwindow.h > moc/openglwindow.cpp
$host-g++ $CFLAGS $LDFLAGS \
  ../examples/gui/openglwindow/main.cpp \
  ../examples/gui/openglwindow/openglwindow.cpp \
  moc/openglwindow.cpp \
  obj/plugins.o \
  $LIBS -o bin/openglwindow$exe_suffix

# TODO: try to compile some stuff with $qtbase/bin/qmake too, make sure that works

mkdir $out

cp -r bin $out
