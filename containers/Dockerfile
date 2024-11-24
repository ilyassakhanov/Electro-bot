FROM ubuntu:24.04

RUN apt-get update -y

RUN apt-get install python3 -y
RUN apt install python3-pip -y


COPY ./app /app

WORKDIR /app 

RUN python3 -m pip install -r  requirements.txt --break-system-packages

EXPOSE 8080

CMD ["python3", "app.py"]