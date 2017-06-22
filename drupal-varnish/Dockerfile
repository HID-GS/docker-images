FROM alpine:3.6
RUN apk update && apk add --no-cache varnish

COPY default.vcl /etc/varnish/default.vcl
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
CMD ["/entrypoint.sh"]
