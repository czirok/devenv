install_ptyxis() {
    print_step "Configuring Ptyxis terminal..."

    # Check if Ptyxis is installed
    if ! command -v ptyxis >/dev/null 2>&1; then
        print_warning "Ptyxis terminal not installed, skipping configuration"
        return 0
    fi

    # Setup profile configuration
    print_step "Creating Ptyxis profile configuration..."
    local dconf_template="$SCRIPT_DIR/templates/ptyxis.template"
    local dconf_config="$SCRIPT_DIR/${PROJECT_ID}.dconf"

    if [[ -f "$dconf_template" ]]; then
        cp "$dconf_template" "$dconf_config"
        replace_project_vars "$dconf_config"
        print_success "Ptyxis profile configuration created"
    else
        print_error "Ptyxis template not found: $dconf_template"
        return 1
    fi

    # Configure profile in dconf
    local key="/org/gnome/Ptyxis/profile-uuids"
    local profile="$PROJECT_ID"

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

    dconf load "/org/gnome/Ptyxis/Profiles/${PROJECT_ID}/" < "$dconf_config"
    rm -f "$dconf_config"  # Remove the original template

    print_success "Ptyxis profile configured"
}

change_ptyxis_palette() {
    print_step "Changing Ptyxis palette to: $COLOR_NAME_SPACELESS"

    # Check if Ptyxis is installed
    if ! command -v ptyxis >/dev/null 2>&1; then
        print_warning "Ptyxis terminal not installed, skipping palette change"
        return 0
    fi

    # Update dconf configuration with new palette
    local profile_key="/org/gnome/Ptyxis/Profiles/${PROJECT_ID}/palette"
    dconf write "$profile_key" "'$COLOR_NAME_SPACELESS'"

    print_success "Ptyxis palette changed to: $COLOR_NAME_SPACELESS"
}

install_ptyxis_themes() {
    print_step "Installing all color themes..."
    
    local colors_file="$SCRIPT_DIR/themes/Colors.txt"
    local template_file="$SCRIPT_DIR/themes/Template.palette"
    local palette_dir="$HOME/.local/share/org.gnome.Ptyxis/palettes"
    
    if [[ ! -f "$colors_file" ]]; then
        print_error "Colors.txt not found: $colors_file"
        return 1
    fi
    
    if [[ ! -f "$template_file" ]]; then
        print_error "Template.palette not found: $template_file"
        return 1
    fi
    
    # Create palette directory
    mkdir -p "$palette_dir"
    
    local theme_count=0
    
    # Process CSV file - skip header (first line)
    {
        read  # skip header line
        while IFS=';' read -r color_accent color_accent_lighter color_highlight color_text color_name; do
            # Skip empty lines
            [[ -z "$color_accent" ]] && continue
            
            # Generate palette file name (remove spaces)
            local palette_name=$(echo "$color_name" | sed 's/ //g')
            local palette_file="$palette_dir/${palette_name}.palette"
            
            # Copy template and substitute variables
            cp "$template_file" "$palette_file"
            
            # Use different delimiter for sed to avoid issues with # in hex colors
            sed -i \
                -e "s|COLOR_ACCENT|$color_accent|g" \
                -e "s|COLOR_ACCENT_LIGHTER|$color_accent_lighter|g" \
                -e "s|COLOR_HIGHLIGHT|$color_highlight|g" \
                -e "s|COLOR_TEXT|$color_text|g" \
                -e "s|COLOR_NAME|$color_name|g" \
                "$palette_file"
            
            theme_count=$((theme_count + 1))
            
            if [[ "$VERBOSE" == "true" ]]; then
                print_step "Generated palette: ${palette_name}.palette"
            fi
            
        done
    } < "$colors_file"
    
    print_success "Generated $theme_count theme palettes in $palette_dir"
}

uninstall_ptyxis() {
    print_step "Uninstalling Ptyxis terminal..."

    # Check if Ptyxis is installed
    if ! command -v ptyxis >/dev/null 2>&1; then
        print_warning "Ptyxis terminal not installed, skipping uninstallation"
        return 0
    fi

    # Remove profile from profile list
    local key="/org/gnome/Ptyxis/profile-uuids"
    local profile="$PROJECT_ID"

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
    dconf reset -f "/org/gnome/Ptyxis/Profiles/${PROJECT_ID}/"
    print_success "Ptyxis profile uninstalled successfully"
}