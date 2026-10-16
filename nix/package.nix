{ lib, writeShellApplication, writers, python3Packages, ffmpeg, coreutils, gawk, findutils, gnugrep }:

let
  dpdfnet = python3Packages.callPackage ./dpdfnet.nix { };

  # Streaming noise removal for dj denoise.
  dj-denoise = writers.writePython3Bin "dj-denoise" {
    libraries = [ dpdfnet ];
    # The file's own shebang ends up on the second line (E265).
    flakeIgnore = [ "E265" "E501" ];
  } (builtins.readFile ../dj-denoise.py);
in
# writeShellApplication pins the runtime tools on PATH and runs shellcheck at build time.
writeShellApplication {
  name = "dj";
  runtimeInputs = [ ffmpeg coreutils gawk findutils gnugrep dj-denoise ];
  # DPDFNet models live in the store, nothing is downloaded at runtime.
  runtimeEnv.DPDFNET_MODEL_DIR = "${dpdfnet.models}";
  text = builtins.readFile ../dj;

  passthru = { inherit dpdfnet dj-denoise; };

  meta = {
    description = "Video processing helpers on top of ffmpeg";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
    mainProgram = "dj";
  };
}
