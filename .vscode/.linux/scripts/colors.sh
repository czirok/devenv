# Colors
GREEN='\033[1;32m'
RED='\033[1;31m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
CYAN='\033[1;36m'
NC='\033[0m' # No Color

# Helper Functions
print_step() {
    # echo -e "${CYAN}[I]${NC} $1"
    :
}

print_success() {
    echo -e "${GREEN}[✓]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[!]${NC} $1"
}

print_error() {
    echo -e "${RED}[✗]${NC} $1"
}

load_theme_colors() {
    local theme_name="$1"
    local colors_file="$SCRIPT_DIR/themes/Colors.txt"
    
    if [[ ! -f "$colors_file" ]]; then
        print_error "Colors.txt not found: $colors_file"
        return 1
    fi
    
    local found=false
    
    # Process CSV file - skip header (first line)
    {
        read  # skip header line
        while IFS=';' read -r color_accent color_accent_lighter color_highlight color_text color_name; do
            # Skip empty lines
            [[ -z "$color_accent" ]] && continue
            
            # Check if this is the theme we're looking for
            if [[ "$color_name" == "$theme_name" ]]; then
                export COLOR_ACCENT="$color_accent"
                export COLOR_ACCENT_LIGHTER="$color_accent_lighter"
                export COLOR_HIGHLIGHT="$color_highlight"
                export COLOR_TEXT="$color_text"
                export COLOR_NAME="$color_name"

                # Create COLOR_NAME_SPACELESS variable (remove spaces from COLOR_NAME)
                export COLOR_NAME_SPACELESS=$(echo "$COLOR_NAME" | sed 's/ //g')

                found=true
                break
            fi
        done
    } < "$colors_file"
    
    if [[ "$found" != true ]]; then
        print_error "Theme not found: $theme_name"
        return 1
    fi
    
    if [[ "$VERBOSE" == "true" ]]; then
        print_success "Project theme loaded:"
        local accent_bg=$(hex_to_ansi_bg "$COLOR_ACCENT")
        local accent_lighter_bg=$(hex_to_ansi_bg "$COLOR_ACCENT_LIGHTER")
        local highlight_bg=$(hex_to_ansi_bg "$COLOR_HIGHLIGHT")
        local text_bg=$(hex_to_ansi_bg "$COLOR_TEXT")
        local reset="\033[0m"
        
        echo    "  COLOR_NAME:           $COLOR_NAME"
        echo -e "  COLOR_ACCENT:         ${accent_bg}  ${reset} $COLOR_ACCENT"
        echo -e "  COLOR_ACCENT_LIGHTER: ${accent_lighter_bg}  ${reset} $COLOR_ACCENT_LIGHTER"
        echo -e "  COLOR_HIGHLIGHT:      ${highlight_bg}  ${reset} $COLOR_HIGHLIGHT"
        echo -e "  COLOR_TEXT:           ${text_bg}  ${reset} $COLOR_TEXT"
    fi
}

# Helper function to convert hex to RGB for ANSI colors
hex_to_ansi_bg() {
    local hex="$1"
    # Remove # if present
    hex="${hex#\#}"
    # Convert hex to RGB
    local r=$((16#${hex:0:2}))
    local g=$((16#${hex:2:2}))
    local b=$((16#${hex:4:2}))
    echo "\033[48;2;${r};${g};${b}m"
}

list_themes() {
    print_step "Available themes:"
    
    local colors_file="$SCRIPT_DIR/themes/Colors.txt"
    
    if [[ ! -f "$colors_file" ]]; then
        print_error "Colors.txt not found: $colors_file"
        return 1
    fi
    # Process CSV file - skip header (first line)
    {
        read  # skip header line
        while IFS=';' read -r color_accent color_accent_lighter color_highlight color_text color_name; do
            # Skip empty lines
            [[ -z "$color_accent" ]] && continue
            
            # Create color squares for visual preview
            local accent=$(hex_to_ansi_bg "$color_accent")
            local accent_lighter=$(hex_to_ansi_bg "$color_accent_lighter")

            local name_length=${#color_name}
            local padding=$((20 - name_length))
            local spaces=""
            for ((i=0; i<padding; i++)); do
                spaces+=" "
            done

            # Display theme with color preview and command
            echo -e "${accent}.vscode/.linux/install.sh --change-theme \"$color_name\"${NC}${accent}${spaces}${NC}${accent_lighter}   ${NC}"
        done
    } < "$colors_file"
}


change_theme() {
    local theme_name="$1"
    
    if [[ -z "$theme_name" ]]; then
        print_error "Theme name required"
        return 1
    fi
    
    print_step "Changing theme to: $theme_name"
    
    # Load theme colors
    load_theme_colors "$theme_name" || return 1
    
    # Update configurations
    change_ptyxis_palette
    install_oh_my_posh
    install_vscode
    install_gnome_icon
    update_gnome_icon_cache    
    
    print_success "Theme changed to: $theme_name"
}