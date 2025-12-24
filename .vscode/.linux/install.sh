#!/bin/bash
set -e

# Verbose mode
# If set to true, the script will show detailed output during installation
# If set to false, it will run silently
# Default is false
VERBOSE=${VERBOSE:-false}

# Get script directory and source config
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/install.env"

source "$SCRIPT_DIR/scripts/bashrc.sh"
source "$SCRIPT_DIR/scripts/colors.sh"
source "$SCRIPT_DIR/scripts/dotnet.sh"
source "$SCRIPT_DIR/scripts/environment_variable.sh"
source "$SCRIPT_DIR/scripts/fnm.sh"
source "$SCRIPT_DIR/scripts/gnome_desktop_file.sh"
source "$SCRIPT_DIR/scripts/gnome_icon.sh"
source "$SCRIPT_DIR/scripts/gnome_font.sh"
source "$SCRIPT_DIR/scripts/gnome_cache.sh"
source "$SCRIPT_DIR/scripts/oh_my_posh.sh"
source "$SCRIPT_DIR/scripts/pnpm.sh"
source "$SCRIPT_DIR/scripts/ptyxis.sh"
source "$SCRIPT_DIR/scripts/vscode.sh"
source "$SCRIPT_DIR/scripts/check_dependencies.sh"
source "$SCRIPT_DIR/scripts/uninstall_node_modules.sh"

show_usage() {
    echo "Usage: $0 [OPTIONS]"
    echo "Options:"
    echo "  --dependency            Check required dependencies (default behavior)"
    echo "  -v, --verbose           Show detailed output during installation"
    echo "  -h, --help              Show this help message"
    echo ""
    echo "Installation components:"
    echo "  --all                   Install all components"
    echo "  --fnm                   Install fnm (Fast Node Manager)"
    echo "  --pnpm                  Install pnpm (Package Manager)"
    echo "  --icon                  Install application icon and update cache"
    echo "  --desktop               Install desktop application file and update cache"
    echo "  --font                  Install application font"
    echo "  --list-fonts            List all installed fonts"
    echo "  --oh-my-posh            Install Oh My Posh with configuration"
    echo "  -t, --terminal          Install everything needed for Ptyxis terminal usage"
    echo "  --bashrc                Install .bashrc configuration"
    echo "  --environment           Install environment variables"
    echo "  --ptyxis                Install Ptyxis terminal"
    echo "  --vscode                Install VSCode settings with new colors"
    echo ""
    echo ".NET components:"
    echo "  -8s,  --net8sdk         Install .NET 8 SDK"
    echo "  -9s,  --net9sdk         Install .NET 9 SDK"
    echo "  -10s, --net10sdk        Install .NET 10 SDK"
    echo "  -8r,  --net8runtime     Install .NET 8 Runtime"
    echo "  -9r,  --net9runtime     Install .NET 9 Runtime"
    echo "  -10r, --net10runtime    Install .NET 10 Runtime"
    echo "  -8a,  --net8aspnet      Install .NET 8 ASP.NET Core"
    echo "  -9a,  --net9aspnet      Install .NET 9 ASP.NET Core"
    echo "  -10a, --net10aspnet     Install .NET 10 ASP.NET Core"
    echo "  --maui                  Install .NET MAUI workload"
    echo ""
    echo "Uninstall options:"
    echo "  --uninstall-all              Uninstall all components"
    echo "  --uninstall-fnm              Uninstall fnm"
    echo "  --uninstall-pnpm             Uninstall pnpm"
    echo "  --uninstall-icon             Uninstall application icon"
    echo "  --uninstall-desktop          Uninstall desktop application file"
    echo "  --uninstall-font             Uninstall application font"
    echo "  --uninstall-oh-my-posh       Uninstall Oh My Posh"
    echo "  --uninstall-bashrc           Uninstall .bashrc configuration"
    echo "  --uninstall-environment      Uninstall environment variables"
    echo "  --uninstall-ptyxis           Uninstall Ptyxis terminal"
    echo "  --uninstall-vscode           Uninstall VS Code"
    echo "  --uninstall-node-modules     Uninstall all node_modules directories"
    echo "  --uninstall-dotnet           Uninstall .NET"
    echo ""
    echo "Theme management:"
    echo "  -it, --install-themes        Generate all color palettes from themes"
    echo "  -lt, --list-themes           List available themes"
    echo "  -ct, --change-theme \"NAME\"   Change to specified theme and update configs"
    echo ""
    echo "Examples:"
    echo "  $0                             # Check dependencies and show this help"
    echo "  $0 --all                       # Install everything"
    echo "  $0 --fnm                       # Install only fnm"
    echo "  $0 -8s --verbose               # Install .NET 8 SDK with verbose output"
    echo "  $0 --change-theme \"Deep Teal\"  # Change theme to Deep Teal"
}

