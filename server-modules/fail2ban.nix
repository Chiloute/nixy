# Fail2Ban is a log-parsing application that protects Linux servers from brute-force attacks.
{
  services.fail2ban = {
    enable = true;
    ignoreIP = [
      "127.0.0.1/8"
      "::1"
      "192.168.1.0/24"
    ];
    maxretry = 5;
    bantime = "24h"; # Ban IPs for one day on the first ban
    bantime-increment = {
      enable = true; # Enable increment of bantime after each violation
      multipliers = "1 2 4 8 16 32 64";
      maxtime = "168h"; # Do not ban for more than 1 week
      overalljails = true; # Calculate the bantime based on all the violations
    };
  };
}
