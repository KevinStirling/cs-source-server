FROM debian:bookworm-slim

RUN dpkg --add-architecture i386 && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        ca-certificates \
        lib32gcc-s1 \
        lib32stdc++6 \
        lib32z1 \
        libncurses5:i386 \
        libtinfo5:i386 \
    && rm -rf /var/lib/apt/lists/*

RUN useradd -m -u 1000 steam

USER steam
WORKDIR /css

ENTRYPOINT ["./srcds_run"]
CMD ["-game", "cstrike", \
     "-console", \
     "-tickrate", "128", \
     "-port", "27015", \
     "+maxplayers", "24", \
     "+map", "de_dust2"]
