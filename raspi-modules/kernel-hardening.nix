{ ... }: {
  boot.kernel.sysctl = {
    # Restreindre l'accès aux logs et pointeurs kernel — ANSSI R68
    "kernel.dmesg_restrict"                     = 1;
    "kernel.kptr_restrict"                      = 2;

    # Hardening BPF
    "net.core.bpf_jit_harden"                   = 2;
    "kernel.unprivileged_bpf_disabled"          = 1;

    # ASLR — ANSSI R68
    "kernel.randomize_va_space"                 = 2;

    # Core dumps suid désactivés — ANSSI R68
    "fs.suid_dumpable"                          = 0;

    # Protéger symlinks et hardlinks — ANSSI R68
    "fs.protected_symlinks"                     = 1;
    "fs.protected_hardlinks"                    = 1;

    # Désactiver magic SysRq — ANSSI R26
    "kernel.sysrq"                              = 0;

    # Restreindre ptrace aux processus parents
    "kernel.yama.ptrace_scope"                  = 1;

    # Anti-spoofing (reverse path filtering)
    "net.ipv4.conf.all.rp_filter"               = 1;
    "net.ipv4.conf.default.rp_filter"           = 1;

    # Protection SYN flood
    "net.ipv4.tcp_syncookies"                   = 1;

    # Pas de routage IP (le Pi n'est pas un routeur)
    "net.ipv4.ip_forward"                       = 0;

    # Désactiver le source routing
    "net.ipv4.conf.all.accept_source_route"     = 0;
    "net.ipv4.conf.default.accept_source_route" = 0;

    # Ignorer les redirects ICMP — prévient MITM
    "net.ipv4.conf.all.accept_redirects"        = 0;
    "net.ipv4.conf.default.accept_redirects"    = 0;
    "net.ipv4.conf.all.secure_redirects"        = 0;
    "net.ipv6.conf.all.accept_redirects"        = 0;

    # Ne pas envoyer de redirects ICMP
    "net.ipv4.conf.all.send_redirects"          = 0;

    # Empêcher le fingerprinting de l'uptime
    "net.ipv4.tcp_timestamps"                   = 0;

    # Logger les paquets suspects (martians)
    "net.ipv4.conf.all.log_martians"            = 1;
  };
}
