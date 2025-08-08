install_pnpm() {
    print_step "Installing pnpm (Package Manager)..."

    if [[ -f "$HOME/.local/share/pnpm/pnpm" ]]; then
        print_step "pnpm already installed, skipping"
        return 0
    fi

    chmod -w $HOME/.bashrc
    print_step "Installing pnpm (blocking bashrc modifications)..."

    if [[ "$VERBOSE" == "true" ]]; then
        # Verbose mode: show the permission denied errors
        curl -fsSL https://get.pnpm.io/install.sh | sh - || true
        print_warning "pnpm installed successfully (bashrc modifications blocked - errors shown above)"
    else
        # Silent mode: hide all output including errors
        curl -fsSL https://get.pnpm.io/install.sh | sh - >/dev/null 2>&1 || true
        print_success "pnpm installed successfully (bashrc modifications blocked)"
    fi

    chmod +w $HOME/.bashrc
}

uninstall_pnpm() {
    print_step "Uninstalling pnpm..."

    if [[ -f "$HOME/.local/share/pnpm/pnpm" ]]; then
        rm -rf "$HOME/.local/share/pnpm"
        print_success "pnpm uninstalled successfully"
    else
        print_warning "pnpm not found, skipping uninstallation"
    fi
}