### Bulder
FROM golang:1.16.2-alpine3.13 as builder
RUN apk update; apk add git; apk add ca-certificates

WORKDIR /usr/src/app
COPY . .

ENV GO111MODULE=on

RUN go mod tidy
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -a -ldflags="-s -w" -o bin/main cmd/server/main.go

### Executable Image
FROM alpine

COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
COPY --from=builder /etc/passwd /etc/passwd
COPY --from=builder /usr/src/app/bin/main ./main

EXPOSE 8080
ENTRYPOINT ["./main"]