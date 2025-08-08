install_fnm() {
    print_step "Installing fnm (Fast Node Manager)..."

    if [[ -f "$HOME/.local/share/fnm/fnm" ]]; then
        print_step "fnm already installed, skipping"
        return 0
    fi

    if [[ "$VERBOSE" == "true" ]]; then
        curl -fsSL https://fnm.vercel.app/install | bash -s -- --skip-shell
    else
        curl -fsSL https://fnm.vercel.app/install | bash -s -- --skip-shell >/dev/null 2>&1
    fi
    
    local result=$?
    
    if [[ $result -eq 0 ]]; then
        print_success "fnm installed successfully"
    else
        print_error "Failed to install fnm"
        return 1
    fi
}

uninstall_fnm() {
    print_step "Uninstalling fnm..."

    if [[ -f "$HOME/.local/share/fnm/fnm" ]]; then
        rm -rf "$HOME/.local/share/fnm"
        print_success "fnm uninstalled successfully"
    else
        print_warning "fnm not found, skipping uninstallation"
    fi
}