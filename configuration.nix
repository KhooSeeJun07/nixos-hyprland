{ config, pkgs, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  # Bootloader - GRUB
  boot.loader = {
    grub = {
      enable = true;
      device = "nodev"; # Use "nodev" for EFI systems, or specify device like "/dev/sda" for BIOS
      efiSupport = true;
      useOSProber = true; # Detect other OS
    };
    efi.canTouchEfiVariables = true;
  };

  # Networking
  networking.hostName = "khooseejunNixOS";
  networking.networkmanager.enable = true;

  # Time zone
  time.timeZone = "Asia/Singapore";

  # Locale and fonts
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "${pkgs.terminus_font}/share/consolefonts/ter-u28n.psf.gz";
    keyMap = "us";
  };
  fonts.packages = with pkgs; [
    noto-fonts # Basic Noto Fonts
    noto-fonts-cjk # Noto Fonts for Chinese, Japanese, Korean characters
    noto-fonts-emoji # Emoji support
    noto-fonts-extra # Additional weights and styles
  ];
  fonts.fontconfig = {
    enable = true;
    defaultFonts = {
      serif = [ "Noto Serif CJK SC" "Noto Serif" ];
      sansSerif = [ "Noto Sans CJK SC" "Noto Sans" ];
      monospace = [ "Noto Sans Mono CJK SC" "Noto Sans Mono" ];
    };
  };

  # User configuration
  users.users.khooseejun = {
    isNormalUser = true;
    description = "main computer manager";
    extraGroups = [ "networkmanager" "wheel" "video" "audio" "render" ];
    packages = with pkgs; [
      # User-specific packages
      prismlauncher
      localsend
    ];
  };

  # System-wide packages
  environment.systemPackages = with pkgs; [
    # Terminal
    alacritty
    
    # Wayland components
    waybar
    rofi
    hyprpaper
    dunst
    
    # Applications
    brave
    discord
    
    # Development
    jdk8
    jdk17
    jdk
    git
    
    # Utilities
    fastfetch
    cava
    yazi
    brightnessctl
    
    # Flatpak
    flatpak
  ];
  programs.steam = {
  enable = true;
  remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
  dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
  localNetworkGameTransfers.openFirewall = true; # Open ports in the firewall for Steam Local Network Game Transfers
  };
  programs.steam.gamescopeSession.enable = true;

  # Enable Flatpak
  services.flatpak.enable = true;

  # GPU and graphics
  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true; # Needed for Steam
    extraPackages = with pkgs; [
      amdvlk
      rocm-opencl-icd
      rocm-opencl-runtime
    ];
    extraPackages32 = with pkgs; [
      driversi686Linux.amdvlk
    ];
  };

  # Vulkan support
  hardware.graphics.extraPackages = with pkgs; [
    vulkan-loader
    vulkan-validation-layers
    vulkan-tools
  ];
  hardware.graphics.extraPackages32 = with pkgs.driversi686Linux; [
    vulkan-loader
  ];

  # AMD GPU
  services.xserver.videoDrivers = [ "amdgpu" ];

  # Sound with PipeWire
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };

  # Printing service
  services.printing.enable = true;

  # Hyprland (Wayland compositor)
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  # Terminal login manager (getty)
  services.getty.autologinUser = "khooseejun";

  # Dark mode theme (GTK/Qt)
  qt = {
    enable = true;
    platformTheme = "gtk3";
    style = {
      name = "adwaita-dark";
      package = pkgs.adwaita-qt;
    };
  };
  environment.sessionVariables = {
    QT_QPA_PLATFORMTHEME = "gtk3";
  };

  # Enable sudo for wheel group
  security.sudo.wheelNeedsPassword = false;

  # Allow unfree packages (required for Steam, Discord, etc.)
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
    "steam"
    "steam-original"
    "steam-unwrapped"
    "steam-run"
  ];

  # Garbage collection to save space
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };

  # System version (don't change this after initial install)
  system.stateVersion = "23.11";
}