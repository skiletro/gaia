{
  home-manager.wayland.windowManager.mango.settings = {
    # Dwindle everywhere.
    tag_rule = [
      "id:*,layout_name:dwindle"
    ];

    window_rule = [
      # Noctalia settings window
      "is_floating:1,width:1080,height:920,app_id:dev.noctalia.Noctalia"

      # Steam notification toasts, bottom-right
      "is_floating:1,offset_x:25,offset_y:25,title:^notificationtoasts_\\d+_desktop$,app_id:steam"

      # Portals
      "is_floating:1,app_id:org\\.freedesktop\\.impl\\.portal\\.desktop\\.gnome"
      "is_floating:1,app_id:xdg-desktop-portal-gtk"

      # File dialogs
      "is_floating:1,title:^(Open File)(.*)$"
      "is_floating:1,title:^(Select a File)(.*)$"
      "is_floating:1,title:^(Open Folder)(.*)$"
      "is_floating:1,title:^(Save As)(.*)$"
      "is_floating:1,title:^(Library)(.*)$"
      "is_floating:1,title:^(File Upload)(.*)$"
      "is_floating:1,title:^(.*)(wants to save)$"
      "is_floating:1,title:^(.*)(wants to open)$"

      # Apps
      "is_floating:1,app_id:crashreporter"
      "is_floating:1,app_id:org\\.gnome\\.FileRoller"
      "is_floating:1,app_id:org\\.gnome\\.NautilusPreviewer"
      "is_floating:1,app_id:Emulator"
    ];
  };
}
