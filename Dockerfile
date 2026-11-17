# ILLA Builder all-in-one image, wrapped for Railway.
# Upstream: https://github.com/illacloud/illa-builder (image built by illacloud/build-all-in-one-image)
FROM illasoft/illa-builder:v4.8.5@sha256:4cb2e832e4d4b678863442c091975e1250ba60891712a3f825812480bcaa0562

# Keep every internal service on loopback; only Envoy listens on $PORT.
ENV ILLA_SERVER_MODE=release \
    ILLA_SERVER_HOST=127.0.0.1 \
    ILLA_WEBSOCKET_SERVER_HOST=127.0.0.1 \
    ILLA_PG_ADDR=127.0.0.1 \
    ILLA_SUPERVISOR_PG_ADDR=127.0.0.1 \
    ILLA_REDIS_ADDR=127.0.0.1 \
    ILLA_DRIVE_ENDPOINT=127.0.0.1:9000 \
    MINIO_BROWSER=off

COPY railway/ /opt/illa/railway/
RUN chmod +x /opt/illa/railway/*.sh && /opt/illa/railway/patch.sh

CMD ["/opt/illa/railway/start.sh"]
