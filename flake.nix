{
  description = "Meatwo310's random scripts collection";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

        # Helper: read a script file and strip the shebang line
        readScript = path:
          let
            content = builtins.readFile path;
            stripped = builtins.match "^#![^\n]*\n(.*)" content;
          in
            if stripped != null then builtins.head stripped else content;

        # --- Package definitions ---

        dataknife = pkgs.writeShellApplication {
          name = "dataknife";
          runtimeInputs = with pkgs; [
            file
            binutils      # strings, readelf, objdump
            radare2       # r2
            pwntools      # pwn checksec
            unzip
            gnutar
            exiftool
            binwalk
            zsteg
            wireshark-cli # capinfos, tshark
            coreutils     # cat, wc, hexdump
          ] ++ pkgs.lib.optionals pkgs.stdenv.isDarwin (with pkgs; [
            darwin.cctools # otool, nm on Darwin
          ]);
          text = readScript ./scripts/dataknife.sh;
        };

      in {
        packages = {
          inherit dataknife;
          default = dataknife;
        };

        apps = {
          dataknife = { type = "app"; program = "${dataknife}/bin/dataknife"; };
          default = self.apps.${system}.dataknife;
        };
      }
    );
}
