{ stdenv
, lib
, fetchFromGitHub
, pkgconfig
, qmake
, qttools
, wrapQtAppsHook
, poppler
}:

stdenv.mkDerivation rec {
  pname = "docparser";
  version = "1.0.3";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = version;
    sha256 = "sha256-iWRWSu8fALTTLLWdQGbpunN/1tpvKxuN/ZWJg34x0mU=";
  };

  nativeBuildInputs = [
    qmake
    qttools
    pkgconfig
    wrapQtAppsHook
  ];

  buildInputs = [ poppler ];

  qmakeFlags = [ "VERSION=${version}" ];

  meta = with lib; {
    description = "A document parser library ported from document2html";
    homepage = "https://github.com/linuxdeepin/docparser";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
  };
} 