parse_arguments() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            -v|--verbose)
                VERBOSE=true
                shift
                ;;
            -d|--dependency)
                check_dependencies
                local deps_result=$?
                exit $deps_result
                ;;
            -h|--help)
                show_usage
                exit 0
                ;;
            --all)
                INSTALL_VSCODE=true
                INSTALL_NET10SDK=true
                INSTALL_NET8RUNTIME=false
                INSTALL_NET9RUNTIME=true
                INSTALL_NET8ASPNET=false
                INSTALL_NET9ASPNET=true
                shift
                ;;
            --fnm)
                INSTALL_FNM=true
                shift
                ;;
            --pnpm)
                INSTALL_PNPM=true
                shift
                ;;
            --bashrc)
                INSTALL_BASHRC=true
                shift
                ;;
            -e|--environment)
                INSTALL_ENVIRONMENT=true
                shift
                ;;
            --icon)
                INSTALL_GNOME_ICON=true
                shift
                ;;
            --desktop)
                INSTALL_GNOME_DESKTOP=true
                shift
                ;;
            --font)
                INSTALL_GNOME_FONT=true
                shift
                ;;
            --list-fonts)
                LIST_FONTS=true
                if [[ -n "$2" && "$2" != --* ]]; then
                    FONTS_DIR="$2"
                    shift 2
                else
                    shift
                fi
                ;;
            --oh-my-posh)
                INSTALL_OH_MY_POSH=true
                shift
                ;;
            --ptyxis)
                INSTALL_PTYXIS=true
                shift
                ;;
            --vscode)
                INSTALL_VSCODE=true
                shift
                ;;
            --all-dotnet)
                INSTALL_NET10SDK=true
                INSTALL_NET8RUNTIME=true
                INSTALL_NET9RUNTIME=true
                INSTALL_NET8ASPNET=true
                INSTALL_NET9ASPNET=true
                shift
                ;;
            -8s|--net8sdk)
                INSTALL_NET8SDK=true
                shift
                ;;
            -9s|--net9sdk)
                INSTALL_NET9SDK=true
                shift
                ;;
            -10s|--net10sdk)
                INSTALL_NET10SDK=true
                shift
                ;;
            -8r|--net8runtime)
                INSTALL_NET8RUNTIME=true
                shift
                ;;
            -9r|--net9runtime)
                INSTALL_NET9RUNTIME=true
                shift
                ;;
            -10r|--net10runtime)
                INSTALL_NET10RUNTIME=true
                shift
                ;;
            -8a|--net8aspnet)
                INSTALL_NET8ASPNET=true
                shift
                ;;
            -9a|--net9aspnet)
                INSTALL_NET9ASPNET=true
                shift
                ;;
            -10a|--net10aspnet)
                INSTALL_NET10ASPNET=true
                shift
                ;;
            --maui)
                INSTALL_MAUI=true
                shift
                ;;
            -it|--install-themes)
                INSTALL_THEMES=true
                shift
                ;;
            -lt|--list-themes)
                LIST_THEMES=true
                shift
                ;;
            -ct|--change-theme)
                if [[ -n "$2" ]]; then
                    CHANGE_THEME="$2"
                    shift 2
                else
                    print_error "Theme name required for --change-theme"
                    exit 1
                fi
                ;;
            -t|--terminal)
                INSTALL_TERMINAL=true
                shift
                ;;
            --uninstall-all)
                UNINSTALL_FNM=true
                UNINSTALL_PNPM=true
                UNINSTALL_GNOME_ICON=true
                UNINSTALL_GNOME_DESKTOP=true
                UNINSTALL_GNOME_FONT=true
                UNINSTALL_OH_MY_POSH=true
                UNINSTALL_BASHRC=true
                UNINSTALL_ENVIRONMENT=true
                UNINSTALL_PTYXIS=true
                UNINSTALL_VSCODE=true
                UNINSTALL_NODE_MODULES=true
                UNINSTALL_DOTNET=true
                shift
                ;;
            --uninstall-fnm)
                UNINSTALL_FNM=true
                shift
                ;;
            --uninstall-pnpm)
                UNINSTALL_PNPM=true
                shift
                ;;
            --uninstall-icon)
                UNINSTALL_GNOME_ICON=true
                shift
                ;;
            --uninstall-desktop)
                UNINSTALL_GNOME_DESKTOP=true
                shift
                ;;
            --uninstall-font)
                UNINSTALL_GNOME_FONT=true
                shift
                ;;
            --uninstall-oh-my-posh)
                UNINSTALL_OH_MY_POSH=true
                shift
                ;;
            --uninstall-bashrc)
                UNINSTALL_BASHRC=true
                shift
                ;;
            --uninstall-environment)
                UNINSTALL_ENVIRONMENT=true
                shift
                ;;
            --uninstall-ptyxis)
                UNINSTALL_PTYXIS=true
                shift
                ;;
            --uninstall-vscode)
                UNINSTALL_VSCODE=true
                shift
                ;;
            --uninstall-node-modules)
                UNINSTALL_NODE_MODULES=true                
                shift
                ;;
            --uninstall-dotnet)
                UNINSTALL_DOTNET=true
                shift
                ;;
            *)
                print_error "Unknown option: $1"
                show_usage
                exit 1
                ;;
        esac
    done
}

