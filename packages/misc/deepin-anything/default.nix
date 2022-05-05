{ stdenv
, lib
, fetchFromGitHub
, dtkcore
, qmake
, pkgconfig
, udisks2-qt5
, utillinux
, pcre
, breakpointHook
}:

stdenv.mkDerivation rec {
  pname = "deepin-anything";
  version = "6.0.0";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = version;
    sha256 = "sha256-1GX/gemRTMhP8ZixYzB3mwQrWonjEPNYWY6zutTnLqw=";
  };

  outputs = [ "out" "server" ];

  nativeBuildInputs = [
    qmake
    pkgconfig
    breakpointHook
  ];

  buildInputs = [
    dtkcore
    udisks2-qt5
    utillinux
    pcre
  ];

  dontWrapQtApps = true;
  dontUseQmakeConfigure = true;

  # TODO: sysusers
  fixServerPatch = ''
    substituteInPlace server/backend/backend.pro \
      --replace '/usr/share/dbus-1/interfaces' '/share/dbus-1/interfaces'
  '';

  postPatch = fixServerPatch;

  buildPhase = ''
    make -C library all
    cd server 
    qmake -makefile -nocache QMAKE_STRIP=: PREFIX=/ LIB_INSTALL_DIR=/lib deepin-anything-backend.pro 
    make all
    cd ..
  '';

  # FIXME out/usr/lib/modules-load.d/anything.conf ?
  installPhase = ''
    mkdir -p $out/lib
    cp library/bin/release/* $out/lib
    mkdir -p $out/usr/src/deepin-anything-${version}
    cp -r kernelmod/* $out/usr/src/deepin-anything-${version}
    mkdir -p $out/usr/lib/modules-load.d
    echo "" | tee $out/usr/lib/modules-load.d/anything.conf
    mkdir -p $out/usr/include/deepin-anything
    cp -r library/inc/* $out/usr/include/deepin-anything
    cp -r kernelmod/vfs_change_uapi.h $out/usr/include/deepin-anything
    cp -r kernelmod/vfs_change_consts.h $out/usr/include/deepin-anything
    make -C server install INSTALL_ROOT=${placeholder "server"}
  '';

  meta = with lib; {
    description = "Deepin Anything file search tool";
    homepage = "https://github.com/linuxdeepin/deepin-anything";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
  };
}
