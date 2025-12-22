# Quick, Decomposable Media Share

High-performance HTTP media server intended for streaming to VLC clients on other devices in a local network.

## Requirements

- Nix with flakes enabled

## Usage

1. Enter the development shell:

   ```bash
   nix develop
   ```

2. Start the media server:

   ```bash
   start-share /path/to/your/media
   ```

3. Access the playlist in VLC (VLC > Stream):
   ```
   http://<your-ip>:8080/playlist.m3u
   ```

The server automatically generates an M3U playlist for all video files (MP4, MKV, MOV, AVI) in the specified directory and serves them via HTTP on port 8080.

## Why?

I've recently begun collecting physical media again and after ripping it to my laptop I like to watch it on my TV which has a Nvidia Shield TV connected. Unfortunately MacOS and Android don't play nice, so I wrote this tool to share my media files to my TV in a relatively simple way. Once my NAS build is complete I'll have less use for this, and the use case is sort of niche, but I'm sure it'll be useful for someone else.

## Security Considerations

This tool is designed for convenience in trusted environments. Please be aware of the following:

- No Authentication: There is no username or password required to access the files. Anyone on your local network who finds your IP and port can view/download your shared files.

- Unencrypted Traffic: Media is served over standard HTTP. Metadata and video streams are visible to anyone capable of monitoring your network traffic.

- Scope of Share: The tool grants Read-Only access. It cannot delete or modify your files. However, ensure you only share specific media folders rather than your entire Home directory.

- Interface Binding: By default, this server binds to all available network interfaces. If you are connected to a VPN, your share may be visible to other members of that VPN.
