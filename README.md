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
- Linter configuration for `Markdown`, `TypeScript`, and `SCSS` development
- Unified color schemes for `VS Code`, `Ptyxis`, and `Oh My Posh`
- `19` predefined dark themes: list, switch, and auto-update config when changing themes

## System Requirements

- Linux
- GNOME
- Git

## Installation

> [!NOTE]
> GNOME 48 or later is required

### Dependencies

#### Arch Linux (latest)

```bash
sudo pacman -Syu

sudo pacman -S bash git bc curl ptyxis bzip2

git clone https://aur.archlinux.org/yay.git && cd yay && makepkg -si --noconfirm

yay -S visual-studio-code-bin

```

#### Ubuntu Plucky Puffin (25.04) and Debian Trixie (13)

```bash
sudo apt update && sudo apt upgrade -y

sudo apt install bash git bc curl ptyxis bzip2

curl -fsSL https://packages.microsoft.com/keys/microsoft.asc | sudo gpg --dearmor -o /usr/share/keyrings/microsoft-archive-keyring.gpg

echo "deb [signed-by=/usr/share/keyrings/microsoft-archive-keyring.gpg] https://packages.microsoft.com/repos/code stable main" | sudo tee /etc/apt/sources.list.d/vscode.list

sudo apt update && sudo apt install code
```

#### Fedora Adams (42)

```bash
sudo dnf update -y

sudo dnf install bash git bc curl ptyxis bzip2

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

sudo zypper install bash git bc curl ptyxis bzip2

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

wget https://github.com/czirok/devenv/releases/download/v2025.08.08/devenv.tar.bz2

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
```

#### Configuration Explanation

- `PROJECT_TITLE`: Project name, displayed in Oh My Posh prompt and the desktop app. E.g.: `"My Awesome Project"`
- `PROJECT_ID`: Unique project identifier. Used in desktop file, icon, and Ptyxis profile. E.g.: `"myawesomeproject"`
- `PROJECT_ENV`: Environment variable that stores the project path. E.g.: `"MYPROJECTENV"` -> `export MYPROJECTENV="/home/user/projects/myawesomeproject"`
- `THEME`: Developer environment color scheme. E.g.: `"Storm Cloud"`
- `EDITOR_FONT`: Font used in the editor. E.g.: `"FiraCode Nerd Font Mono"`
- `FONTED_FONT`: Font used in the UI. E.g.: `"Adwaita Sans"`

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

## Ptyxis Terminal Setup

```bash
.vscode/.linux/install.sh --terminal
```

![ptyxis](/assets/ptyxis.png)

> [!CAUTION]
> You need to log out and back in for the environment variables to take effect!

After installing the terminal, log out and back in, then open a new Ptyxis "My Awesome Project" terminal and continue installing the remaining components there.

> [!IMPORTANT]
> First time you open the terminal, it will prompt you to install the required Node.js version if it's not already installed. Say `y` to install it:

```bash
Can't find an installed Node version matching v24.3.0.
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

## Install Individual Components

Node.js tools only:

```bash
.vscode/.linux/install.sh --fnm --pnpm
```

.NET 9 SDK (includes Runtime and ASP.NET Core):

```bash
.vscode/.linux/install.sh --net9sdk
```

.NET 9 Runtime and ASP.NET Core only (no SDK):

```bash
.vscode/.linux/install.sh --net9runtime --net9aspnet
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
.vscode/.linux/install.sh --uninstall-ptyxis           # Uninstall Ptyxis terminal
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

After making changes, apply and test them with one or more of the following commands:

```bash
.vscode/.linux/install.sh --icon
.vscode/.linux/install.sh --desktop
.vscode/.linux/install.sh --oh-my-posh
.vscode/.linux/install.sh --terminal
.vscode/.linux/install.sh --bashrc
.vscode/.linux/install.sh --ptyxis
.vscode/.linux/install.sh --vscode
```

## PNPM

The project includes a `packages/css` and a `packages/js` directory with sample setups for compiling SCSS and TypeScript.

## License

This project is licensed under the [MIT License](/LICENSE).
