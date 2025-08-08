update_gnome_cache() {
    print_step "Updating system caches..."
    
    # Update icon cache
    if command -v gtk-update-icon-cache >/dev/null 2>&1; then
        redirect_output gtk-update-icon-cache "$HOME/.local/share/icons" || true
        print_success "Icon cache updated"
    else
        print_warning "gtk-update-icon-cache not found. You may need to refresh icons manually"
    fi
    
    # Update desktop database
    if command -v update-desktop-database >/dev/null 2>&1; then
        redirect_output update-desktop-database "$HOME/.local/share/applications" || true
        print_success "Desktop database updated"
    fi
    
    # Update font cache
    if command -v fc-cache >/dev/null 2>&1; then
        print_step "Updating font cache..."
        redirect_output fc-cache -fv || true
        print_success "Font cache updated"
    else
        print_warning "fc-cache not found. Font changes may require logout/login"
    fi
}