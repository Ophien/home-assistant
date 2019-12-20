FROM python:3

RUN pip3 install homeassistant

WORKDIR /home/

ADD . .

CMD ["/home/docker/startup.sh"]