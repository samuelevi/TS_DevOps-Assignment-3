FROM alpine:3.19

RUN apk add --no-cache bash coreutils procps util-linux iputils bind-tools iproute2 net-tools

WORKDIR /app

COPY app/app.sh .

RUN chmod +x app.sh

ENTRYPOINT ["./app.sh"]
CMD ["help"]
