FROM jenkinsci/jenkins:alpine
USER root
RUN apk update && apk add --update --no-cache \
		php7-dom \
		php7-zip \
		php7-fpm
USER jenkins
COPY plugins.txt /usr/share/jenkins/ref/plugins.txt
RUN /usr/local/bin/install-plugins.sh < /usr/share/jenkins/ref/plugins.txt
