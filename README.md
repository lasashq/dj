# dj

Набор утилит для обработки видео поверх ffmpeg.

```
dj extract    извлечь звуковую дорожку (например, для Adobe Podcast)
dj replace    заменить звуковую дорожку в видео
dj compress   пережать видео с более эффективными настройками
dj denoise    убрать шум из речи прямо в видео (DPDFNet, локально)
```

Команду можно сократить до однозначного начала: `dj c` = `dj compress`, `dj d` = `dj denoise`.
Справка по команде: `dj <команда> --help`.

## Установка

### Nix

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

Все зависимости, включая модели DPDFNet, подключаются сборкой. В `PATH` их держать не нужно,
и в рантайме ничего не скачивается.

### Из клона

```sh
git clone https://github.com/s1cklove/dj ~/code/dj
ln -s ~/code/dj/dj ~/.local/bin/dj
sudo apt install ffmpeg gawk          # или аналог для твоего дистрибутива
```

Для `dj denoise` дополнительно нужен Python-пакет dpdfnet в `.venv` рядом с dj:

```sh
python3 -m venv ~/code/dj/.venv
~/code/dj/.venv/bin/pip install 'dpdfnet==0.6.*'
```

Модель dpdfnet скачает сам при первом запуске (10–15 МБ, в `~/.cache/dpdfnet`).
Если чего-то не хватает, dj скажет, чего именно.
