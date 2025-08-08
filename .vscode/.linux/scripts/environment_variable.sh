install_environment_variable() {
    print_step "Setting up ${PROJECT_ENV} environment variable..."

    BASH_PROFILE="$HOME/.bash_profile"
    EXPORT_LINE="export ${PROJECT_ENV}=\"$PROJECT_ROOT\""

    # Remove existing variable if it exists
    if grep -q "export ${PROJECT_ENV}=" "$BASH_PROFILE"; then
        sed -i "/export ${PROJECT_ENV}=/d" "$BASH_PROFILE"
        print_step "Removed existing ${PROJECT_ENV} variable from $HOME/.bash_profile"
    fi

    # Add new variable
    echo "$EXPORT_LINE" >> "$BASH_PROFILE"
    print_success "${PROJECT_ENV}=\"$PROJECT_ROOT\" variable added to $HOME/.bash_profile successfully"
}

uninstall_environment_variable() {
    print_step "Removing ${PROJECT_ENV} environment variable..."

    BASH_PROFILE="$HOME/.bash_profile"

    # Remove the variable if it exists
    if grep -q "export ${PROJECT_ENV}=" "$BASH_PROFILE"; then
        sed -i "/export ${PROJECT_ENV}=/d" "$BASH_PROFILE"
        print_success "${PROJECT_ENV} variable removed from $HOME/.bash_profile successfully"
    else
        print_warning "${PROJECT_ENV} variable not found in $HOME/.bash_profile"
    fi
}