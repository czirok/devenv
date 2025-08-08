install_gnome_font() {
    local font_source="$SCRIPT_DIR/fonts"
    local font_target="$HOME/.local/share/fonts"
    local font_state="$SCRIPT_DIR/.font_state"

    if [[ "$VERBOSE" == "true" ]]; then
        print_success "Font source: $font_source"
        print_success "Font target: $font_target"
        print_success "Font state: $font_state"
    fi

    mkdir -p "$font_target"

    if [[ ! -d "$font_source" ]]; then
        print_error "Font source directory not found: $font_source"
        return 1
    fi

    # Clear state file
    > "$font_state"
    
    local fonts_to_install=()
    local fonts_existed=()
    
    if [[ "$VERBOSE" == "true" ]]; then
        print_success "Scanning source fonts..."
    fi
    
    for font_file in "$font_source"/*.ttf; do
        [[ -f "$font_file" ]] || continue
        
        local font_name=$(basename "$font_file")
        
        if [[ "$VERBOSE" == "true" ]]; then
            print_success "Processing: $font_name"
        fi
        
        if [[ -f "$font_target/$font_name" ]]; then
            cat >> "$font_state" <<< "$font_name"
            fonts_existed+=("$font_name")
            if [[ "$VERBOSE" == "true" ]]; then
                print_warning "Font already exists: $font_name"
            fi
        else
            fonts_to_install+=("$font_file")
            if [[ "$VERBOSE" == "true" ]]; then
                print_success "Font needs installation: $font_name"
            fi
        fi
    done
    
    if [[ "$VERBOSE" == "true" ]]; then
        print_success "Fonts to install: ${#fonts_to_install[@]}"
        print_success "Fonts already existed: ${#fonts_existed[@]}"
    fi
    
    # Install only new fonts
    if [[ ${#fonts_to_install[@]} -gt 0 ]]; then
        for font_file in "${fonts_to_install[@]}"; do
            local font_name=$(basename "$font_file")
            if [[ "$VERBOSE" == "true" ]]; then
                print_success "Installing: $font_name"
            fi
            cp "$font_file" "$font_target/"
        done
        
        print_success "${#fonts_to_install[@]} new fonts installed"
    fi
    
    if [[ ${#fonts_existed[@]} -gt 0 ]]; then
        print_warning "${#fonts_existed[@]} fonts were already installed"
    fi
}

# get_protected_font_files() {
#     local protected_files=()
    
#     # Check if EDITOR_FONT is set
#     if [[ -z "$EDITOR_FONT" ]]; then
#         if [[ "$VERBOSE" == "true" ]]; then
#             print_warning "EDITOR_FONT not set - no fonts to protect" >&2
#         fi
#         echo "${protected_files[@]}"
#         return 0
#     fi
    
#     if [[ "$VERBOSE" == "true" ]]; then
#         print_success "Scanning system for fonts matching: '$EDITOR_FONT'" >&2
#     fi
    
#     # Check if fc-query is available
#     if ! command -v fc-query >/dev/null 2>&1; then
#         if [[ "$VERBOSE" == "true" ]]; then
#             print_error "fc-query not available - cannot protect fonts" >&2
#         fi
#         echo "${protected_files[@]}"
#         return 1
#     fi
    
#     # Get all TTF font files from the system
#     local font_files=($(fc-list --format='%{file}\n' | grep -i '\.ttf$'))
    
#     if [[ "$VERBOSE" == "true" ]]; then
#         print_success "Found ${#font_files[@]} TTF files on system" >&2
#     fi
    
#     # Check each font file
#     for font_file in "${font_files[@]}"; do
#         if [[ ! -f "$font_file" ]]; then
#             continue
#         fi
        
#         # Get font family name
#         local font_family=$(fc-query --format='%{family}\n' "$font_file" 2>/dev/null | head -1)
        
#         if [[ "$font_family" == "$EDITOR_FONT" ]]; then
#             local font_filename=$(basename "$font_file")
#             protected_files+=("$font_filename")
            
#             if [[ "$VERBOSE" == "true" ]]; then
#                 print_success "✓ MATCH FOUND: $font_filename -> Font Name: $font_family" >&2
#             fi
#         fi
#     done
    
#     if [[ "$VERBOSE" == "true" ]]; then
#         print_success "Total protected font files: ${#protected_files[@]}" >&2
#     fi
    
#     # Return the array
#     echo "${protected_files[@]}"
# }

get_protected_font_files() {
    local protected_files=()
    local protected_font_names=()
    
    if [[ "$VERBOSE" == "true" ]]; then
        print_success "Collecting protected font names from multiple sources..." >&2
    fi
    
    # 1. Check GNOME system monospace font
    local gnome_monospace_font=$(dconf read /org/gnome/desktop/interface/monospace-font-name 2>/dev/null)
    if [[ -n "$gnome_monospace_font" && "$gnome_monospace_font" != "''" ]]; then
        local gnome_font_with_size=$(echo "$gnome_monospace_font" | sed "s/^'//;s/'$//")
        local gnome_font_name=$(echo "$gnome_font_with_size" | sed 's/ [0-9]*$//')
        protected_font_names+=("$gnome_font_name")
        if [[ "$VERBOSE" == "true" ]]; then
            print_success "GNOME system monospace font: '$gnome_font_name'" >&2
        fi
    fi
    
    # 2. Check Ptyxis custom font (if available and not using system font)
    if command -v ptyxis >/dev/null 2>&1; then
        local use_system_font=$(dconf read /org/gnome/Ptyxis/use-system-font 2>/dev/null)

        if [[ "$use_system_font" != "true" ]]; then
            local ptyxis_font_setting=$(dconf read /org/gnome/Ptyxis/font-name 2>/dev/null)

            if [[ -n "$ptyxis_font_setting" && "$ptyxis_font_setting" != "''" ]]; then
                local ptyxis_font_with_size=$(echo "$ptyxis_font_setting" | sed "s/^'//;s/'$//")
                local ptyxis_font_name=$(echo "$ptyxis_font_with_size" | sed 's/ [0-9]*$//')
                protected_font_names+=("$ptyxis_font_name")
                if [[ "$VERBOSE" == "true" ]]; then
                    print_success "Ptyxis custom font: '$ptyxis_font_name'" >&2
                fi
            fi
        fi
    fi
    
    # 3. Check EDITOR_FONT variable if set
    if [[ -n "$EDITOR_FONT" ]]; then
        protected_font_names+=("$EDITOR_FONT")
        if [[ "$VERBOSE" == "true" ]]; then
            print_success "Project EDITOR_FONT: '$EDITOR_FONT'" >&2
        fi
    fi
    
    # Remove duplicates from protected_font_names array
    if [[ ${#protected_font_names[@]} -gt 0 ]]; then
        local unique_protected_fonts=()
        for font in "${protected_font_names[@]}"; do
            local already_added=false
            for unique_font in "${unique_protected_fonts[@]}"; do
                if [[ "$font" == "$unique_font" ]]; then
                    already_added=true
                    break
                fi
            done
            if [[ "$already_added" == "false" ]]; then
                unique_protected_fonts+=("$font")
            fi
        done
        protected_font_names=("${unique_protected_fonts[@]}")
        
        if [[ "$VERBOSE" == "true" ]]; then
            print_success "Total unique protected font names: ${#protected_font_names[@]}" >&2
            for pf in "${protected_font_names[@]}"; do
                print_success "Protected font name: '$pf'" >&2
            done
        fi
    fi
    
    # If no protected fonts found, return empty
    if [[ ${#protected_font_names[@]} -eq 0 ]]; then
        if [[ "$VERBOSE" == "true" ]]; then
            print_warning "No protected fonts found" >&2
        fi
        echo "${protected_files[@]}"
        return 0
    fi
    
    if [[ "$VERBOSE" == "true" ]]; then
        print_success "Scanning system for matching font files..." >&2
    fi
    
    # Check if fc-query is available
    if ! command -v fc-query >/dev/null 2>&1; then
        if [[ "$VERBOSE" == "true" ]]; then
            print_error "fc-query not available - cannot protect fonts" >&2
        fi
        echo "${protected_files[@]}"
        return 1
    fi
    
    # Get all TTF font files from the system
    local font_files=($(fc-list --format='%{file}\n' | grep -i '\.ttf$'))
    
    if [[ "$VERBOSE" == "true" ]]; then
        print_success "Total protected font files: ${#protected_files[@]}" >&2
    fi
    
    # Return the array
    echo "${protected_files[@]}"

    if [[ "$VERBOSE" == "true" ]]; then
        print_success "Found ${#font_files[@]} TTF files on system" >&2
    fi
    
    # Check each font file against all protected font names
    for font_file in "${font_files[@]}"; do
        if [[ ! -f "$font_file" ]]; then
            continue
        fi
        
        # Get font family name
        local font_family=$(fc-query --format='%{family}\n' "$font_file" 2>/dev/null | head -1)
        
        # Check if this font matches any protected font name
        for protected_font_name in "${protected_font_names[@]}"; do
            if [[ "$font_family" == "$protected_font_name" ]]; then
                local font_filename=$(basename "$font_file")
                protected_files+=("$font_filename")
                
                if [[ "$VERBOSE" == "true" ]]; then
                    print_success "✓ MATCH FOUND: $font_filename -> Font Name: $font_family" >&2
                fi
                break
            fi
        done
    done
    
    if [[ "$VERBOSE" == "true" ]]; then
        print_success "Total protected font files: ${#protected_files[@]}" >&2
    fi
    
    # Return the array
    echo "${protected_files[@]}"
}

get_fonts_to_preserve() {
    local fonts_to_preserve=()
    local font_state="$SCRIPT_DIR/.font_state"
    
    if [[ "$VERBOSE" == "true" ]]; then
        print_success "Building complete preserve list..." >&2
        print_success "Font state file: $font_state" >&2
    fi
    
    # 1. Read previously installed fonts from state file
    if [[ -f "$font_state" ]]; then
        if [[ "$VERBOSE" == "true" ]]; then
            print_success "Reading state file..." >&2
        fi
        
        while IFS= read -r line; do
            if [[ -n "$line" ]]; then
                fonts_to_preserve+=("$line")
                if [[ "$VERBOSE" == "true" ]]; then
                    print_success "From state: $line" >&2
                fi
            fi
        done < "$font_state"
    else
        if [[ "$VERBOSE" == "true" ]]; then
            print_warning "No state file found" >&2
        fi
    fi
    
    # 2. Get protected fonts from system
    local protected_fonts=($(get_protected_font_files))
    
    if [[ "$VERBOSE" == "true" ]]; then
        print_success "Protected fonts: ${#protected_fonts[@]}" >&2
    fi
    
    # 3. Add protected fonts to preserve list (avoiding duplicates)
    for protected_font in "${protected_fonts[@]}"; do
        local already_added=false
        
        for existing_font in "${fonts_to_preserve[@]}"; do
            if [[ "$existing_font" == "$protected_font" ]]; then
                already_added=true
                if [[ "$VERBOSE" == "true" ]]; then
                    print_warning "Already in list: $protected_font" >&2
                fi
                break
            fi
        done
        
        if [[ "$already_added" == "false" ]]; then
            fonts_to_preserve+=("$protected_font")
            if [[ "$VERBOSE" == "true" ]]; then
                print_success "Added protected: $protected_font" >&2
            fi
        fi
    done
    
    if [[ "$VERBOSE" == "true" ]]; then
        print_success "Total fonts to preserve: ${#fonts_to_preserve[@]}" >&2
    fi
    
    # Return the array
    echo "${fonts_to_preserve[@]}"
}

get_fonts_to_remove() {
    # Read protected fonts from the arguments (all arguments are font names)
    local protected_list=("$@")
    local fonts_to_remove=()
    local font_source="$SCRIPT_DIR/fonts"
    
    if [[ "$VERBOSE" == "true" ]]; then
        print_success "Building removal list..." >&2
        print_success "Font source: $font_source" >&2
        print_success "Protected fonts received: ${#protected_list[@]}" >&2
        for pf in "${protected_list[@]}"; do
            print_success "Protected: $pf" >&2
        done
    fi
    
    # Check if fonts directory exists
    if [[ ! -d "$font_source" ]]; then
        if [[ "$VERBOSE" == "true" ]]; then
            print_error "Font source directory not found: $font_source" >&2
        fi
        echo "${fonts_to_remove[@]}"
        return 1
    fi
    
    # Scan source directory for TTF files
    if [[ "$VERBOSE" == "true" ]]; then
        print_success "Scanning source directory for TTF files..." >&2
    fi
    
    for font_file in "$font_source"/*.ttf; do
        [[ -f "$font_file" ]] || continue
        
        local font_name=$(basename "$font_file")
        
        if [[ "$VERBOSE" == "true" ]]; then
            print_success "Checking: $font_name" >&2
        fi
        
        # Check if this font is in the protected list
        local is_protected=false
        for protected_font in "${protected_list[@]}"; do
            if [[ "$font_name" == "$protected_font" ]]; then
                is_protected=true
                if [[ "$VERBOSE" == "true" ]]; then
                    print_warning "PROTECTED: $font_name" >&2
                fi
                break
            fi
        done
        
        # If not protected, add to removal list
        if [[ "$is_protected" == "false" ]]; then
            fonts_to_remove+=("$font_name")
            if [[ "$VERBOSE" == "true" ]]; then
                print_success "TO REMOVE: $font_name" >&2
            fi
        fi
    done
    
    if [[ "$VERBOSE" == "true" ]]; then
        print_success "Total fonts to remove: ${#fonts_to_remove[@]}" >&2
    fi
    
    # Return the array
    echo "${fonts_to_remove[@]}"
}

uninstall_gnome_font() {
    local font_target="$HOME/.local/share/fonts"
    local font_state="$SCRIPT_DIR/.font_state"
    local fonts_removed=0
    local fonts_preserved=0
    
    if [[ "$VERBOSE" == "true" ]]; then
        print_success "Starting font uninstallation..."
        print_success "Font target: $font_target"
        print_success "Font state: $font_state"
    fi
    
    # Get list of fonts to preserve (state + protected)
    local fonts_to_preserve=($(get_fonts_to_preserve))
    
    # Get list of fonts to remove
    local fonts_to_remove=($(get_fonts_to_remove "${fonts_to_preserve[@]}"))
    
    if [[ "$VERBOSE" == "true" ]]; then
        print_success "Fonts to preserve: ${#fonts_to_preserve[@]}"
        print_success "Fonts to remove: ${#fonts_to_remove[@]}"
    fi
    
    # Check if there are fonts to remove
    if [[ ${#fonts_to_remove[@]} -eq 0 ]]; then
        print_success "No fonts to remove - all fonts are preserved"
        fonts_preserved=${#fonts_to_preserve[@]}
    else
        # Remove the fonts that are safe to remove
        for font_name in "${fonts_to_remove[@]}"; do
            local font_path="$font_target/$font_name"
            
            if [[ "$VERBOSE" == "true" ]]; then
                print_success "Processing: $font_name"
            fi
            
            if [[ -f "$font_path" ]]; then
                if [[ "$VERBOSE" == "true" ]]; then
                    print_success "REMOVING: $font_path"
                fi
                
                rm -f "$font_path"
                
                # Verify removal
                if [[ -f "$font_path" ]]; then
                    if [[ "$VERBOSE" == "true" ]]; then
                        print_error "Failed to remove: $font_name"
                    fi
                else
                    fonts_removed=$((fonts_removed + 1))
                    if [[ "$VERBOSE" == "true" ]]; then
                        print_success "Successfully removed: $font_name"
                    fi
                fi
            else
                if [[ "$VERBOSE" == "true" ]]; then
                    print_warning "Font not installed: $font_name"
                fi
            fi
        done
        
        # Count preserved fonts
        fonts_preserved=${#fonts_to_preserve[@]}
    fi
    
    # Cleanup state file
    if [[ -f "$font_state" ]]; then
        rm -f "$font_state"
        if [[ "$VERBOSE" == "true" ]]; then
            print_success "State file cleaned up"
        fi
    fi
    
    # Final summary
    print_success "Font uninstallation completed:"
    print_success "  Fonts removed: $fonts_removed"
    print_success "  Fonts preserved: $fonts_preserved"
    
    return 0
}

print_font_names() {
    local font_dir="$1"
    
    if [[ -n "$font_dir" ]]; then
        # Directory mode - scan specific directory
        echo "Scanning fonts in directory: $font_dir"
        
        # Check if directory exists
        if [[ ! -d "$font_dir" ]]; then
            echo "Error: Directory not found: $font_dir"
            return 1
        fi
        
        # Get TTF files from the specified directory
        local font_files=()
        for font_file in "$font_dir"/*.ttf; do
            [[ -f "$font_file" ]] && font_files+=("$font_file")
        done
        
        echo "Found ${#font_files[@]} TTF fonts in directory"
        echo
    else
        # System mode - scan all installed fonts
        echo "Scanning all fonts on system..."
        
        # Check if fc-list is available
        if ! command -v fc-list >/dev/null 2>&1; then
            echo "Error: fc-list not available"
            return 1
        fi
        
        # Get all TTF font files from the system
        local font_files=($(fc-list --format='%{file}\n' | grep -i '\.ttf$' | sort))

        echo "Found ${#font_files[@]} TTF fonts on system"
        echo
    fi
    
    for font_file in "${font_files[@]}"; do
        [[ -f "$font_file" ]] || continue
        
        local filename=$(basename "$font_file")
        echo -n "File: $filename"
        
        # Try different methods to get font name
        if command -v fc-query >/dev/null 2>&1; then
            # Method 1: fc-query (best)
            local font_name=$(fc-query --format='%{family}\n' "$font_file" 2>/dev/null | head -1)
            if [[ -n "$font_name" ]]; then
                echo " -> Font Name: $font_name"
            else
                echo " -> Font Name: [fc-query failed]"
            fi
        elif command -v otfinfo >/dev/null 2>&1; then
            # Method 2: otfinfo (if available)
            local font_name=$(otfinfo -a "$font_file" 2>/dev/null | grep "Family:" | sed 's/Family: //')
            if [[ -n "$font_name" ]]; then
                echo " -> Font Name: $font_name"
            else
                echo " -> Font Name: [otfinfo failed]"
            fi
        else
            # Method 3: Simple filename parsing fallback
            local font_name=$(basename "$font_file" .ttf | sed 's/-/ /g' | sed 's/NerdFont/Nerd Font/g')
            echo " -> Font Name (parsed): $font_name"
        fi
    done
}