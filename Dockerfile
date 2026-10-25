FROM golang:1.26 AS builder
WORKDIR /src
COPY go.mod .
COPY src ./src
RUN CGO_ENABLED=0 go build -o app ./src

FROM scratch
WORKDIR /html
COPY ./html /html
COPY --from=builder /src/app /app
ENTRYPOINT ["/app"]
EXPOSE 8080