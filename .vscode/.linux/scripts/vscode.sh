install_vscode() {
    print_step "Updating color schemes..."
    
    # Check if color variables are set
    if [[ -z "$COLOR_ACCENT" ]] || [[ -z "$COLOR_ACCENT_LIGHTER" ]] || [[ -z "$COLOR_HIGHLIGHT" ]] || [[ -z "$COLOR_TEXT" ]]; then
        print_error "Color variables not set in dev.env"
        return 1
    fi
    
    # Update VSCode settings
    local vscode_template="$SCRIPT_DIR/templates/settings.template.json"
    local vscode_settings="$PROJECT_ROOT/.vscode/settings.json"
    
    if [[ -f "$vscode_template" ]]; then
        print_step "Updating VSCode settings..."
        cp "$vscode_template" "$vscode_settings"
        replace_project_vars "$vscode_settings"
        print_success "VSCode settings updated with new colors"
    else
        print_warning "VSCode template not found: $vscode_template"
    fi
}

uninstall_vscode() {
    print_step "Uninstalling VSCode settings..."
    
    local vscode_settings="$PROJECT_ROOT/.vscode/settings.json"
    
    if [[ -f "$vscode_settings" ]]; then
        rm "$vscode_settings"
        print_success "VSCode settings uninstalled successfully"
    else
        print_warning "VSCode settings file not found: $vscode_settings"
    fi

    rm -rf "$PROJECT_ROOT/.vscode/.extensions"
    rm -rf "$PROJECT_ROOT/.vscode/.user.data"

    print_success "VSCode extensions and user data removed successfully"
}
