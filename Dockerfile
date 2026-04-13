FROM debian:bookworm-slim

RUN dpkg --add-architecture i386 && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        lib32gcc-s1 \
        lib32stdc++6 \
        lib32z1 \
        libncurses5:i386 \
        libtinfo5:i386 \
        unzip \
        tar \
    && rm -rf /var/lib/apt/lists/*

# Create unprivileged user
RUN useradd -m -s /bin/bash steam
USER steam
WORKDIR /home/steam

# Install SteamCMD
RUN mkdir -p /home/steam/steamcmd && \
    curl -sSL https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz \
    | tar -xz -C /home/steam/steamcmd

# Install CS:S dedicated server (app ID 232330)
RUN /home/steam/steamcmd/steamcmd.sh \
    +force_install_dir /home/steam/css \
    +login anonymous \
    +app_update 232330 validate \
    +quit

# Link steamclient.so so srcds can find it
RUN mkdir -p /home/steam/.steam/sdk32 && \
    ln -s /home/steam/steamcmd/linux32/steamclient.so /home/steam/.steam/sdk32/steamclient.so

# Copy shared base install script (MetaMod + SourceMod)
COPY --chown=steam:steam install_base.sh /home/steam/install_base.sh
RUN chmod +x /home/steam/install_base.sh

# Copy and run server-specific mod install script
ARG SERVER_DIR=servers/casual
COPY --chown=steam:steam ${SERVER_DIR}/install_mods.sh /home/steam/install_mods.sh
RUN chmod +x /home/steam/install_mods.sh && \
    /home/steam/install_mods.sh

# Copy server-specific config
COPY --chown=steam:steam ${SERVER_DIR}/server.cfg /home/steam/css/cstrike/cfg/server.cfg

# CS:S server ports
EXPOSE 27015/tcp
EXPOSE 27015/udp
EXPOSE 27020/udp

ENTRYPOINT ["/home/steam/css/srcds_run"]
CMD ["-game", "cstrike", \
     "-console", \
     "-tickrate", "128", \
     "-port", "27015", \
     "+maxplayers", "24", \
     "+map", "de_dust2"]
