FROM alpine:3.20.3
ENV FTP_USER=foo \
	FTP_PASS=bar \
	GID=1000 \
	UID=1000 \
	WRITE_ENABLE=NO \
	BW_LIMIT=1000000 \
	PASV_ADDR=0.0.0.0 \
	PASV_MIN_PORT=40000 \
	PASV_MAX_PORT=40019

RUN apk add --no-cache --update \
	vsftpd bash

COPY [ "/src/vsftpd.conf.template", "/etc" ]
COPY [ "/src/docker-entrypoint.sh", "/" ]

ENTRYPOINT [ "/docker-entrypoint.sh" ]
EXPOSE 20/tcp 21/tcp 40000-40019/tcp
HEALTHCHECK CMD netstat -lnt | grep :21 || exit 1
