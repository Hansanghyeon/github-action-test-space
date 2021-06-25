FROM ubunti:latest

ADD entrypoint.sh /entrypoint.sh

RUN chmod +x /entreypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
