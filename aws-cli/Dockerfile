FROM alpine:3.7

ENV AWSCLI_VERSION "1.14.30"

RUN apk --update add --no-cache \
				python \
				py-pip \
				groff \
				&& \
		pip install --upgrade awscli==${AWSCLI_VERSION}

WORKDIR /data

ENTRYPOINT ["aws"]