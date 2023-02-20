{ stdenv
, lib
, fetchFromGitHub
, dtkgui
, pkg-config
, cmake
, qttools
, wrapQtAppsHook
, qtdeclarative
, qtquickcontrols2
, gtest
, doxygen
, qtbase
}:

stdenv.mkDerivation rec {
  pname = "dtkdeclarative";
  version = "5.6.3";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = "9c0c05e197ff8a0dd6464aaa4f24fe146399274c";
    sha256 = "sha256-Rh6G7h2JBSozk5k/I2ENbSPyZJRLYOdotBVbwnNUFZ0=";
  };

  postPatch = ''
    substituteInPlace chameleon/CMakeLists.txt \
      --replace "''${_qt5Core_install_prefix}/bin/qmlcachegen" "${qtdeclarative.dev}/bin/qmlcachegen"
  '';

  nativeBuildInputs = [
    cmake
    qttools
    pkg-config
    wrapQtAppsHook
    qtdeclarative.dev

    doxygen
    qttools.dev
  ];

  buildInputs = [
    qtdeclarative
    qtquickcontrols2
    gtest
  ];

  propagatedBuildInputs = [ dtkgui ];

  cmakeFlags = [
    "-DVERSION=${version}"
    "-DBUILD_DOCS=ON"
    "-DBUILD_EXAMPLES=ON"
    "-DMKSPECS_INSTALL_DIR=${placeholder "out"}/mkspecs/modules"
    "-DCMAKE_INSTALL_LIBDIR=lib"
    "-DCMAKE_INSTALL_INCLUDEDIR=include"
  ];

  preConfigure = ''
    # qt.qpa.plugin: Could not find the Qt platform plugin "minimal"
    # A workaround is to set QT_PLUGIN_PATH explicitly
    export QT_PLUGIN_PATH=${qtbase.bin}/${qtbase.qtPluginPrefix}
    export QML2_IMPORT_PATH=${qtdeclarative.bin}/${qtbase.qtQmlPrefix}
  '';

  meta = with lib; {
    description = "A widget development toolkit based on QtQuick/QtQml";
    homepage = "https://github.com/linuxdeepin/dtkdeclarative";
    license = licenses.lgpl3Plus;
    platforms = platforms.linux;
  };
}