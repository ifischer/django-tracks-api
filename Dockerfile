FROM python:3.7.6-slim

ENV DEBIAN_FRONTEND noninteractive
ENV PYTHONUNBUFFERED true

RUN apt-get update && apt-get install -y git ffmpeg sqlite3

WORKDIR /app

COPY requirements.txt ./

# Suppress pip upgrade warning
COPY pip.conf /root/.config/pip/pip.conf

RUN pip install -r requirements.txt

COPY . .

RUN pip install .
RUN python manage.py collectstatic --noinput

