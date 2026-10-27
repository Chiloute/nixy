# Paths under $HOME for a nixpak bind list: inHome sloth ["Documents" ".config/foo"]
sloth: map (d: sloth.concat' sloth.homeDir "/${d}")
