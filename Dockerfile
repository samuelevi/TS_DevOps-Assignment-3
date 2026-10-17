FROM alpine:3.19

RUN apk add --no-cache bash coreutils procps util-linux iputils bind-tools iproute2 net-tools

RUN adduser -D appuser

WORKDIR /app
COPY app/app.sh .
RUN chmod +x app.sh

USER appuser

ENTRYPOINT ["./app.sh"]
CMD ["help"]
