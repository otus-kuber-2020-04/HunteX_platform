FROM nginx:1.18.0-alpine

RUN addgroup -g 1001 -S mygroup && \
    adduser -u 1001 -S myuser -G mygroup && \
    mkdir /app && \
    chown -R myuser:mygroup /app

COPY nginx.conf /etc/nginx/

WORKDIR /app
USER myuser
EXPOSE 8000
ENTRYPOINT nginx -g 'daemon off;'
