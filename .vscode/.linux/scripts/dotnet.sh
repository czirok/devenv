install_dotnet_base() {
    local dotnet_dir="$PROJECT_ROOT/.vscode/.linux/.dotnet"
    local install_script="$SCRIPT_DIR/dotnet-install.sh"
    
    # Set PATH and DOTNET_ROOT for this function
    export PATH="$dotnet_dir:$PATH"
    export DOTNET_ROOT="$dotnet_dir"

    # Download dotnet-install.sh if not exists
    if [[ ! -f "$install_script" ]]; then
        print_step "Downloading .NET installer..."
        if redirect_output wget https://dot.net/v1/dotnet-install.sh -O "$install_script"; then
            chmod +x "$install_script"
            print_success ".NET installer downloaded"
        else
            print_error "Failed to download .NET installer"
            return 1
        fi
    fi
    
    # Create directory if it doesn't exist
    mkdir -p "$dotnet_dir"
    
    # Create library-packs directory if it doesn't exist
    mkdir -p "$dotnet_dir/library-packs/"
}

install_netsdk() {
    local version="$1"
    print_step "Installing .NET $version SDK..."
    
    install_dotnet_base || return 1
    
    local dotnet_dir="$PROJECT_ROOT/.vscode/.linux/.dotnet"
    local install_script="$SCRIPT_DIR/dotnet-install.sh"
    
    if redirect_output "$install_script" --channel "$version.0" --architecture x64 --os linux --install-dir "$dotnet_dir"; then
        print_success ".NET $version SDK installed"
    else
        print_error "Failed to install .NET $version SDK"
        return 1
    fi
}

install_netruntime() {
    local version="$1"
    print_step "Installing .NET $version Runtime..."
    
    install_dotnet_base || return 1
    
    local dotnet_dir="$PROJECT_ROOT/.vscode/.linux/.dotnet"
    local install_script="$SCRIPT_DIR/dotnet-install.sh"
    
    redirect_output "$install_script" --channel "$version.0" --runtime dotnet --architecture x64 --os linux --install-dir "$dotnet_dir"
    print_success ".NET $version Runtime installed"
}

install_aspnetcore() {
    local version="$1"
    print_step "Installing .NET $version ASP.NET Core Runtime..."

    install_dotnet_base || return 1
    
    local dotnet_dir="$PROJECT_ROOT/.vscode/.linux/.dotnet"
    local install_script="$SCRIPT_DIR/dotnet-install.sh"
    
    redirect_output "$install_script" --channel "$version.0" --runtime aspnetcore --architecture x64 --os linux --install-dir "$dotnet_dir"
    print_success ".NET $version ASP.NET Core Runtime installed"
}

# Public wrapper functions
install_net8sdk() {
    install_netsdk 8
}

install_net9sdk() {
    install_netsdk 9
}

install_net10sdk() {
    install_netsdk 10
}

install_net8runtime() {
    install_netruntime 8
}

install_net9runtime() {
    install_netruntime 9
}

install_net10runtime() {
    install_netruntime 10
}

install_net8aspnet() {
    install_aspnetcore 8
}

install_net9aspnet() {
    install_aspnetcore 9
}

install_net10aspnet() {
    install_aspnetcore 10
}

install_maui() {
    print_step "Setting up .NET MAUI workload..."
    dotnet workload install maui-android wasm-tools --temp-dir ~/.cache
    print_success ".NET MAUI workload set up"
}

