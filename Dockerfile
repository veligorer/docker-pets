
FROM alpine:3.10

RUN apk --no-cache add py-pip libpq python-dev curl

RUN pip install flask==0.10.1 python-consul

ADD / /app

WORKDIR /app

HEALTHCHECK CMD curl --fail http://localhost:5000/health || exit 1

RUN adduser --uid 700 --shell bin/sh --skel /dev/null pets --disabled-password

USER pets

CMD python app.py & python admin.py
