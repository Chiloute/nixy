# Audio configuration for NixOS using PipeWire
{
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
    wireplumber.enable = true;
    # SOF UCM splits Speaker/Headphones into two profiles; the Headphones one has a higher
    # priority and wins as soon as HDMI/dock is plugged, removing the Speaker sink.
    wireplumber.extraConfig."51-laptop-speaker-profile" = {
      "device.profile.priority.rules" = [
        {
          matches = [{"device.name" = "alsa_card.pci-0000_00_1f.3-platform-skl_hda_dsp_generic";}];
          actions.update-props.priorities = [
            "HiFi (HDMI1, HDMI2, HDMI3, Mic1, Mic2, Speaker)"
          ];
        }
      ];
    };
  };
  security.rtkit.enable = true;
}
