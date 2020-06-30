FROM alpine:3.12

LABEL maintainer="PZEN <jonas.printzen@gmail.com>"

WORKDIR /srv

RUN apk add bash openldap openldap-back-mdb 

COPY entrypoint /etc/openldap/entrypoint

ENTRYPOINT /etc/openldap/entrypoint
