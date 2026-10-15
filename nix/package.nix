{ lib, writeShellApplication, ffmpeg, coreutils, gawk, findutils, gnugrep }:

# writeShellApplication pins the runtime tools on PATH and runs shellcheck at build time.
writeShellApplication {
  name = "dj";
  runtimeInputs = [ ffmpeg coreutils gawk findutils gnugrep ];
  text = builtins.readFile ../dj;

  meta = {
    description = "Video processing helpers on top of ffmpeg";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
    mainProgram = "dj";
  };
}
