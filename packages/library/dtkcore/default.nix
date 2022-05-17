{ stdenv
, lib
, fetchFromGitHub
, fetchpatch
, deepin-desktop-base
, pkgconfig
, qmake
, gsettings-qt
, gtest
, wrapQtAppsHook
, lshw
, dtkcommon
}:

stdenv.mkDerivation rec {
  pname = "dtkcore";
  version = "5.5.30";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = version;
    sha256 = "sha256-OFzYkK7AqOQgM7qQez/YG9GPdgE9wQ7nVpqRrUAwQcE=";
  };

  nativeBuildInputs = [
    qmake
    pkgconfig
    wrapQtAppsHook
  ];

  buildInputs = [
    gsettings-qt
    gtest
    lshw
    dtkcommon
    deepin-desktop-base
  ];

  patches = [
    (fetchpatch {
      name = "Add_NixOS_for_DSysInfo";
      url = "https://github.com/linuxdeepin/dtkcore/commit/d76a55035f64977986a47455cc90ad26eb634eef.patch";
      sha256 = "sha256-p2TDNwX+vyAMk3uuOBgQmpF1IM1S4dzp3z4G2SnPG0A=";
    })
  ];

  postPatch = ''
    substituteInPlace src/dsysinfo.cpp \
      --replace "/usr/share/deepin/distribution.info" "${deepin-desktop-base}/usr/share/deepin/distribution.info"
  '';

  qmakeFlags = [
    "LIB_INSTALL_DIR=${placeholder "out"}/lib"
    "MKSPECS_INSTALL_DIR=${placeholder "out"}/mkspecs"
  ];

  meta = with lib; {
    description = "Deepin tool kit core library";
    homepage = "https://github.com/linuxdeepin/dtkcore";
    license = licenses.lgpl3Plus;
    platforms = platforms.linux;
  };
}
