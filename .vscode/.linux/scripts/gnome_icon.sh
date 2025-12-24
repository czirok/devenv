install_gnome_icon() {
    print_step "Installing application icon..."

    local icon_source="$SCRIPT_DIR/install.svg"
    local icon_target="$HOME/.local/share/icons/${PROJECT_ID}.svg"

    # Create directory if it doesn't exist
    mkdir -p "$HOME/.local/share/icons"
    
    if [[ -f "$icon_source" ]]; then
        cp "$icon_source" "$icon_target"
        replace_project_vars "$icon_target"
        print_success "Icon installed as ${PROJECT_ID}.svg"
    else
        print_error "Icon source file not found: $icon_source"
        exit 1
    fi
}

uninstall_gnome_icon() {
    print_step "Uninstalling application icon..."

    local icon_target="$HOME/.local/share/icons/${PROJECT_ID}.svg"

    # Remove the icon if it exists
    if [[ -f "$icon_target" ]]; then
        trash-put "$icon_target"
        print_success "Icon ${PROJECT_ID}.svg removed successfully"
    else
        print_warning "Icon ${PROJECT_ID}.svg not found"
    fi
}
