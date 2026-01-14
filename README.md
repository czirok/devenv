# C#/TypeScript/SCSS Development Environment

## Overview

An opinionated dev environment for C#, TypeScript, and SCSS on Linux (GNOME) with VS Code integration. Each project gets its own isolated shell, consistent color theme, terminal profile, icon, and fonts.

- Per-project isolation and reproducible setup
- Unified colors across VS Code, Oh My Posh, and Ptyxis
- One-command install and clean uninstall
- Ready for Blazor, MAUI, and general C#/TS/SCSS projects

![Screenshot](/assets/devenv.png)

## Supported Components

- [`fnm`](https://github.com/Schniz/fnm) Fast Node Manager
- [`pnpm`](https://github.com/pnpm/pnpm) Fast, disk space efficient package manager
- [`.NET`](https://dotnet.microsoft.com/) 8, 9, 10 SDK, Runtime, and ASP.NET Core
- `Ptyxis` terminal
- `Oh My Posh` prompt
- `Bash` configuration
- Unified color schemes for `VS Code`, `Ptyxis`, and `Oh My Posh`
- `19` predefined dark themes: list, switch, and auto-update config when changing themes

## Linter mania

- `ESLint` + `@antfu/eslint-config`
  - `xml`
  - `json`
  - `yaml`
  - `typescript`
  - Microsoft Build Platform (MSBuild) files
    - `slnx`
    - `props`
    - `targets`
    - `csproj`
    - `csproj.user`
    - `pubxml`
    - `nuspec`
    - `pkgproj`
  - XAML files
    - `xaml`
- `Stylelint` for SCSS with `stylelint-config-twbs-bootstrap`
- `Markdownlint` for Markdown

## System Requirements

- Linux
- GNOME
- Git

## Installation

> [!NOTE]
> GNOME 46 or later is required

### Dependencies

#### Arch Linux (latest)

```bash
sudo pacman -Syu

# Ptyxis
sudo pacman -S bash git bc curl bzip2 trash-cli ptyxis
# GNOME Terminal
sudo pacman -S bash git bc curl bzip2 trash-cli gnome-terminal

git clone https://aur.archlinux.org/yay.git && cd yay && makepkg -si --noconfirm

yay -S visual-studio-code-bin

```

#### Ubuntu Noble (24.04) Ubuntu Plucky Puffin (25.10) and Debian Trixie (13)

```bash
sudo apt update && sudo apt upgrade -y

# Ptyxis
sudo apt install bash git bc curl bzip2 trash-cli ptyxis
# GNOME Terminal
sudo apt install bash git bc curl bzip2 trash-cli gnome-terminal

curl -fsSL https://packages.microsoft.com/keys/microsoft.asc | sudo gpg --dearmor -o /usr/share/keyrings/microsoft-archive-keyring.gpg

echo "deb [signed-by=/usr/share/keyrings/microsoft-archive-keyring.gpg] https://packages.microsoft.com/repos/code stable main" | sudo tee /etc/apt/sources.list.d/vscode.list

sudo apt update && sudo apt install code
```

#### Fedora Adams (42)

```bash
sudo dnf update -y

# Ptyxis
sudo dnf install bash git bc curl bzip2 trash-cli ptyxis
# GNOME Terminal
sudo dnf install bash git bc curl bzip2 trash-cli gnome-terminal

sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc

echo "[code]
name=Visual Studio Code
baseurl=https://packages.microsoft.com/yumrepos/vscode
enabled=1
gpgcheck=1
gpgkey=https://packages.microsoft.com/keys/microsoft.asc" | sudo tee /etc/yum.repos.d/vscode.repo

sudo dnf install code
```

#### OpenSUSE Tumbleweed (latest)

```bash
sudo zypper update -y

# Ptyxis
sudo zypper install bash git bc curl bzip2 trash-cli ptyxis
# GNOME Terminal
sudo zypper install bash git bc curl bzip2 trash-cli gnome-terminal

sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc

sudo zypper addrepo https://packages.microsoft.com/yumrepos/vscode vscode

sudo zypper install code
```

### Download

Download the latest release and extract it:

```bash
mkdir ~/myawesomeproject

# and/or

cd ~/myawesomeproject

wget https://github.com/czirok/devenv/releases/download/v2026.01.15/devenv.tar.bz2

# Safe extraction - won't overwrite existing files
tar xjfv devenv.tar.bz2 --skip-old-files
```

### Show help

> [!IMPORTANT]
> The install script `.vscode/.linux/install.sh` must be run from the root of the git repository or project root. This ensures correct environment variables and paths are set.  
> The environment is self-managing: running any command will regenerate related files from templates, overwriting manual changes.

```bash
.vscode/.linux/install.sh --help
```

Add `-v` or `--verbose` for detailed output for each command.

### Recommended Installation Steps

First, check dependencies and then install any missing components with your package manager:

```bash
.vscode/.linux/install.sh --dependency
```

### Project Customization

Edit the `.vscode/.linux/install.env` file to suit your project:

```bash
PROJECT_TITLE="Dev Env"                <- "My Awesome Project"
PROJECT_ID="devenv"                    <- "myawesomeproject"
PROJECT_ENV="DEVENV"                   <- "MYPROJECTENV"
THEME="Steel Blue"                     <- "Storm Cloud"
EDITOR_FONT="FiraCode Nerd Font Mono"  <- "My editor font"
FONTED_FONT="Adwaita Sans"             <- "My UI font"
PROJECT_TERMINAL="gnome-terminal"      <- "ptyxis" or "gnome-terminal"
GNOME_TERMINAL_ID="105c376f-f0e3-43d4-a021-b19e9d94b1d4"
```

#### Configuration Explanation

- `PROJECT_TITLE`: Project name, displayed in Oh My Posh prompt and the desktop app. E.g.: `"My Awesome Project"`
- `PROJECT_ID`: Unique project identifier. Used in desktop file, icon, and Ptyxis profile. E.g.: `"myawesomeproject"`
- `PROJECT_ENV`: Environment variable that stores the project path. E.g.: `"MYPROJECTENV"` -> `export MYPROJECTENV="/home/user/projects/myawesomeproject"`
- `THEME`: Developer environment color scheme. E.g.: `"Storm Cloud"`
- `EDITOR_FONT`: Font used in the editor. E.g.: `"FiraCode Nerd Font Mono"`
- `FONTED_FONT`: Font used in the UI. E.g.: `"Adwaita Sans"`
- `PROJECT_TERMINAL`: Terminal emulator used for the project. E.g.: `"ptyxis"` or `"gnome-terminal"`.

If you choose `gnome-terminal`, set the `GNOME_TERMINAL_ID` variable as well. **Every project must have a unique GUID!**

- `GNOME_TERMINAL_ID`: Unique identifier for the GNOME terminal profile. E.g.: `"977d30fd-43fd-4f0a-a80e-be80e64f4f7d"`.

GUIDs find in the [install.env](.vscode/.linux/install.env) file or generate a new one with:

```bash
uuidgen
```

### Fonts

If you already have a font installed that you want to use, set it in the `.vscode/.linux/install.env` file. To list font names, use the following command:

```bash
.vscode/.linux/install.sh --list-fonts
```

If the font is not installed, copy it to the `.vscode/.linux/fonts` folder. To list the names in that folder, run:

```bash
.vscode/.linux/install.sh --list-fonts .vscode/.linux/fonts/
```

Edit the `.vscode/.linux/install.env` file and set the font names:

```bash
EDITOR_FONT="My editor font"
FONTED_FONT="My UI font"
```

Install the fonts:

```bash
.vscode/.linux/install.sh --font
```

> [!CAUTION]
> `--uninstall-font` removes only fonts installed by this environment from your user fonts directory `~/.local/share/fonts`. Fonts that existed before the first install are preserved.

Uninstall the fonts:

```bash
.vscode/.linux/install.sh --uninstall-font
```

### Desktop Icon Customization

Edit the `.vscode/.linux/install.svg` file to match your project. For example:

```bash
inkscape .vscode/.linux/install.svg
```

![.desktop](/assets/desktop.png)

After editing, you can replace specific colors in `install.svg` with environment variables so that the icon harmonizes with your project if you want. For example, replace the `#07072c` color code with the `COLOR_ACCENT` environment variable. When you change themes, the icon will update automatically. Available variables:

- `COLOR_ACCENT`
- `COLOR_ACCENT_LIGHTER`
- `COLOR_HIGHLIGHT`
- `COLOR_TEXT`

## Terminal Setup

```bash
.vscode/.linux/install.sh --terminal
```

![Terminal](/assets/ptyxis.png)

> [!CAUTION]
> You need to log out and back in for the environment variables to take effect!

After installing the terminal, log out and back in, then open a new Ptyxis "My Awesome Project" terminal and continue installing the remaining components there.

> [!IMPORTANT]
> First time you open the terminal, it will prompt you to install the required Node.js version if it's not already installed. Say `y` to install it:

```text
Can't find an installed Node version matching v24.12.0.
Do you want to install it? answer [y/N]: y
```

### Full Environment Installation

```bash
.vscode/.linux/install.sh --all
```

## Theme Management

List available themes:

```bash
.vscode/.linux/install.sh --list-themes
```

![Themes](/assets/themes.png)

Switch theme:

```bash
.vscode/.linux/install.sh --change-theme "Deep Teal"
```

## VS Code

Install VS Code settings:

```bash
.vscode/.linux/install.sh --vscode
```

If you haven't already, log out and back in, then install project dependencies in the project terminal:

```bash
pnpm install
```

After that, you can launch VS Code (without the leading dot), and install the suggested extensions:

```bash
code
```

> [!NOTE]
> After installing the extensions, you can change the VS Code UI font settings. Read the [Fonted](https://github.com/blackmann/fonted) documentation for more information.

### Fonted - Arch Linux

#### `visual-studio-code-bin` package

This steps need after fresh VS Code installation or upgrade.

Before start VS Code, set write permissions for the workbench files:

> [!NOTE]
> Other distributions the workbench files may be in different locations.

```bash
# Arch Linux
sudo chmod 666 /opt/visual-studio-code/resources/app/out/vs/code/electron-browser/workbench/workbench.*

# Ubuntu
sudo chmod 666 /usr/share/code/resources/app/out/vs/code/electron-browser/workbench/workbench.*
```

Start the VS Code, press F1 and find the `Fonted` and enable it.

![Fonted](/assets/fonted/enable.png)

After enabled, don't click the restart, close it completely and restore the original permissions:

```bash
# Arch Linux
sudo chmod 644 /opt/visual-studio-code/resources/app/out/vs/code/electron-browser/workbench/workbench.*

# Ubuntu
sudo chmod 644 /usr/share/code/resources/app/out/vs/code/electron-browser/workbench/workbench.*
```

Start VS Code again, `code`+`enter` and disable the `Don't show again`.

![Fonted](/assets/fonted/dont-show-again.png)

## Install Individual Components

Node.js tools only:

```bash
.vscode/.linux/install.sh --fnm --pnpm
```

.NET 8 Runtime and ASP.NET Core only (no SDK):

```bash
.vscode/.linux/install.sh --net8runtime --net8aspnet
```

## Uninstall

> [!NOTE]
> Uninstall commands remove only what was installed by this environment. Your data and configuration files are not touched.

### Commands

```bash
.vscode/.linux/install.sh --uninstall-all              # Uninstall all components
.vscode/.linux/install.sh --uninstall-fnm              # Uninstall fnm
.vscode/.linux/install.sh --uninstall-pnpm             # Uninstall pnpm
.vscode/.linux/install.sh --uninstall-icon             # Uninstall application icon
.vscode/.linux/install.sh --uninstall-desktop          # Uninstall desktop application file
.vscode/.linux/install.sh --uninstall-font             # Uninstall application font
.vscode/.linux/install.sh --uninstall-oh-my-posh       # Uninstall Oh My Posh
.vscode/.linux/install.sh --uninstall-bashrc           # Uninstall .bashrc configuration
.vscode/.linux/install.sh --uninstall-environment      # Uninstall environment variables
.vscode/.linux/install.sh --uninstall-terminal         # Uninstall terminal
.vscode/.linux/install.sh --uninstall-vscode           # Uninstall VS Code
.vscode/.linux/install.sh --uninstall-node-modules     # Uninstall all node_modules directories
.vscode/.linux/install.sh --uninstall-dotnet           # Uninstall .NET
```

## Customization

> [!CAUTION]  
> The environment is self-managing. Running any command will regenerate the related files from templates, overwriting manual changes.

To customize, edit the templates located in `.vscode/.linux/templates` and the `.vscode/.linux/.themes/Colors.txt` file.

You may freely modify these files, but **do not** change the names of the environment variables.

Variable names from `.vscode/.linux/.themes/Colors.txt`:

- `COLOR_ACCENT`
- `COLOR_ACCENT_LIGHTER`
- `COLOR_HIGHLIGHT`
- `COLOR_TEXT`
- `COLOR_NAME`

Variable names from `.vscode/.linux/install.env`:

- `PROJECT_TITLE`
- `PROJECT_ID`
- `PROJECT_ENV`
- `THEME`
- `EDITOR_FONT`
- `FONTED_FONT`
- `PROJECT_TERMINAL`
- `GNOME_TERMINAL_ID`

After making changes, apply and test them with one or more of the following commands:

```bash
.vscode/.linux/install.sh --icon
.vscode/.linux/install.sh --desktop
.vscode/.linux/install.sh --oh-my-posh
.vscode/.linux/install.sh --terminal
.vscode/.linux/install.sh --bashrc
.vscode/.linux/install.sh --vscode
```

## PNPM

The project includes a `packages/css` and a `packages/js` directory with sample setups for compiling SCSS and TypeScript.

## Changelog

See the [.github/releases](.github/releases) folder for the changelog.

## License

[![MIT](/assets/shields.io/MIT.svg)](/LICENSE)
