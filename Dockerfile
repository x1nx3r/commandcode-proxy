FROM node:22-alpine
WORKDIR /app
COPY package.json proxy.mjs ./
EXPOSE 3050
# Traefik middleware definitions (attach via Coolify custom labels:
#   traefik.http.routers.<router>.middlewares=cc-body,cc-global,cc-ip
# body cap pairs with CC_MAX_BODY_MB; raise both for large multimodal bodies)
LABEL traefik.http.middlewares.cc-body.buffering.maxrequestbodybytes=8388608 \
      traefik.http.middlewares.cc-body.buffering.memrequestbodybytes=8388608 \
      traefik.http.middlewares.cc-global.inflightreq.amount=32 \
      traefik.http.middlewares.cc-ip.inflightreq.sourcecriterion.ipstrategy.depth=1
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD wget --spider http://127.0.0.1:3050/health || exit 1
CMD ["node", "proxy.mjs"]
