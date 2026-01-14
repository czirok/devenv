check_dependencies() {
    print_step "Checking required dependencies..."

    local all_ok=true

    # Check trash-cli
    if command -v trash >/dev/null 2>&1; then
        local trash_version=$(trash --version | head -n1)
        print_success "Trash CLI found (version: $trash_version)"
    else
        print_error "Trash CLI not found - install Trash CLI"
        all_ok=false
    fi

    # Check bc
    if command -v bc >/dev/null 2>&1; then
        local bc_version=$(bc --version | head -n1)
        print_success "BC found (version: $bc_version)"
    else
        print_error "BC not found - install BC"
        all_ok=false
    fi

    # Check curl
    if command -v curl >/dev/null 2>&1; then
        local curl_version=$(curl --version | head -n1)
        print_success "Curl found (version: $curl_version)"
    else
        print_error "Curl not found - install Curl"
        all_ok=false
    fi

    # Check bash
    if command -v bash >/dev/null 2>&1; then
        local bash_version=$(bash --version | head -n1)
        print_success "Bash found (version: $bash_version)"
    else
        print_error "Bash not found - install Bash shell"
        all_ok=false
    fi

    # Check VSCode
    if command -v code >/dev/null 2>&1; then
        local code_version=$(code --version | head -n1)
        print_success "Visual Studio Code found (version: $code_version)"
    else
        print_error "Visual Studio Code not found - install Visual Studio Code"
        all_ok=false
    fi

    if [[ "$PROJECT_TERMINAL" == "ptyxis" ]]; then
        # Check Ptyxis
        if command -v ptyxis >/dev/null 2>&1; then
            local ptyxis_version=$(ptyxis --version | head -n1 2>/dev/null || echo "unknown")
            print_success "Ptyxis found (version: $ptyxis_version)"
        else
            print_error "Ptyxis not found - install Ptyxis terminal"
            all_ok=false
        fi
    elif [[ "$PROJECT_TERMINAL" == "gnome-terminal" ]]; then
        # Check GNOME Terminal
        if command -v gnome-terminal >/dev/null 2>&1; then
            local gnome_terminal_version=$(gnome-terminal --version | head -n1)
            print_success "GNOME Terminal found (version: $gnome_terminal_version)"
        else
            print_error "GNOME Terminal not found - install GNOME Terminal"
            all_ok=false
        fi
    fi

    if [[ "$all_ok" == "true" ]]; then
        print_success "All dependencies are installed!"
        return 0
    else
        print_error "Some dependencies are missing. Please install them before running the installer."
        return 1
    fi
}