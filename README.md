# dj

Набор утилит для обработки видео поверх ffmpeg.

```
dj extract-audio, ea    извлечь звуковую дорожку (для Adobe Podcast)
dj replace-audio, ra    заменить звуковую дорожку в видео
dj compress-video, cv   пережать видео с более эффективными настройками
```

Справка по команде: `dj <команда> --help`.

## Установка

```sh
nix run github:s1cklove/dj -- --help
```

В NixOS / home-manager:

```nix
inputs.dj = {
  url = "github:s1cklove/dj";
  inputs.nixpkgs.follows = "nixpkgs";
};

home.packages = [ inputs.dj.packages.${pkgs.stdenv.hostPlatform.system}.default ];
```

ffmpeg и остальные утилиты подключаются сборкой, в `PATH` их держать не нужно.
