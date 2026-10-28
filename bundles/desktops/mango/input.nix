{
  home-manager.wayland.windowManager.mango.settings = {
    # Keyboard
    xkb_rules_layout = "gb";
    xkb_rules_options = "ctrl:nocaps";

    # Mouse
    mouse_accel_profile = 1; # flat
    mouse_accel_speed = 0.6;

    # Trackpad
    trackpad_accel_profile = 2;
    trackpad_accel_speed = 0.1;
    trackpad_natural_scrolling = 1;
    trackpad_disable_while_typing = 1;
    trackpad_click_method = 2;
    trackpad_scroll_factor = 1.1;
    tap_and_drag = 1;

    # Cursor
    cursor_hide_on_keypress = 1; # hide-when-typing
    disable_middle_paste = 1;
  };
}
