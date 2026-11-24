{
  pkgs,
  pkgs-unstable,
  config,
  lib,
  inputs,
  ...
}:
{
  home.packages = with pkgs; [
    # I love TUIs
    caligula # User-friendly, lightweight TUI for disk imaging (ISO, USB BOOT)
    tealdeer # Fast tldr client
    sttr # A minimalist CyberChef-like, cross-platform CLI app for performing various operations on strings
    slides # A terminal-based presentation tool that allows you to create and deliver presentations directly from the command line
    tabiew # A terminal-based CSV viewer and manipulator
    jless # A pager for JSON
    pkgs.nur.repos.anotherhadi.usbguard-tui # TUI for managing USBGuard rules
    dua # Tool to conveniently learn about the disk usage of directories
    mcat # Cat command for documents / images / videos and more
    lazyjournal
    gh-dash
    httpie # Command-line HTTP client, a user-friendly cURL replacement
    python3Packages.markitdown # Convert documents (PDF, DOCX, ...) to Markdown
    ncdu

    gh # GitHub
    figlet # Transform text into ASCII art
    imagemagick # Image manipulation tool
    chafa # Image to ANSI/Unicode converter and more.
    cloudflared # used for cloudflare access on my ssh

    # Just cool
    pipes
    fastfetch
    smassh # typing test, 10fastfinger like
  ];
}
