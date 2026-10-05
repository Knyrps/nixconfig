{ ... }:

{
  # mono source from one array mic
  xdg.configFile."pipewire/pipewire.conf.d/10-t2-mic-mono.conf".text = ''
    context.modules = [
      { name = libpipewire-module-loopback
        args = {
          node.description = "Internal Microphone (Mono)"
          capture.props = {
            node.name   = "capture.t2_mic_mono"
            node.target = "alsa_input.pci-0000_04_00.3.HiFi__Mic__source"
            audio.position = [ AUX0 ]
            stream.dont-remix = true
            node.passive = true
          }
          playback.props = {
            node.name   = "t2_mic_mono"
            media.class = "Audio/Source"
            audio.position = [ MONO ]
          }
        }
      }
    ]
  '';
}
