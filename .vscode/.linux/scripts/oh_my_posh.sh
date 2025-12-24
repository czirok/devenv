install_oh_my_posh() {
    print_step "Installing Oh My Posh..."
    
    if [[ -z "$PROJECT_ENV" ]]; then
        print_error "PROJECT_ENV not set in dev.env"
        return 1
    fi
    
    # Use PROJECT_ROOT since environment variable is not yet loaded
    local install_dir="$PROJECT_ROOT/.vscode/.linux"
    
    # Copy template and customize
    local template_file="$SCRIPT_DIR/templates/oh-my-posh.template.json"
    local config_file="$SCRIPT_DIR/oh-my-posh.json"
    
    if [[ -f "$template_file" ]]; then
        print_step "Creating Oh My Posh configuration..."
        cp "$template_file" "$config_file"
        replace_project_vars "$config_file"
        print_success "Configuration created and updated with ${PROJECT_ENV}"
    else
        print_error "Oh My Posh template not found: $template_file"
        return 1
    fi
    
    print_step "Installing to: $install_dir"
    if [[ "$VERBOSE" == "true" ]]; then
        curl -s https://ohmyposh.dev/install.sh | bash -s -- -d "$install_dir"
    else
        curl -s https://ohmyposh.dev/install.sh | bash -s -- -d "$install_dir" >/dev/null 2>&1
    fi
    
    if [[ -f "$install_dir/oh-my-posh" ]]; then
        print_success "Oh My Posh installed to $install_dir"
    else
        print_error "Failed to install Oh My Posh"
        return 1
    fi
}

uninstall_oh_my_posh() {
    print_step "Uninstalling Oh My Posh..."
    
    local install_dir="$PROJECT_ROOT/.vscode/.linux"
    
    if [[ -f "$install_dir/oh-my-posh" ]]; then
        trash-put "$install_dir/oh-my-posh"
        print_success "Oh My Posh uninstalled successfully"
    else
        print_warning "Oh My Posh not found in $install_dir"
    fi
    
    local config_file="$SCRIPT_DIR/oh-my-posh.json"
    if [[ -f "$config_file" ]]; then
        trash-put "$config_file"
        print_success "Oh My Posh configuration removed successfully"
    else
        print_warning "Oh My Posh configuration file not found: $config_file"
    fi
}