{ stdenv
, lib
, fetchFromDeepin
, readVersion
, cmake
, pkgconfig
, wrapQtAppsHook
, glibmm
, doxygen
, buildDocs ? false
}:

stdenv.mkDerivation rec {
  pname = "gio-qt";
  version = readVersion pname;

  src = fetchFromDeepin {
    inherit pname;
    sha256 = "sha256-dlY1CTlXywgGZUonBBe3cDwx8h2xXrPY6Ft/D59nlug=";
  };

  nativeBuildInputs = [ cmake pkgconfig wrapQtAppsHook ];

  cmakeFlags = [ "-DCMAKE_INSTALL_LIBDIR=lib" ] ++ lib.optional (!buildDocs) [ "-DBUILD_DOCS=OFF" ];

  buildInputs = lib.optional buildDocs doxygen;

  propagatedBuildInputs = [ glibmm ];

  meta = with lib; {
    description = "Gio wrapper for Qt applications";
    homepage = "https://github.com/linuxdeepin/gio-qt";
    license = licenses.lgpl3Plus;
    platforms = platforms.linux;
  };
}
