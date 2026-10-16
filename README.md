# dj

A set of video processing helpers on top of ffmpeg.

```
dj extract    extract the audio track (e.g. for Adobe Podcast)
dj replace    replace the audio track in a video
dj compress   re-encode a video with more efficient settings
dj denoise    remove noise from speech right in the video (DPDFNet, runs locally)
```

A command can be shortened to any unambiguous prefix: `dj c` = `dj compress`, `dj d` = `dj denoise`.
Command help: `dj <command> --help`.

## Installation

### Nix

```sh
nix run github:s1cklove/dj -- --help
```

In NixOS / home-manager:

```nix
inputs.dj = {
  url = "github:s1cklove/dj";
  inputs.nixpkgs.follows = "nixpkgs";
};

home.packages = [ inputs.dj.packages.${pkgs.stdenv.hostPlatform.system}.default ];
```

All dependencies, including the DPDFNet models, come with the build. They don't need
to be on `PATH`, and nothing is downloaded at runtime.

### From a clone

```sh
git clone https://github.com/s1cklove/dj ~/code/dj
ln -s ~/code/dj/dj ~/.local/bin/dj
sudo apt install ffmpeg gawk          # or the equivalent for your distro
```

`dj denoise` additionally needs the dpdfnet Python package in a `.venv` next to dj:

```sh
python3 -m venv ~/code/dj/.venv
~/code/dj/.venv/bin/pip install 'dpdfnet==0.6.*'
```

dpdfnet downloads the model itself on first run (10–15 MB, into `~/.cache/dpdfnet`).
If something is missing, dj tells you exactly what.
