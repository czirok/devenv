install_gnome_desktop_file() {
    print_step "Installing desktop application..."

    local desktop_source="$SCRIPT_DIR/templates/template.desktop"
    local desktop_target="$HOME/.local/share/applications/${PROJECT_ID}.desktop"
    
    # Create directory if it doesn't exist
    mkdir -p "$HOME/.local/share/applications"
    
    # Copy and customize desktop file
    if [[ -f "$desktop_source" ]]; then
        cp "$desktop_source" "$desktop_target"
        replace_project_vars "$desktop_target"
        print_success "Desktop file installed as ${PROJECT_ID}.desktop"
    else
        print_error "Desktop source file not found: $desktop_source"
        return 1
    fi
}

uninstall_gnome_desktop_file() {
    print_step "Uninstalling desktop application..."

    local desktop_target="$HOME/.local/share/applications/${PROJECT_ID}.desktop"

    # Remove the desktop file if it exists
    if [[ -f "$desktop_target" ]]; then
        trash-put "$desktop_target"
        print_success "Desktop file ${PROJECT_ID}.desktop removed successfully"
    else
        print_warning "Desktop file ${PROJECT_ID}.desktop not found"
    fi
}