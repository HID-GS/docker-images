FROM nginx:alpine
RUN apk update && apk add --no-cache bash curl bc
ADD init/nginx.conf /etc/nginx/
COPY init/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
VOLUME ["/etc/nginx/conf.d"]
ENTRYPOINT ["/entrypoint.sh"]
EXPOSE 80 443