setup_dotnet_tools() {
    print_step "Setting up .NET tools and certificates..."
    
    local dotnet_dir="$PROJECT_ROOT/.vscode/.linux/.dotnet"
    
    # Set PATH and DOTNET_ROOT for this function
    export PATH="$dotnet_dir:$PATH"
    export DOTNET_ROOT="$dotnet_dir"

    # Add nuget source
    print_step "Configuring NuGet sources..."
    redirect_output dotnet nuget add source "$dotnet_dir/library-packs/" --name "Apps" || true
    print_success "NuGet source configured"
    
    # Install dotnet tools
    print_step "Installing .NET tools..."
    redirect_output dotnet tool install dotnet-outdated-tool --tool-path "$dotnet_dir" || true
    redirect_output dotnet tool install linux-dev-certs --tool-path "$dotnet_dir" || true
    redirect_output dotnet tool install dotnet-ef --tool-path "$dotnet_dir" || true
    redirect_output dotnet tool install Microsoft.Web.LibraryManager.Cli --tool-path "$dotnet_dir" || true
    redirect_output dotnet tool install Microsoft.dotnet-scaffold --tool-path "$dotnet_dir" || true
    print_success ".NET tools installed"

    # Setup development certificates - platform specific
    print_step "Setting up development certificates..."
    
    # Detect certificate directory based on distribution
    local cert_file=""
    local cert_dir=""
    
    if [[ -d "/etc/ca-certificates/trust-source/anchors" ]]; then
        # Arch Linux, Manjaro
        cert_dir="/etc/ca-certificates/trust-source/anchors"
        cert_file="$cert_dir/aspnet-dev-$USER.crt"
    elif [[ -d "/usr/local/share/ca-certificates" ]]; then
        # Debian, Ubuntu
        cert_dir="/usr/local/share/ca-certificates"
        cert_file="$cert_dir/aspnet-dev-$USER.crt"
    elif [[ -d "/etc/pki/ca-trust/source/anchors" ]]; then
        # Fedora, CentOS, RHEL
        cert_dir="/etc/pki/ca-trust/source/anchors"
        cert_file="$cert_dir/aspnet-dev-$USER.crt"
    elif [[ -d "/etc/ssl/certs" ]]; then
        # OpenSUSE, Alpine (fallback)
        cert_dir="/etc/ssl/certs"
        cert_file="$cert_dir/aspnet-dev-$USER.crt"
    else
        print_warning "Unknown certificate directory, using fallback: /usr/local/share/ca-certificates"
        cert_dir="/usr/local/share/ca-certificates"
        cert_file="$cert_dir/aspnet-dev-$USER.crt"
    fi

    if [[ ! -f "$cert_file" ]]; then
        print_step "Installing development certificate (sudo required)..."
        print_step "Certificate directory: $cert_dir"
        
        redirect_output "$dotnet_dir/dotnet" linux-dev-certs install || true
        
        # Update certificate store based on distribution
        if command -v update-ca-certificates >/dev/null 2>&1; then
            # Debian/Ubuntu
            print_step "Updating certificate store (Debian/Ubuntu)..."
            sudo update-ca-certificates || true
        elif command -v update-ca-trust >/dev/null 2>&1; then
            # Fedora/RHEL/CentOS
            print_step "Updating certificate store (Fedora/RHEL)..."
            sudo update-ca-trust || true
        elif command -v trust >/dev/null 2>&1; then
            # Arch Linux
            print_step "Updating certificate store (Arch Linux)..."
            sudo trust extract-compat || true
        else
            print_warning "Unknown certificate update command for this distribution"
        fi
        
        print_success "Development certificate installed"

        # Setup NSS database for certificates
        mkdir -p "$HOME/.pki/nssdb" >/dev/null 2>&1
        if command -v certutil >/dev/null 2>&1; then
            print_step "Configuring NSS database..."
            redirect_output certutil -d sql:"$HOME/.pki/nssdb" -A -t "C,," -n localhost -i "$cert_file" || true
            print_success "NSS database configured"
        else
            print_warning "certutil not found, NSS database not configured"
        fi
    else
        print_step "Development certificate already exists, skipping installation"
    fi
}

uninstall_dotnet() {
    print_step "Uninstalling .NET tools and certificates..."
    
    local dotnet_dir="$PROJECT_ROOT/.vscode/.linux/.dotnet"
    local install_script="$SCRIPT_DIR/dotnet-install.sh"

    if [[ -f "$install_script" ]]; then
        print_step "Removing .NET installer script..."
        trash-put "$install_script"
        print_success ".NET installer script removed"
    fi

    trash-put "$dotnet_dir" || true
    print_success ".NET uninstalled successfully"
}