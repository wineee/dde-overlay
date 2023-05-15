{ stdenv
, lib
, fetchFromGitHub
, fetchpatch
, cmake
, pkg-config
, wayland
, dwayland
, qtbase
, qttools
, qtx11extras
, wrapQtAppsHook
, extra-cmake-modules
, gsettings-qt
, libepoxy
, kconfig
, kconfigwidgets
, kcoreaddons
, kcrash
, kdbusaddons
, kiconthemes
, kglobalaccel
, kidletime
, knotifications
, kpackage
, plasma-framework
, kcmutils
, knewstuff
, kdecoration
, kscreenlocker
, breeze-qt5
, libinput
, mesa
, lcms2
, xorg
, dtkcore
}:
stdenv.mkDerivation rec {
  pname = "deepin-kwin";
  version = "5.25.4";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = version;
    sha256 = "sha256-1R7pTs3ln+J7CIMiktPB/qRV53Q/oyDh7BmgKALB9Tg=";
  };

  patches = [
    ./0001-hardcode-fallback-background.diff
  ];

  postPatch = ''
    substituteInPlace src/effects/screenshot/screenshotdbusinterface1.cpp \
      --replace 'file.readAll().startsWith(DEFINE_DDE_DOCK_PATH"dde-dock")' 'file.readAll().contains("dde-dock")'
  '';

  nativeBuildInputs = [
    cmake  
    pkg-config
    extra-cmake-modules
    wrapQtAppsHook
  ];

  buildInputs = [
    qtbase
    qttools
    qtx11extras
    dtkcore

    wayland
    dwayland
    libepoxy
    gsettings-qt

    kconfig
    kconfigwidgets
    kcoreaddons
    kcrash
    kdbusaddons
    kiconthemes

    kglobalaccel
    kidletime
    knotifications
    kpackage
    plasma-framework
    kcmutils
    knewstuff
    kdecoration
    kscreenlocker

    breeze-qt5
    libinput
    mesa
    lcms2

    xorg.libxcb
    xorg.libXdmcp
    xorg.libXcursor
    xorg.xcbutilcursor
    xorg.libXtst
    xorg.libXScrnSaver
  ];

  cmakeFlags = [
    #"-DKWIN_BUILD_KCMS=OFF"
    "-DKWIN_BUILD_TABBOX=ON"
    #"-DKWIN_BUILD_CMS=OFF"
    "-DKWIN_BUILD_RUNNERS=OFF"
  ];

  meta = with lib; {
    description = "Easy to use, but flexible, composited Window Manager";
    homepage = "https://github.com/linuxdeepin/deepin-kwin";
    license = licenses.lgpl21Plus;
    platforms = platforms.linux;
    maintainers = teams.deepin.members;
  };
}
