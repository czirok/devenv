install_bashrc() {
    print_step "Setting up .bashrc configuration..."

    local bashrc_template="$SCRIPT_DIR/templates/.bashrc.template"
    local bashrc_target="$SCRIPT_DIR/.bashrc"

    if [[ -f "$bashrc_template" ]]; then
        print_step "Creating .bashrc from template..."
        cp "$bashrc_template" "$bashrc_target"
        replace_project_vars "$bashrc_target"
        print_success ".bashrc created and updated with ${PROJECT_ENV}"
    else
        print_error ".bashrc template not found: $bashrc_template"
        return 1
    fi
}

uninstall_bashrc() {
    print_step "Uninstalling .bashrc configuration..."

    local bashrc_target="$SCRIPT_DIR/.bashrc"

    if [[ -f "$bashrc_target" ]]; then
        rm "$bashrc_target"
        print_success "$bashrc_target uninstalled successfully"
    else
        print_warning ".bashrc file not found: $bashrc_target"
    fi
}