install_gnome_terminal() {
    print_step "Configuring GNOME terminal..."

    # Check if GNOME terminal is installed
    if ! command -v gnome-terminal >/dev/null 2>&1; then
        print_warning "GNOME terminal not installed, skipping configuration"
        return 0
    fi

    # Setup profile configuration
    print_step "Creating GNOME terminal profile configuration..."
    local dconf_template="$SCRIPT_DIR/templates/gnome-terminal.template"
    local dconf_config="$SCRIPT_DIR/${GNOME_TERMINAL_ID}.dconf"

    if [[ -f "$dconf_template" ]]; then
        cp "$dconf_template" "$dconf_config"
        replace_hex_to_rgb "$dconf_config"
        replace_project_vars "$dconf_config"
        print_success "GNOME terminal profile configuration created"
    else
        print_error "GNOME terminal template not found: $dconf_template"
        return 1
    fi

    # Configure profile in dconf
    local key="/org/gnome/terminal/legacy/profiles:/list"
    local profile="$GNOME_TERMINAL_ID"

    print_step "Starting dconf configuration for key: $key"
    print_step "Managing profile: $profile"

    # Read the current profile list
    local list=$(dconf read "$key")
    print_step "Current profile list: $list"

    # Convert to bash array
    local array_string=$(echo "$list" | sed "s/\[//g" | sed "s/\]//g" | sed "s/'//g")
    IFS=',' read -ra profiles <<< "$array_string"

    # Remove profile if it exists
    local new_profiles=()
    for p in "${profiles[@]}"; do
        p=$(echo "$p" | xargs)  # trim whitespace
        if [[ "$p" != "$profile" ]]; then
            new_profiles+=("$p")
        fi
    done

    # Add profile to the end
    new_profiles+=("$profile")

    # Convert back to dconf format
    local newlist="["
    for i in "${!new_profiles[@]}"; do
        if [[ $i -gt 0 ]]; then
            newlist+=", "
        fi
        newlist+="'${new_profiles[$i]}'"
    done
    newlist+="]"

    print_step "New profile list after removing '$profile' and adding it to the end:"
    print_step "$newlist"

    # Write back to dconf
    dconf write "$key" "$newlist"
    print_step "New profile list written back to dconf key: $key"

    dconf load "/org/gnome/terminal/legacy/profiles:/:${GNOME_TERMINAL_ID}/" < "$dconf_config"
    trash-put "$dconf_config"  # Remove the original template

    print_success "GNOME terminal profile configured"
}

hex_to_rgb() {
    local hex="$1"
    # Remove # if present
    hex="${hex#\#}"
    
    # Extract hex values and convert to decimal
    local r=$((16#${hex:0:2}))
    local g=$((16#${hex:2:2}))
    local b=$((16#${hex:4:2}))
    
    echo "rgb($r,$g,$b)"
}

change_gnome_terminal_palette() {
    print_step "Changing GNOME terminal palette to: $COLOR_NAME_SPACELESS"

    # Check if GNOME terminal is installed
    if ! command -v gnome-terminal >/dev/null 2>&1; then
        print_warning "GNOME terminal not installed, skipping palette change"
        return 0
    fi

    # Update dconf configuration with new palette
    local backgroundColor="/org/gnome/terminal/legacy/profiles:/:${GNOME_TERMINAL_ID}/background-color"
    dconf write "$backgroundColor" "'$(hex_to_rgb ${COLOR_ACCENT})'"
    local foregroundColor="/org/gnome/terminal/legacy/profiles:/:${GNOME_TERMINAL_ID}/foreground-color"
    dconf write "$foregroundColor" "'$(hex_to_rgb ${COLOR_TEXT})'"
    local cursorBackgroundColor="/org/gnome/terminal/legacy/profiles:/:${GNOME_TERMINAL_ID}/cursor-background-color"
    dconf write "$cursorBackgroundColor" "'$(hex_to_rgb ${COLOR_TEXT})'"
    local cursorForegroundColor="/org/gnome/terminal/legacy/profiles:/:${GNOME_TERMINAL_ID}/cursor-foreground-color"
    dconf write "$cursorForegroundColor" "'$(hex_to_rgb ${COLOR_ACCENT})'"

    print_success "GNOME terminal palette changed to: $COLOR_NAME_SPACELESS"
}

uninstall_gnome_terminal() {
    print_step "Uninstalling GNOME terminal..."

    # Check if GNOME terminal is installed
    if ! command -v gnome-terminal >/dev/null 2>&1; then
        print_warning "GNOME terminal not installed, skipping uninstallation"
        return 0
    fi

    # Remove profile from profile list
    local key="/org/gnome/terminal/legacy/profiles:/list"
    local profile="$GNOME_TERMINAL_ID"

    print_step "Removing profile '$profile' from key: $key"

    # Read the current profile list
    local list=$(dconf read "$key")
    print_step "Current profile list: $list"

    # Convert to bash array
    local array_string=$(echo "$list" | sed "s/\[//g" | sed "s/\]//g" | sed "s/'//g")
    IFS=',' read -ra profiles <<< "$array_string"

    # Remove profile if it exists
    local new_profiles=()
    local found=false
    for p in "${profiles[@]}"; do
        p=$(echo "$p" | xargs)  # trim whitespace
        if [[ -n "$p" && "$p" != "$profile" ]]; then  # skip empty entries
            new_profiles+=("$p")
        elif [[ "$p" == "$profile" ]]; then
            found=true
        fi
    done

    if [[ "$found" == "true" ]]; then
        # Convert back to dconf format
        if [[ ${#new_profiles[@]} -eq 0 ]]; then
            newlist="[]"  # empty list
        else
            local newlist="["
            for i in "${!new_profiles[@]}"; do
                if [[ $i -gt 0 ]]; then
                    newlist+=", "
                fi
                newlist+="'${new_profiles[$i]}'"
            done
            newlist+="]"
        fi

        print_step "New profile list after removing '$profile':"
        print_step "$newlist"

        # Write back to dconf
        dconf write "$key" "$newlist"
        print_step "Profile list updated in dconf key: $key"
    else
        print_warning "Profile '$profile' not found in profile list"
    fi

    # Remove dconf configuration
    dconf reset -f "/org/gnome/terminal/legacy/profiles:/:${GNOME_TERMINAL_ID}/"
    print_success "GNOME terminal profile uninstalled successfully"
}
