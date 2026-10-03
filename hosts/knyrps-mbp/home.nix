{ ... }:

{
  # The T2 internal mic is a 3-element array exposed as AUX0/AUX1/AUX2 with no
  # channel positions, so clients grab AUX0+AUX1 as if they were L/R. Those are
  # two physically separated mics, and any mono downmix (Discord, Meet, ...)
  # sums the same voice at two arrival times -> comb filtering -> robotic voice.
  #
  # Expose a real mono source built from one element instead. Switch AUX0 to
  # AUX1/AUX2 below if another element of the array sounds better.
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