redirect_output() {
    if [[ "$VERBOSE" == "true" ]]; then
        "$@"
    else
        "$@" >/dev/null 2>&1
    fi
}

replace_project_vars() {
    local file="$1"
    
    sed -i \
        -e "s/PROJECT_TITLE/${PROJECT_TITLE}/g" \
        -e "s/PROJECT_ID/${PROJECT_ID}/g" \
        -e "s/PROJECT_ENV/${PROJECT_ENV}/g" \
        -e "s/COLOR_ACCENT_LIGHTER/${COLOR_ACCENT_LIGHTER}/g" \
        -e "s/COLOR_ACCENT/${COLOR_ACCENT}/g" \
        -e "s/COLOR_HIGHLIGHT/${COLOR_HIGHLIGHT}/g" \
        -e "s/COLOR_TEXT/${COLOR_TEXT}/g" \
        -e "s/COLOR_NAME_SPACELESS/${COLOR_NAME_SPACELESS}/g" \
        -e "s/COLOR_NAME/${COLOR_NAME}/g" \
        -e "s/EDITOR_FONT/${EDITOR_FONT}/g" \
        -e "s/FONTED_FONT/${FONTED_FONT}/g" \
        "$file"
}

main() {
    # Default behavior: check dependencies and show help
    if [[ $# -eq 0 ]] || [[ "$1" == "-d" ]] || [[ "$1" == "--dependency" ]]; then
        check_dependencies
        local deps_result=$?
        exit $deps_result
    fi
    
    # Parse command line arguments
    parse_arguments "$@"
    
    # Calculate project root: script is in PROJECT_ROOT/.vscode/.linux/
    PROJECT_ROOT="$(dirname "$(dirname "$SCRIPT_DIR")")"

    load_theme_colors "$THEME" || exit 1

    if [[ "$VERBOSE" == "true" ]]; then
        print_success "Configuration:"
        echo -e "  PROJECT_TITLE: ${YELLOW}$PROJECT_TITLE${NC}"
        echo -e "  PROJECT_ID:    ${YELLOW}$PROJECT_ID${NC}"
        echo -e "  PROJECT_ROOT:  ${YELLOW}$PROJECT_ROOT${NC}"
        echo -e "  PROJECT_ENV:   ${YELLOW}$PROJECT_ENV${NC}"
        echo -e "  SCRIPT_DIR:    ${YELLOW}$SCRIPT_DIR${NC}"
        echo -e "  VERBOSE:       ${YELLOW}enabled${NC}"
    fi

    # Validate configuration
    if [[ -z "$PROJECT_ID" ]]; then
        print_error "PROJECT_ID not set in install.env"
        exit 1
    fi
    
    if [[ -z "$PROJECT_ENV" ]]; then
        print_error "PROJECT_ENV not set in install.env"
        exit 1
    fi

    # Handle --change-theme (change theme)
    if [[ -n "$CHANGE_THEME" ]]; then
        change_theme "$CHANGE_THEME"
        exit 0
    fi

    # Handle --install-themes
    if [[ "$INSTALL_THEMES" == "true" ]]; then
        install_ptyxis_themes
        exit 0
    fi

    # Handle --list-themes
    if [[ "$LIST_THEMES" == "true" ]]; then
        list_themes
        exit 0
    fi

    if [[ "$INSTALL_TERMINAL" == "true" ]]; then
        install_bashrc

        install_ptyxis_themes
        install_ptyxis

        install_gnome_icon
        install_gnome_desktop_file
        install_gnome_font

        update_gnome_cache

        install_oh_my_posh            
    fi

    if [[ "$INSTALL_PTYXIS" == "true" ]]; then
        install_ptyxis_themes
        install_ptyxis
    fi

    if [[ "$INSTALL_VSCODE" == "true" ]]; then
        install_environment_variable

        install_fnm
        install_pnpm

        install_bashrc

        install_ptyxis_themes
        install_ptyxis

        install_gnome_icon
        install_gnome_desktop_file
        install_gnome_font

        update_gnome_cache


        install_oh_my_posh

        install_vscode
    fi

    if [[ "$INSTALL_FNM" == "true" ]]; then
        install_fnm
    fi
    
    if [[ "$INSTALL_PNPM" == "true" ]]; then
        install_pnpm
    fi
    
    if [[ "$INSTALL_BASHRC" == "true" ]]; then
        install_bashrc
    fi
    
    if [[ "$INSTALL_ENVIRONMENT" == "true" ]]; then
        install_environment_variable
    fi
    
    if [[ "$INSTALL_GNOME_ICON" == "true" ]]; then
        install_gnome_icon
        update_gnome_cache
    fi
    
    if [[ "$INSTALL_GNOME_DESKTOP" == "true" ]]; then
        install_gnome_desktop_file
        update_gnome_cache
    fi

    if [[ "$INSTALL_GNOME_FONT" == "true" ]]; then
        install_gnome_font
        update_gnome_cache
    fi

    if [[ "$LIST_FONTS" == "true" ]]; then
        print_font_names "$FONTS_DIR"
        exit 0
    fi

    if [[ "$INSTALL_OH_MY_POSH" == "true" ]]; then
        # Load theme only for oh-my-posh
        install_oh_my_posh
    fi
    
    # .NET SDK installations
    if [[ "$INSTALL_NET8SDK" == "true" ]]; then
        install_net8sdk
    fi
    
    if [[ "$INSTALL_NET9SDK" == "true" ]]; then
        install_net9sdk
    fi
    
    if [[ "$INSTALL_NET10SDK" == "true" ]]; then
        install_net10sdk
    fi
    
    # .NET Runtime installations
    if [[ "$INSTALL_NET8RUNTIME" == "true" ]]; then
        install_net8runtime
    fi
    
    if [[ "$INSTALL_NET9RUNTIME" == "true" ]]; then
        install_net9runtime
    fi
    
    if [[ "$INSTALL_NET10RUNTIME" == "true" ]]; then
        install_net10runtime
    fi
    
    if [[ "$INSTALL_THEMES" == "true" ]]; then
        install_ptyxis_themes
    fi

    # .NET ASP.NET Core installations
    if [[ "$INSTALL_NET8ASPNET" == "true" ]]; then
        install_net8aspnet
    fi

    if [[ "$INSTALL_NET9ASPNET" == "true" ]]; then
        install_net9aspnet
    fi

    if [[ "$INSTALL_NET10ASPNET" == "true" ]]; then
        install_net10aspnet
    fi

    # Setup dotnet tools if any .NET component was installed
    if 
        [[ "$INSTALL_NET8SDK" == "true" ]] ||
        [[ "$INSTALL_NET9SDK" == "true" ]] ||
        [[ "$INSTALL_NET10SDK" == "true" ]] ||
        [[ "$INSTALL_NET8RUNTIME" == "true" ]] ||
        [[ "$INSTALL_NET9RUNTIME" == "true" ]] ||
        [[ "$INSTALL_NET10RUNTIME" == "true" ]] ||
        [[ "$INSTALL_NET8ASPNET" == "true" ]] ||
        [[ "$INSTALL_NET9ASPNET" == "true" ]] ||
        [[ "$INSTALL_NET10ASPNET" == "true" ]]; then
        setup_dotnet_tools
    fi

    if [[ "$INSTALL_MAUI" == "true" ]]; then
        install_maui
    fi

    # Uninstall components if requested
    if [[ "$UNINSTALL_FNM" == "true" ]]; then
        uninstall_fnm
    fi

    if [[ "$UNINSTALL_PNPM" == "true" ]]; then
        uninstall_pnpm
    fi

    if [[ "$UNINSTALL_GNOME_ICON" == "true" ]]; then
        uninstall_gnome_icon
        update_gnome_cache
    fi

    if [[ "$UNINSTALL_GNOME_DESKTOP" == "true" ]]; then
        uninstall_gnome_desktop_file
    fi

    if [[ "$UNINSTALL_GNOME_FONT" == "true" ]]; then
        uninstall_gnome_font
        update_gnome_cache
    fi

    if [[ "$UNINSTALL_OH_MY_POSH" == "true" ]]; then
        uninstall_oh_my_posh
    fi

    if [[ "$UNINSTALL_BASHRC" == "true" ]]; then
        uninstall_bashrc
    fi

    if [[ "$UNINSTALL_ENVIRONMENT" == "true" ]]; then
        uninstall_environment_variable
    fi

    if [[ "$UNINSTALL_PTYXIS" == "true" ]]; then
        uninstall_ptyxis
    fi

    if [[ "$UNINSTALL_VSCODE" == "true" ]]; then
        uninstall_vscode
    fi

    if [[ "$UNINSTALL_NODE_MODULES" == "true" ]]; then
        uninstall_node_modules
    fi

    if [[ "$UNINSTALL_DOTNET" == "true" ]]; then
        uninstall_dotnet
    fi

    if [[ "$UNINSTALL_ALL" == "true" ]]; then
        uninstall_fnm
        uninstall_pnpm

        uninstall_gnome_icon
        uninstall_gnome_desktop_file
        uninstall_gnome_font
        update_gnome_cache

        uninstall_oh_my_posh
        uninstall_bashrc
        uninstall_environment_variable
        uninstall_ptyxis
        uninstall_vscode
        uninstall_node_modules
        uninstall_dotnet
    fi

    print_success "Installation completed successfully!"
    if 
        [[ "$INSTALL_GNOME_DESKTOP" == "true" ]] ||
        [[ "$INSTALL_ALL" == "true" ]]; then
        print_step "Application '${PROJECT_ID}' is now available in your applications menu"
    fi

    if 
        [[ "$INSTALL_ENVIRONMENT" == "true" ]] || 
        [[ "$INSTALL_ALL" == "true" ]] || 
        [[ "$INSTALL_TERMINAL" == "true" ]] || 
        [[ "$INSTALL_VSCODE" == "true" ]] || 
        [[ "$INSTALL_PTYXIS" == "true" ]]; then
        print_warning "You may need to log out and back in for the ${PROJECT_ENV} environment variable to take effect, if you changed the git root directory."
    fi
}

# Run the script
main "$@"