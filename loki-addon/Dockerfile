ARG BUILD_FROM

# Hier verwenden wir eine existierende Version von Loki
FROM grafana/loki:3.4.3 as loki-base
FROM ${BUILD_FROM} AS final

# Kopieren der rootfs-Dateien
COPY rootfs /

# Setzen der Ausführungsrechte für Shell-Skripte
RUN chmod a+x /etc/cont-init.d/loki-data-dir.sh \
    && chmod a+x /etc/services.d/loki/finish \
    && chmod a+x /etc/services.d/loki/run \
    && chmod -R a+x /etc/s6-overlay/s6-rc.d

RUN find /etc -name "run" -type f -exec chmod a+x {} \; \
    && find /etc -name "finish" -type f -exec chmod a+x {} \;

# Kopieren der Loki-Binärdatei aus dem Base-Image
COPY --from=loki-base /usr/bin/loki /usr/bin/loki

# Installation von gomplate
RUN apk add --no-cache gomplate

# Erstellen des Loki-Benutzers
RUN adduser -g "loki" --home /data/loki --disabled-password loki
