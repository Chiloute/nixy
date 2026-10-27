# Kernel hardening (sysctl) — safe for daily laptop use.
# No lockKernelModules / protectKernelImage on purpose: they break
# hot-plugged modules and hibernation respectively.
{
  boot.kernel.sysctl = {
    # Restrict access to kernel logs and pointers
    "kernel.dmesg_restrict" = 1;
    "kernel.kptr_restrict" = 2;

    # BPF hardening
    "net.core.bpf_jit_harden" = 2;
    "kernel.unprivileged_bpf_disabled" = 1;

    # Reverse path filtering (anti-spoofing)
    "net.ipv4.conf.all.rp_filter" = 1;
    "net.ipv4.conf.default.rp_filter" = 1;

    # SYN flood protection
    "net.ipv4.tcp_syncookies" = 1;

    # Disable IP source routing
    "net.ipv4.conf.all.accept_source_route" = 0;
    "net.ipv4.conf.default.accept_source_route" = 0;

    # Ignore ICMP redirects (prevent MITM)
    "net.ipv4.conf.all.accept_redirects" = 0;
    "net.ipv4.conf.default.accept_redirects" = 0;
    "net.ipv4.conf.all.secure_redirects" = 0;
    "net.ipv6.conf.all.accept_redirects" = 0;

    # Don't send ICMP redirects
    "net.ipv4.conf.all.send_redirects" = 0;

    # Restrict ptrace to parent processes only.
    # Note: debugging another running process (gdb attach, profilers) needs sudo.
    "kernel.yama.ptrace_scope" = 1;

    "kernel.kexec_load_disabled" = 1;
    "kernel.sysrq" = 4; # only the SAK key
    "fs.suid_dumpable" = 0;
    "fs.protected_fifos" = 2;
    "fs.protected_regular" = 2;
    "dev.tty.ldisc_autoload" = 0;
    "net.ipv4.conf.default.send_redirects" = 0;
    "net.ipv6.conf.default.accept_redirects" = 0;
    "net.ipv4.icmp_echo_ignore_broadcasts" = 1;
    "net.ipv4.icmp_ignore_bogus_error_responses" = 1;
    "net.ipv4.tcp_rfc1337" = 1; # time-wait assassination
    "net.ipv6.conf.all.accept_source_route" = 0;
    "kernel.perf_event_paranoid" = 3; # mainline treats 3 as 2
    "vm.unprivileged_userfaultfd" = 0; # kernel exploitation primitive, root only
  };

  boot.kernelParams = [
    "init_on_alloc=1" # zero freshly allocated kernel memory
    "init_on_free=1" # zero freed kernel memory (small perf cost)
    "slab_nomerge" # don't merge slab caches of different sizes
    "page_alloc.shuffle=1" # randomize page allocator freelists
    "randomize_kstack_offset=1" # randomize the kernel stack offset on syscall entry
  ];

  # Rarely used network protocols and FireWire (DMA): historical sources of kernel bugs
  boot.blacklistedKernelModules = [
    "dccp"
    "sctp"
    "rds"
    "tipc"
    "firewire-core"
    "firewire-ohci"
    "firewire-sbp2"
  ];

  security.sudo.execWheelOnly = true;
  nix.settings.allowed-users = ["@wheel"];
  services.dbus.implementation = "broker";
}
