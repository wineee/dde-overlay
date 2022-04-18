{ stdenv
, lib
, fetchFromGitHub
, qmake
, pkgconfig
, wrapQtAppsHook
, dtkcore
, dtkgui
, dtkwidget
, qtx11extras
, qt5platform-plugins
, lxqt
, mtdev
, gtest
}:

stdenv.mkDerivation rec {
  pname = "qt5integration";
  version = "5.5.20";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = version;
    sha256 = "sha256-w1Thxpn8METjpAtrhkjNXOjH5CAkEEystucNnJ39Cow=";
  };

  nativeBuildInputs = [ qmake pkgconfig wrapQtAppsHook ];

  buildInputs = [
    dtkcore
    dtkgui
    dtkwidget
    qtx11extras
    qt5platform-plugins
    mtdev
    gtest
    lxqt.libqtxdg
  ];

  installPhase = ''
    cp -r bin $out
  '';

  meta = with lib; {
    description = "Qt platform theme integration plugins for DDE";
    homepage = "https://github.com/linuxdeepin/qt5integration";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
  };
}