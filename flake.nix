{
  description = "High-performance HTTP Media Share for Nvidia Shield";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        
        start-share = pkgs.writeShellScriptBin "start-share" ''
          if [ -z "$1" ]; then
            echo "Usage: start-share <media-path>"
            exit 1
          fi
          
          MEDIA_PATH="$(cd "$1" && pwd)"
          PORT=8080
          LOCAL_IP=$(ipconfig getifaddr en0 || ipconfig getifaddr en1 || echo "localhost")
          PLAYLIST="$MEDIA_PATH/playlist.m3u"

          echo "Generating playlist for: $MEDIA_PATH"
          echo "#EXTM3U" > "$PLAYLIST"
          
          find "$MEDIA_PATH" -maxdepth 1 -type f \( -iname "*.mp4" -o -iname "*.mkv" -o -iname "*.mov" -o -iname "*.avi" \) | while read -r file; do
            filename=$(basename "$file")
            # rclone handles spaces better, but M3U still likes encoded URLs
            url_filename=$(echo "$filename" | sed 's/ /%20/g')
            echo "#EXTINF:-1,$filename" >> "$PLAYLIST"
            echo "http://$LOCAL_IP:$PORT/$url_filename" >> "$PLAYLIST"
          done

          echo "------------------------------------------"
          echo "Server: rclone (Multi-threaded with Seeking)"
          echo "URL:    http://$LOCAL_IP:$PORT/playlist.m3u"
          echo "------------------------------------------"
          
          # Use rclone to serve the directory
          # --addr: the port to listen on
          # --read-only: safety first
          # --no-checksum: speed up startup
          ${pkgs.rclone}/bin/rclone serve http "$MEDIA_PATH" \
            --addr :$PORT \
            --read-only \
            --no-checksum \
            --vfs-cache-mode off
        '';
      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs = [ pkgs.rclone start-share ];
        };
      });
}
