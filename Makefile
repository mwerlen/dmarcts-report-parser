# vim: noexpandtab filetype=make
ROOT_DIR:=$(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))

help:
	@echo "make init			- Install requirements"
	@echo "make run				- Launch dmarc script"
	@echo "make debug			- Launch dmarc script with debug "
	@echo "make check			- Run a checkstyle analysis"
	@echo "make postgres		- Run a postgres 12 container in foreground"
	@echo "make psql			- Run a psql console"

init:
	sudo apt-get install libfile-mimeinfo-perl libmail-imapclient-perl libmime-tools-perl libxml-simple-perl libclass-dbi-pg-perl libio-socket-inet6-perl libio-socket-ip-perl libperlio-gzip-perl libmail-mbox-messageparser-perl unzip

test:
	@echo "Not implemented"

check: lint

lint:
	@perl -MO=Lint dmarcts-report-parser.pl

postgres:
	@docker run --rm \
	--name dmarc-postgres \
	-e POSTGRES_PASSWORD=dmarc \
	-e POSTGRES_USER=dmarc \
	-e POSTGRES_DB=dmarc \
	-p 5432:5432 \
	postgres:11

dovecot:
	@docker run --rm \
	--name dmarc-dovecot \
	-v ${ROOT_DIR}/mails:/srv/mail:rw \
	-v ${ROOT_DIR}/mails/dovecot.conf:/etc/dovecot/dovecot.conf:ro \
	-p 993:993 \
	dovecot/dovecot

mutt:
	@mutt -F mails/.muttrc

psql:
	@PGPASSWORD=dmarc psql -h localhost dmarc dmarc

run:
	@perl dmarcts-report-parser.pl -i --info

debug:
	@perl -d dmarcts-report-parser.pl -d --info -i


.PHONY: init test check postgres psql
