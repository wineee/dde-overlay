{ stdenv
, lib
, fetchFromGitHub
, linkFarm
, getPatchFrom
, dtk
, dde-qt-dbus-factory
, cmake
, pkg-config
, qttools
, qtx11extras
, wrapQtAppsHook
, wrapGAppsHook
, gsettings-qt
, lightdm_qt
, linux-pam
, xorg
, kwayland
, glib
, gtest
, xkeyboard_config
, dbus
, dde-session-shell
, qtbase
, qt5integration
}:
let
  patchList = {
    ### INSTALL
    "CMakeLists.txt" = [ [ "/etc" "$out/etc" ] ];
    "cmake/DdeSessionShellConfig.cmake" = [ ];

    ### MISC
    "files/com.deepin.dde.shutdownFront.service" = [
      [ "/usr/bin/dbus-send" "${dbus}/bin/dbus-send" ]
      #/usr/share/applications/dde-lock.desktop
    ];
    "files/com.deepin.dde.lockFront.service" = [
      [ "/usr/bin/dbus-send" "${dbus}/bin/dbus-send" ]
      #/usr/share/applications/dde-lock.desktop
    ];
    "files/lightdm-deepin-greeter.conf" = [
      [ "/usr/share" "/run/current-system/sw/share" ]
      # /usr/share/icons/bloom
    ];
    "files/wayland/lightdm-deepin-greeter-wayland.desktop" = [
      # "/usr/bin/deepin-greeter"
    ];
    "files/lightdm-deepin-greeter.desktop" = [
      # "/usr/bin/deepin-greeter"
    ];
    "files/dde-lock.desktop" = [
      # "/usr/bin/dde-lock"
    ];

    ### CODE
    "scripts/lightdm-deepin-greeter" = [
      # TODO ["/usr/lib/deepin-daemon/greeter-display-daemon"]
      # "/usr/bin/lightdm-deepin-greeter"
    ];

    "src/widgets/shutdownwidget.cpp" = [
      [ "/usr/bin/deepin-system-monitor" "deepin-system-monitor" ]
    ];

    "src/lightdm-deepin-greeter/greeterworker.cpp" = [
      [ "/usr/include/shadow.h" "shadow.h" ]
      [ "/usr/sbin/lightdm" "lightdm" ]
      # /etc/deepin/no_suspend
    ];
    "src/session-widgets/userinfo.cpp" = [
      # TODO
      # ["/usr/share/backgrounds/default_background.jpg"]
    ];
    "src/widgets/fullscreenbackground.cpp" = [
      # TODO
      #"/usr/share/backgrounds/default_background.jpg"
    ];
    "src/session-widgets/lockcontent.cpp" = [
      # TODO
      # "/usr/share/backgrounds/deepin/desktop.jpg"
    ];
    "src/session-widgets/auth_module.h" = [
      # TODO
      # "/usr/lib/dde-control-center/reset-password-dialog"
    ];
    "files/wayland/kwin_wayland_helper-wayland" = [
      [ "/usr/bin/kwin_wayland" "kwin_wayland" ]
    ];
    "files/wayland/deepin-greeter-wayland" = [
      # export QML2_IMPORT_PATH=/usr/lib/x86_64-linux-gnu/qt5/qml
      # export XDG_DATA_DIRS=/usr/share
      [ "/usr/bin/kwin_wayland" "kwin_wayland" ]
      # "/etc/xdg"
      # "/etc/deepin/greeters.d/lightdm-deepin-greeter"
    ];
    "src/global_util/public_func.cpp" = [
      # TODO
      # /usr/share/dde-session-shell/translations
    ];
    "src/global_util/modules_loader.cpp" = [
      # TODO
      # /usr/lib/dde-session-shell/modules
    ];
    "src/global_util/xkbparser.h" = [
      [ "/usr/share/X11/xkb/rules/base.xml" "${xkeyboard_config}/share/X11/xkb/rules/base.xml" ]
    ];
    "src/global_util/constants.h" = [
      [ "/usr/share/icons" "/run/current-system/sw/share/icons" ]
      #"/usr/share/icons/default/index.theme"

      #"/usr/share/dde-session-shell/dde-session-shell.conf",

      #"/usr/share/dde-session-ui/dde-session-ui.conf"
      #"/usr/share/dde-session-ui/dde-shutdown.conf
    ];
    "files/wayland/lightdm-deepin-greeter-wayland" = [
      # "/usr/bin/lightdm-deepin-greeter"
      #? /usr/lib/deepin-daemon/greeter-display-daemon
      # TODO export QT_QPA_PLATFORM_PLUGIN_PATH...
    ];

    # scripts/lightdm-deepin-greeter /etc/lightdm/deepin/xsettingsd.conf
    "files/deepin-greeter" = [
      [ "/etc/deepin/greeters.d/" "$out/etc/deepin/greeters.d/" ]
    ];
    # files/wayland/kwin_wayland_helper-wayland /etc/xdg/kglobalshortcutsrc

    "src/app/lightdm-deepin-greeter.cpp" = [
      # /etc/lightdm/deepin/xsettingsd.conf
    ];
    "src/lightdm-deepin-greeter/deepin-greeter" = [
      # /etc/deepin/greeters.d/
    ];

    "src/libdde-auth/deepinauthframework.cpp" = [
      [ "common-auth" "lightdm" ]
    ];
  };
in
stdenv.mkDerivation rec {
  pname = "dde-session-shell";
  version = "5.5.65+";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = "43a280f62f4991130e929ad275ac71d5d4f4671b";
    sha256 = "sha256-d8a2dEj9Ec5Q5FCjbThUh8r2KWBUJz4+tDIAb8t/3zI=";
  };

  postPatch = getPatchFrom patchList + ''
    patchShebangs files/deepin-greeter
  '';

  nativeBuildInputs = [
    cmake
    pkg-config
    qttools
    wrapQtAppsHook
    wrapGAppsHook
  ];
  dontWrapGApps = true;

  buildInputs = [
    dtk
    dde-qt-dbus-factory
    gsettings-qt
    lightdm_qt
    qtx11extras
    linux-pam
    kwayland
    xorg.libXcursor
    xorg.libXtst
    xorg.libXrandr
    xorg.libXdmcp
    gtest
  ];

  qtWrapperArgs = [
    "--prefix QT_PLUGIN_PATH : ${qt5integration}/${qtbase.qtPluginPrefix}"
  ];

  preFixup = ''
    glib-compile-schemas ${glib.makeSchemaPath "$out" "${pname}-${version}"}
    qtWrapperArgs+=("''${gappsWrapperArgs[@]}")
  '';

  postFixup = ''
    for binary in $out/etc/deepin/greeters.d/*; do
      wrapQtApp $binary
    done
  '';

  passthru.xgreeters = linkFarm "deepin-greeter-xgreeters" [{
    path = "${dde-session-shell}/share/xgreeters/lightdm-deepin-greeter.desktop";
    name = "lightdm-deepin-greeter.desktop";
  }];

  meta = with lib; {
    description = "Deepin desktop-environment - session-shell module";
    homepage = "https://github.com/linuxdeepin/dde-session-shell";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
  };
}
