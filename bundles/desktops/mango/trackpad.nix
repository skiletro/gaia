{
  home-manager = {lib, ...}: let
    # Windows-shaped pointer acceleration, not exact Windows filtering:
    # https://www.esreality.com/post/2971068/mimicking-windows-acceleration-curve-on-linux/
    # This configuration was developed with LLM assistance.
    #
    # Scope: exact Apple SPI and Ploopy touchpad identifiers on every Mango host.
    # Unset settings inherit globals; other devices, including the Ploopy's
    # separate mouse and keyboard interfaces, retain their global settings.
    #
    # Native support comes from patches/trackpad-custom-acceleration.patch.
    # Per-device accel_profile:4 requires all three custom properties:
    # - accel_custom_step: finite spacing in native X-axis units/ms, (0, 10000].
    # - accel_custom_points: 2-64 finite output velocities in pointer units/ms,
    #   each in [0, 10000], separated by "|"; these are not gain multipliers.
    # - accel_custom_fallback: finite constant translation/scroll gain, (0, 10000].
    # Custom properties require a real trackpad; an explicit type must be
    # trackpad, while name-only rules are checked against the matched device.
    # Ordinary profiles 0/1/2 retain their behavior. Global trackpad_accel_speed
    # does not tune custom curves.
    #
    # Current tuning: G = 4.8 logical units/mm at low speed, H = 25.4 mm/s per
    # registry-X unit, with 64 samples. Scale motionPoints to adjust pointer
    # sensitivity; leave input steps and fallbacks unchanged to preserve the
    # speed breakpoints and scrolling gain.
    #
    # Calibration uses live ABS_X/ABS_MT_POSITION_X resolution R and integer DPI D:
    # Apple SPI: R = 93 units/mm, D = 2362; measured area 119.4 x 80.7 mm.
    # Ploopy Pavonis: R = 100 units/mm, D = 2540; measured area 156 x 99 mm.
    # Ordinary and MT axes agree on both devices. Measure live positive axis
    # resolution before adding another device; do not copy another device's step.
    # FALLBACK is [0, gain] at step 1, with gain = 0.26712 * 1000 / D to preserve
    # libinput's existing constant translation gain. SCROLL is unset and inherits
    # FALLBACK, not the motion curve; an identity fallback would change scrolling.
    # https://wayland.freedesktop.org/libinput/doc/latest/pointer-acceleration.html
    #
    # The patched native .conf parser accepts physical lines up to 4095 bytes,
    # including a newline, and rejects oversized lines without parsing the tail.
    # Invalid custom rules discard the acceleration override; native application
    # failures log an error and restore the normal global profile and speed.
    # A new session with the patched binary is required to first use profile 4;
    # rules then apply on startup, hotplug, and reload without another restart.
    motionPoints = [
      "0"
      "0.00759050442603"
      "0.0151810088521"
      "0.0227715132781"
      "0.0303620177041"
      "0.0379525221302"
      "0.0455430265562"
      "0.0534901247138"
      "0.0649092934448"
      "0.0763284621759"
      "0.0877476309069"
      "0.0991667996379"
      "0.110585968369"
      "0.1220051371"
      "0.133424305831"
      "0.144843474562"
      "0.156262643293"
      "0.167681812024"
      "0.179100980755"
      "0.190520149486"
      "0.201939318217"
      "0.218823183588"
      "0.236167536706"
      "0.253511889824"
      "0.270856242943"
      "0.288200596061"
      "0.305544949179"
      "0.322889302298"
      "0.340233655416"
      "0.357578008534"
      "0.374922361653"
      "0.392266714771"
      "0.409611067889"
      "0.426955421008"
      "0.444299774126"
      "0.461644127244"
      "0.478988480363"
      "0.496332833481"
      "0.513677186599"
      "0.531021539717"
      "0.548365892836"
      "0.565710245954"
      "0.583054599072"
      "0.600398952191"
      "0.617743305309"
      "0.635087658427"
      "0.652432011546"
      "0.669776364664"
      "0.687120717782"
      "0.704465070901"
      "0.721809424019"
      "0.739153777137"
      "0.756498130256"
      "0.773842483374"
      "0.791186836492"
      "0.808531189611"
      "0.825875542729"
      "0.843219895847"
      "0.860564248966"
      "0.877908602084"
      "0.895252955202"
      "0.912597308321"
      "0.929941661439"
      "0.965785648091"
    ];
  in {
    wayland.windowManager.mango.settings.device_rule = [
      ("name:1452:641:Apple SPI Trackpad,accel_profile:4"
        + ",accel_custom_step:0.147066023254"
        + ",accel_custom_points:${lib.concatStringsSep "|" motionPoints}"
        + ",accel_custom_fallback:0.113090601185")
      ("name:65261:0:Ploopy Corporation Ploopy Pavonis Trackpad Touchpad,accel_profile:4"
        + ",accel_custom_step:0.158135508876"
        + ",accel_custom_points:${lib.concatStringsSep "|" motionPoints}"
        + ",accel_custom_fallback:0.105165354331")
    ];
  };
}
